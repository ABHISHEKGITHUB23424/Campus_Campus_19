# Quick Start Guide: Exam Seating Management

## Prerequisites

1. Backend running at `http://localhost:8000`
2. Flutter app running (web/mobile)

## Step-by-Step Guide

### Step 1: Add Rooms 🏢

1. Open the app and tap **"Exam Seating"** on the home page
2. Tap the **admin icon (⚙️)** in the top-right corner
3. You're now in the **Management Dashboard** - stay on the **Rooms** tab
4. Click **"Sample"** button to download a template CSV
5. Edit the CSV with your room data:
   ```csv
   code,capacity,rows,columns
   A101,30,5,6
   A102,40,6,7
   B201,35,5,7
   ```
6. Click **"Choose CSV"** and select your file
7. Wait for the upload to complete
8. See your rooms appear in the list below

### Step 2: Add Students 👨‍🎓

1. Switch to the **Students** tab
2. Click **"Sample"** to download template
3. Fill in student data:
   ```csv
   register_no,name,department_code,department_name,batch_year
   2023001,John Doe,CSE,Computer Science,2023
   2023002,Jane Smith,CSE,Computer Science,2023
   2022101,Bob Wilson,IT,Information Technology,2022
   ```
4. Upload the CSV
5. Use the filters to view by department or batch:
   - **Department dropdown**: Filter by CSE, IT, ECE, etc.
   - **Batch Year dropdown**: Filter by 2021, 2022, 2023, 2024

### Step 3: Schedule Exams 📅

1. Switch to the **Exams** tab
2. Download the sample CSV
3. Create your exam schedule:
   ```csv
   subject_code,subject_name,exam_date,session,department_batches
   CS101,Data Structures,2025-12-15,FN,"CSE:2023,IT:2023"
   MA101,Mathematics,2025-12-16,AN,"CSE:2023,ECE:2023"
   ```
   **Note**:
   - Date format: `YYYY-MM-DD`
   - Session: `FN` (Forenoon) or `AN` (Afternoon)
   - Departments: `"DEPT:YEAR,DEPT:YEAR"` format
4. Upload the CSV
5. View all scheduled exams in the list

### Step 4: Generate Seating 🎯

1. Go back to the **Exam Seating** page (tap back button)
2. Tap **"Generate Seating"** button at the center
3. In the modal:
   - **Select Date**: Pick the exam date
   - **Choose Session**: FN or AN
   - **Room Selection**:
     - **Auto-Select ON** (recommended): System picks rooms automatically
     - **Auto-Select OFF**: Manually choose rooms from the list
4. Tap **"Generate Seating Arrangement"**
5. Success! You'll see a confirmation with the number of students allocated

### Step 5: View & Download Results 📊

1. Tap the **admin icon (⚙️)** to return to Management Dashboard
2. Go to the **Seating Results** tab
3. **Select Date**: Pick the exam date
4. **Choose Session**: FN or AN
5. **Optional**: Select a specific room to preview

#### Download Options:

- **Download All Rooms CSV**: Complete seating for all rooms in one file
- **Download [Room] CSV**: Specific room's seating arrangement
- **View SVG Layout**: Visual diagram of the seating (opens in new tab)

## Tips & Tricks 💡

### CSV Upload Best Practices

- Always download the sample CSV first
- Keep column names exactly as shown
- Use UTF-8 encoding for special characters
- Rows and columns are optional for rooms (system works without grid layout)

### Room Selection Strategy

- **Use Auto-Select when**:
  - You have many rooms
  - You want optimal allocation
  - Room doesn't matter
- **Use Manual Selection when**:
  - Specific rooms needed (e.g., near faculty offices)
  - Testing with limited rooms
  - Special requirements (accessible rooms, etc.)

### Department-Batch Filtering

- Filter students by department to verify department data
- Filter by batch to check batch enrollment
- Combine both filters for precise subsets

### Download Workflow

1. Generate seating first
2. Download all rooms CSV for complete records
3. Download individual room CSVs for room-specific distribution
4. Print SVG layouts to post outside rooms

## Common Scenarios

### Scenario 1: Mid-Semester Exam

```
1. Upload rooms (one-time setup)
2. Upload students for current semester
3. Schedule 5-6 exams via CSV
4. Generate seating for each exam date
5. Download and distribute PDFs
```

### Scenario 2: Final Exams

```
1. Upload updated student list (if changed)
2. Upload 15-20 exams via CSV
3. Generate seating day-by-day or all at once
4. Download all rooms CSV for each day
5. Print SVG layouts for display boards
```

### Scenario 3: Department-Specific Exam

```
1. Filter students by department before scheduling
2. Schedule exam with only that department in CSV
3. Generate seating (auto-select will use minimal rooms)
4. Download room-specific CSVs
```

## Troubleshooting

### "Cannot connect to backend" Error

- Ensure backend is running: `uvicorn app.main:app --reload`
- Check backend URL in browser: http://localhost:8000
- Verify CORS is enabled in backend

### CSV Upload Fails

- Check CSV format matches sample exactly
- Ensure no extra columns or wrong column names
- Verify data types (capacity = number, batch_year = number)
- Check for special characters or encoding issues

### No Rooms Available for Generation

- Upload rooms first via Rooms tab
- Verify rooms appear in the room selector
- Check if rooms are already occupied for that date/session

### Missing Students in Seating

- Verify students uploaded successfully (check Students tab)
- Ensure exam's department-batch matches student records
- Check exam date and session are correct

## Data Format Reference

### Rooms CSV

```csv
code,capacity,rows,columns
A101,30,5,6          ← Room with grid layout
B201,40,,            ← Room without layout (rows/columns empty)
```

### Students CSV

```csv
register_no,name,department_code,department_name,batch_year
2023001,John,CSE,Computer Science,2023
2023002,Jane,CSE,,2023              ← Department name optional
2022101,Bob,IT,Information Tech,     ← Batch year optional
```

### Exams CSV

```csv
subject_code,subject_name,exam_date,session,department_batches
CS101,Data Structures,2025-12-15,FN,"CSE:2023,IT:2023"
MA101,Math,2025-12-16,AN,CSE:2023   ← Single department (no quotes needed)
```

## Next Steps

Once you're comfortable with the basics:

1. **Experiment with filters** - Try different department/batch combinations
2. **Test auto-select** - Compare with manual selection
3. **Explore SVG layouts** - See the visual representation
4. **Bulk operations** - Upload large CSV files to test scalability

For advanced features and API details, see `EXAM_SEATING_INTEGRATION_COMPLETE.md`.

Happy exam scheduling! 🎓
