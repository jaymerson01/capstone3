import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/injection_container.dart';
import '../services/fcm_service.dart';
import '../services/station_audio_service.dart';

class EmergencyBroadcastListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;
  const EmergencyBroadcastListener({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  @override
  State<EmergencyBroadcastListener> createState() =>
      _EmergencyBroadcastListenerState();
}

class _EmergencyBroadcastListenerState
    extends State<EmergencyBroadcastListener> {
  StreamSubscription<QuerySnapshot>? _broadcastSubscription;
  final Set<String> _dismissedBroadcastIds = {};
  bool _isDialogShowing = false;
  BuildContext? _activeDialogContext;
  String? _activeDialogBroadcastId;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _broadcastSubscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    _broadcastSubscription = FirebaseFirestore.instance
        .collection('broadcasts')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen(
      (snapshot) {
        if (!mounted) return;

        // Auto-dismiss active siren dialog if admin silenced or deleted it
        if (_isDialogShowing && _activeDialogBroadcastId != null) {
          final stillActive =
              snapshot.docs.any((d) => d.id == _activeDialogBroadcastId);
          if (!stillActive) {
            if (_activeDialogContext != null && _activeDialogContext!.mounted) {
              Navigator.of(_activeDialogContext!).pop();
            }
            _isDialogShowing = false;
            _activeDialogBroadcastId = null;
            _activeDialogContext = null;
          }
        }

        if (snapshot.docs.isEmpty) return;

        // Sort by timestamp descending
        final sortedDocs = List<QueryDocumentSnapshot>.from(snapshot.docs);
        sortedDocs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['createdAt'] as Timestamp? ?? Timestamp.now();
          final bTime = bData['createdAt'] as Timestamp? ?? Timestamp.now();
          return bTime.compareTo(aTime);
        });

        for (final doc in sortedDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final broadcastId = doc.id;

          if (!_dismissedBroadcastIds.contains(broadcastId) &&
              !_isDialogShowing) {
            _showEmergencySirenDialog(broadcastId, data);
            break;
          }
        }
      },
      onError: (e) {
        debugPrint("Error listening to emergency broadcasts: $e");
      },
    );
  }

  Future<void> _triggerSirenHaptics() async {
    for (int i = 0; i < 4; i++) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 180));
    }
  }

  void _showEmergencySirenDialog(
      String broadcastId, Map<String, dynamic> data) async {
    _isDialogShowing = true;
    _activeDialogBroadcastId = broadcastId;
    _triggerSirenHaptics();

    final title = data['title'] as String? ?? "MUNICIPAL EMERGENCY ADVISORY";
    final alertType = data['alertType'] as String? ?? "Emergency Siren";
    final sector = data['sector'] as String? ?? "All Sectors";
    final message = data['message'] as String? ??
        "Immediate safety precautions are advised by Barangay authorities.";
    final source =
        data['source'] as String? ?? "Barangay Command Center";

    final now = DateTime.now();
    final timeStr =
        "${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    // Also trigger system heads-up floating notification, vibration & siren chime
    try {
      sl<FCMService>().showLocalNotification(
        title: "🚨 $alertType: $title",
        body: "[$sector] $message",
      );
      StationAudioService.playAlertSound();
    } catch (_) {}


    final targetContext = widget.navigatorKey?.currentContext ??
        Navigator.maybeOf(context)?.context ??
        context;

    if (!mounted) {
      _isDialogShowing = false;
      _activeDialogBroadcastId = null;
      return;
    }

    try {
      await showGeneralDialog(
        context: targetContext,
        barrierDismissible: false,
        barrierLabel: "Emergency Siren Alert",
        barrierColor: Colors.black.withValues(alpha: 0.85),
        transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogContext, anim1, anim2) {
        _activeDialogContext = dialogContext;
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1627),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFF3B30), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.4),
                    blurRadius: 36,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pulsing Siren Header
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              const Color(0xFFFF3B30).withValues(alpha: 0.15),
                          border: Border.all(
                              color: const Color(0xFFFF3B30), width: 2),
                        ),
                        child: const Icon(
                          Icons.crisis_alert_rounded,
                          color: Color(0xFFFF3B30),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFF3B30).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFFF3B30)
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFF3B30),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "MUNICIPAL EMERGENCY SIREN",
                              style: TextStyle(
                                color: Color(0xFFFF3B30),
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF060D1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E2D4A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.warning_rounded,
                                        size: 16, color: Color(0xFFFF9500)),
                                    const SizedBox(width: 6),
                                    Text(
                                      alertType,
                                      style: const TextStyle(
                                        color: Color(0xFFFF9500),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                    color: Color(0xFF7B8DB0),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.place_outlined,
                                    size: 15, color: Color(0xFF0A84FF)),
                                const SizedBox(width: 6),
                                Text(
                                  "Target Sector: $sector",
                                  style: const TextStyle(
                                    color: Color(0xFF0A84FF),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                                color: Color(0xFF1E2D4A), height: 20),
                            Text(
                              message,
                              style: const TextStyle(
                                color: Color(0xFFE8F0FE),
                                fontSize: 13.5,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Origin: $source",
                              style: const TextStyle(
                                color: Color(0xFF7B8DB0),
                                fontSize: 10.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF3B30),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.check_circle_outline,
                                  size: 18),
                              label: const Text(
                                "ACKNOWLEDGE ALERT",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              onPressed: () {
                                _dismissedBroadcastIds.add(broadcastId);
                                Navigator.pop(dialogContext);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
    } catch (e) {
      debugPrint("🚨 [EmergencyBroadcast] Error showing siren dialog: $e");
    } finally {
      _isDialogShowing = false;
      _activeDialogContext = null;
      _activeDialogBroadcastId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
