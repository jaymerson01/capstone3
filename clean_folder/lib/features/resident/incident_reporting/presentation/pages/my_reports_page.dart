import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage>
    with SingleTickerProviderStateMixin {
  String selectedFilter = "ALL";
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    context.read<IncidentBloc>().add(const StreamActiveIncidentsRequested());
    
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _MyReportsAppBar(),
      body: FadeTransition(
        opacity: _entranceController,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Report Directory",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Your submitted incident reports",
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const _SearchButton(),
                ],
              ),
              const SizedBox(height: 16),

              // ── Filter Chips ─────────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _FilterChip(
                      text: "ALL",
                      selected: selectedFilter == "ALL",
                      onTap: () => setState(() => selectedFilter = "ALL"),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      text: "Pending",
                      selected: selectedFilter == "Pending",
                      color: AppColors.pending,
                      onTap: () =>
                          setState(() => selectedFilter = "Pending"),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      text: "In Progress",
                      selected: selectedFilter == "In Progress",
                      color: AppColors.progress,
                      onTap: () =>
                          setState(() => selectedFilter = "In Progress"),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      text: "Resolved",
                      selected: selectedFilter == "Resolved",
                      color: AppColors.solved,
                      onTap: () =>
                          setState(() => selectedFilter = "Resolved"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Report List ──────────────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<IncidentBloc>().add(const StreamActiveIncidentsRequested());
                  },
                  child: BlocBuilder<IncidentBloc, IncidentState>(
                    builder: (context, state) {
                      if (state is IncidentLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        );
                      } else if (state is IncidentError) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            _emptyBox("Error fetching reports: ${state.message}"),
                          ],
                        );
                      } else if (state is IncidentLoaded) {
                        final incidents = state.incidents;

                        // Note: In my_reports_page, you might want to filter by the current user's ID
                        // but since the original BLoC implementation handled filtering in the widget or relied
                        // on StreamActiveIncidentsRequested to return the appropriate list, we filter by status.
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
                              _emptyBox("No reports found under this status filter."),
                            ],
                          );
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          itemCount: filteredIncidents.length,
                          itemBuilder: (context, index) {
                            final incident = filteredIncidents[index];
                            final formattedTime =
                                "${incident.timestamp.day}/${incident.timestamp.month}/${incident.timestamp.year} ${incident.timestamp.hour}:${incident.timestamp.minute.toString().padLeft(2, '0')}";
                            return _AnimatedReportCard(
                              delay: Duration(milliseconds: 60 * index),
                              title: incident.category,
                              time: formattedTime,
                              status: incident.status,
                              statusColor: _getStatusColor(incident.status),
                              location: incident.description, // using description as location since location isn't string
                            );
                          },
                        );
                      }

                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _emptyBox("Pull down to load reported incidents."),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyBox(String placeholderText) {
    return Custom3dCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 18,
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              color: AppColors.primary.withValues(alpha: 0.5), size: 48),
          const SizedBox(height: 12),
          Text(
            placeholderText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _MyReportsAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
            bottom: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              onPressed: () => Navigator.pop(context),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary,
                    child: const Icon(Icons.shield,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "My Reports",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person,
                  color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search, size: 15, color: AppColors.textLight),
          SizedBox(width: 6),
          Text(
            "Search",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.text,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? chipColor.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          border: Border.all(
            color: selected
                ? chipColor.withValues(alpha: 0.5)
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: chipColor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? chipColor : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}

class _AnimatedReportCard extends StatefulWidget {
  final String title;
  final String time;
  final String status;
  final Color statusColor;
  final String location;
  final Duration delay;

  const _AnimatedReportCard({
    required this.title,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.location,
    required this.delay,
  });

  @override
  State<_AnimatedReportCard> createState() => _AnimatedReportCardState();
}

class _AnimatedReportCardState extends State<_AnimatedReportCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusClr = widget.statusColor;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Custom3dCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          borderRadius: 18,
          glowColor: statusClr,
          child: Row(
            children: [
              // Status indicator bar
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: statusClr,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: statusClr.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textLight),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            widget.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textLight),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_outlined,
                            size: 12, color: AppColors.textLight),
                        const SizedBox(width: 3),
                        Text(
                          widget.time,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusClr.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusClr.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: statusClr.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusClr,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
