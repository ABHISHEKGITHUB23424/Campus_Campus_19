/// Seating-related models
class SeatingEntry {
  final String registerNo;
  final String name;
  final String departmentCode;
  final int batchYear;
  final String roomCode;
  final int rowNum;
  final int columnNum;
  final int seatNum;

  SeatingEntry({
    required this.registerNo,
    required this.name,
    required this.departmentCode,
    required this.batchYear,
    required this.roomCode,
    required this.rowNum,
    required this.columnNum,
    required this.seatNum,
  });

  /// Create SeatingEntry from JSON
  /// Example: {
  ///   "register_no": "21CS001",
  ///   "name": "John Doe",
  ///   "department_code": "CSE",
  ///   "batch_year": 2021,
  ///   "room_code": "A101",
  ///   "row_num": 1,
  ///   "column_num": 1,
  ///   "seat_num": 1
  /// }
  factory SeatingEntry.fromJson(Map<String, dynamic> json) {
    return SeatingEntry(
      registerNo: json['register_no'] as String,
      name: json['name'] as String,
      departmentCode: json['department_code'] as String,
      batchYear: json['batch_year'] as int,
      roomCode: json['room_code'] as String,
      rowNum: json['row_num'] as int,
      columnNum: json['column_num'] as int,
      seatNum: json['seat_num'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'register_no': registerNo,
      'name': name,
      'department_code': departmentCode,
      'batch_year': batchYear,
      'room_code': roomCode,
      'row_num': rowNum,
      'column_num': columnNum,
      'seat_num': seatNum,
    };
  }
}

/// Room availability detail from backend /available-rooms endpoint
class RoomAvailability {
  final String code;
  final int capacity;
  final int occupiedSeats;
  final int availableSeats;
  final String status; // available | partial | full

  RoomAvailability({
    required this.code,
    required this.capacity,
    required this.occupiedSeats,
    required this.availableSeats,
    required this.status,
  });

  factory RoomAvailability.fromJson(Map<String, dynamic> json) {
    return RoomAvailability(
      code: json['code']?.toString() ?? '',
      capacity: (json['capacity'] is int) ? json['capacity'] as int : 0,
      occupiedSeats: (json['occupied_seats'] is int)
          ? json['occupied_seats'] as int
          : 0,
      availableSeats: (json['available_seats'] is int)
          ? json['available_seats'] as int
          : 0,
      status: json['status']?.toString() ?? 'available',
    );
  }
}

/// Available rooms response model (adapted to current backend shape)
class AvailableRoomResponse {
  final String examDate;
  final String session;
  final List<RoomAvailability> rooms;

  AvailableRoomResponse({
    required this.examDate,
    required this.session,
    required this.rooms,
  });

  factory AvailableRoomResponse.fromJson(Map<String, dynamic> json) {
    final roomsJson = json['available_rooms'];
    List<RoomAvailability> parsedRooms = [];
    if (roomsJson is List) {
      parsedRooms = roomsJson
          .whereType<Map<String, dynamic>>()
          .map(RoomAvailability.fromJson)
          .toList();
    }
    return AvailableRoomResponse(
      examDate: json['exam_date']?.toString() ?? '',
      session: json['session']?.toString() ?? '',
      rooms: parsedRooms,
    );
  }
}

/// Generate seating request model
class GenerateSeatingRequest {
  final String examDate; // YYYY-MM-DD
  final String session; // FN or AN
  final List<String> roomCodes;

  GenerateSeatingRequest({
    required this.examDate,
    required this.session,
    required this.roomCodes,
  });

  Map<String, dynamic> toJson() {
    return {'exam_date': examDate, 'session': session, 'room_codes': roomCodes};
  }
}

/// Generate seating response model
class GenerateSeatingResponse {
  final int seatsGenerated;
  final Map<String, int> roomsUsed;
  final String message;
  final String status;

  GenerateSeatingResponse({
    required this.seatsGenerated,
    required this.roomsUsed,
    required this.message,
    required this.status,
  });

  /// Flexible factory to handle both legacy and current backend shapes.
  /// Possible backend responses observed:
  /// 1) {"status": "ok", "allocated": 45}
  /// 2) {"seats_generated": 45, "rooms_used": {"A101": 30}, "message": "Generated 45 seats"}
  factory GenerateSeatingResponse.fromJson(Map<String, dynamic> json) {
    final hasAllocated = json.containsKey('allocated');
    final hasSeatsGenerated = json.containsKey('seats_generated');
    final seats = hasAllocated
        ? (json['allocated'] is int ? json['allocated'] as int : 0)
        : (hasSeatsGenerated && json['seats_generated'] is int
              ? json['seats_generated'] as int
              : 0);

    final roomsMapRaw = json['rooms_used'];
    Map<String, int> roomsMap = {};
    if (roomsMapRaw is Map) {
      roomsMap = roomsMapRaw.map(
        (key, value) => MapEntry(key.toString(), value is int ? value : 0),
      );
    }

    final status = json['status']?.toString() ?? 'ok';
    final message = json['message']?.toString() ?? 'Allocated $seats seats';

    return GenerateSeatingResponse(
      seatsGenerated: seats,
      roomsUsed: roomsMap,
      message: message,
      status: status,
    );
  }
}
