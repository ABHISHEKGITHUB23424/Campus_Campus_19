import 'package:json_annotation/json_annotation.dart';

part 'class_model.g.dart';

@JsonSerializable()
class ClassModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'department')
  final String department;

  @JsonKey(name: 'year')
  final int year;

  @JsonKey(name: 'section')
  final String section;

  @JsonKey(name: 'subject_code')
  final String? subjectCode;

  @JsonKey(name: 'subject_name')
  final String? subjectName;

  @JsonKey(name: 'faculty_id')
  final int? facultyId;

  ClassModel({
    this.id,
    required this.department,
    required this.year,
    required this.section,
    this.subjectCode,
    this.subjectName,
    this.facultyId,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClassModelToJson(this);

  String get displayName => '$department - Year $year $section';

  ClassModel copyWith({
    int? id,
    String? department,
    int? year,
    String? section,
    String? subjectCode,
    String? subjectName,
    int? facultyId,
  }) {
    return ClassModel(
      id: id ?? this.id,
      department: department ?? this.department,
      year: year ?? this.year,
      section: section ?? this.section,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      facultyId: facultyId ?? this.facultyId,
    );
  }
}
