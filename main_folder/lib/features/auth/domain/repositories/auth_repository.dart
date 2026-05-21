import 'package:main_folder/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<void> signOut();

  Future<String?> getCurrentUserRole();
}
