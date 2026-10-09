import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/domain/repositories/incident_repository.dart';
import 'package:community_safety_app/features/incident/presentation/pages/incident_detail_page.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';

class MyReportsPage extends StatefulWidget {
  final bool isRootTab;
  const MyReportsPage({super.key, this.isRootTab = false});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage>
    with SingleTickerProviderStateMixin {
  String selectedFilter = "ALL";
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  late AnimationController _entranceController;

  Stream<List<IncidentEntity>>? _userReportsStream;
  String _activeUserId = '';

  @override
  void initState() {
    super.initState();
    _initUserStream();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entranceController.forward();
  }

  void _initUserStream() {
    final authState = context.read<AuthBloc>().state;
    _activeUserId = (authState is Authenticated)
        ? authState.user.id
        : (FirebaseAuth.instance.currentUser?.uid ?? 'resident_local');
    _userReportsStream = sl<IncidentRepository>().streamUserIncidents(_activeUserId);
  }

  Future<void> _refreshUserReports() async {
    setState(() {
      _initUserStream();
    });
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _MyReportsAppBar(isRootTab: widget.isRootTab),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                  ),
                  _SearchButton(
                    isSearching: _isSearching,
                    onTap: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          _searchQuery = "";
                        }
                      });
                    },
                  ),
                ],
              ),
              if (_isSearching) ...[
                SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 20, color: AppColors.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search title, location, category...",
                            hintStyle: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim().toLowerCase();
                            });
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, size: 18, color: AppColors.textLight),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = "";
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16),

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
                    SizedBox(width: 8),
                    _FilterChip(
                      text: "Pending",
                      selected: selectedFilter == "Pending",
                      color: AppColors.pending,
                      onTap: () =>
                          setState(() => selectedFilter = "Pending"),
                    ),
                    SizedBox(width: 8),
                    _FilterChip(
                      text: "In Progress",
                      selected: selectedFilter == "In Progress",
                      color: AppColors.progress,
                      onTap: () =>
                          setState(() => selectedFilter = "In Progress"),
                    ),
                    SizedBox(width: 8),
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
              SizedBox(height: 20),

              // ── Report List ──────────────────────────────────────────────
              Expanded(
                child: BlocListener<AuthBloc, AuthState>(
                  listener: (context, authState) {
                    final currentId = (authState is Authenticated)
                        ? authState.user.id
                        : (FirebaseAuth.instance.currentUser?.uid ?? 'resident_local');
                    if (currentId != _activeUserId) {
                      setState(() {
                        _initUserStream();
                      });
                    }
                  },
                  child: RefreshIndicator(
                    onRefresh: _refreshUserReports,
                    color: AppColors.primary,
                    child: StreamBuilder<List<IncidentEntity>>(
                      stream: _userReportsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          );
                        } else if (snapshot.hasError) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              _emptyBox("Error fetching reports: ${snapshot.error}"),
                            ],
                          );
                        }

                        final incidents = snapshot.data ?? [];

                        final filteredIncidents = incidents.where((incident) {
                          // 0. Ownership Filter: strictly show only reports owned by this resident
                          if (_activeUserId != 'resident_local' &&
                              incident.reporterId != _activeUserId) {
                            return false;
                          }

                          // 1. Status Filter
                          bool matchesStatus = true;
                          if (selectedFilter != "ALL") {
                            if (selectedFilter == "Resolved") {
                              matchesStatus = incident.status.toLowerCase() == "resolved" ||
                                  incident.status.toLowerCase() == "solved" ||
                                  incident.status.toLowerCase() == "resolve";
                            } else {
                              matchesStatus = incident.status.toLowerCase() ==
                                  selectedFilter.toLowerCase();
                            }
                          }
                          if (!matchesStatus) return false;

                          // 2. Search Query Filter
                          if (_searchQuery.isNotEmpty) {
                            final category = incident.category.toLowerCase();
                            final description = incident.description.toLowerCase();
                            final address = (incident.resolvedAddress ?? "").toLowerCase();
                            final sector = (incident.areaSector ?? "").toLowerCase();
                            final id = incident.id.toLowerCase();
                            return category.contains(_searchQuery) ||
                                description.contains(_searchQuery) ||
                                address.contains(_searchQuery) ||
                                sector.contains(_searchQuery) ||
                                id.contains(_searchQuery);
                          }
                          return true;
                        }).toList();

                        if (filteredIncidents.isEmpty) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              _emptyBox(_searchQuery.isNotEmpty
                                  ? "No reports matching '$_searchQuery' found."
                                  : "No reports found under this status filter."),
                            ],
                          );
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          itemCount: filteredIncidents.length,
                          itemBuilder: (context, index) {
                            final incident = filteredIncidents[index];
                            return _AnimatedReportCard(
                              delay: Duration(milliseconds: 60 * index),
                              incident: incident,
                              statusColor: _getStatusColor(incident.status),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => IncidentDetailPage(
                                      initialIncident: incident,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
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
          SizedBox(height: 12),
          Text(
            placeholderText,
            textAlign: TextAlign.center,
            style: TextStyle(
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
  final bool isRootTab;
  const _MyReportsAppBar({this.isRootTab = false});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        final topPadding = MediaQuery.of(context).padding.top;
        return Container(
          height: 64 + topPadding,
          padding: EdgeInsets.only(top: topPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: isDark ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (!isRootTab) ...[
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                ],
                Container(
                  width: 36,
                  height: 36,
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
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primary,
                        child: Icon(Icons.shield,
                            color: AppColors.textDark, size: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.cyanGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: const Text(
                    "MY REPORTS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.history_edu_rounded,
                      color: AppColors.primary, size: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchButton extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onTap;

  const _SearchButton({
    required this.isSearching,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSearching
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          border: Border.all(
            color: isSearching ? AppColors.primary : AppColors.border,
            width: isSearching ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.close_rounded : Icons.search_rounded,
              size: 15,
              color: isSearching ? AppColors.primary : AppColors.textLight,
            ),
            SizedBox(width: 6),
            Text(
              isSearching ? "Close" : "Search",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSearching ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
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
  final IncidentEntity incident;
  final Color statusColor;
  final Duration delay;
  final VoidCallback onTap;

  const _AnimatedReportCard({
    required this.incident,
    required this.statusColor,
    required this.delay,
    required this.onTap,
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
    final incident = widget.incident;
    final formattedTime =
        "${incident.timestamp.day.toString().padLeft(2, '0')}/${incident.timestamp.month.toString().padLeft(2, '0')}/${incident.timestamp.year} ${incident.timestamp.hour.toString().padLeft(2, '0')}:${incident.timestamp.minute.toString().padLeft(2, '0')}";

    // Combine address and area sector into a clean, unified location line
    final String displayLocation;
    if (incident.resolvedAddress != null && incident.resolvedAddress!.isNotEmpty) {
      if (incident.areaSector != null &&
          incident.areaSector!.isNotEmpty &&
          !incident.resolvedAddress!.toLowerCase().contains(incident.areaSector!.toLowerCase())) {
        displayLocation = "${incident.resolvedAddress!} • ${incident.areaSector!}";
      } else {
        displayLocation = incident.resolvedAddress!;
      }
    } else if (incident.areaSector != null && incident.areaSector!.isNotEmpty) {
      displayLocation = incident.areaSector!;
    } else {
      displayLocation =
          "${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}";
    }

    final hasContextTags = incident.isReportingOnBehalf ||
        (incident.isInProgress &&
            incident.estimatedResponseTime != null &&
            incident.estimatedResponseTime!.isNotEmpty);

    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: GestureDetector(
              onTap: widget.onTap,
          child: Custom3dCard(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            padding: const EdgeInsets.all(16),
            borderRadius: 18,
            child: Row(
              children: [
                // Subtle colored status indicator bar
                Container(
                  width: 3.5,
                  height: hasContextTags ? 68 : 52,
                  decoration: BoxDecoration(
                    color: statusClr,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Title
                      Text(
                        incident.category,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 5),

                      // Location & Sector (unified inline)
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.textLight),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              displayLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textLight),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),

                      // Timestamp & Sync Status (clean metadata)
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 12, color: AppColors.textLight),
                          SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textLight),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.textLight.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            incident.isSynced
                                ? Icons.cloud_done_rounded
                                : Icons.cloud_queue_rounded,
                            size: 12,
                            color: incident.isSynced
                                ? AppColors.solved
                                : AppColors.pending,
                          ),
                          SizedBox(width: 3),
                          Text(
                            incident.isSynced ? "Live" : "Local",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: incident.isSynced
                                  ? AppColors.solved
                                  : AppColors.pending,
                            ),
                          ),
                        ],
                      ),

                      // Contextual Chips: Only rendered when active/applicable
                      if (hasContextTags) ...[
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            // On-Behalf Tag (if reporting for someone else)
                            if (incident.isReportingOnBehalf)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9500)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFFFF9500)
                                          .withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_pin_circle_outlined,
                                      size: 11,
                                      color: const Color(0xFFFF9500),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "For: ${incident.victimName?.isNotEmpty == true ? incident.victimName! : 'Relative'}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFF9500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Dispatch ETA Tag (if patrol dispatched)
                            if (incident.isInProgress &&
                                incident.estimatedResponseTime != null &&
                                incident.estimatedResponseTime!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFF00E5FF)
                                          .withValues(alpha: 0.35)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 11,
                                      color: const Color(0xFF00E5FF),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "ETA: ${incident.estimatedResponseTime!}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF00E5FF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8),

                // Primary Status Badge & Tap Arrow
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusClr.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusClr.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        incident.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: statusClr,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textLight.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
}
}
