import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/core/error/failures.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/domain/repositories/incident_repository.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';

class MockIncidentRepository extends Mock implements IncidentRepository {}

class FakeIncidentEntity extends Fake implements IncidentEntity {}

void main() {
  late IncidentBloc incidentBloc;
  late MockIncidentRepository mockIncidentRepository;

  setUpAll(() {
    registerFallbackValue(FakeIncidentEntity());
  });

  setUp(() {
    mockIncidentRepository = MockIncidentRepository();
    incidentBloc = IncidentBloc(repository: mockIncidentRepository);
  });

  tearDown(() {
    incidentBloc.close();
  });

  final tIncident = IncidentEntity(
    id: '1',
    title: 'Test Incident',
    description: 'Test Description',
    latitude: 1.0,
    longitude: 1.0,
    photoUrl: 'test_photo.jpg',
    status: 'pending',
    timestamp: DateTime.fromMillisecondsSinceEpoch(0),
  );

  test('initial state should be IncidentInitial', () {
    expect(incidentBloc.state, isA<IncidentInitial>());
  });

  group('SubmitIncidentRequested', () {
    blocTest<IncidentBloc, IncidentState>(
      'should emit [IncidentSubmitLoading, IncidentSubmitSuccess] when submission is successful',
      build: () {
        when(() => mockIncidentRepository.submitIncident(any()))
            .thenAnswer((_) async => const Right(null));
        return incidentBloc;
      },
      act: (bloc) => bloc.add(SubmitIncidentRequested(tIncident)),
      expect: () => [
        isA<IncidentSubmitLoading>(),
        isA<IncidentSubmitSuccess>(),
      ],
      verify: (_) {
        verify(() => mockIncidentRepository.submitIncident(tIncident)).called(1);
      },
    );

    blocTest<IncidentBloc, IncidentState>(
      'should emit [IncidentSubmitLoading, IncidentSubmitFailure] when submission fails',
      build: () {
        when(() => mockIncidentRepository.submitIncident(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Firestore Error')));
        return incidentBloc;
      },
      act: (bloc) => bloc.add(SubmitIncidentRequested(tIncident)),
      expect: () => [
        isA<IncidentSubmitLoading>(),
        isA<IncidentSubmitFailure>().having((state) => state.message, 'message', 'Firestore Error'),
      ],
      verify: (_) {
        verify(() => mockIncidentRepository.submitIncident(tIncident)).called(1);
      },
    );
  });

  group('FetchIncidentsRequested', () {
    blocTest<IncidentBloc, IncidentState>(
      'should emit [IncidentFetchLoading, IncidentFetchSuccess] when fetch is successful',
      build: () {
        when(() => mockIncidentRepository.getIncidents())
            .thenAnswer((_) async => Right([tIncident]));
        return incidentBloc;
      },
      act: (bloc) => bloc.add(const FetchIncidentsRequested()),
      expect: () => [
        isA<IncidentFetchLoading>(),
        isA<IncidentFetchSuccess>().having((state) => state.incidents, 'incidents', [tIncident]),
      ],
      verify: (_) {
        verify(() => mockIncidentRepository.getIncidents()).called(1);
      },
    );

    blocTest<IncidentBloc, IncidentState>(
      'should emit [IncidentFetchLoading, IncidentFetchFailure] when fetch fails',
      build: () {
        when(() => mockIncidentRepository.getIncidents())
            .thenAnswer((_) async => const Left(ServerFailure('Firestore Fetch Error')));
        return incidentBloc;
      },
      act: (bloc) => bloc.add(const FetchIncidentsRequested()),
      expect: () => [
        isA<IncidentFetchLoading>(),
        isA<IncidentFetchFailure>().having((state) => state.message, 'message', 'Firestore Fetch Error'),
      ],
      verify: (_) {
        verify(() => mockIncidentRepository.getIncidents()).called(1);
      },
    );
  });
}
