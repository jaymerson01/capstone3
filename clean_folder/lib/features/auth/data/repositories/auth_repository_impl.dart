import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/core/error/failures.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:hive/hive.dart';
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
      if (email.trim().toLowerCase() == 'demo@resident.ph' && password == 'resident123') {
        await Hive.box('auth').put('isDemoLoggedIn', true);
        await Hive.box('auth').put('demo_role', 'resident');
        return const Right(UserEntity(
          id: 'resident_demo_01',
          email: 'demo@resident.ph',
          displayName: 'Juan Dela Cruz',
          role: 'resident',
          phoneNumber: '09171234567',
          isVerified: true,
        ));
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
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
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
      await Hive.box('auth').put('isDemoLoggedIn', false);
      await Hive.box('auth').delete('demo_role');
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
      if (user != null) return Right(user);
      final isDemoLoggedIn =
          Hive.box('auth').get('isDemoLoggedIn', defaultValue: false);
      if (isDemoLoggedIn == true) {
        final demoRole =
            Hive.box('auth').get('demo_role', defaultValue: 'resident');
        if (demoRole == 'admin') {
          return const Right(UserEntity(
            id: 'admin_demo_01',
            email: 'admin@safe.gov',
            displayName: 'Barangay Captain / Dispatcher',
            role: 'admin',
            phoneNumber: '09170000911',
            isVerified: true,
          ));
        }
        final cached = Hive.box('auth').get('demo_user_profile');
        if (cached is Map) {
          final map = Map<String, dynamic>.from(cached);
          return Right(
              UserModel.fromMap(map, map['id'] ?? 'resident_demo_01'));
        }
        return const Right(UserEntity(
          id: 'resident_demo_01',
          email: 'demo@resident.ph',
          displayName: 'Juan Dela Cruz',
          role: 'resident',
          phoneNumber: '09171234567',
          address: 'Bldg 4, St. Francis Compound, Moonwalk',
          barangayArea: 'Area 1 - San Jose',
          emergencyContactName: 'Maria Dela Cruz',
          emergencyContactNumber: '09198887766',
          isVerified: true,
        ));
      }
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user) async {
    try {
      final isDemoLoggedIn =
          Hive.box('auth').get('isDemoLoggedIn', defaultValue: false);
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

      if (isDemoLoggedIn == true || user.id == 'resident_demo_01') {
        await Hive.box('auth').put('demo_user_profile', model.toMap());
        return Right(model);
      }

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
      final isDemoLoggedIn =
          Hive.box('auth').get('isDemoLoggedIn', defaultValue: false);
      if (isDemoLoggedIn == true) {
        return const Right(null);
      }
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
