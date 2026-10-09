import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../widgets/custom_3d_card.dart';
import '../services/mock_database_service.dart';

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
                  _SearchButton(),
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
                      text: "Resolve",
                      selected: selectedFilter == "Resolve",
                      color: AppColors.solved,
                      onTap: () =>
                          setState(() => selectedFilter = "Resolve"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Report List ──────────────────────────────────────────────
              Expanded(
                child: ListenableBuilder(
                  listenable: MockDatabaseService(),
                  builder: (context, _) {
                    final currentUser =
                        MockDatabaseService().currentUser;
                    if (currentUser == null) {
                      return const Center(
                        child: Text(
                          "Not logged in.",
                          style: TextStyle(color: AppColors.textLight),
                        ),
                      );
                    }

                    final allReports = MockDatabaseService().reports;
                    final myReports = allReports
                        .where((r) =>
                            r.reporterName == currentUser.name &&
                            !r.isArchived)
                        .toList();
                    myReports.sort((a, b) => b.date.compareTo(a.date));

                    final filteredReports = myReports.where((r) {
                      if (selectedFilter == "ALL") return true;
                      if (selectedFilter == "Pending")
                        return r.statusLabel.toLowerCase() == "pending";
                      if (selectedFilter == "In Progress")
                        return r.statusLabel.toLowerCase() == "in progress";
                      if (selectedFilter == "Resolve")
                        return r.statusLabel.toLowerCase() == "solved";
                      return true;
                    }).toList();

                    if (filteredReports.isEmpty) {
                      return ListView(
                        children: [_emptyBox("No reports found under this status filter.")],
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        final dateStr =
                            "${report.date.month}/${report.date.day}/${report.date.year}";
                        return _AnimatedReportCard(
                          delay: Duration(milliseconds: 60 * index),
                          title: report.incidentType,
                          time: dateStr,
                          status: report.statusLabel,
                          statusColor: report.statusColor,
                          location: report.location,
                        );
                      },
                    );
                  },
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
    final statusClr = AppColors.statusColor(widget.status);
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
                        Text(
                          widget.location,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textLight),
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
                  widget.status,
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