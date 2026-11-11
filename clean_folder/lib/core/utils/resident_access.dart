import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';

/// What a resident may do before the barangay has verified their ID.
///
/// Unverified residents can always report emergencies and call the hotlines.
/// Until verified they:
/// - see only their own reports (not their neighbors') on Home and the map;
/// - cannot report anonymously or on someone else's behalf;
/// - can file [dailyReportLimit] reports a day, after which only emergencies
///   go through until the next day.
///
/// The Firestore rules enforce the first two; the daily limit is kept by the
/// app.
class ResidentAccess {
  ResidentAccess._();

  /// Reports an unverified resident may file per day (Philippine time)
  /// before only emergencies go through.
  static const int dailyReportLimit = 3;

  /// Never limited, whoever reports them.
  static const List<String> emergencyCategories = [
    'Fire Incident',
    'Medical Emergency',
    'Road Accident',
    'Flood / Calamity',
    'Violence / Physical Fight',
    'Theft / Robbery',
    'Other Emergency',
  ];

  static bool isEmergency(String? category) =>
      category != null && emergencyCategories.contains(category);

  static bool isVerified(UserEntity? user) => user?.isVerified ?? false;

  /// Neighbors' reports on Home and the map, and alerts about them.
  static bool canSeeCommunity(UserEntity? user) => isVerified(user);

  /// Reporting anonymously, or on someone else's behalf.
  static bool canReportAnonymouslyOrForOthers(UserEntity? user) => isVerified(user);

  static DateTime _phDay(DateTime t) {
    final ph = t.toUtc().add(const Duration(hours: 8));
    return DateTime.utc(ph.year, ph.month, ph.day);
  }

  /// Reports [uid] filed today, Philippine time.
  static int reportsToday(Iterable<IncidentEntity> incidents, String uid, {DateTime? now}) {
    final today = _phDay(now ?? DateTime.now());
    return incidents.where((i) => i.reporterId == uid && _phDay(i.timestamp) == today).length;
  }

  /// Reports [user] may still file today before only emergencies go through
  /// (null when verified: no limit).
  static int? reportsLeftToday(UserEntity? user, Iterable<IncidentEntity> incidents, {DateTime? now}) {
    if (user == null || isVerified(user)) return null;
    final left = dailyReportLimit - reportsToday(incidents, user.id, now: now);
    return left < 0 ? 0 : left;
  }

  /// Whether [user] may file a report of [category] now.
  static bool canFile(UserEntity? user, String? category, Iterable<IncidentEntity> incidents, {DateTime? now}) {
    if (isEmergency(category)) return true;
    final left = reportsLeftToday(user, incidents, now: now);
    return left == null || left > 0;
  }

  /// The reports this resident may see: everyone's active reports once
  /// verified, otherwise only their own.
  static IncidentEvent streamFor(UserEntity? user) => user != null && !canSeeCommunity(user)
      ? StreamUserIncidentsRequested(user.id)
      : const StreamActiveIncidentsRequested();
}
