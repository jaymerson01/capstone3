import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/domain/repositories/incident_repository.dart';
import 'package:community_safety_app/features/incident/domain/usecases/triage_incident_usecase.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';

class MockIncidentRepository extends Mock implements IncidentRepository {}
class MockTriageIncidentUseCase extends Mock implements TriageIncidentUseCase {}
class FakeIncidentEntity extends Fake implements IncidentEntity {}

void main() {
  late IncidentBloc incidentBloc;
  late MockIncidentRepository mockIncidentRepository;
  late MockTriageIncidentUseCase mockTriageIncidentUseCase;

  setUpAll(() {
    registerFallbackValue(FakeIncidentEntity());
  });

  setUp(() {
    mockIncidentRepository = MockIncidentRepository();
    mockTriageIncidentUseCase = MockTriageIncidentUseCase();
    incidentBloc = IncidentBloc(
      repository: mockIncidentRepository,
      triageIncidentUseCase: mockTriageIncidentUseCase,
    );
  });

  tearDown(() {
    incidentBloc.close();
  });

  final tIncident = IncidentEntity(
    id: '1',
    reporterId: 'dummy_reporter',
    category: 'Test Category',
    description: 'Test Description',
    latitude: 1.0,
    longitude: 1.0,
    photoUrl: 'test_photo.jpg',
    status: 'pending',
    urgencyStatus: 'MEDIUM',
    timestamp: DateTime.fromMillisecondsSinceEpoch(0),
  );

  test('initial state should be IncidentInitial', () {
    expect(incidentBloc.state, isA<IncidentInitial>());
  });

  group('SubmitIncidentReportRequested', () {
    blocTest<IncidentBloc, IncidentState>(
      'should emit [IncidentSubmitLoading, IncidentSubmitSuccess] when submission is successful',
      build: () {
        when(() => mockIncidentRepository.submitIncidentReport(any()))
            .thenAnswer((_) async => Future.value());
        return incidentBloc;
      },
      act: (bloc) => bloc.add(SubmitIncidentReportRequested(tIncident)),
      expect: () => [
        isA<IncidentSubmitLoading>(),
        isA<IncidentSubmitSuccess>(),
      ],
      verify: (_) {
        verify(() => mockIncidentRepository.submitIncidentReport(tIncident)).called(1);
      },
    );

    blocTest<IncidentBloc, IncidentState>(
      'should emit [IncidentSubmitLoading, IncidentSubmitFailure] when submission fails',
      build: () {
        when(() => mockIncidentRepository.submitIncidentReport(any()))
            .thenThrow(Exception('Firestore Error'));
        return incidentBloc;
      },
      act: (bloc) => bloc.add(SubmitIncidentReportRequested(tIncident)),
      expect: () => [
        isA<IncidentSubmitLoading>(),
        isA<IncidentSubmitFailure>().having((state) => state.message, 'message', 'Exception: Firestore Error'),
      ],
      verify: (_) {
        verify(() => mockIncidentRepository.submitIncidentReport(tIncident)).called(1);
      },
    );
  });

  group('StreamActiveIncidentsRequested', () {
    blocTest<IncidentBloc, IncidentState>(
      'should emit [IncidentLoading, IncidentLoaded] when stream emits data',
      build: () {
        when(() => mockIncidentRepository.streamActiveIncidents())
            .thenAnswer((_) => Stream.value([tIncident]));
        return incidentBloc;
      },
      act: (bloc) => bloc.add(const StreamActiveIncidentsRequested()),
      expect: () => [
        isA<IncidentLoading>(),
        isA<IncidentLoaded>().having((state) => state.incidents, 'incidents', [tIncident]),
      ],
      verify: (_) {
        verify(() => mockIncidentRepository.streamActiveIncidents()).called(1);
      },
    );

    blocTest<IncidentBloc, IncidentState>(
      'should emit [IncidentLoading, IncidentError] when stream emits error',
      build: () {
        when(() => mockIncidentRepository.streamActiveIncidents())
            .thenAnswer((_) => Stream.error(Exception('Firestore Fetch Error')));
        return incidentBloc;
      },
      act: (bloc) => bloc.add(const StreamActiveIncidentsRequested()),
      expect: () => [
        isA<IncidentLoading>(),
        isA<IncidentError>().having((state) => state.message, 'message', 'Exception: Firestore Fetch Error'),
      ],
      verify: (_) {
        verify(() => mockIncidentRepository.streamActiveIncidents()).called(1);
      },
    );
  });
}
