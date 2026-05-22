import 'package:flutter/material.dart';
import '../../data/models/incident_model.dart';

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
        return 'Resolve'; // Match the exact UI text "Resolve"
      case IncidentStatus.rejected:
        return 'Rejected';
    }
  }

  Color _getStatusColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.pending:
        return Colors.yellow;
      case IncidentStatus.verified:
        return Colors.orange;
      case IncidentStatus.resolved:
        return Colors.green;
      case IncidentStatus.rejected:
        return Colors.red;
    }
  }

  Color _getStatusTextColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.pending:
        return Colors.black;
      case IncidentStatus.verified:
      case IncidentStatus.resolved:
      case IncidentStatus.rejected:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.black54),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${incident.title}\n${_getRelativeTime(incident.timestamp)}",
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(incident.status),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getStatusText(incident.status),
              style: TextStyle(
                fontSize: 10,
                color: _getStatusTextColor(incident.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
