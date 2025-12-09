class Batch {
  final int id;
  final int year;
  final String name;

  Batch({required this.id, required this.year, required this.name});

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as int,
      year: json['year'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'year': year, 'name': name};
  }
}

class BatchCreate {
  final int year;
  final String name;

  BatchCreate({required this.year, required this.name});

  Map<String, dynamic> toJson() {
    return {'year': year, 'name': name};
  }
}
