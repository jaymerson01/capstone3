class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String role; // strictly 'resident' or 'admin'
  final String? phoneNumber;
  final String? address;
  final String? barangayArea;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? photoUrl;
  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.role = 'resident',
    this.phoneNumber,
    this.address,
    this.barangayArea,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.photoUrl,
    this.isVerified = false,
    this.isActive = true,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isResident => role == 'resident';
  String? get fullName => displayName;

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? role,
    String? phoneNumber,
    String? address,
    String? barangayArea,
    String? emergencyContactName,
    String? emergencyContactNumber,
    String? photoUrl,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      barangayArea: barangayArea ?? this.barangayArea,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactNumber:
          emergencyContactNumber ?? this.emergencyContactNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
