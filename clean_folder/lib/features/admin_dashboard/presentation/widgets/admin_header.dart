import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_header_parts.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/broadcast_siren_parts.dart';
import 'package:community_safety_app/features/notifications/data/datasources/notification_service.dart';
import 'package:community_safety_app/features/notifications/data/models/notification_model.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/audit_log_remote_data_source.dart';
import 'package:community_safety_app/core/services/station_audio_service.dart';

class AdminHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;
  final bool isMobile;
  final ValueChanged<int>? onNavigate;
  final VoidCallback? onLogout;

  const AdminHeader({
    super.key,
    required this.title,
    required this.onMenuPressed,
    required this.isMobile,
    this.onNavigate,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          // Left: Toggle Menu and Title
          AdminHeaderButton(
            icon: isMobile ? Icons.menu_rounded : Icons.menu_open_rounded,
            onPressed: onMenuPressed,
            tooltip: isMobile ? null : "Toggle Sidebar",
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AdminColors.textStrong,
                letterSpacing: -0.2,
              ),
            ),
          ),
          SizedBox(width: 12),

          // Right: Emergency Siren, Notifications and Admin Profile
          // Emergency Broadcast Siren Button with Live Active Counter
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('broadcasts')
                .where('isActive', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              final activeDocs = snapshot.data?.docs ?? [];
              final hasActive = activeDocs.isNotEmpty;

              return AdminSirenButton(
                activeCount: activeDocs.length,
                compact: isMobile,
                onTap: () => _showBroadcastModal(context,
                    initialTab: hasActive ? 0 : 1),
              );
            },
          ),
          SizedBox(width: isMobile ? 10 : 12),

          // Interactive Dispatch Notifications Bell
          StreamBuilder<List<NotificationModel>>(
            stream: NotificationService().streamAdminNotifications(),
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? [];
              final unreadCount =
                  notifications.where((n) => !n.isRead).length;

              return AdminBellButton(
                unreadCount: unreadCount,
                onTap: () => _showAdminNotificationsModal(context),
              );
            },
          ),
          SizedBox(width: isMobile ? 10 : 12),

          // Interactive Admin Profile Dropdown Menu
          _buildAdminUserMenu(context),
        ],
      ),
    );
  }

  Widget _buildAdminUserMenu(BuildContext context) {
    final currentFirebaseUser = FirebaseAuth.instance.currentUser;
    final uid = currentFirebaseUser?.uid;

    if (uid == null) {
      return _renderUserPill(
        context,
        displayName: "Admin",
        email: "admin@safe.gov",
        photoUrl: null,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final rawName = data?['displayName'] as String?;
        final displayName = (rawName != null && rawName.trim().isNotEmpty)
            ? rawName
            : (currentFirebaseUser?.displayName?.trim().isNotEmpty == true
                ? currentFirebaseUser!.displayName!
                : (currentFirebaseUser?.email?.split('@').first ?? "Admin"));
        final email = (data?['email'] as String?) ??
            (currentFirebaseUser?.email ?? "admin@safe.gov");
        final photoUrl = (data?['photoUrl'] as String?) ??
            currentFirebaseUser?.photoURL;

        return _renderUserPill(
          context,
          displayName: displayName,
          email: email,
          photoUrl: photoUrl,
        );
      },
    );
  }

  Widget _renderUserPill(
    BuildContext context, {
    required String displayName,
    required String email,
    String? photoUrl,
  }) {
    final initial = displayName.trim().isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : (email.isNotEmpty ? email[0].toUpperCase() : 'A');

    return SizedBox(
      height: 44,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: PopupMenuButton<int>(
          tooltip: "Admin Account & Station Options",
          padding: EdgeInsets.zero,
          color: AdminColors.dialogBackground,
          elevation: 16,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          offset: const Offset(0, 52),
        onSelected: (val) {
          switch (val) {
            case 1:
              onNavigate?.call(6); // Navigate to Profile Settings
              break;
            case 2:
              StationAudioService.testAlertSound();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AdminColors.cardBackground,
                  behavior: SnackBarBehavior.floating,
                  content: Row(
                    children: [
                      Icon(Icons.volume_up_rounded,
                          color: AdminColors.success, size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Playing Station Alert Siren Test...",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
              break;
            case 3:
              onNavigate?.call(5); // Navigate to Admin Audit Logs
              break;
            case 4:
              onLogout?.call();
              break;
          }
        },
        itemBuilder: (context) => [
          // Header Card with Account Details
          PopupMenuItem<int>(
            enabled: false,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                AdminAvatar(
                  initial: initial,
                  photoUrl: photoUrl,
                  size: 42,
                  online: true,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          color: AdminColors.textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AdminColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                AdminColors.success.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                color: AdminColors.success, size: 11),
                            SizedBox(width: 4),
                            Text(
                              "Admin",
                              style: TextStyle(
                                color: AdminColors.success,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          // Option 1: Profile & Station Settings
          const PopupMenuItem<int>(
            value: 1,
            child: Row(
              children: [
                Icon(Icons.manage_accounts_outlined,
                    color: AdminColors.primary, size: 18),
                SizedBox(width: 12),
                Text(
                  "Profile Settings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Option 2: Test Station Audio
          const PopupMenuItem<int>(
            value: 2,
            child: Row(
              children: [
                Icon(Icons.volume_up_outlined,
                    color: AdminColors.success, size: 18),
                SizedBox(width: 12),
                Text(
                  "Test Station Audio",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Option 3: Admin Audit Logs
          const PopupMenuItem<int>(
            value: 3,
            child: Row(
              children: [
                Icon(Icons.history_toggle_off_rounded,
                    color: AdminColors.orange, size: 18),
                SizedBox(width: 12),
                Text(
                  "Admin Audit Logs",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          // Option 4: Log Out
          const PopupMenuItem<int>(
            value: 4,
            child: Row(
              children: [
                Icon(Icons.logout_rounded,
                    color: AdminColors.danger, size: 18),
                SizedBox(width: 12),
                Text(
                  "Log Out",
                  style: TextStyle(
                    color: AdminColors.danger,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
        child: AdminUserChip(
          displayName: displayName,
          initial: initial,
          photoUrl: photoUrl,
          compact: isMobile,
        ),
      ),
    ),
  );
}

  // Alert types and target sectors offered by the broadcast form.
  static const List<String> _alertTypes = [
    "Fire Alarm",
    "Flood Evacuation",
    "Earthquake Advisory",
    "Severe Weather",
    "Security Curfew",
    "General Notice",
  ];

  // Stored sector value → the shorter name shown in the picker.
  static const Map<String, String> _targetSectors = {
    "All Barangay Moonwalk": "All Moonwalk",
    "Area 1 - San Jose": "Area 1",
    "Area 2 - Airborne": "Area 2",
    "Area 3 - Multinational": "Area 3",
    "Area 4 - San Agustin": "Area 4",
    "Area 5 - Moonwalk Proper": "Area 5",
  };

  void _showBroadcastModal(BuildContext context, {int initialTab = 0}) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String alertType = "Fire Alarm";
    String targetSector = "All Barangay Moonwalk";
    bool isBroadcasting = false;
    int currentTab = initialTab;
    // One listener for the whole dialog, so picking an alert type next to
    // the list doesn't resubscribe it.
    final activeSirensStream = FirebaseFirestore.instance
        .collection('broadcasts')
        .where('isActive', isEqualTo: true)
        .snapshots();

    showDialog(
      context: context,
      barrierColor: const Color(0x99050810),
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> deleteRecord(String docId) async {
              await FirebaseFirestore.instance
                  .collection('broadcasts')
                  .doc(docId)
                  .delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AdminColors.cardBackground,
                    content: Text(
                      "Broadcast record deleted.",
                      style: TextStyle(color: Colors.white),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }

            Future<void> silenceSiren(
                String docId, String title, String sector) async {
              await FirebaseFirestore.instance
                  .collection('broadcasts')
                  .doc(docId)
                  .update({
                'isActive': false,
                'silencedAt': FieldValue.serverTimestamp(),
              });

              await sl<AuditLogRemoteDataSource>().recordLog(
                actionType: 'Emergency Siren',
                details: 'Silenced and cleared emergency siren broadcast: "$title" (Sector: $sector)',
                targetId: docId,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AdminColors.cardBackground,
                    content: Text(
                      "🚨 Siren '$title' silenced and removed from citizen devices!",
                      style: const TextStyle(
                          color: AdminColors.success,
                          fontWeight: FontWeight.bold),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }

            Future<void> transmitSiren() async {
              final title = titleController.text.trim();
              final message = messageController.text.trim();
              if (title.isEmpty) return;

              setDialogState(() => isBroadcasting = true);
              try {
                await FirebaseFirestore.instance
                    .collection('broadcasts')
                    .add({
                  'title': title,
                  'alertType': alertType,
                  'sector': targetSector,
                  'message': message,
                  'createdAt': FieldValue.serverTimestamp(),
                  'isActive': true,
                  'source':
                      'Barangay Moonwalk Command Center',
                });

                // Dispatch in-app notification to all citizens
                await NotificationService().sendNotification(
                  recipientId: 'all_residents',
                  title: '🚨 MUNICIPAL SIREN: $title',
                  message:
                      '[$alertType • $targetSector] ${message.isNotEmpty ? message : "Immediate safety precautions advised by authorities."}',
                  type: 'siren',
                );

                await sl<AuditLogRemoteDataSource>().recordLog(
                  actionType: 'Emergency Siren',
                  details: 'Transmitted emergency siren broadcast: "$title" [$alertType • $targetSector]',
                );

                if (context.mounted) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AdminColors.danger,
                      content: Text(
                        "🚨 Emergency Broadcast Dispatched to Barangay Moonwalk!",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                setDialogState(() => isBroadcasting = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red.shade900,
                      content: Text(
                          "Failed to dispatch broadcast: $e"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: BroadcastSirenPanel(
                tab: currentTab,
                onTabChanged: (tab) => setDialogState(() => currentTab = tab),
                onClose: () => Navigator.pop(dialogCtx),
                // ── Active Sirens List & Silence Controls ──
                activeSirens: (context, sideBySide) =>
                    StreamBuilder<QuerySnapshot>(
                  stream: activeSirensStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return SirensClearNotice(
                        onTransmitNew: sideBySide
                            ? null
                            : () => setDialogState(() => currentTab = 1),
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title =
                            data['title'] as String? ?? "Emergency Broadcast";
                        final type = data['alertType'] as String? ?? "Siren";
                        final sector =
                            data['sector'] as String? ?? "All Sectors";
                        final message = data['message'] as String? ?? "";
                        final createdAt = data['createdAt'] as Timestamp?;
                        final dateStr = createdAt != null
                            ? "${createdAt.toDate().hour > 12 ? createdAt.toDate().hour - 12 : (createdAt.toDate().hour == 0 ? 12 : createdAt.toDate().hour)}:${createdAt.toDate().minute.toString().padLeft(2, '0')} ${createdAt.toDate().hour >= 12 ? 'PM' : 'AM'}"
                            : "Just now";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ActiveSirenCard(
                            type: type,
                            title: title,
                            sector: sector,
                            message: message,
                            timeLabel: dateStr,
                            onSilence: () =>
                                silenceSiren(doc.id, title, sector),
                            onDelete: () => deleteRecord(doc.id),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                // ── Transmit New Siren Form ──
                transmitForm: BroadcastTransmitForm(
                  titleController: titleController,
                  messageController: messageController,
                  alertTypes: _alertTypes,
                  alertType: alertType,
                  onAlertTypeChanged: (v) =>
                      setDialogState(() => alertType = v),
                  sectors: _targetSectors,
                  sector: targetSector,
                  onSectorChanged: (v) =>
                      setDialogState(() => targetSector = v),
                  busy: isBroadcasting,
                  onTransmit: transmitSiren,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAdminNotificationsModal(BuildContext context) {
    final notificationService = NotificationService();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: AdminColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AdminColors.border, width: 1.5),
          ),
          child: Container(
            width: 520,
            constraints: const BoxConstraints(maxHeight: 650),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AdminColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AdminColors.primary
                                .withValues(alpha: 0.4)),
                      ),
                      child: Icon(Icons.notifications_active_rounded,
                          color: AdminColors.primary, size: 20),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "DISPATCH NOTIFICATIONS",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        notificationService.markAllAdminAsRead();
                      },
                      icon: Icon(Icons.done_all_rounded,
                          size: 16, color: AdminColors.textLight),
                      label: Text(
                        "Mark all read",
                        style: TextStyle(
                            color: AdminColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AdminColors.textLight),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: AdminColors.border, height: 1),
                SizedBox(height: 12),

                // Notifications Stream
                Flexible(
                  child: StreamBuilder<List<NotificationModel>>(
                    stream: notificationService.streamAdminNotifications(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                              color: AdminColors.primary),
                        );
                      }

                      final notifications = snapshot.data ?? [];
                      if (notifications.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.notifications_none_rounded,
                                    size: 48, color: AdminColors.textLight),
                                SizedBox(height: 12),
                                Text(
                                  "No Dispatch Alerts",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Incoming citizen reports and emergency broadcasts will appear here in real-time.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AdminColors.textLight,
                                      fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: notifications.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          final isUnread = !item.isRead;

                          return InkWell(
                            onTap: () {
                              if (!item.isRead) {
                                notificationService.markAsRead(item.id);
                              }
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isUnread
                                    ? AdminColors.rowActive
                                    : AdminColors.rowIdle,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isUnread
                                      ? AdminColors.primary
                                          .withValues(alpha: 0.5)
                                      : AdminColors.border,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AdminColors.primary
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.campaign_rounded,
                                        color: AdminColors.primary, size: 18),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            color: isUnread
                                                ? Colors.white
                                                : AdminColors.textDark,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          item.message,
                                          style: const TextStyle(
                                            color: AdminColors.textLight,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close,
                                        size: 16, color: AdminColors.textLight),
                                    onPressed: () {
                                      notificationService
                                          .deleteNotification(item.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
