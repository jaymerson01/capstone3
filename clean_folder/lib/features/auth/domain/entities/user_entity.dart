class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String role; // 'resident', 'admin' or 'responder'
  final String? phoneNumber;
  final String? address;
  final String? barangayArea;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? photoUrl;
  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;

  /// An admin who may create other admin accounts and reset their
  /// two-step verification. Set by another super admin, never by the user.
  final bool isSuperAdmin;

  /// Whether this admin has linked an authenticator app for sign-in.
  final bool mfaEnabled;

  /// The Terms and Conditions version this resident accepted, if any.
  final String? acceptedTermsVersion;

  /// A responder's department id (see Department), set by a super admin.
  final String? department;

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
    this.isSuperAdmin = false,
    this.mfaEnabled = false,
    this.acceptedTermsVersion,
    this.department,
  });

  bool get isAdmin => role == 'admin';
  bool get isResident => role == 'resident';
  bool get isResponder => role == 'responder';
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
    bool? isSuperAdmin,
    bool? mfaEnabled,
    String? acceptedTermsVersion,
    String? department,
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
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      acceptedTermsVersion: acceptedTermsVersion ?? this.acceptedTermsVersion,
      department: department ?? this.department,
    );
  }
}
