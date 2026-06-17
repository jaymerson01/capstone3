import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/incident_model.dart';
import '../blocs/incident_bloc.dart';
import '../widgets/incident_card.dart';
import '../theme/app_colors.dart';

class IncidentOverviewPage extends StatefulWidget {
  const IncidentOverviewPage({super.key});

  @override
  State<IncidentOverviewPage> createState() => _IncidentOverviewPageState();
}

class _IncidentOverviewPageState extends State<IncidentOverviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<IncidentBloc>().add(const LoadIncidents());
  }

  Widget logoBox() {
    return Container(
      height: 36,
      width: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
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
            Row(
              children: [
                const Text(
                  "Report Directory",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
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

            Expanded(
              child: BlocBuilder<IncidentBloc, IncidentState>(
                builder: (context, state) {
                  if (state is IncidentLoading || state is IncidentInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
                      ),
                    );
                  }

                  if (state is IncidentError) {
                    return Center(
                      child: Text(
                        state.errorMessage,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    );
                  }

                  if (state is IncidentLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scrollable Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              filterChip(
                                context,
                                text: "ALL",
                                status: null,
                                isActive: state.selectedFilter == null,
                              ),
                              const SizedBox(width: 8),
                              filterChip(
                                context,
                                text: "Pending",
                                status: IncidentStatus.pending,
                                isActive: state.selectedFilter == IncidentStatus.pending,
                              ),
                              const SizedBox(width: 8),
                              filterChip(
                                context,
                                text: "In Progress",
                                status: IncidentStatus.verified,
                                isActive: state.selectedFilter == IncidentStatus.verified,
                              ),
                              const SizedBox(width: 8),
                              filterChip(
                                context,
                                text: "Resolve",
                                status: IncidentStatus.resolved,
                                isActive: state.selectedFilter == IncidentStatus.resolved,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Reports List
                        Expanded(
                          child: state.filteredIncidents.isEmpty
                              ? emptyBox("No reports found under this status filter.")
                              : ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: state.filteredIncidents.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    return IncidentCard(
                                      incident: state.filteredIncidents[index],
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterChip(
    BuildContext context, {
    required String text,
    required IncidentStatus? status,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<IncidentBloc>().add(FilterIncidents(status));
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
                    color: AppColors.darkGreen.withOpacity(0.2),
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

  Widget emptyBox(String placeholderText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade400, size: 36),
          const SizedBox(height: 12),
          Text(
            placeholderText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
