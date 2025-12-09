class Department {
  final int id;
  final String code;
  final String name;

  Department({required this.id, required this.code, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }
}

class DepartmentCreate {
  final String code;
  final String name;

  DepartmentCreate({required this.code, required this.name});

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name};
  }
}
