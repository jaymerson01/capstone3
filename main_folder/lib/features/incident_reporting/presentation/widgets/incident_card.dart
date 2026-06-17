import 'package:flutter/material.dart';
import '../../data/models/incident_model.dart';
import '../theme/app_colors.dart';

class IncidentCard extends StatelessWidget {
  final IncidentModel incident;

  const IncidentCard({
    super.key,
    required this.incident,
  });

  String _getRelativeTime(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return mins <= 0 ? "Just now" : "$mins mins ago";
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1 ? "1 hour ago" : "$hours hours ago";
    } else {
      final days = difference.inDays;
      return days == 1 ? "1 day ago" : "$days days ago";
    }
  }

  String _getStatusText(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.pending:
        return 'Pending';
      case IncidentStatus.verified:
        return 'In Progress';
      case IncidentStatus.resolved:
        return 'Resolve';
      case IncidentStatus.rejected:
        return 'Rejected';
    }
  }

  Color _getStatusColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.pending:
        return AppColors.pending;
      case IncidentStatus.verified:
        return AppColors.progress;
      case IncidentStatus.resolved:
        return AppColors.solved;
      case IncidentStatus.rejected:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(incident.status);
    final statusText = _getStatusText(incident.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled_outlined,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getRelativeTime(incident.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor == AppColors.pending
                    ? Colors.orange.shade800
                    : statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
