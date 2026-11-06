class SessionModel {
  final String id;
  final DateTime startedAt;
  final int plannedSeconds;
  final int actualSeconds;
  final String note;

  const SessionModel({
    required this.id,
    required this.startedAt,
    required this.plannedSeconds,
    required this.actualSeconds,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'plannedSeconds': plannedSeconds,
      'actualSeconds': actualSeconds,
      'note': note,
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      plannedSeconds: json['plannedSeconds'] as int,
      actualSeconds: json['actualSeconds'] as int,
      note: json['note'] as String,
    );
  }
}