class ManagementStats {
  final int totalStudents;
  final int totalDepartments;
  final int totalBatches;
  final Map<String, int> studentsByDepartment;
  final Map<String, int> studentsByBatch;

  ManagementStats({
    required this.totalStudents,
    required this.totalDepartments,
    required this.totalBatches,
    required this.studentsByDepartment,
    required this.studentsByBatch,
  });

  factory ManagementStats.fromJson(Map<String, dynamic> json) {
    return ManagementStats(
      totalStudents: json['total_students'] as int,
      totalDepartments: json['total_departments'] as int,
      totalBatches: json['total_batches'] as int,
      studentsByDepartment: Map<String, int>.from(
        json['students_by_department'] ?? {},
      ),
      studentsByBatch: Map<String, int>.from(json['students_by_batch'] ?? {}),
    );
  }
}
