class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  bool isActive;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}
