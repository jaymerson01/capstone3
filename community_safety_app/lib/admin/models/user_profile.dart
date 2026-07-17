class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String password;
  bool isActive;
  bool isArchived;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.password = 'Moonwalk#01', // Default for mock users
    required this.isActive,
    this.isArchived = false,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? password,
    bool? isActive,
    bool? isArchived,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      password: password ?? this.password,
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
      'password': password,
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
      password: json['password'] ?? 'Moonwalk#01',
      isActive: json['isActive'],
      isArchived: json['isArchived'] ?? false,
    );
  }
}
