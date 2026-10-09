class UserEntity {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role; // 'resident' or 'admin'

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });
}
