class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String password;
  final String? phone;
  final String? emergencyContact;
  final String? savedAddress;
  final String? avatarUrl;
  final String language;
  final String theme;
  final bool notificationsEnabled;
  bool isActive;
  bool isArchived;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.password = 'Moonwalk#01', // Default for mock users
    this.phone,
    this.emergencyContact,
    this.savedAddress,
    this.avatarUrl,
    this.language = 'en',
    this.theme = 'dark',
    this.notificationsEnabled = true,
    required this.isActive,
    this.isArchived = false,
    this.createdAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? password,
    String? phone,
    String? emergencyContact,
    String? savedAddress,
    String? avatarUrl,
    String? language,
    String? theme,
    bool? notificationsEnabled,
    bool? isActive,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      savedAddress: savedAddress ?? this.savedAddress,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'password': password,
      'phone': phone,
      'emergencyContact': emergencyContact,
      'savedAddress': savedAddress,
      'avatarUrl': avatarUrl,
      'language': language,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'isActive': isActive,
      'isArchived': isArchived,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      password: json['password'] ?? 'Moonwalk#01',
      phone: json['phone'],
      emergencyContact: json['emergencyContact'],
      savedAddress: json['savedAddress'],
      avatarUrl: json['avatarUrl'],
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'dark',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      isActive: json['isActive'] ?? true,
      isArchived: json['isArchived'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}

