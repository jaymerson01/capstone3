import '../../features/incident_reporting/data/models/incident_model.dart';

abstract class SpamThrottler {
  /// The maximum number of allowed concurrent 'pending' reports 
  /// a single resident can have active at any given moment.
  int get maxPendingThreshold;

  /// Checks if the resident with [residentId] has violated 
  /// submission frequency rules or exceeded the active pending report limits.
  /// 
  /// Returns [true] if submissions should be paused or throttled.
  bool shouldThrottle({
    required String residentId,
    required List<IncidentModel> activeIncidents,
  });
}
