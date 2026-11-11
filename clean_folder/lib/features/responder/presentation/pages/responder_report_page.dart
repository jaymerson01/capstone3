import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/services/camera_service.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/utils/moonwalk_area.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/features/responder/data/responder_repository.dart';
import 'package:community_safety_app/features/responder/presentation/pages/responder_home_page.dart';

/// One report in the responder portal: where it is, what happened, who to
/// call, and the buttons to accept it and report progress. While the
/// responder is on the way, their position is shared with the reporter and
/// the admin desk.
class ResponderReportPage extends StatefulWidget {
  const ResponderReportPage({super.key, required this.reportId, required this.user, required this.repository});

  final String reportId;
  final UserEntity user;
  final ResponderRepository repository;

  @override
  State<ResponderReportPage> createState() => _ResponderReportPageState();
}

class _ResponderReportPageState extends State<ResponderReportPage> {
  late final Stream<IncidentModel?> _report = widget.repository.watchReport(widget.reportId);
  final TextEditingController _notes = TextEditingController();
  Future<Map<String, dynamic>?>? _contact;
  StreamSubscription<Position>? _sharing;
  DateTime? _lastShared;
  bool _busy = false;
  bool _notesLoaded = false;

  String get _name => widget.user.displayName ?? widget.user.email;

  @override
  void dispose() {
    _sharing?.cancel();
    _notes.dispose();
    super.dispose();
  }

  bool _isMine(IncidentModel report) => report.assignedResponderId == widget.user.id;

