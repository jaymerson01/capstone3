import 'package:dartz/dartz.dart';
import 'package:community_safety_app/core/error/failures.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return const Left(ServerFailure("Email and password cannot be empty."));
      }
      final user = UserEntity(
        id: 'mock_uid_123',
        email: email,
        displayName: "Mock Citizen",
      );
      // ignore: avoid_print
      print('📦 [AUTH DATA REPOSITORY] -> Returning Mock User Profile Success to the domain layer.');
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return const Left(ServerFailure("Email and password cannot be empty."));
      }
      final user = UserEntity(
        id: 'mock_uid_123',
        email: email,
        displayName: "Mock Citizen",
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = UserEntity(
        id: 'mock_uid_123',
        email: 'mocked@resq.com',
        displayName: "Mock Citizen",
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
