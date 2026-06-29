import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/incident_entity.dart';
import '../bloc/incident_bloc.dart';
import '../bloc/incident_state.dart';
import 'incident_status_timeline.dart';

class IncidentTrackingSheet extends StatelessWidget {
  final IncidentEntity initialIncident;

  const IncidentTrackingSheet({
    super.key,
    required this.initialIncident,
  });

  /// Static helper to easily invoke the modal bottom sheet from anywhere
  static void show(BuildContext context, IncidentEntity incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Ensures the rounded corners display properly over the map
      barrierColor: Colors.black.withOpacity(0.4), // Translucent overlay to keep map context visible
      builder: (context) {
        return IncidentTrackingSheet(initialIncident: incident);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // DraggableScrollableSheet handles scaling nicely and provides seamless swipe-down dismissal gestures.
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            children: [
              // Swipe Drag Handle Bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              // Header with Exit Icon Button
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 12.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Incident Tracking',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 28, color: Colors.black54),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close tracking panel',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              // Scrollable Dynamic Content Body
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: BlocBuilder<IncidentBloc, IncidentState>(
                    builder: (context, state) {
                      // Default to the initially submitted incident
                      IncidentEntity currentIncident = initialIncident;

                      // If the real-time stream is active and loaded, find the latest real-time instance
                      if (state is IncidentLoaded) {
                        try {
                          final liveIncident = state.incidents.firstWhere(
                            (inc) => inc.id == initialIncident.id,
                          );
                          currentIncident = liveIncident;
                        } catch (_) {
                          // The incident was not found in the live stream.
                          // It may have been fully resolved and filtered out, or it hasn't arrived via network yet.
                          // Safely fallback to rendering the last known currentIncident object.
                        }
                      }

                      // Pass the resolved entity downstream to dynamically update the animation timeline
                      return IncidentStatusTimeline(incident: currentIncident);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
