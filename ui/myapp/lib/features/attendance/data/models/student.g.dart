// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
  id: (json['id'] as num?)?.toInt(),
  registerNo: json['reg_no'] as String?,
  name: json['name'] as String,
  department: json['department'] as String,
  year: (json['year'] as num).toInt(),
  section: json['section'] as String,
  rollNo: json['roll_no'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  classId: (json['class_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
  'id': instance.id,
  'reg_no': instance.registerNo,
  'name': instance.name,
  'department': instance.department,
  'year': instance.year,
  'section': instance.section,
  'roll_no': instance.rollNo,
  'email': instance.email,
  'phone': instance.phone,
  'class_id': instance.classId,
};
