# Exam Seating Module - Integration Guide

## Overview

The Exam Seating module has been integrated into the CampusConnect Flutter app as a **section** within the existing application. This module allows professors to manage exam seating arrangements, rooms, students, and exams through a FastAPI backend.

## Features Implemented

### ✅ Core Features

- **Generate Seating Modal**: Global modal accessible from the Seating tab
- **Smooth Animations**: Apple-like animations for all interactions
- **Riverpod State Management**: Efficient state management across the app
- **Dio HTTP Client**: Robust API communication with error handling
- **Profile Button**: Moved to top-right corner of every page (app bar action)
- **Seating Tab**: New tab in bottom navigation (placeholder for now)

### 🎯 Seating Page Features

- Empty placeholder screen with "UI Coming Soon" message
- "Generate Seating" button to open the global modal
- Smooth slide-up animation for the modal
- Date picker for exam date selection
- Session selector (FN/AN) with animated chips
- Room multi-selector with filter chips
- Generate button with loading state and validation

### 📦 File Structure

```
lib/
├── exam_seating/
│   ├── config.dart                    # API configuration
│   ├── models/
│   │   ├── room.dart                 # Room model
│   │   ├── student.dart              # Student model
│   │   ├── exam.dart                 # Exam model & DepartmentBatch
│   │   └── seating.dart              # Seating models & responses
│   ├── services/
│   │   └── api_service.dart          # Dio-based API service
│   └── providers/
│       └── providers.dart            # Riverpod providers
├── seating_page.dart                  # Updated seating section
└── prof_shell.dart                    # Main navigation shell
```

## Setup Instructions

### 1. Install Dependencies

The following packages have been added to `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.6.1 # State management
  dio: ^5.7.0 # HTTP client
  file_picker: ^8.1.6 # File upload
  share_plus: ^10.1.2 # File sharing
  intl: ^0.19.0 # Date formatting
  flutter_svg: ^2.0.10+1 # SVG rendering (already installed)
```

Run to install:

```bash
cd myapp
flutter pub get
```

### 2. Configure API Base URL

Edit `lib/exam_seating/config.dart` and set your backend URL:

```dart
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:8000';  // Change this!
  // ...
}
```

### 3. Wrap App with ProviderScope

The main.dart needs to be wrapped with `ProviderScope` for Riverpod:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(  // Add this wrapper
      child: MyApp(),
    ),
  );
}
```

### 4. Run the App

```bash
flutter run -d windows
```

## Navigation Structure

### Bottom Navigation (4 tabs):

1. **Home** - Dashboard and quick actions
2. **Attendance** - Attendance management
3. **Occupancy** - Lab/room occupancy
4. **Seating** - Exam seating section (new!)

### Top App Bar Actions (on every page):

- **Profile** icon (right corner) - Opens profile page
- **Settings** icon - App settings (future)

## API Integration

### API Service (`api_service.dart`)

All backend endpoints are implemented:

#### Health Check

```dart
api.checkHealth()  // GET /health
```

#### Rooms

```dart
api.getRooms()                    // GET /api/v1/rooms/
api.createRoomsBulk(rooms)        // POST /api/v1/rooms/bulk
api.uploadRoomsCsv(file)          // POST /api/v1/rooms/upload-csv
```

#### Students

```dart
api.getStudents(departmentCode: 'CSE', batchYear: 2023)
api.createStudentsBulk(students)
api.uploadStudentsCsv(file)
```

#### Exams

```dart
api.getExams()
api.createExam(exam)
api.uploadExamsCsv(file)
```

#### Seating

```dart
api.getAvailableRooms(examDate: '2025-12-15', session: 'FN')
api.generateSeating(request)
api.getSeatingByRoom(examDate, session, roomCode)
api.downloadSeatingCsvByRoom(...)
api.downloadSeatingCsvAll(...)
api.getSvgByRoom(...)  // Returns SVG bytes
```

### Riverpod Providers (`providers.dart`)

State management providers:

```dart
// Fetch data
ref.watch(roomsProvider)           // List<Room>
ref.watch(studentsProvider)        // List<Student>
ref.watch(examsProvider)           // List<Exam>
ref.watch(dashboardSummaryProvider) // Summary stats

// Query with parameters
ref.watch(studentsProvider(StudentFilters(
  departmentCode: 'CSE',
  batchYear: 2023,
)))

