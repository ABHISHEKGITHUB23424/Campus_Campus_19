// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassModel _$ClassModelFromJson(Map<String, dynamic> json) => ClassModel(
  id: (json['id'] as num?)?.toInt(),
  department: json['department'] as String,
  year: (json['year'] as num).toInt(),
  section: json['section'] as String,
  subjectCode: json['subject_code'] as String?,
  subjectName: json['subject_name'] as String?,
  facultyId: (json['faculty_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$ClassModelToJson(ClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'department': instance.department,
      'year': instance.year,
      'section': instance.section,
      'subject_code': instance.subjectCode,
      'subject_name': instance.subjectName,
      'faculty_id': instance.facultyId,
    };
