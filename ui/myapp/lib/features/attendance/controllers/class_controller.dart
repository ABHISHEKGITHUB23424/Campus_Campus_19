import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../data/class_api.dart';
import '../data/models/class_model.dart';

/// Provider for ClassApi
final classApiProvider = Provider<ClassApi>((ref) {
  final apiClient = ApiClient.getInstance();
  return ClassApi(apiClient.dio);
});

/// State for class selection and management
class ClassState {
  final List<ClassModel> classes;
  final bool isLoading;
  final String? error;
  final ClassModel? selectedClass;

  // Filters
  final String? selectedDepartment;
  final int? selectedYear;
  final String? selectedSection;

  ClassState({
    this.classes = const [],
    this.isLoading = false,
    this.error,
    this.selectedClass,
    this.selectedDepartment,
    this.selectedYear,
    this.selectedSection,
  });

  ClassState copyWith({
    List<ClassModel>? classes,
    bool? isLoading,
    String? error,
    ClassModel? selectedClass,
    String? selectedDepartment,
    int? selectedYear,
    String? selectedSection,
  }) {
    return ClassState(
      classes: classes ?? this.classes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedSection: selectedSection ?? this.selectedSection,
    );
  }

  /// Get unique departments from classes
  List<String> get departments {
    final Set<String> depts = {};
    for (var classModel in classes) {
      depts.add(classModel.department);
    }
    return depts.toList()..sort();
  }

  /// Get unique years from classes
  List<int> get years {
    final Set<int> yrs = {};
    for (var classModel in classes) {
      yrs.add(classModel.year);
    }
    return yrs.toList()..sort();
  }

  /// Get unique sections from classes
  List<String> get sections {
    final Set<String> secs = {};
    for (var classModel in classes) {
      secs.add(classModel.section);
    }
    return secs.toList()..sort();
  }

  /// Check if a class can be found with current filters
  bool get canFindClass {
    return selectedDepartment != null &&
        selectedYear != null &&
        selectedSection != null;
  }
}

/// Controller for managing classes
class ClassController extends StateNotifier<ClassState> {
  final ClassApi _classApi;

  ClassController(this._classApi) : super(ClassState());

  /// Load all classes
  Future<void> loadClasses() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final classes = await _classApi.getClasses();
      state = state.copyWith(classes: classes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new class
  Future<ClassModel?> createClass(ClassModel classModel) async {
    try {
      final newClass = await _classApi.createClass(classModel);

      // Add to local list
      state = state.copyWith(classes: [...state.classes, newClass]);

      return newClass;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Get a single class by ID
  Future<ClassModel?> getClass(int classId) async {
    try {
      return await _classApi.getClass(classId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Delete a class
  Future<bool> deleteClass(int classId) async {
    try {
      await _classApi.deleteClass(classId);

      // Remove from local list
      state = state.copyWith(
        classes: state.classes.where((c) => c.id != classId).toList(),
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Search class by details
  Future<ClassModel?> getClassByDetails({
    required String department,
    required int year,
    required String section,
  }) async {
    try {
      return await _classApi.getClassByDetails(
        department: department,
        year: year,
        section: section,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Map students to a class
  Future<bool> mapStudentsToClass({
    required int classId,
    required List<int> studentIds,
  }) async {
    try {
      await _classApi.mapStudentsToClass(
        classId: classId,
        studentIds: studentIds,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Set selected department filter
  void setDepartment(String? department) {
    state = state.copyWith(selectedDepartment: department);
    _updateSelectedClass();
  }

  /// Set selected year filter
  void setYear(int? year) {
    state = state.copyWith(selectedYear: year);
    _updateSelectedClass();
  }

  /// Set selected section filter
  void setSection(String? section) {
    state = state.copyWith(selectedSection: section);
    _updateSelectedClass();
  }

  /// Update selected class based on filters
  void _updateSelectedClass() {
    if (state.canFindClass) {
      final matchingClass = state.classes.firstWhere(
        (c) =>
            c.department == state.selectedDepartment &&
            c.year == state.selectedYear &&
            c.section == state.selectedSection,
        orElse: () => ClassModel(
          department: state.selectedDepartment!,
          year: state.selectedYear!,
          section: state.selectedSection!,
        ),
      );
      state = state.copyWith(selectedClass: matchingClass);
    } else {
      state = state.copyWith(selectedClass: null);
    }
  }

  /// Manually set selected class
  void selectClass(ClassModel classModel) {
    state = state.copyWith(
      selectedClass: classModel,
      selectedDepartment: classModel.department,
      selectedYear: classModel.year,
      selectedSection: classModel.section,
    );
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(
      selectedClass: null,
      selectedDepartment: null,
      selectedYear: null,
      selectedSection: null,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = ClassState();
  }
}

/// Provider for ClassController
final classControllerProvider =
    StateNotifierProvider<ClassController, ClassState>((ref) {
      final classApi = ref.watch(classApiProvider);
      return ClassController(classApi);
    });

/// Provider for getting all classes
final classesProvider = FutureProvider<List<ClassModel>>((ref) async {
  final classApi = ref.watch(classApiProvider);
  return classApi.getAllClasses();
});

/// Provider for getting a single class by ID
final classByIdProvider = FutureProvider.family<ClassModel, int>((
  ref,
  classId,
) async {
  final classApi = ref.watch(classApiProvider);
  return classApi.getClass(classId);
});

/// Provider for getting class by details
final classByDetailsProvider =
    FutureProvider.family<ClassModel, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final classApi = ref.watch(classApiProvider);
      return classApi.getClassByDetails(
        department: params['department'] as String,
        year: params['year'] as int,
        section: params['section'] as String,
      );
    });
