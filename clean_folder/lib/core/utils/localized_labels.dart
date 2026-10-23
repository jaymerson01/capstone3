import 'package:flutter/widgets.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// Display text for values that are stored in Firestore.
///
/// Categories, statuses and urgency levels are always saved in English (or as
/// codes) so the admin portal, analytics and AI triage keep working. Use these
/// helpers only to *show* them — never save their result.
class LocalizedLabels {
  const LocalizedLabels._();

  static const String _otherPrefix = 'Other Emergency (';

  static String category(BuildContext context, String storedCategory) {
    final l10n = AppLocalizations.of(context);
    switch (storedCategory) {
      case 'Fire Incident':
        return l10n.categoryFire;
      case 'Theft / Robbery':
        return l10n.categoryTheft;
      case 'Medical Emergency':
        return l10n.categoryMedical;
      case 'Violence / Physical Fight':
        return l10n.categoryViolence;
      case 'Road Accident':
        return l10n.categoryRoadAccident;
      case 'Suspicious Activity':
        return l10n.categorySuspicious;
      case 'Flood / Calamity':
        return l10n.categoryFlood;
      case 'Lost Item / Missing Person':
        return l10n.categoryLostOrMissing;
      case 'Noise Complaint':
        return l10n.categoryNoise;
      case 'Other Emergency':
        return l10n.categoryOther;
    }
    // "Other Emergency (Gas Leak)": translate the prefix, keep what the
    // resident typed.
    if (storedCategory.startsWith(_otherPrefix) && storedCategory.endsWith(')')) {
      final typed = storedCategory.substring(
        _otherPrefix.length,
        storedCategory.length - 1,
      );
      return '${l10n.categoryOther} ($typed)';
    }
    return storedCategory;
  }

  static String status(BuildContext context, String storedStatus) {
    final l10n = AppLocalizations.of(context);
    switch (IncidentStatusExtension.fromString(storedStatus)) {
      case IncidentStatus.pending:
        return l10n.statusPending;
      case IncidentStatus.inProgress:
        return l10n.statusInProgress;
      case IncidentStatus.resolved:
        return l10n.statusResolved;
      case IncidentStatus.spam:
        return l10n.statusSpam;
      case IncidentStatus.archived:
        return l10n.statusArchived;
    }
  }

  static String urgency(BuildContext context, String? storedUrgency) {
    final l10n = AppLocalizations.of(context);
    switch (storedUrgency?.toUpperCase()) {
      case 'LOW':
        return l10n.urgencyLow;
      case 'MEDIUM':
        return l10n.urgencyMedium;
      case 'HIGH':
        return l10n.urgencyHigh;
      case 'CRITICAL':
        return l10n.urgencyCritical;
      default:
        return storedUrgency ?? '';
    }
  }

  /// "just now", "5 mins ago", "2 hrs ago", "3 days ago" in the current language.
  static String relativeTime(
    BuildContext context,
    DateTime timestamp, {
    DateTime? now,
  }) {
    final l10n = AppLocalizations.of(context);
    final diff = (now ?? DateTime.now()).difference(timestamp);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    return l10n.timeDaysAgo(diff.inDays);
  }
}
