/// Exam model for exam seating
class Exam {
  final String subjectCode;
  final String subjectName;
  final String examDate; // YYYY-MM-DD format
  final String session; // "FN" or "AN"
  final List<DepartmentBatch> departmentBatches;

  Exam({
    required this.subjectCode,
    required this.subjectName,
    required this.examDate,
    required this.session,
    required this.departmentBatches,
  });

  /// Create Exam from JSON
  /// Example: {
  ///   "subject_code": "CS101",
  ///   "subject_name": "Data Structures",
  ///   "exam_date": "2025-12-15",
  ///   "session": "FN",
  ///   "department_batches": [{"department_code": "CSE", "batch_year": 2023}]
  /// }
  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      subjectCode: json['subject_code'] as String,
      subjectName: json['subject_name'] as String,
      examDate: json['exam_date'] as String,
      session: json['session'] as String,
      departmentBatches: (json['department_batches'] as List)
          .map((e) => DepartmentBatch.fromJson(e))
          .toList(),
    );
  }

  /// Convert Exam to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'exam_date': examDate,
      'session': session,
      'department_batches': departmentBatches.map((e) => e.toJson()).toList(),
    };
  }

  String get departmentsPreview {
    if (departmentBatches.isEmpty) return 'No departments';
    return departmentBatches
        .map((db) => '${db.departmentCode}:${db.batchYear}')
        .join(', ');
  }

  @override
  String toString() => 'Exam($subjectCode, $examDate $session)';
}

/// Department-Batch pair for exams
class DepartmentBatch {
  final String departmentCode;
  final int batchYear;

  DepartmentBatch({required this.departmentCode, required this.batchYear});

  factory DepartmentBatch.fromJson(Map<String, dynamic> json) {
    return DepartmentBatch(
      departmentCode: json['department_code'] as String,
      batchYear: json['batch_year'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'department_code': departmentCode, 'batch_year': batchYear};
  }

  @override
  String toString() => '$departmentCode:$batchYear';
}
