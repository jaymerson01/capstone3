class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  bool isActive;
  bool isArchived;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.isArchived = false,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isActive,
    bool? isArchived,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      'isArchived': isArchived,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isActive: json['isActive'],
      isArchived: json['isArchived'] ?? false,
    );
  }
}
