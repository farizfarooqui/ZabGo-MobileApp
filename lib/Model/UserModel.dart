class UserModel {
  final String id;
  final String name;
  final String? front_id_url;
  final String gender;
  final String number;
  final String studentId;
  final String department;
  final String semester;

  UserModel({
    required this.id,
    required this.name,
    required this.front_id_url,
    required this.gender,
    required this.number,
    required this.studentId,
    required this.department,
    required this.semester,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        front_id_url: json['front_id_url'],
        gender: json['gender'] ?? '',
        number: json['number'] ?? '',
        studentId: json['student_id'] ?? '',
        department: json['department'] ?? '',
        semester: json['semester'] ?? '',

      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        "front_id_url": front_id_url,
        'gender': gender,
        'number': number,
        'student_id': studentId,
        'department': department,
        'semester': semester,
      };
}
