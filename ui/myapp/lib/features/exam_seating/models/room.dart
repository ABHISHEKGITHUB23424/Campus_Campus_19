/// Room model for exam seating
class Room {
  final String code;
  final int capacity;
  final int? rows;
  final int? columns;

  Room({required this.code, required this.capacity, this.rows, this.columns});

  /// Create Room from JSON
  /// Example: {"code": "A101", "capacity": 30, "rows": 5, "columns": 6}
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      code: json['code'] as String,
      capacity: json['capacity'] as int,
      rows: json['rows'] as int?,
      columns: json['columns'] as int?,
    );
  }

  /// Convert Room to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'capacity': capacity,
      if (rows != null) 'rows': rows,
      if (columns != null) 'columns': columns,
    };
  }

  @override
  String toString() => rows != null && columns != null
      ? 'Room($code, $capacity seats, ${rows}x$columns)'
      : 'Room($code, $capacity seats)';
}
