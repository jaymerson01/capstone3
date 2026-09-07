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
}