ref.watch(availableRoomsProvider(SeatingQuery(
  examDate: '2025-12-15',
  session: 'FN',
)))
```

## Models

### Room

```dart
Room(
  code: 'A101',
  capacity: 30,
  rows: 5,
  columns: 6,
)
```

### Student

```dart
Student(
  registerNo: '21CS001',
  name: 'John Doe',
  departmentCode: 'CSE',
  batchYear: 2021,
)
```

### Exam

```dart
Exam(
  subjectCode: 'CS101',
  subjectName: 'Data Structures',
  examDate: '2025-12-15',
  session: 'FN',
  departmentBatches: [
    DepartmentBatch(departmentCode: 'CSE', batchYear: 2023),
  ],
)
```

### Seating

```dart
SeatingEntry(
  registerNo: '21CS001',
  name: 'John Doe',
  departmentCode: 'CSE',
  batchYear: 2021,
  roomCode: 'A101',
  rowNum: 1,
  columnNum: 1,
  seatNum: 1,
)
```

## Testing the Generate Seating Feature

1. **Navigate to Seating Tab** (bottom navigation, 4th tab)
2. **Click "Generate Seating" button** on the placeholder screen
3. **Modal opens** with smooth slide-up animation
4. **Select exam date** using the date picker
5. **Choose session** (FN or AN) - animated chip selection
6. **Select rooms** - tap filter chips to select multiple rooms
7. **Click "Generate Seating Arrangement"**
8. **Success/Error message** displays via SnackBar
9. **Modal closes** automatically on success

## Animations Used

### Implicit Animations

- `AnimatedContainer` for session chips
- FilterChip selection states

### Explicit Animations

- Modal slide-up with `SlideTransition`
- `CurvedAnimation` with `Curves.easeOutCubic`
- 400ms smooth modal entrance

### Spring Physics (Future)

- Will be added to list items, cards, and page transitions
- Using `SpringSimulation` and `AnimationController`

## Error Handling

All API calls include:

- ✅ Try-catch blocks
- ✅ Server error message extraction (from `detail` field)
- ✅ User-friendly SnackBar notifications
- ✅ Loading states with spinners
- ✅ Disabled buttons during loading

## Next Steps

### Recommended Implementation Order:

1. **Dashboard Screen** (`dashboard_screen.dart`)

   - Summary cards (students, rooms, exams)
   - Quick actions (Upload CSV, Create Exam, Generate Seating)
   - Recent activity list

2. **Exams Screen** (`exams_screen.dart`)

   - List all exams with filters
   - Create exam form
   - CSV upload

3. **Rooms Screen** (`rooms_screen.dart`)

   - List all rooms
   - Room details with SVG viewer
   - CSV upload

4. **Students Screen** (`students_screen.dart`)

   - List with filters (department, batch)
   - Student details
   - CSV upload

5. **Complete Seating Section**
   - View seating by room
   - Download CSV files
   - SVG visualization
   - Available rooms checker

### CSV Upload Pattern

Example for rooms:

```dart
// Pick file
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['csv'],
);

if (result != null) {
  final file = result.files.first;

  // Show preview (first 5 rows)
  // ...

  // Upload
  final response = await api.uploadRoomsCsv(file);

  // Show success
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(response['message'])),
  );

  // Refresh list
  ref.refresh(roomsProvider);
}
```

### SVG Rendering

```dart
final svgBytes = await api.getSvgByRoom(
  examDate: '2025-12-15',
  session: 'FN',
  roomCode: 'A101',
);

// Display using flutter_svg
SvgPicture.memory(
  Uint8List.fromList(svgBytes),
  width: 400,
  height: 600,
)
```

## Theme & Styling

### Colors (matching CampusConnect theme)

- **Primary**: `#00ADB5` (Cyan accent)
- **Dark**: `#222831` (Text, headings)
- **Light**: `#EEEEEE` (Backgrounds)
- **Neutral**: `#393E46` (Secondary text)
- **White**: `#FFFFFF` (Cards, app bar)

### Consistent UI Elements

- Border radius: `12px` (rounded corners)
- Card elevation: `0-2` (subtle shadows)
- Padding: `16px` (standard spacing)
- Font: Google Fonts Inter (already used in app)

## Backend Setup (Required)

Make sure your FastAPI backend is running:

```bash
# Assuming backend is at C:\Users\shree\Desktop\GOJO\campusconnect-backend
cd C:\Users\shree\Desktop\GOJO\campusconnect-backend
venv\Scripts\activate
uvicorn app.main:app --reload --port 8000
```

Backend should be accessible at: `http://localhost:8000`

API docs available at: `http://localhost:8000/docs`

## Troubleshooting

### API Connection Issues

- ✅ Check `AppConfig.apiBaseUrl` matches your backend
- ✅ Ensure backend is running on correct port
- ✅ Check Windows Firewall isn't blocking localhost

### State Not Updating

- ✅ Use `ref.refresh(provider)` to force reload
- ✅ Ensure `ProviderScope` wraps the app
- ✅ Check console for provider errors

### Modal Not Showing

- ✅ Ensure context is valid
- ✅ Check for overlay conflicts
- ✅ Verify animation controller is initialized

## Contact & Support

For issues or questions about the Exam Seating module:

- Check API documentation at `/docs`
- Review model classes for expected data formats
- Use SnackBar error messages for debugging
- Check browser/app console for detailed errors

---

**Status**: ✅ Seating tab integrated with placeholder + working Generate Seating modal  
**Next**: Implement remaining screens (Dashboard, Exams, Rooms, Students)  
**Version**: 1.0.0
