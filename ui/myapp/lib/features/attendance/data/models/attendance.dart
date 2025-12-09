import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';

@JsonSerializable()
class Attendance {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'class_id')
  final int classId;

  @JsonKey(name: 'date')
  final String date; // YYYY-MM-DD

  @JsonKey(name: 'session')
  final String session; // FN or AN

  @JsonKey(name: 'faculty_id')
  final int? facultyId;

  @JsonKey(name: 'total_students')
  final int? totalStudents;

  @JsonKey(name: 'present_count')
  final int? presentCount;

  @JsonKey(name: 'absent_count')
  final int? absentCount;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  Attendance({
    this.id,
    required this.classId,
    required this.date,
    required this.session,
    this.facultyId,
    this.totalStudents,
    this.presentCount,
    this.absentCount,
    this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceToJson(this);

  double get attendancePercentage {
    if (totalStudents == null || totalStudents == 0) return 0.0;
    return (presentCount ?? 0) / totalStudents! * 100;
  }

  Attendance copyWith({
    int? id,
    int? classId,
    String? date,
    String? session,
    int? facultyId,
    int? totalStudents,
    int? presentCount,
    int? absentCount,
    String? createdAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      date: date ?? this.date,
      session: session ?? this.session,
      facultyId: facultyId ?? this.facultyId,
      totalStudents: totalStudents ?? this.totalStudents,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