  /// Shares the position only while this responder is on the way.
  void _syncSharing(IncidentModel report) {
    final share = _isMine(report) && !report.isSolved && report.responderStatus == ResponderStatus.onTheWay;
    if (share && _sharing == null) {
      _sharing = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 20),
      ).listen((position) {
        final last = _lastShared;
        if (last != null && DateTime.now().difference(last) < const Duration(seconds: 15)) return;
        _lastShared = DateTime.now();
        widget.repository
            .shareLocation(report.id, position.latitude, position.longitude, name: _name)
            .catchError((Object e) => debugPrint('[Responder] Sharing location failed: $e'));
      }, onError: (Object e) => debugPrint('[Responder] Location stream: $e'));
    } else if (!share && _sharing != null) {
      _sharing!.cancel();
      _sharing = null;
      _lastShared = null;
    }
  }

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    setState(() => _busy = true);
    try {
      await action();
      if (done != null && mounted) _toast(done, AdminColors.success);
    } on StateError {
      if (mounted) _toast('Another responder already took this report.', AdminColors.amber);
    } catch (e) {
      if (mounted) _toast("Couldn't save that: $e", AdminColors.critical);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _onTheWay(IncidentModel report) async {
    // Asked here, on the button tap, so the browser shows its permission prompt.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (mounted) _toast('Location is off, so the reporter won\'t see you on the map.', AdminColors.amber);
    }
    await _run(
      () => widget.repository.setProgress(report, ResponderStatus.onTheWay, name: _name),
      done: 'On the way. The reporter can follow you on the map.',
    );
  }

  Future<void> _resolve(IncidentModel report) async {
    final notes = TextEditingController(text: _notes.text);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AdminDialog(
        title: 'Mark as resolved?',
        icon: Icons.task_alt_rounded,
        tone: AdminTone.green,
        maxWidth: 440,
        actions: [
          AdminButton(label: 'Cancel', style: AdminButtonStyle.ghost, onPressed: () => Navigator.pop(ctx, false)),
          AdminButton(label: 'Resolved', icon: Icons.check_rounded, onPressed: () => Navigator.pop(ctx, true)),
        ],
        child: TextField(
          controller: notes,
          maxLines: 4,
          style: adminInputText,
          decoration: adminInputDecoration(hint: 'What was done? (shared with the admin desk)'),
        ),
      ),
    );
    if (confirmed != true) return;
    await _run(() => widget.repository.resolve(report, name: _name, notes: notes.text), done: 'Report resolved.');
  }

  Future<void> _addPhoto(IncidentModel report) async {
    final camera = sl<CameraService>();
    final file = await camera.pickImageFromCamera();
    if (file == null) return;
    await _run(() async {
      final url = await camera.uploadImage(file);
      if (!url.startsWith('http')) throw Exception('the photo could not be uploaded');
      await widget.repository.savePhoto(report.id, url);
    }, done: 'Photo added.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        foregroundColor: AdminColors.textStrong,
        elevation: 0,
        title: const Text('Report'),
      ),
      body: StreamBuilder<IncidentModel?>(
        stream: _report,
        builder: (context, snapshot) {
          final report = snapshot.data;
          if (snapshot.hasError) {
            return AdminEmptyState(icon: Icons.error_outline, title: "Couldn't load the report", message: '${snapshot.error}');
          }
          if (report == null) {
            return snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator(color: AdminColors.cyan))
                : const AdminEmptyState(icon: Icons.search_off_rounded, title: 'This report no longer exists');
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _syncSharing(report);
          });
          if (_isMine(report)) {
            _contact ??= widget.repository.contactFor(report.id);
            if (!_notesLoaded) {
              _notes.text = report.responderNotes ?? '';
              _notesLoaded = true;
            }
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  _summary(report),
                  const SizedBox(height: 12),
                  _map(report),
                  const SizedBox(height: 12),
                  _details(report),
                  const SizedBox(height: 12),
                  _reporter(report),
                  const SizedBox(height: 12),
                  _actions(report),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summary(IncidentModel report) {
    final critical = (report.urgencyStatus ?? '').toUpperCase() == 'CRITICAL';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(report.category, style: const TextStyle(color: AdminColors.textStrong, fontSize: 21, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('${report.ticketNumber} · ${timeAgo(report.timestamp)}',
            style: const TextStyle(color: AdminColors.textHint, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          AdminPill(label: (report.urgencyStatus ?? 'NORMAL').toUpperCase(), tone: critical ? AdminTone.red : AdminTone.slate),
          AdminPill(label: progressLabel(report), tone: progressTone(report)),
          for (final d in report.departments) AdminPill(label: d.label, tone: AdminTone.blue, icon: d.icon),
        ]),
      ],
    );
  }

  Widget _map(IncidentModel report) {
    final target = LatLng(report.latitude, report.longitude);
    return AdminPanel(
      padding: EdgeInsets.zero,
      radius: 18,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 260,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: target, zoom: 16.5),
                cameraTargetBounds: MoonwalkArea.cameraBounds,
                minMaxZoomPreference: MoonwalkArea.zoomRange,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                markers: {
                  Marker(
                    markerId: const MarkerId('report'),
                    position: target,
                    infoWindow: InfoWindow(title: report.category, snippet: report.resolvedAddress),
                  ),
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: AdminButton(
              label: 'Directions',
              icon: Icons.directions_rounded,
              expand: true,
              onPressed: () => launchUrl(
                Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${report.latitude},${report.longitude}'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _details(IncidentModel report) {
    return AdminPanel(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDetailRow(label: 'Where', value: report.resolvedAddress ?? report.areaSector ?? 'Barangay Moonwalk', labelWidth: 90),
          AdminDetailRow(label: 'Area', value: report.areaSector ?? '—', labelWidth: 90),
          const SizedBox(height: 8),
          Text(report.description, style: const TextStyle(color: AdminColors.textBody, fontSize: 14, height: 1.5)),
          if ((report.photoUrl ?? '').startsWith('http')) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(report.photoUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          if ((report.videoUrl ?? '').startsWith('http'))
            TextButton.icon(
              onPressed: () => launchUrl(Uri.parse(report.videoUrl!), mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Play the video'),
            ),
        ],
      ),
    );
  }

  Widget _reporter(IncidentModel report) {
    if (!_isMine(report)) {
      return const AdminInset(
        tone: AdminTone.slate,
        child: Text("The reporter's name and phone show once the report is yours.",
            style: TextStyle(color: AdminColors.textSoft, fontSize: 13)),
      );
    }
    return FutureBuilder<Map<String, dynamic>?>(
      future: _contact,
      builder: (context, snapshot) {
        final contact = snapshot.data ?? const {};
        final phone = (contact['reporterPhone'] ?? contact['victimPhone']) as String?;
        return AdminPanel(
          padding: const EdgeInsets.all(16),
          radius: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('REPORTER', style: TextStyle(color: AdminColors.textHint, fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1)),
              const SizedBox(height: 6),
              if (snapshot.connectionState == ConnectionState.waiting)
                const LinearProgressIndicator(color: AdminColors.cyan)
              else ...[
                AdminDetailRow(label: 'Name', value: (contact['reporterName'] as String?) ?? '—', labelWidth: 90),
                AdminDetailRow(label: 'Email', value: (contact['reporterEmail'] as String?) ?? '—', labelWidth: 90),
                if (report.isReportingOnBehalf)
                  AdminDetailRow(label: 'Victim', value: (contact['victimName'] as String?) ?? '—', labelWidth: 90),
                const SizedBox(height: 8),
                AdminButton(
                  label: phone == null || phone.isEmpty ? 'No phone number on file' : 'Call $phone',
                  icon: Icons.call_rounded,
                  style: AdminButtonStyle.cyan,
                  expand: true,
                  onPressed: phone == null || phone.isEmpty ? null : () => launchUrl(Uri(scheme: 'tel', path: phone)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _actions(IncidentModel report) {
    if (report.isSolved) {
      return AdminInset(
        tone: AdminTone.green,
        child: Text(
          'Resolved${report.assignedResponderName == null ? '' : ' by ${report.assignedResponderName}'}.',
          style: const TextStyle(color: AdminColors.textDark, fontSize: 13.5),
        ),
      );
    }
    if (report.assignedResponderId == null) {
      return AdminButton(
        label: 'Accept this report',
        icon: Icons.assignment_turned_in_rounded,
        expand: true,
        height: 54,
        busy: _busy,
        onPressed: () => _run(
          () => widget.repository.accept(report, uid: widget.user.id, name: _name),
          done: 'Accepted. It\'s now in "Assigned to me".',
        ),
      );
    }
    if (!_isMine(report)) {
      return AdminInset(
        tone: AdminTone.slate,
        child: Text('Assigned to ${report.assignedResponderName ?? 'another responder'}.',
            style: const TextStyle(color: AdminColors.textSoft, fontSize: 13)),
      );
    }

    final status = report.responderStatus;
    return AdminPanel(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (status == ResponderStatus.onTheWay)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Icon(Icons.share_location_rounded, color: AdminColors.cyan, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Sharing your location with the reporter while you\'re on the way. Keep this page open.',
                      style: TextStyle(color: AdminColors.cyanText, fontSize: 12.5)),
                ),
              ]),
            ),
          if (status == null)
            AdminButton(
              label: "I'm on the way",
              icon: Icons.directions_run_rounded,
              expand: true,
              height: 52,
              busy: _busy,
              onPressed: () => _onTheWay(report),
            ),
          if (status == ResponderStatus.onTheWay)
            AdminButton(
              label: "I'm on the scene",
              icon: Icons.location_on_rounded,
              expand: true,
              height: 52,
              busy: _busy,
              onPressed: () => _run(
                () => widget.repository.setProgress(report, ResponderStatus.onScene, name: _name),
                done: 'On the scene.',
              ),
            ),
          const SizedBox(height: 10),
          AdminButton(
            label: 'Mark resolved',
            icon: Icons.task_alt_rounded,
            style: AdminButtonStyle.slate,
            expand: true,
            onPressed: _busy ? null : () => _resolve(report),
          ),
          const SizedBox(height: 16),
          const AdminFieldLabel('NOTES FOR THE ADMIN DESK'),
          TextField(
            controller: _notes,
            maxLines: 3,
            style: adminInputText,
            decoration: adminInputDecoration(hint: 'What you found, what you did…'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AdminButton(
                  label: 'Save notes',
                  icon: Icons.save_outlined,
                  style: AdminButtonStyle.ghost,
                  onPressed: _busy ? null : () => _run(() => widget.repository.saveNotes(report.id, _notes.text), done: 'Notes saved.'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AdminButton(
                  label: report.responderPhotoUrl == null ? 'Add photo' : 'Replace photo',
                  icon: Icons.photo_camera_outlined,
                  style: AdminButtonStyle.ghost,
                  onPressed: _busy ? null : () => _addPhoto(report),
                ),
              ),
            ],
          ),
          if ((report.responderPhotoUrl ?? '').startsWith('http')) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(report.responderPhotoUrl!, height: 160, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
        ],
      ),
    );
  }
}
