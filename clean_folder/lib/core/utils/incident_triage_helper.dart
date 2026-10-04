class IncidentTriageHelper {
  /// Returns the deterministic baseline urgency based on the incident category.
  /// Values: "CRITICAL", "HIGH", "MEDIUM", "LOW"
  static String getBaselineUrgency(String category) {
    final cat = category.toLowerCase().trim();

    // 🔴 CRITICAL: Immediate threat to life & safety
    if (cat.contains('fire') ||
        cat.contains('medical') ||
        cat.contains('explosion') ||
        cat.contains('gas')) {
      return 'CRITICAL';
    }

    // 🟠 HIGH: Active danger to persons, severe property threat, violence, flood, live electrical hazard
    if (cat.contains('violence') ||
        cat.contains('fight') ||
        cat.contains('flood') ||
        cat.contains('calamity') ||
        cat.contains('theft') ||
        cat.contains('robbery') ||
        cat.contains('wire') ||
        cat.contains('electric') ||
        cat.contains('sinkhole') ||
        cat.contains('collapse')) {
      return 'HIGH';
    }

    // 🔵 MEDIUM: Public safety disruptions, secondary hazards, road accidents
    if (cat.contains('accident') ||
        cat.contains('suspicious') ||
        cat.contains('other')) {
      return 'MEDIUM';
    }

    // ⚪ LOW: Municipal noise ordinance, minor lost item
    if (cat.contains('noise') || cat.contains('lost')) {
      return 'LOW';
    }

    return 'MEDIUM';
  }

  /// Evaluates dynamic urgency considering both category baseline and corroboration upvotes.
  /// Total Affected is calculated as: 1 (reporter) + upvoteCount (corroborating neighbors).
  static String calculateEffectiveUrgency({
    required String category,
    required int upvoteCount,
    String? currentUrgency,
  }) {
    final current = (currentUrgency ?? '').toUpperCase();
    if (current == 'CRITICAL') return 'CRITICAL';

    final totalAffected = upvoteCount + 1;

    // 5+ total affected (4+ upvotes) escalates ANY report to CRITICAL (community-wide crisis)
    if (totalAffected >= 5 || upvoteCount >= 4) {
      return 'CRITICAL';
    }

    final baseline = getBaselineUrgency(category);
    if (baseline == 'CRITICAL') return 'CRITICAL';

    // 3+ total affected (2+ upvotes) escalates HIGH to CRITICAL, or MEDIUM/LOW to HIGH
    if (totalAffected >= 3 || upvoteCount >= 2) {
      if (baseline == 'HIGH') {
        return 'CRITICAL';
      }
      return 'HIGH';
    }

    return baseline;
  }

  /// Numerical weight for sorting (higher = more urgent)
  static int getUrgencyWeight(String? urgency) {
    switch ((urgency ?? '').toUpperCase()) {
      case 'CRITICAL':
        return 4;
      case 'HIGH':
        return 3;
      case 'MEDIUM':
        return 2;
      case 'LOW':
        return 1;
      default:
        return 0;
    }
  }
}
