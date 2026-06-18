import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  String selectedFilter = "ALL";

  @override
  void initState() {
    super.initState();
    context.read<IncidentBloc>().add(const FetchIncidentsRequested());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'in progress':
      case 'progress':
        return AppColors.progress;
      case 'resolved':
      case 'resolved/solved':
      case 'solved':
      case 'resolve':
        return AppColors.solved;
      default:
        return AppColors.textLight;
    }
  }

  Widget logoBox() {
    return Container(
      height: 36,
      width: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.security, size: 20, color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Row(
          children: [
            logoBox(),
            const SizedBox(width: 10),
            const Text(
              "My Reports",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              child: Icon(Icons.person),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                const Text(
                  "Report Directory",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.search, size: 16, color: AppColors.textLight),
                      SizedBox(width: 6),
                      Text("Search", style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Interactive Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  filterChip("ALL"),
                  const SizedBox(width: 8),
                  filterChip("Pending"),
                  const SizedBox(width: 8),
                  filterChip("In Progress"),
                  const SizedBox(width: 8),
                  filterChip("Resolved"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // List of Reports
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<IncidentBloc>().add(const FetchIncidentsRequested());
                },
                child: BlocBuilder<IncidentBloc, IncidentState>(
                  builder: (context, state) {
                    if (state is IncidentFetchLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is IncidentFetchFailure) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          emptyBox("Error fetching reports: ${state.message}"),
                        ],
                      );
                    } else if (state is IncidentFetchSuccess) {
                      final incidents = state.incidents;

                      final filteredIncidents = incidents.where((incident) {
                        if (selectedFilter == "ALL") return true;
                        if (selectedFilter == "Resolved") {
                          return incident.status.toLowerCase() == "resolved" ||
                              incident.status.toLowerCase() == "solved" ||
                              incident.status.toLowerCase() == "resolve";
                        }
                        return incident.status.toLowerCase() == selectedFilter.toLowerCase();
                      }).toList();

                      if (filteredIncidents.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            emptyBox("No reports found under this status filter."),
                          ],
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredIncidents.length,
                        itemBuilder: (context, index) {
                          final incident = filteredIncidents[index];
                          final formattedTime =
                              "${incident.timestamp.day}/${incident.timestamp.month}/${incident.timestamp.year} ${incident.timestamp.hour}:${incident.timestamp.minute.toString().padLeft(2, '0')}";
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: reportBox(
                              title: incident.title,
                              time: formattedTime,
                              status: incident.status,
                              statusColor: _getStatusColor(incident.status),
                              photoUrl: incident.photoUrl,
                            ),
                          );
                        },
                      );
                    }

                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        emptyBox("Pull down to load reported incidents."),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterChip(String text) {
    final bool isActive = selectedFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.darkGreen : Colors.white,
          border: Border.all(color: isActive ? AppColors.darkGreen : AppColors.border),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.darkGreen.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget reportBox({
    required String title,
    required String time,
    required String status,
    required Color statusColor,
    String? photoUrl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (photoUrl != null && photoUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photoUrl,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade100,
                  height: 50,
                  width: 50,
                  child: const Icon(Icons.image_not_supported_outlined, size: 20, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_filled_outlined, size: 14, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor == AppColors.pending ? Colors.orange.shade800 : statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyBox(String placeholderText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              placeholderText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
