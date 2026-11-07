import 'enums.dart';

/// A signed-in person, as stored in `users/{uid}`.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final String studentId;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.role = UserRole.student,
    this.department = '',
    this.studentId = '',
  });

  bool get isStaff => role == UserRole.staff;

  Map<String, Object?> toMap() => <String, Object?>{
        'uid': uid,
        'name': name,
        'email': email,
        'role': role.firestoreValue,
        'department': department,
        'studentId': studentId,
      };

  factory AppUser.fromMap(String uid, Map<String, Object?> map) => AppUser(
        uid: uid,
        name: (map['name'] as String?) ?? '',
        email: (map['email'] as String?) ?? '',
        role: roleFromValue(map['role'] as String?),
        department: (map['department'] as String?) ?? '',
        studentId: (map['studentId'] as String?) ?? '',
      );

  String get initials {
    final List<String> parts =
        name.trim().split(' ').where((String p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
