// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    AttendanceRecord(
      id: (json['id'] as num?)?.toInt(),
      attendanceId: (json['attendance_id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
      studentName: json['student_name'] as String?,
      registerNo: json['register_no'] as String?,
    );

Map<String, dynamic> _$AttendanceRecordToJson(AttendanceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attendance_id': instance.attendanceId,
      'student_id': instance.studentId,
      'status': instance.status,
      'remarks': instance.remarks,
      'student_name': instance.studentName,
      'register_no': instance.registerNo,
    };
