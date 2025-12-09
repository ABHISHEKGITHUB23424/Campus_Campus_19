from fastapi import FastAPI, UploadFile, File, Request
from fastapi.middleware.cors import CORSMiddleware
import cv2
import numpy as np
from ultralytics import YOLO
from deep_sort_realtime.deepsort_tracker import DeepSort
import threading
import os
from pathlib import Path
from threading import Lock

# --------------------------
# GLOBAL VARIABLES
# --------------------------
# Dictionary to track counts for each lab
lab_counts = {
    "Python LAB": 0,
    "NETWORK LAB": 0,
    "LANGUAGE LAB": 0,
    "MOCK LAB": 0,
    "ILP LAB": 0,
}
current_lab = None
processing = False
VIDEO_PATH = None
_state_lock = Lock()

# --------------------------
# SETTINGS
# --------------------------
MIN_BOX_AREA = 900
MIN_ASPECT_RATIO = 0.3
MAX_ASPECT_RATIO = 3.5
TRACK_CONSECUTIVE_FRAMES_TO_COUNT = 12
TRACK_MAX_AGE = 16
MODEL_PATH = r"models/yolov8n.pt"

if not Path(MODEL_PATH).exists():
    if Path("yolov8n.pt").exists():
        MODEL_PATH = "yolov8n.pt"
    elif Path("../yolov8n.pt").exists():
        MODEL_PATH = "../yolov8n.pt"
    else:
        print("❌ YOLO MODEL NOT FOUND")

# --------------------------
# FastAPI setup
# --------------------------
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --------------------------
# Load YOLO model + ✅ WARM-UP
# --------------------------
print("Loading YOLO model...")
try:
    yolo = YOLO(MODEL_PATH)
    print("✅ YOLO LOADED")

    print("🔥 Warming up model...")
    dummy_frame = (255 * np.ones((640, 640, 3))).astype("uint8")
    yolo(dummy_frame, conf=0.4)
    print("✅ YOLO WARM-UP COMPLETE")

except Exception as e:
    print("❌ YOLO LOAD FAILED:", e)
    yolo = None

# --------------------------
# Init DeepSORT
# --------------------------
tracker = DeepSort(
    max_age=TRACK_MAX_AGE,
    n_init=5,
    nn_budget=100,
    max_iou_distance=0.7
)

# --------------------------
# HELPER FUNCTION
# --------------------------
def convert_yolo_predictions(results):
    detections = []

    for r in results:
        for box in r.boxes:
            cls = int(box.cls[0])
            conf = float(box.conf[0])

            if cls != 0:
                continue

            x1, y1, x2, y2 = box.xyxy[0].tolist()
            area = max(0, x2 - x1) * max(0, y2 - y1)

            if area < MIN_BOX_AREA:
                continue

            w = max(1, x2 - x1)
            aspect = (y2 - y1) / w

            if aspect < MIN_ASPECT_RATIO or aspect > MAX_ASPECT_RATIO:
                continue

            detections.append(([x1, y1, x2, y2], conf, "person"))

    return detections

# --------------------------
# VIDEO PROCESSING
# --------------------------
def process_video():
    global current_count, processing, VIDEO_PATH

    cap = cv2.VideoCapture(VIDEO_PATH)

    if not cap.isOpened():
        print("❌ VIDEO NOT OPENED")
        with _state_lock:
            processing = False
        return

    confirmed_ids = set()
    consecutive_seen = {}
    last_seen_frame_idx = {}
    frame_idx = 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame_idx += 1

        # ✅ SKIP FIRST 5 FRAMES (FIXES GHOST DETECTIONS)
        if frame_idx < 5:
            continue

        yolo_results = yolo(frame, conf=0.5)
        detections = convert_yolo_predictions(yolo_results)

        tracks = tracker.update_tracks(detections, frame=frame)
        seen_this_frame = set()

        for track in tracks:
            if not track.is_confirmed():
                continue

            tid = track.track_id
            seen_this_frame.add(tid)

            x1, y1, x2, y2 = map(int, track.to_ltrb())

            if last_seen_frame_idx.get(tid, 0) == frame_idx - 1:
                consecutive_seen[tid] = consecutive_seen.get(tid, 0) + 1
            else:
                consecutive_seen[tid] = 1

            last_seen_frame_idx[tid] = frame_idx

            if consecutive_seen[tid] >= TRACK_CONSECUTIVE_FRAMES_TO_COUNT:
                confirmed_ids.add(tid)

            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
            cv2.putText(frame, f"ID {tid}", (x1, y1 - 10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)

        for tid in list(consecutive_seen.keys()):
            if tid not in seen_this_frame:
                last_idx = last_seen_frame_idx.get(tid, 0)
                if (frame_idx - last_idx) > TRACK_MAX_AGE:
                    consecutive_seen.pop(tid, None)
                    last_seen_frame_idx.pop(tid, None)
                else:
                    consecutive_seen[tid] = 0

        current_count = len(confirmed_ids)
        
        with _state_lock:
            if current_lab:
                lab_counts[current_lab] = current_count
                if frame_idx % 30 == 0:  # Print every 30 frames
                    print(f"🎬 [{current_lab}] Frame {frame_idx}: {current_count} students detected")

        cv2.putText(frame,
                    f"STUDENTS: {current_count}",
                    (30, 40),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1,
                    (0, 0, 255),
                    3)

        cv2.imshow("LIVE STUDENT DETECTION", frame)

        if cv2.waitKey(1) & 0xFF == 27:
            break

    cap.release()
    cv2.destroyAllWindows()

    with _state_lock:
        processing = False

    if current_lab:
        print(f"✅ FINAL COUNT for {current_lab}:", lab_counts[current_lab])
    else:
        print("✅ Processing completed")


# --------------------------
# API ENDPOINTS
# --------------------------
@app.post("/process_video_url")
async def start_processing_json(request: Request):
    global VIDEO_PATH, processing, current_lab

    if processing:
        return {"status": "already_running"}

    data = await request.json()
    VIDEO_PATH = data.get("url")
    current_lab = data.get("lab_name", "Python LAB")  # Default to Python LAB

    if not VIDEO_PATH:
        return {"status": "error", "message": "No video URL provided"}

    with _state_lock:
        processing = True

    threading.Thread(target=process_video, daemon=True).start()
    return {"status": "processing_started", "lab_name": current_lab}


@app.post("/process_video_file")
async def process_video_file(request: Request):
    global VIDEO_PATH, processing, current_lab

    if processing:
        return {"status": "already_running"}

    form = await request.form()
    file: UploadFile = form.get("file")
    lab_name = form.get("lab_name", "Python LAB")
    
    if not file:
        return {"status": "error", "message": "No file provided"}

    os.makedirs("uploads", exist_ok=True)
    tmp_path = os.path.join("uploads", file.filename)

    with open(tmp_path, "wb") as f:
        f.write(await file.read())

    VIDEO_PATH = tmp_path
    current_lab = lab_name  # Set the current lab
    
    print(f"🎬 Processing video for lab: {current_lab}")

    with _state_lock:
        processing = True

    threading.Thread(target=process_video, daemon=True).start()
    return {"status": "processing_started", "lab_name": lab_name}


@app.get("/count")
def get_current_count():
    with _state_lock:
        return {
            "labs": lab_counts,
            "current_lab": current_lab,
            "processing": processing,
            "processing_lab": current_lab if processing else ""
        }


# --------------------------
# SERVER START
# --------------------------
if __name__ == "__main__":
    import uvicorn
    print("🚀 Server running at http://0.0.0.0:8000")
    uvicorn.run("main:app", host="0.0.0.0", port=8000)

