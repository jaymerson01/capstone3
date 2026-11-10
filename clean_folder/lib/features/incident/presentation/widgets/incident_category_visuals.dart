import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

/// Icon and accent color for an incident category, by the value stored in
/// Firestore (always English, e.g. "Fire Incident"). Display only.
class IncidentCategoryVisual {
  final IconData icon;
  final Color color;

  const IncidentCategoryVisual(this.icon, this.color);

  static const _fire = IncidentCategoryVisual(
      Icons.local_fire_department_rounded, Color(0xFFB91C1C));
  static const _theft =
      IncidentCategoryVisual(Icons.local_police_rounded, Color(0xFF7C3AED));
  static const _medical =
      IncidentCategoryVisual(Icons.medical_services_rounded, Color(0xFFDB2777));
  static const _violence =
      IncidentCategoryVisual(Icons.sports_kabaddi_rounded, Color(0xFFB45309));
  static const _road =
      IncidentCategoryVisual(Icons.car_crash_rounded, Color(0xFFC2410C));
  static const _suspicious =
      IncidentCategoryVisual(Icons.visibility_rounded, Color(0xFF475569));
  static const _flood =
      IncidentCategoryVisual(Icons.flood_rounded, Color(0xFF1D4ED8));
  static const _lost =
      IncidentCategoryVisual(Icons.person_search_rounded, Color(0xFF0E7490));
  static const _noise =
      IncidentCategoryVisual(Icons.volume_up_rounded, Color(0xFF3730A3));
  static const _other =
      IncidentCategoryVisual(Icons.report_problem_rounded, Color(0xFFB91C1C));

  /// "Other Emergency (Gas Leak)" and unknown values use the "Other" look.
  static IncidentCategoryVisual of(String storedCategory) {
    switch (storedCategory) {
      case 'Fire Incident':
        return _fire;
      case 'Theft / Robbery':
        return _theft;
      case 'Medical Emergency':
        return _medical;
      case 'Violence / Physical Fight':
        return _violence;
      case 'Road Accident':
        return _road;
      case 'Suspicious Activity':
        return _suspicious;
      case 'Flood / Calamity':
        return _flood;
      case 'Lost Item / Missing Person':
        return _lost;
      case 'Noise Complaint':
        return _noise;
    }
    return _other;
  }

  /// The icon color: the accent itself on light glass, lighter at night.
  Color get foreground =>
      AppColors.isDarkMode ? Color.lerp(color, Colors.white, 0.45)! : color;

  /// A soft tint of the accent for icon tiles.
  Color get tint => color.withValues(alpha: AppColors.isDarkMode ? 0.24 : 0.13);
}

/// The category icon on its tinted rounded tile, e.g. at the start of a
/// report card.
class IncidentCategoryTile extends StatelessWidget {
  final String storedCategory;
  final double size;

  const IncidentCategoryTile({
    super.key,
    required this.storedCategory,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    final visual = IncidentCategoryVisual.of(storedCategory);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: visual.tint,
        borderRadius: BorderRadius.circular(size * 0.33),
      ),
      child: Icon(visual.icon, color: visual.foreground, size: size * 0.48),
    );
  }
}
