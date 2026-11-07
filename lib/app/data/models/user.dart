/// Mirrors `Triptriva.API.DTOs.Users.UserResponse`.
///
/// ASP.NET Core serialises with camelCase by default, so the JSON keys are
/// `id`, `name`, `email`, `phone`, `role`, `avatarUrl`, `language`,
/// `isActive`, `createdAt`, `updatedAt`. `passwordHash` never leaves the
/// server, so there is deliberately no field for it here.
class User {
  const User({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.role = 'normal',
    this.avatarUrl,
    this.language = 'en',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      role: '${json['role'] ?? 'normal'}',
      avatarUrl: json['avatarUrl'] as String?,
      language: '${json['language'] ?? 'en'}',
      isActive: json['isActive'] != false,
      createdAt: DateTime.tryParse('${json['createdAt']}'),
      updatedAt: DateTime.tryParse('${json['updatedAt']}'),
    );
  }

  final String id;
  final String name;
  final String email;
  final String phone;

  /// One of `normal`, `partner`, `admin` (see `Triptriva.Common.UserRoles`).
  final String role;
  final String? avatarUrl;
  final String language;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPartner => role == 'partner';
  bool get isAdmin => role == 'admin';
}
