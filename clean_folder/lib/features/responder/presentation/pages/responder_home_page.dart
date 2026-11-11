import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/core/services/station_audio_service.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/utils/departments.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/responder/data/responder_repository.dart';
import 'package:community_safety_app/features/responder/presentation/pages/responder_report_page.dart';

enum _Tab { mine, queue, done }

/// The responder's reports: assigned to them, their department's queue, and
/// the ones they resolved. A chime sounds when a new report arrives.
class ResponderHomePage extends StatefulWidget {
  const ResponderHomePage({super.key, required this.user, this.repository});

  final UserEntity user;
  final ResponderRepository? repository;

  @override
  State<ResponderHomePage> createState() => _ResponderHomePageState();
}

class _ResponderHomePageState extends State<ResponderHomePage> {
  late final ResponderRepository _repository = widget.repository ?? ResponderRepository();
  late final Department? _department = Department.fromId(widget.user.department);
  StreamSubscription<List<IncidentModel>>? _subscription;
  List<IncidentModel>? _reports;
  Object? _error;
  Set<String>? _seen;
  _Tab _tab = _Tab.mine;

  @override
  void initState() {
    super.initState();
    final department = _department;
    if (department == null) return;
    // One subscription feeds both the lists and the new-report chime.
    _subscription = _repository.streamReports(department, widget.user.id).listen(
      (reports) {
        if (!mounted) return;
        setState(() {
          _reports = reports;
          _error = null;
        });
        _announceArrivals(reports);
      },
      onError: (Object e) {
        if (mounted) setState(() => _error = e);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _announceArrivals(List<IncidentModel> reports) {
    final open = reports.where((r) => !r.isSolved).map((r) => r.id).toSet();
    final seen = _seen;
    _seen = {...?seen, ...open};
    if (seen == null) return; // the first list is what was already there
    final fresh = reports.where((r) => open.contains(r.id) && !seen.contains(r.id)).toList();
    if (fresh.isEmpty || !mounted) return;
    StationAudioService.playAlertSound();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AdminColors.cardBackground,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 8),
      content: Text(
        'New report: ${fresh.first.category} · ${fresh.first.areaSector ?? fresh.first.resolvedAddress ?? ''}',
        style: const TextStyle(color: AdminColors.textStrong, fontWeight: FontWeight.w700),
      ),
      action: SnackBarAction(label: 'OPEN', onPressed: () => _open(fresh.first)),
    ));
  }

  void _open(IncidentEntity report) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ResponderReportPage(reportId: report.id, user: widget.user, repository: _repository),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final department = _department;
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(user: widget.user, department: department),
                if (department == null)
                  const Expanded(
                    child: AdminEmptyState(
                      icon: Icons.domain_disabled_outlined,
                      title: 'No department on this account',
                      message: 'Ask the super admin to set your department in User Management.',
                    ),
                  )
                else
                  Expanded(
                    child: _error != null
                        ? AdminEmptyState(icon: Icons.error_outline, title: "Couldn't load reports", message: '$_error')
                        : _reports == null
                            ? const Center(child: CircularProgressIndicator(color: AdminColors.cyan))
                            : _buildLists(_reports!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLists(List<IncidentModel> reports) {
    final uid = widget.user.id;
    final mine = reports.where((r) => r.assignedResponderId == uid && !r.isSolved).toList();
    final queue = reports.where((r) => r.assignedResponderId != uid && !r.isSolved).toList()
      ..sort((a, b) => (a.assignedResponderId == null ? 0 : 1).compareTo(b.assignedResponderId == null ? 0 : 1));
    final done = reports.where((r) => r.assignedResponderId == uid && r.isSolved).toList();
    final shown = switch (_tab) { _Tab.mine => mine, _Tab.queue => queue, _Tab.done => done };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: AdminSegmented<_Tab>(
              segments: [
                (_Tab.mine, 'Assigned to me (${mine.length})'),
                (_Tab.queue, 'Department queue (${queue.length})'),
                (_Tab.done, 'Done (${done.length})'),
              ],
              value: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? AdminEmptyState(
                  icon: Icons.inbox_outlined,
                  title: switch (_tab) {
                    _Tab.mine => 'Nothing assigned to you',
                    _Tab.queue => 'No open reports for your department',
                    _Tab.done => 'No resolved reports yet',
                  },
                  message: _tab == _Tab.mine ? 'Accept a report from the department queue.' : null,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: shown.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ReportCard(report: shown[i], uid: uid, onTap: () => _open(shown[i])),
                ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user, required this.department});

  final UserEntity user;
  final Department? department;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          ClipOval(child: Image.asset('assets/images/logo.png', width: 38, height: 38)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AdminColors.textStrong, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  department == null ? 'ResQ Responder' : 'ResQ Responder · ${department!.label}',
                  style: const TextStyle(color: AdminColors.textHint, fontSize: 12.5),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded, color: AdminColors.textHint),
            onPressed: () => context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.uid, required this.onTap});

  final IncidentEntity report;
  final String uid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final critical = (report.urgencyStatus ?? '').toUpperCase() == 'CRITICAL';
    final takenBySomeoneElse = report.assignedResponderId != null && report.assignedResponderId != uid;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AdminPanel(
        padding: const EdgeInsets.all(14),
        radius: 18,
        accent: critical ? AdminColors.danger : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.category,
                    style: const TextStyle(color: AdminColors.textStrong, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
                AdminPill(
                  label: (report.urgencyStatus ?? 'NORMAL').toUpperCase(),
                  tone: critical ? AdminTone.red : AdminTone.slate,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${report.ticketNumber} · ${timeAgo(report.timestamp)}'
              '${report.reporterVerified == false ? ' · Unverified reporter' : ''}',
              style: const TextStyle(color: AdminColors.textHint, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 15, color: AdminColors.textHint),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.resolvedAddress ?? report.areaSector ?? 'Barangay Moonwalk',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AdminColors.textSoft, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                AdminPill(label: progressLabel(report), tone: progressTone(report)),
                if (takenBySomeoneElse)
                  AdminPill(label: 'Assigned to ${report.assignedResponderName ?? 'another responder'}', tone: AdminTone.slate),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "5 min ago", "2 h ago", "3 d ago".
String timeAgo(DateTime time, {DateTime? now}) {
  final d = (now ?? DateTime.now()).difference(time);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  return '${d.inDays} d ago';
}

String progressLabel(IncidentEntity report) {
  if (report.isSolved) return 'Resolved';
  return switch (report.responderStatus) {
    ResponderStatus.onTheWay => 'On the way',
    ResponderStatus.onScene => 'On the scene',
    _ => report.assignedResponderId == null ? 'Waiting for a responder' : 'Accepted',
  };
}

AdminTone progressTone(IncidentEntity report) {
  if (report.isSolved) return AdminTone.green;
  return switch (report.responderStatus) {
    ResponderStatus.onTheWay => AdminTone.cyan,
    ResponderStatus.onScene => AdminTone.violet,
    _ => report.assignedResponderId == null ? AdminTone.orange : AdminTone.blue,
  };
}
