class Absence {
  final int? id;
  final String studentId;
  final DateTime date;
  final String? reason;
  final AbsenceType type;
  final String? subject;

  Absence({
    this.id,
    required this.studentId,
    required this.date,
    this.reason,
    required this.type,
    this.subject,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'reason': reason,
      'type': type.toString().split('.').last,
      'subject': subject,
    };
  }

  factory Absence.fromMap(Map<String, dynamic> map) {
    return Absence(
      id: map['id'] as int?,
      studentId: map['studentId'] as String,
      date: DateTime.parse(map['date'] as String),
      reason: map['reason'] as String?,
      type: AbsenceType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => AbsenceType.unjustified,
      ),
      subject: map['subject'] as String?,
    );
  }
}

enum AbsenceType {
  justified,
  unjustified,
  late,
}
