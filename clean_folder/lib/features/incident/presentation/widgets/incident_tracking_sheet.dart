import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:community_safety_app/core/presentation/neo/neo_icon_button.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';
import '../../domain/entities/incident_entity.dart';
import '../bloc/incident_bloc.dart';
import '../bloc/incident_state.dart';
import 'incident_status_timeline.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

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
      barrierColor: Colors.black.withValues(alpha: 0.4), // Translucent overlay to keep map context visible
      builder: (context) {
        return IncidentTrackingSheet(initialIncident: incident);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    // DraggableScrollableSheet handles scaling nicely and provides seamless swipe-down dismissal gestures.
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF1C2742), Color(0xFF0E1A33)]
                  : const [Color(0xFFFFFFFF), AppColors.frost],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(NeoRadii.panel),
            ),
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
            boxShadow: AppColors.soft3dShadow,
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
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              // Header with Exit Icon Button
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 14.0, bottom: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).trackingTitle,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    NeoIconButton(
                      icon: Icons.close_rounded,
                      tooltip: AppLocalizations.of(context).trackingClose,
                      size: 40,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Scrollable Dynamic Content Body
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
