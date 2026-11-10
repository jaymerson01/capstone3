import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/neo/aurora_background.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/neo_chip.dart';
import 'package:community_safety_app/core/presentation/neo/neo_icon_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_surface.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/domain/repositories/incident_repository.dart';
import 'package:community_safety_app/features/incident/presentation/pages/incident_detail_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/widgets/my_report_card.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';
import 'package:community_safety_app/core/presentation/neo/word_safe_text.dart';

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

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = "";
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    // Stored values may use "in_progress" as well as "In Progress".
    switch (status.toLowerCase().replaceAll('_', ' ')) {
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
        final l10n = AppLocalizations.of(context);
        // A root tab sits on the shell's aurora; a pushed page brings its own.
        final bottomInset =
            widget.isRootTab ? 0.0 : MediaQuery.paddingOf(context).bottom;
        final page = Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _entranceController,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ───────────────────────────────────────────────
                    Row(
                      children: [
                        if (!widget.isRootTab) ...[
                          NeoIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: l10n.commonBack,
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WordSafeText(
                                l10n.myReportsTitle,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.myReportsSubtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        NeoChip(
                          label: _isSearching
                              ? l10n.myReportsCloseSearch
                              : l10n.myReportsSearch,
                          icon: _isSearching
                              ? Icons.close_rounded
                              : Icons.search_rounded,
                          selected: _isSearching,
                          onPressed: _toggleSearch,
                        ),
                      ],
                    ),
                    if (_isSearching) ...[
                      const SizedBox(height: 14),
                      _buildSearchField(l10n),
                    ],
                    const SizedBox(height: 14),

                    // ── Filter Chips ─────────────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          NeoChip(
                            label: l10n.myReportsFilterAll,
                            selected: selectedFilter == "ALL",
                            onPressed: () =>
                                setState(() => selectedFilter = "ALL"),
                          ),
                          const SizedBox(width: 8),
                          NeoChip(
                            label: l10n.statusPending,
                            selected: selectedFilter == "Pending",
                            onPressed: () =>
                                setState(() => selectedFilter = "Pending"),
                          ),
                          const SizedBox(width: 8),
                          NeoChip(
                            label: l10n.statusInProgress,
                            selected: selectedFilter == "In Progress",
                            onPressed: () =>
                                setState(() => selectedFilter = "In Progress"),
                          ),
                          const SizedBox(width: 8),
                          NeoChip(
                            label: l10n.statusResolved,
                            selected: selectedFilter == "Resolved",
                            onPressed: () =>
                                setState(() => selectedFilter = "Resolved"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        l10n.myReportsDirectory.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ── Report List ──────────────────────────────────────────
                    Expanded(
                      child: BlocListener<AuthBloc, AuthState>(
                        listener: (context, authState) {
                          final currentId = (authState is Authenticated)
                              ? authState.user.id
                              : (FirebaseAuth.instance.currentUser?.uid ??
                                  'resident_local');
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
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  !snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.primary),
                                );
                              } else if (snapshot.hasError) {
                                return ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(top: 6),
                                  children: [
                                    _emptyBox(l10n.myReportsLoadError(
                                        '${snapshot.error}')),
                                  ],
                                );
                              }

                              final incidents = snapshot.data ?? [];

                              final filteredIncidents =
                                  incidents.where((incident) {
                                // 0. Ownership Filter: strictly show only reports owned by this resident
                                if (_activeUserId != 'resident_local' &&
                                    incident.reporterId != _activeUserId) {
                                  return false;
                                }

                                // 1. Status Filter
                                bool matchesStatus = true;
                                if (selectedFilter != "ALL") {
                                  if (selectedFilter == "Resolved") {
                                    matchesStatus = incident.status
                                                .toLowerCase() ==
                                            "resolved" ||
                                        incident.status.toLowerCase() ==
                                            "solved" ||
                                        incident.status.toLowerCase() ==
                                            "resolve";
                                  } else {
                                    // The admin portal saves "in_progress".
                                    matchesStatus = incident.status
                                            .toLowerCase()
                                            .replaceAll('_', ' ') ==
                                        selectedFilter.toLowerCase();
                                  }
                                }
                                if (!matchesStatus) return false;

                                // 2. Search Query Filter
                                if (_searchQuery.isNotEmpty) {
                                  final category =
                                      incident.category.toLowerCase();
                                  final description =
                                      incident.description.toLowerCase();
                                  final address =
                                      (incident.resolvedAddress ?? "")
                                          .toLowerCase();
                                  final sector =
                                      (incident.areaSector ?? "").toLowerCase();
                                  final id = incident.id.toLowerCase();
                                  return category.contains(_searchQuery) ||
                                      LocalizedLabels.category(
                                              context, incident.category)
                                          .toLowerCase()
                                          .contains(_searchQuery) ||
                                      description.contains(_searchQuery) ||
                                      address.contains(_searchQuery) ||
                                      sector.contains(_searchQuery) ||
                                      id.contains(_searchQuery);
                                }
                                return true;
                              }).toList();

                              if (filteredIncidents.isEmpty) {
                                return ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(top: 6),
                                  children: [
                                    _emptyBox(_searchQuery.isNotEmpty
                                        ? l10n.myReportsNoMatch(_searchQuery)
                                        : l10n.myReportsNoneForFilter),
                                  ],
                                );
                              }

                              return ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics()),
                                padding: EdgeInsets.fromLTRB(
                                    0, 6, 0, 24 + bottomInset),
                                itemCount: filteredIncidents.length,
                                itemBuilder: (context, index) {
                                  final incident = filteredIncidents[index];
                                  return _AnimatedReportCard(
                                    delay: Duration(milliseconds: 60 * index),
                                    incident: incident,
                                    statusColor:
                                        _getStatusColor(incident.status),
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
          ),
        );
        return widget.isRootTab ? page : AuroraBackground(child: page);
      },
    );
  }

  // A sunken search well under the header, shown while searching.
  Widget _buildSearchField(AppLocalizations l10n) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 16, right: 6),
      decoration: NeoSurface.inset(),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: AppColors.textLight),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              cursorColor: AppColors.primary,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: l10n.myReportsSearchHint,
                hintStyle: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
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
              icon: Icon(Icons.clear_rounded,
                  size: 18, color: AppColors.textLight),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = "";
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _emptyBox(String placeholderText) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              color: AppColors.primary.withValues(alpha: 0.5), size: 48),
          const SizedBox(height: 12),
          Text(
            placeholderText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

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
    final l10n = AppLocalizations.of(context);
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

    // Contextual tags: only shown when they apply
    final onBehalfLabel = incident.isReportingOnBehalf
        ? l10n.reportForPerson(incident.victimName?.isNotEmpty == true
            ? incident.victimName!
            : l10n.commonRelative)
        : null;
    final etaLabel = incident.isInProgress &&
            incident.estimatedResponseTime != null &&
            incident.estimatedResponseTime!.isNotEmpty
        ? l10n.commonEta(incident.estimatedResponseTime!)
        : null;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: MyReportCard(
            storedCategory: incident.category,
            categoryLabel: LocalizedLabels.category(context, incident.category),
            location: displayLocation,
            time: formattedTime,
            statusLabel: LocalizedLabels.status(context, incident.status),
            statusColor: widget.statusColor,
            isSynced: incident.isSynced,
            syncLabel:
                incident.isSynced ? l10n.myReportsLive : l10n.myReportsLocal,
            onBehalfLabel: onBehalfLabel,
            etaLabel: etaLabel,
            blotterLabel: incident.isBlotter ? l10n.commonBlotterEntry : null,
            viewDetailsLabel: l10n.mapsViewDetails,
            highlight: incident.isInProgress,
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}
