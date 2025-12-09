import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart';

@JsonSerializable()
class Student {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'reg_no')
  final String? registerNo;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'department')
  final String department;

  @JsonKey(name: 'year')
  final int year;

  @JsonKey(name: 'section')
  final String section;

  @JsonKey(name: 'roll_no')
  final String? rollNo;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'class_id')
  final int? classId;

  Student({
    this.id,
    this.registerNo,
    required this.name,
    required this.department,
    required this.year,
    required this.section,
    this.rollNo,
    this.email,
    this.phone,
    this.classId,
  });

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);

  Student copyWith({
    int? id,
    String? registerNo,
    String? name,
    String? department,
    int? year,
    String? section,
    String? rollNo,
    String? email,
    String? phone,
    int? classId,
  }) {
    return Student(
      id: id ?? this.id,
      registerNo: registerNo ?? this.registerNo,
      name: name ?? this.name,
      department: department ?? this.department,
      year: year ?? this.year,
      section: section ?? this.section,
      rollNo: rollNo ?? this.rollNo,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      classId: classId ?? this.classId,
    );
  }
}
