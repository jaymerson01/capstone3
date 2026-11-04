import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.role = 'resident',
    super.phoneNumber,
    super.address,
    super.barangayArea,
    super.emergencyContactName,
    super.emergencyContactNumber,
    super.photoUrl,
    super.isVerified = false,
    super.isActive = true,
    super.createdAt,
    super.isSuperAdmin = false,
    super.mfaEnabled = false,
    super.acceptedTermsVersion,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime? parsedCreatedAt;
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(data['createdAt']);
      }
    }

    return UserModel(
      id: id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? data['fullName'] as String?,
      role: data['role'] as String? ?? 'resident',
      phoneNumber: data['phoneNumber'] as String?,
      address: data['address'] as String?,
      barangayArea: data['barangayArea'] as String?,
      emergencyContactName: data['emergencyContactName'] as String?,
      emergencyContactNumber: data['emergencyContactNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: parsedCreatedAt,
      // Read only: toMap never writes these, so a profile save can't change them.
      isSuperAdmin: data['isSuperAdmin'] as bool? ?? false,
      mfaEnabled: data['mfaEnabledAt'] != null,
      acceptedTermsVersion: data['termsVersion'] as String?,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'fullName': displayName,
      'role': role,
      'phoneNumber': phoneNumber,
      'address': address,
      'barangayArea': barangayArea,
      'emergencyContactName': emergencyContactName,
      'emergencyContactNumber': emergencyContactNumber,
      'photoUrl': photoUrl,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  @override
  UserModel copyWith({
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
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      barangayArea: barangayArea ?? this.barangayArea,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactNumber: emergencyContactNumber ?? this.emergencyContactNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      acceptedTermsVersion: acceptedTermsVersion ?? this.acceptedTermsVersion,
    );
  }
}
