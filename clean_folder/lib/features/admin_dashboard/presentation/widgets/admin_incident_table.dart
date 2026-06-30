import 'package:flutter/material.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

class AdminIncidentTable extends StatelessWidget {
  final List<IncidentEntity> incidents;
  final void Function(IncidentEntity) onViewDetails;
  final void Function(IncidentEntity) onUpdateStatus;
  final void Function(IncidentEntity) onMarkAsSpam;

  const AdminIncidentTable({
    super.key,
    required this.incidents,
    required this.onViewDetails,
    required this.onUpdateStatus,
    required this.onMarkAsSpam,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: DataTable(
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        dataRowMinHeight: 50,
        dataRowMaxHeight: 65,
        columns: const [
          DataColumn(label: Text('Report ID')),
          DataColumn(label: Text('Type/Category')),
          DataColumn(label: Text('Reporter')),
          DataColumn(label: Text('Location (Purok/Zone)')),
          DataColumn(label: Text('Date/Timestamp')),
          DataColumn(label: Text('Urgency Tier')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: incidents.map((incident) => _buildDataRow(incident)).toList(),
      ),
    );
  }

  DataRow _buildDataRow(IncidentEntity incident) {
    // Format timestamp manually since intl package is not available
    final date = incident.timestamp.toLocal();
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    // Reporter anonymous masking
    final bool isAnonymous = incident.reporterId.isEmpty || incident.reporterId.toLowerCase() == 'anonymous';
    final String reporterName = isAnonymous ? 'Anonymous' : incident.reporterId;

    return DataRow(
      cells: [
        DataCell(Text(
          incident.id.length > 8 ? incident.id.substring(0, 8).toUpperCase() : incident.id,
          style: const TextStyle(fontWeight: FontWeight.w500),
        )),
        DataCell(Text(incident.category)),
        DataCell(Text(
          reporterName,
          style: TextStyle(
            fontStyle: isAnonymous ? FontStyle.italic : FontStyle.normal,
            color: isAnonymous ? Colors.grey.shade600 : Colors.black87,
          ),
        )),
        DataCell(SizedBox(
          width: 150, // Constrain width for compact layouts
          child: Text(
            incident.resolvedAddress ?? 'Unknown Location',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Text(dateString)),
        DataCell(_buildUrgencyBadge(incident.urgencyStatus ?? 'UNKNOWN')),
        DataCell(_buildStatusBadge(incident.status)),
        DataCell(_buildActions(incident)),
      ],
    );
  }

  Widget _buildUrgencyBadge(String urgency) {
    Color bgColor;
    Color textColor;
    FontWeight weight;

    switch (urgency.toUpperCase()) {
      case 'HIGH':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        weight = FontWeight.w900; // Stark alert weight
        break;
      case 'MEDIUM':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        weight = FontWeight.w700; // Warning weight
        break;
      case 'LOW':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade900;
        weight = FontWeight.w500; // Informational weight
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        weight = FontWeight.normal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        urgency.toUpperCase(),
        style: TextStyle(color: textColor, fontWeight: weight, fontSize: 12),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'resolved':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        break;
      case 'inprogress':
      case 'in progress':
      case 'in_progress':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        break;
      case 'pending':
      default:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        break;
    }

    String displayStatus = status.toLowerCase();
    if (displayStatus == 'inprogress' || displayStatus == 'in_progress') {
      displayStatus = 'In Progress';
    } else if (displayStatus == 'pending') {
      displayStatus = 'Pending';
    } else if (displayStatus == 'resolved') {
      displayStatus = 'Resolved';
    } else {
      displayStatus = status; // fallback
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            displayStatus == 'Resolved'
                ? Icons.check_circle
                : displayStatus == 'In Progress'
                    ? Icons.sync
                    : Icons.pending_actions,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            displayStatus,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(IncidentEntity incident) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
          tooltip: 'View Details',
          splashRadius: 20,
          onPressed: () => onViewDetails(incident),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.orange),
          tooltip: 'Update Status',
          splashRadius: 20,
          onPressed: () => onUpdateStatus(incident),
        ),
        IconButton(
          icon: const Icon(Icons.block, color: Colors.red),
          tooltip: 'Mark as Spam',
          splashRadius: 20,
          onPressed: () => onMarkAsSpam(incident),
        ),
      ],
    );
  }
}
