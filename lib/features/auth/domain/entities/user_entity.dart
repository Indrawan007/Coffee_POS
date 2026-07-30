class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.isActive,
  });

  final int id;
  final String name;
  final String username;
  final String role;
  final bool isActive;

  bool get isAdmin => role == 'admin';

  UserEntity copyWith({
    int? id,
    String? name,
    String? username,
    String? role,
    bool? isActive,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}