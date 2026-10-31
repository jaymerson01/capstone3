import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_safety_app/core/widgets/emergency_siren_alert.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';
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
  StreamSubscription<User?>? _authSubscription;
  final Set<String> _dismissedBroadcastIds = {};
  bool _isDialogShowing = false;
  BuildContext? _activeDialogContext;
  String? _activeDialogBroadcastId;

  @override
  void initState() {
    super.initState();
    _initAndListen();
  }

  Future<void> _initAndListen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('resq_dismissed_broadcasts') ?? [];
      _dismissedBroadcastIds.addAll(saved);
    } catch (_) {}
    if (mounted) {
      _startListening();
      // Listen to auth changes so the stream automatically attaches when a user logs in
      _authSubscription?.cancel();
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
        if (mounted) {
          debugPrint("🔔 [EmergencyBroadcastListener] Auth state changed (${user?.uid ?? 'guest'}), refreshing stream");
          _startListening();
        }
      });
    }
  }

  Future<void> _recordDismissal(String broadcastId) async {
    _dismissedBroadcastIds.add(broadcastId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('resq_dismissed_broadcasts', _dismissedBroadcastIds.toList());
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _broadcastSubscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    _broadcastSubscription?.cancel();
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

          // Check if broadcast was created recently (within last 15 minutes)
          // If createdAt is null, it was just created with FieldValue.serverTimestamp()
          final dynamic rawTime = data['createdAt'];
          DateTime? createdDate;
          if (rawTime is Timestamp) {
            createdDate = rawTime.toDate();
          } else if (rawTime is String) {
            createdDate = DateTime.tryParse(rawTime);
          }
          final isRecent = createdDate == null ||
              createdDate.isAfter(
                  DateTime.now().subtract(const Duration(minutes: 15)));

          if (!_dismissedBroadcastIds.contains(broadcastId) &&
              !_isDialogShowing) {
            if (isRecent) {
              _showEmergencySirenDialog(broadcastId, data);
              break;
            } else {
              // Stale broadcast from past session - auto-dismiss so it won't alert on app launch
              _recordDismissal(broadcastId);
            }
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

    final title = data['title'] as String? ?? AppLocalizations.of(context).broadcastDefaultTitle;
    final alertType = data['alertType'] as String? ?? AppLocalizations.of(context).broadcastDefaultType;
    final sector = data['sector'] as String? ?? AppLocalizations.of(context).dashboardAllSectors;
    final message = data['message'] as String? ??
        AppLocalizations.of(context).broadcastDefaultMessage;
    final source =
        data['source'] as String? ?? AppLocalizations.of(context).broadcastDefaultSource;

    final now = DateTime.now();
    final timeStr =
        "${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    // Defer dialog display to post-frame to ensure Navigator is mounted and frame build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) {
        _isDialogShowing = false;
        _activeDialogBroadcastId = null;
        return;
      }

      final navState = widget.navigatorKey?.currentState ??
          Navigator.maybeOf(context);

      if (navState != null && navState.mounted) {
        try {
          await navState.push(
            RawDialogRoute(
              barrierDismissible: false,
              barrierLabel: AppLocalizations.of(context).broadcastBarrierLabel,
              barrierColor: Colors.black.withValues(alpha: 0.85),
              transitionDuration: const Duration(milliseconds: 350),
              pageBuilder: (dialogContext, anim1, anim2) {
                _activeDialogContext = dialogContext;
                final l10n = AppLocalizations.of(dialogContext);
                return PopScope(
                  canPop: false,
                  child: EmergencySirenAlert(
                    header: l10n.broadcastHeader,
                    alertType: alertType,
                    title: title,
                    message: message,
                    targetLabel: l10n.broadcastTargetSector(sector),
                    originLabel: l10n.broadcastOrigin(source),
                    timeLabel: timeStr,
                    acknowledgeLabel: l10n.broadcastAcknowledge,
                    onAcknowledge: () {
                      _recordDismissal(broadcastId);
                      Navigator.pop(dialogContext);
                    },
                  ),
                );
              },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    ),
  );
        } catch (e) {
          debugPrint("🚨 [EmergencyBroadcast] Error showing siren dialog: $e");
        } finally {
          _isDialogShowing = false;
          _activeDialogContext = null;
          _activeDialogBroadcastId = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
