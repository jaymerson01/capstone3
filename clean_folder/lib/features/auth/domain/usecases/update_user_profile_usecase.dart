import 'package:dartz/dartz.dart';
import 'package:community_safety_app/core/error/failures.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final AuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(UserEntity user) {
    return repository.updateUserProfile(user);
  }
}
