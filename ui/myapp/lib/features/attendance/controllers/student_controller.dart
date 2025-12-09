import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../data/student_api.dart';
import '../data/models/student.dart';

/// Provider for StudentApi
final studentApiProvider = Provider<StudentApi>((ref) {
  final apiClient = ApiClient.getInstance();
  return StudentApi(apiClient.dio);
});

/// State for students list
class StudentsState {
  final List<Student> students;
  final bool isLoading;
  final String? error;
  final int? selectedClassId;

  StudentsState({
    this.students = const [],
    this.isLoading = false,
    this.error,
    this.selectedClassId,
  });

  StudentsState copyWith({
    List<Student>? students,
    bool? isLoading,
    String? error,
    int? selectedClassId,
  }) {
    return StudentsState(
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedClassId: selectedClassId ?? this.selectedClassId,
    );
  }
}

/// Controller for managing students
class StudentController extends StateNotifier<StudentsState> {
  final StudentApi _studentApi;

  StudentController(this._studentApi) : super(StudentsState());

  /// Load students for a specific class
  Future<void> loadStudentsByClass(int classId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedClassId: classId,
    );

    try {
      final students = await _studentApi.getStudentsByClass(classId);
      state = state.copyWith(students: students, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load all students
  Future<void> loadAllStudents() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final students = await _studentApi.getAllStudents();
      state = state.copyWith(students: students, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add a new student
  Future<Student?> addStudent(Student student) async {
    try {
      final newStudent = await _studentApi.createStudent(student);

      // Add to local list
      state = state.copyWith(students: [...state.students, newStudent]);

      return newStudent;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Get a single student by ID
  Future<Student?> getStudent(int studentId) async {
    try {
      return await _studentApi.getStudent(studentId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Delete a student
  Future<bool> deleteStudent(int studentId) async {
    try {
      await _studentApi.deleteStudent(studentId);

      // Remove from local list
      state = state.copyWith(
        students: state.students.where((s) => s.id != studentId).toList(),
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Load students by class parameters
  Future<void> loadStudentsByClassParams({
    String? department,
    int? year,
    String? section,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final students = await _studentApi.getStudentsByClassParams(
        department: department,
        year: year,
        section: section,
      );
      state = state.copyWith(students: students, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Download sample CSV template
  Future<List<int>?> downloadSampleTemplate() async {
    try {
      return await _studentApi.downloadSampleTemplate();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Upload students from CSV
  Future<bool> uploadStudentsCSV(dynamic formData) async {
    try {
      await _studentApi.uploadStudents(formData);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = StudentsState();
  }
}

/// Provider for StudentController
final studentControllerProvider =
    StateNotifierProvider<StudentController, StudentsState>((ref) {
      final studentApi = ref.watch(studentApiProvider);
      return StudentController(studentApi);
    });

/// Provider for getting students by class ID
final studentsByClassProvider = FutureProvider.family<List<Student>, int>((
  ref,
  classId,
) async {
  final studentApi = ref.watch(studentApiProvider);
  return studentApi.getStudentsByClassId(classId);
});

/// Provider for getting all students
final allStudentsProvider = FutureProvider<List<Student>>((ref) async {
  final studentApi = ref.watch(studentApiProvider);
  return studentApi.getAllStudents();
});

/// Provider for getting a single student by ID
final studentByIdProvider = FutureProvider.family<Student, int>((
  ref,
  studentId,
) async {
  final studentApi = ref.watch(studentApiProvider);
  return studentApi.getStudent(studentId);
});

/// Provider for downloading sample CSV template
final sampleTemplateProvider = FutureProvider<List<int>>((ref) async {
  final studentApi = ref.watch(studentApiProvider);
  return studentApi.downloadSampleTemplate();
});
