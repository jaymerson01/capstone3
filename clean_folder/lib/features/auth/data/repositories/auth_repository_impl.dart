import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/core/error/failures.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl();

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      if (email.trim().isEmpty || password.isEmpty) {
        return const Left(ServerFailure("Email and password cannot be empty."));
      }
      final user = await _remoteDataSource.signInWithEmailAndPassword(email, password);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String email,
    String password, {
    String? fullName,
    String role = 'resident',
  }) async {
    try {
      if (email.trim().isEmpty || password.isEmpty) {
        return const Left(ServerFailure("Email and password cannot be empty."));
      }
      final user = await _remoteDataSource.signUpWithEmailAndPassword(
        email,
        password,
        fullName: fullName,
        role: role,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user) async {
    try {
      final model = UserModel(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        role: user.role,
        phoneNumber: user.phoneNumber,
        address: user.address,
        barangayArea: user.barangayArea,
        emergencyContactName: user.emergencyContactName,
        emergencyContactNumber: user.emergencyContactNumber,
        photoUrl: user.photoUrl,
        isVerified: user.isVerified,
        isActive: user.isActive,
        createdAt: user.createdAt,
      );
      final updated = await _remoteDataSource.updateUserProfile(model);
      return Right(updated);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _remoteDataSource.changePassword(currentPassword, newPassword);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
