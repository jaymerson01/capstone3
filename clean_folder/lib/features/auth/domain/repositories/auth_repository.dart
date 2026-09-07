import 'package:dartz/dartz.dart';
import 'package:community_safety_app/core/error/failures.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail(String email, String password);
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String email,
    String password, {
    String? fullName,
    String role = 'resident',
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user);
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword);
  Future<Either<Failure, void>> deleteAccount();
}
