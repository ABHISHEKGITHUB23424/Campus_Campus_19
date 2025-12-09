import 'package:json_annotation/json_annotation.dart';

part 'attendance_record.g.dart';

@JsonSerializable()
class AttendanceRecord {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'attendance_id')
  final int attendanceId;

  @JsonKey(name: 'student_id')
  final int studentId;

  @JsonKey(name: 'status')
  final String status; // present, absent, late

  @JsonKey(name: 'remarks')
  final String? remarks;

  // Extended fields for display
  @JsonKey(name: 'student_name')
  final String? studentName;

  @JsonKey(name: 'register_no')
  final String? registerNo;

  AttendanceRecord({
    this.id,
    required this.attendanceId,
    required this.studentId,
    required this.status,
    this.remarks,
    this.studentName,
    this.registerNo,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceRecordToJson(this);

  bool get isPresent => status.toLowerCase() == 'present';
  bool get isAbsent => status.toLowerCase() == 'absent';
  bool get isLate => status.toLowerCase() == 'late';

  AttendanceRecord copyWith({
    int? id,
    int? attendanceId,
    int? studentId,
    String? status,
    String? remarks,
    String? studentName,
    String? registerNo,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      attendanceId: attendanceId ?? this.attendanceId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      studentName: studentName ?? this.studentName,
      registerNo: registerNo ?? this.registerNo,
    );
  }
}
