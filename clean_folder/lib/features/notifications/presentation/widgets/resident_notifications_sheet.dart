import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../incident/data/models/incident_model.dart';
import '../../../incident/presentation/pages/incident_detail_page.dart';
import '../../data/datasources/notification_service.dart';
import '../../data/models/notification_model.dart';

class ResidentNotificationsSheet extends StatelessWidget {
  final String userId;

  const ResidentNotificationsSheet({super.key, required this.userId});

  static void show(BuildContext context, {required String userId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResidentNotificationsSheet(userId: userId),
    );
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${dt.month}/${dt.day}/${dt.year}";
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'status_change':
        return const Color(0xFF0A84FF); // Azure blue
      case 'upvote':
        return const Color(0xFFFF9500); // Amber
      case 'siren':
        return const Color(0xFFFF3B30); // Crimson red
      case 'new_report':
        return const Color(0xFF30D158); // Green
      default:
        return AppColors.primary; // Cyan
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'status_change':
        return Icons.sync_alt_rounded;
      case 'upvote':
        return Icons.thumb_up_alt_rounded;
      case 'siren':
        return Icons.crisis_alert_rounded;
      case 'new_report':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1627),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF1E2D4A), width: 1.5),
          left: BorderSide(color: Color(0xFF1E2D4A), width: 1),
          right: BorderSide(color: Color(0xFF1E2D4A), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2A3D63),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "NOTIFICATIONS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    notificationService.markAllResidentAsRead(userId);
                  },
                  icon: const Icon(Icons.done_all_rounded,
                      size: 16, color: Color(0xFF7B8DB0)),
                  label: const Text(
                    "Mark all read",
                    style: TextStyle(
                      color: Color(0xFF7B8DB0),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF1E2D4A), height: 1),

          // Notification List
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: notificationService.streamResidentNotifications(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E2D4A).withValues(alpha: 0.4),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              size: 48,
                              color: Color(0xFF7B8DB0),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No Notifications Yet",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "You will be alerted when dispatch updates your reports, neighbors corroborate incidents, or community sirens sound.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF7B8DB0),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    final color = _getTypeColor(item.type);
                    final icon = _getTypeIcon(item.type);
                    final timeStr = _formatRelativeTime(item.createdAt);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          // Mark as read
                          if (!item.isRead) {
                            notificationService.markAsRead(item.id);
                          }

                          // If linked to an incident, navigate to its details
                          if (item.incidentId != null &&
                              item.incidentId!.isNotEmpty) {
                            try {
                              final doc = await FirebaseFirestore.instance
                                  .collection('incidents')
                                  .doc(item.incidentId)
                                  .get();

                              if (doc.exists && context.mounted) {
                                final incident =
                                    IncidentModel.fromFirestore(doc);
                                Navigator.pop(context); // Close bottom sheet
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => IncidentDetailPage(
                                      initialIncident: incident,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint("Error opening incident details: $e");
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item.isRead
                                ? const Color(0xFF080F1E)
                                : const Color(0xFF101C33),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: item.isRead
                                  ? const Color(0xFF1E2D4A)
                                  : color.withValues(alpha: 0.6),
                              width: item.isRead ? 1 : 1.5,
                            ),
                            boxShadow: item.isRead
                                ? null
                                : [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon container
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              const SizedBox(width: 12),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              color: item.isRead
                                                  ? const Color(0xFFE8F0FE)
                                                  : Colors.white,
                                              fontWeight: item.isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (!item.isRead) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: color,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: color.withValues(alpha: 0.8),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.message,
                                      style: TextStyle(
                                        color: item.isRead
                                            ? const Color(0xFF7B8DB0)
                                            : const Color(0xFFC0CDF0),
                                        fontSize: 12.5,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 12,
                                          color: const Color(0xFF7B8DB0),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          timeStr,
                                          style: const TextStyle(
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 11,
                                          ),
                                        ),
                                        if (item.incidentId != null &&
                                            item.incidentId!.isNotEmpty) ...[
                                          const Spacer(),
                                          Text(
                                            "View report →",
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Delete button
                              IconButton(
                                icon: const Icon(Icons.close,
                                    size: 16, color: Color(0xFF7B8DB0)),
                                onPressed: () {
                                  notificationService.deleteNotification(item.id);
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: "Remove",
                              ),
                            ],
                          ),
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
    );
  }
}
