/// Student model for exam seating
class Student {
  final String registerNo;
  final String name;
  final String? departmentCode;
  final String? departmentName;
  final int? batchYear;

  Student({
    required this.registerNo,
    required this.name,
    this.departmentCode,
    this.departmentName,
    this.batchYear,
  });

  /// Create Student from JSON
  /// Example: {"register_no": "21CS001", "name": "John Doe", "department_code": "CSE", "department_name": "Computer Science", "batch_year": 2021}
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      registerNo: json['register_no'] as String,
      name: json['name'] as String,
      departmentCode: json['department_code'] as String?,
      departmentName: json['department_name'] as String?,
      batchYear: json['batch_year'] as int?,
    );
  }

  /// Convert Student to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'register_no': registerNo,
      'name': name,
      'department_code': departmentCode,
      'department_name': departmentName,
      'batch_year': batchYear,
    };
  }

  @override
  String toString() =>
      'Student($registerNo, $name, $departmentCode $batchYear)';
}
