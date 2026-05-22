import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/shared_incident_database.dart';
import '../../data/models/incident_model.dart';

// ==========================================
// Incident Events
// ==========================================
abstract class IncidentEvent {
  const IncidentEvent();
}

class LoadIncidents extends IncidentEvent {
  const LoadIncidents();
}

class FilterIncidents extends IncidentEvent {
  final IncidentStatus? filterStatus;
  const FilterIncidents(this.filterStatus);
}

class AddIncident extends IncidentEvent {
  final IncidentModel incident;
  const AddIncident(this.incident);
}

// ==========================================
// Incident States
// ==========================================
abstract class IncidentState {
  const IncidentState();
}

class IncidentInitial extends IncidentState {}

class IncidentLoading extends IncidentState {}

class IncidentLoaded extends IncidentState {
  final List<IncidentModel> allIncidents;
  final List<IncidentModel> filteredIncidents;
  final IncidentStatus? selectedFilter;

  const IncidentLoaded({
    required this.allIncidents,
    required this.filteredIncidents,
    this.selectedFilter,
  });

  IncidentLoaded copyWith({
    List<IncidentModel>? allIncidents,
    List<IncidentModel>? filteredIncidents,
    IncidentStatus? selectedFilter,
    bool clearFilter = false,
  }) {
    return IncidentLoaded(
      allIncidents: allIncidents ?? this.allIncidents,
      filteredIncidents: filteredIncidents ?? this.filteredIncidents,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
    );
  }
}

class IncidentError extends IncidentState {
  final String errorMessage;
  const IncidentError(this.errorMessage);
}

// ==========================================
// Incident Bloc
// ==========================================
class IncidentBloc extends Bloc<IncidentEvent, IncidentState> {
  IncidentBloc() : super(IncidentInitial()) {
    on<LoadIncidents>(_onLoadIncidents);
    on<FilterIncidents>(_onFilterIncidents);
    on<AddIncident>(_onAddIncident);
    
    // Subscribe to SharedIncidentDatabase changes to automatically reload
    SharedIncidentDatabase().addListener(_onDatabaseChanged);
  }

  void _onDatabaseChanged() {
    add(const LoadIncidents());
  }

  List<IncidentModel> _loadFromDatabase() {
    final rawList = SharedIncidentDatabase().getRawIncidents();
    return rawList.map((raw) {
      IncidentStatus status;
      switch (raw['status'] as String? ?? 'pending') {
        case 'inProgress':
        case 'verified':
          status = IncidentStatus.verified;
          break;
        case 'solved':
        case 'resolved':
          status = IncidentStatus.resolved;
          break;
        case 'rejected':
          status = IncidentStatus.rejected;
          break;
        case 'pending':
        default:
          status = IncidentStatus.pending;
          break;
      }

      return IncidentModel(
        id: raw['id'] as String? ?? '',
        residentId: 'res-999',
        title: raw['title'] as String? ?? 'Incident',
        description: raw['description'] as String? ?? '',
        latitude: (raw['latitude'] as num?)?.toDouble() ?? 14.4796,
        longitude: (raw['longitude'] as num?)?.toDouble() ?? 121.0196,
        humanReadableAddress: raw['location'] as String? ?? 'Unknown',
        timestamp: raw['timestamp'] != null
            ? DateTime.parse(raw['timestamp'] as String)
            : DateTime.now(),
        imagePath: raw['imagePath'] as String? ?? 'assets/images/logo.png',
        status: status,
      );
    }).toList();
  }

  Future<void> _onLoadIncidents(
    LoadIncidents event,
    Emitter<IncidentState> emit,
  ) async {
    emit(IncidentLoading());
    try {
      // Small simulated latency for smooth loading transitions
      await Future.delayed(const Duration(milliseconds: 100));
      final incidents = _loadFromDatabase();
      emit(IncidentLoaded(
        allIncidents: incidents,
        filteredIncidents: incidents,
        selectedFilter: null,
      ));
    } catch (e) {
      emit(IncidentError(e.toString()));
    }
  }

  void _onFilterIncidents(
    FilterIncidents event,
    Emitter<IncidentState> emit,
  ) {
    if (state is IncidentLoaded) {
      final loadedState = state as IncidentLoaded;
      final status = event.filterStatus;

      List<IncidentModel> filtered;
      if (status == null) {
        filtered = List.from(loadedState.allIncidents);
      } else {
        filtered = loadedState.allIncidents
            .where((incident) => incident.status == status)
            .toList();
      }

      emit(loadedState.copyWith(
        filteredIncidents: filtered,
        selectedFilter: status,
        clearFilter: status == null,
      ));
    }
  }

  Future<void> _onAddIncident(
    AddIncident event,
    Emitter<IncidentState> emit,
  ) async {
    final incident = event.incident;
    String statusStr;
    switch (incident.status) {
      case IncidentStatus.verified:
        statusStr = 'inProgress';
        break;
      case IncidentStatus.resolved:
        statusStr = 'solved';
        break;
      case IncidentStatus.rejected:
        statusStr = 'rejected';
        break;
      case IncidentStatus.pending:
      default:
        statusStr = 'pending';
        break;
    }

    await SharedIncidentDatabase().saveIncident({
      'id': incident.id,
      'title': incident.title,
      'reporterName': 'Anonymous Resident',
      'location': incident.humanReadableAddress,
      'description': incident.description,
      'timestamp': incident.timestamp.toIso8601String(),
      'status': statusStr,
      'severity': 'Medium',
      'latitude': incident.latitude,
      'longitude': incident.longitude,
      'imagePath': incident.imagePath,
    });
  }

  @override
  Future<void> close() {
    SharedIncidentDatabase().removeListener(_onDatabaseChanged);
    return super.close();
  }
}
