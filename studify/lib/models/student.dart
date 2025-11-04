class Student {
  final int? id;
  final String name;
  final String studentId;
  final String? parentEmail;

  Student({
    this.id,
    required this.name,
    required this.studentId,
    this.parentEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'studentId': studentId,
      'parentEmail': parentEmail,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      studentId: map['studentId'] as String,
      parentEmail: map['parentEmail'] as String?,
    );
  }
}
