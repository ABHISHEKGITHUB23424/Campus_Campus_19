// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
  id: (json['id'] as num?)?.toInt(),
  classId: (json['class_id'] as num).toInt(),
  date: json['date'] as String,
  session: json['session'] as String,
  facultyId: (json['faculty_id'] as num?)?.toInt(),
  totalStudents: (json['total_students'] as num?)?.toInt(),
  presentCount: (json['present_count'] as num?)?.toInt(),
  absentCount: (json['absent_count'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$AttendanceToJson(Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class_id': instance.classId,
      'date': instance.date,
      'session': instance.session,
      'faculty_id': instance.facultyId,
      'total_students': instance.totalStudents,
      'present_count': instance.presentCount,
      'absent_count': instance.absentCount,
      'created_at': instance.createdAt,
    };
