import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:community_safety_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:community_safety_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:community_safety_app/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:community_safety_app/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:community_safety_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:community_safety_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:community_safety_app/features/incident/domain/repositories/incident_repository.dart';
import 'package:community_safety_app/features/incident/data/repositories/incident_repository_impl.dart';
import 'package:community_safety_app/features/incident/data/datasources/incident_ai_remote_data_source.dart';
import 'package:community_safety_app/features/incident/domain/usecases/triage_incident_usecase.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';

import 'package:community_safety_app/core/services/location_service.dart';
import 'package:community_safety_app/core/services/location_service_impl.dart';
import 'package:community_safety_app/core/services/camera_service.dart';
import 'package:community_safety_app/core/services/camera_service_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => AuthBloc(
        signInWithEmailUseCase: sl(),
        signUpWithEmailUseCase: sl(),
        signOutUseCase: sl(),
        getCurrentUserUseCase: sl(),
      ));
  sl.registerFactory(() => IncidentBloc(
        repository: sl(),
        triageIncidentUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => TriageIncidentUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<IncidentRepository>(
      () => IncidentRepositoryImpl(
            firestore: sl(),
            localBox: sl(),
            aiRemoteDataSource: sl(),
          ));

  // Data Sources
  sl.registerLazySingleton<IncidentAiRemoteDataSource>(
      () => IncidentAiRemoteDataSourceImpl(client: sl()));

  // Services
  sl.registerLazySingleton<LocationService>(() => const LocationServiceImpl());
  sl.registerLazySingleton<CameraService>(() => CameraServiceImpl(storage: sl()));

  // External
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<Box<IncidentModel>>(() => Hive.box<IncidentModel>('incidents'));
  sl.registerLazySingleton(() => http.Client());
}
