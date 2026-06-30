import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_incident_table.dart';

class IncidentReportsPage extends StatelessWidget {
  const IncidentReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<IncidentBloc, IncidentState>(
        builder: (context, state) {
          if (state is IncidentLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is IncidentLoaded) {
            return AdminIncidentTable(
              incidents: state.incidents,
              onViewDetails: (incident) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Action triggered: View Details for ${incident.id}')),
                );
              },
              onUpdateStatus: (incident) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Action triggered: Update Status for ${incident.id}')),
                );
              },
              onMarkAsSpam: (incident) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Action triggered: Mark as Spam for ${incident.id}')),
                );
              },
            );
          } else if (state is IncidentError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
