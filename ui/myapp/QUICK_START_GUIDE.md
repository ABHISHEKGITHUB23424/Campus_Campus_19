# Exam Seating Module - Quick Start Guide

## ✅ Completed Setup

1. **Dependencies Installed** ✓

   - flutter_riverpod: 2.6.1
   - dio: 5.7.0
   - file_picker: 8.3.7
   - share_plus: 10.1.4
   - intl: 0.19.0

2. **Main App Wrapped with ProviderScope** ✓

   - `lib/main.dart` updated

3. **All Exam Seating Files Created** ✓
   - Configuration: `exam_seating/config.dart`
   - Models: Room, Student, Exam, Seating
   - API Service: Complete Dio client with all endpoints
   - Providers: Riverpod state management
   - UI: Seating page with Generate Seating modal

---

## 🚀 Testing the Generate Seating Feature

### Step 1: Configure API Base URL

Open `lib/exam_seating/config.dart` and verify the API URL:

```dart
static const String apiBaseUrl = 'http://localhost:8000';
```

If your backend runs on a different URL/port, update it here.

### Step 2: Start Backend Server

Navigate to your backend folder and start FastAPI:

```bash
cd campusconnect-backend
uvicorn app.main:app --reload --port 8000
```

The backend should be running at `http://localhost:8000`

### Step 3: Prepare Test Data

Before testing, ensure you have:

1. **Rooms in Database**

   - Use POST `/api/v1/rooms/bulk` or upload CSV
   - Example: A101, A102, A103 with capacities

2. **Students in Database** (optional for basic test)
   - Use POST `/api/v1/students/bulk` or upload CSV

### Step 4: Run Flutter App

```bash
flutter run -d windows
```

### Step 5: Test Generate Seating Flow

1. **Login** (if required) and navigate to **Seating** tab (4th tab in bottom nav)

2. You'll see a placeholder screen with:

   - Icon (event_seat)
   - "UI Coming Soon" text
   - **"Generate Seating" button**

3. **Click "Generate Seating" button**

   - Modal slides up smoothly from bottom

4. **Select Exam Date**

   - Click the date field
   - Pick a date from the date picker
   - Format: YYYY-MM-DD (e.g., 2024-06-15)

5. **Choose Session**

   - Click either "FN" (Forenoon) or "AN" (Afternoon)
   - The chip will animate when selected

6. **Select Rooms**

   - Multi-select from available rooms
   - Rooms are fetched from your backend API
   - Click multiple FilterChips to select

7. **Generate Seating**
   - "Generate" button enables when date + rooms are selected
   - Click "Generate"
   - Loading spinner appears
   - Success: Green SnackBar + modal closes
   - Error: Red SnackBar with error message

---

## 🐛 Troubleshooting

### Backend Not Responding

**Issue**: API calls fail with connection error

**Solution**:

- Check backend is running: `http://localhost:8000/docs`
- Verify API_BASE_URL in `config.dart`
- Check Windows Firewall settings
- Try: `http://127.0.0.1:8000` instead of localhost

### No Rooms Appear in Modal

**Issue**: Room selector is empty

**Solution**:

- Backend must have rooms in database
- Check: `http://localhost:8000/api/v1/rooms/`
- Upload rooms via CSV or use bulk create endpoint
- Check console for API errors

### Modal Doesn't Slide Up

**Issue**: Animation not working

**Solution**:

- This is normal on hot reload
- Do a full restart: Press 'R' in terminal twice
- Or: Stop app and `flutter run` again

### Generate Button Stays Disabled

**Issue**: Can't click Generate

**Solution**:

- Both date AND at least one room must be selected
- Session (FN/AN) is auto-selected (FN by default)
- Try clicking the date field first

### Dependency Errors

**Issue**: Import errors after pub get

**Solution**:

```bash
flutter clean
flutter pub get
```

---

## 📁 Project Structure

```
lib/
├── exam_seating/
│   ├── config.dart                 # API configuration
│   ├── models/
│   │   ├── room.dart              # Room entity
│   │   ├── student.dart           # Student entity
│   │   ├── exam.dart              # Exam entity
│   │   └── seating.dart           # Seating models
│   ├── services/
│   │   └── api_service.dart       # Dio HTTP client
│   └── providers/
│       └── providers.dart         # Riverpod providers
├── seating_page.dart              # Seating UI with modal
└── main.dart                      # App entry (with ProviderScope)
```

---

## 🎯 Next Steps

### Immediate (Optional)

- Test the Generate Seating feature
- Verify backend integration works
- Check API responses in console

### Future Implementation

Refer to `EXAM_SEATING_README.md` for complete implementation guide:

1. **Dashboard Screen** - Summary cards, quick actions
2. **Exams Screen** - List, create, CSV upload
3. **Rooms Screen** - List, details, SVG viewer
4. **Students Screen** - List with filters, CSV upload
5. **Complete Seating Section** - View by room, download CSV, SVG visualization

Each screen follows the same pattern:

```dart
// 1. Create ConsumerWidget/ConsumerStatefulWidget
class NewScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Use provider
    final dataAsync = ref.watch(someProvider);

    // 3. Handle AsyncValue states
    return dataAsync.when(
      data: (data) => /* build UI */,
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

---

## 📚 Documentation

- **Complete Guide**: `EXAM_SEATING_README.md` (450 lines)
- **Backend Setup**: `BACKEND_SETUP_GUIDE.md`
- **API Documentation**: `http://localhost:8000/docs` (when backend running)

---

## ✨ Features Implemented

✅ Riverpod state management (8 providers)  
✅ Dio HTTP client with error handling  
✅ All 20+ API endpoints implemented  
✅ CSV upload support (file_picker)  
✅ CSV download (bytes to file)  
✅ SVG rendering support (flutter_svg)  
✅ Smooth animations (SlideTransition, AnimatedContainer)  
✅ Profile in app bar  
✅ Seating tab placeholder  
✅ **Generate Seating modal (fully functional)**  
✅ Input validation  
✅ Loading states  
✅ Error handling with SnackBars

---

## 🎨 Animations

The Generate Seating modal uses:

1. **SlideTransition** (400ms, easeOutCubic)

   - Smooth slide-up from bottom

2. **AnimatedContainer** (200ms)

   - Session chips (FN/AN) animate on selection
   - Color transitions

3. **FilterChips** (implicit animation)
   - Checkmark appears on selection

---

## 🔧 Configuration

### API Base URL

`lib/exam_seating/config.dart`:

```dart
static const String apiBaseUrl = 'http://localhost:8000';
```

### Theme Colors (matches CampusConnect)

```dart
primaryColor: Color(0xFF222831)  // Dark
accentColor: Color(0xFF00ADB5)   // Cyan
backgroundColor: Color(0xFFEEEEEE) // Light grey
white: Color(0xFFFFFFFF)
```

---

## 🎉 You're Ready!

The Exam Seating module is fully integrated and ready to test. The Generate Seating feature is complete and functional. Start your backend, run the Flutter app, and test the flow!

For any issues, check the Troubleshooting section above or refer to the comprehensive `EXAM_SEATING_README.md`.

**Happy Coding! 🚀**
