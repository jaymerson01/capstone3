import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/admin_data_service.dart';

class NotificationsModal extends StatelessWidget {
  final Function(String incidentId)? onIncidentSelected;

  const NotificationsModal({super.key, this.onIncidentSelected});

  static void show(BuildContext context, {Function(String incidentId)? onIncidentSelected}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotificationsModal(onIncidentSelected: onIncidentSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminService = AdminDataService();

    return ListenableBuilder(
      listenable: adminService,
      builder: (context, _) {
        final notifications = adminService.notifications;
        final unreadCount = adminService.unreadNotificationsCount;

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFF0D1627),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Color(0xFF1E2D4A), width: 1.5),
            ),
          ),
          child: Column(
            children: [
              // Modal Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: Color(0xFF0A84FF), size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      "System Notifications",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8F0FE),
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFF3B30).withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          "$unreadCount UNREAD",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF3B30),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (unreadCount > 0)
                      TextButton(
                        onPressed: () {
                          adminService.markAllNotificationsAsRead();
                        },
                        child: const Text(
                          "Mark all read",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0A84FF),
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
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.notifications_off_outlined, color: Color(0xFF475569), size: 48),
                            SizedBox(height: 12),
                            Text(
                              "No notifications yet",
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return _buildNotificationItem(context, notification, adminService);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context, AppNotification notification, AdminDataService adminService) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'incident':
        iconData = Icons.warning_amber_rounded;
        iconColor = const Color(0xFFFF9500);
        break;
      case 'user':
        iconData = Icons.person_add_rounded;
        iconColor = const Color(0xFF34C759);
        break;
      default:
        iconData = Icons.info_outline_rounded;
        iconColor = const Color(0xFF0A84FF);
    }

    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          adminService.markNotificationAsRead(notification.id);
        }
        if (notification.incidentId != null && onIncidentSelected != null) {
          Navigator.of(context).pop();
          onIncidentSelected!(notification.incidentId!);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? const Color(0xFF131F37) : const Color(0xFF1A2B4C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead ? const Color(0xFF1E2D4A) : const Color(0xFF0A84FF).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: const Color(0xFFE8F0FE),
                          ),
                        ),
                      ),
                      Text(
                        _formatTimeAgo(notification.createdAt),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      height: 1.3,
                    ),
                  ),
                  if (notification.incidentId != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF0A84FF)),
                        SizedBox(width: 4),
                        Text(
                          "Tap to view on command map",
                          style: TextStyle(fontSize: 11, color: Color(0xFF0A84FF), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!notification.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF0A84FF),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
