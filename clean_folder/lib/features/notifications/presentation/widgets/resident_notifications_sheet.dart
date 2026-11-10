import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/presentation/neo/neo_surface.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../incident/data/models/incident_model.dart';
import '../../../incident/presentation/pages/incident_detail_page.dart';
import '../../data/datasources/notification_service.dart';
import '../../data/models/notification_model.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

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

  String _formatRelativeTime(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context);
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return l10n.timeShortJustNow;
    if (diff.inMinutes < 60) return l10n.timeShortMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeShortHours(diff.inHours);
    if (diff.inDays < 7) return l10n.timeShortDays(diff.inDays);
    return "${dt.month}/${dt.day}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();

    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF1C2742), Color(0xFF141E36)]
                  : const [Color(0xFFF8FAFC), Color(0xFFE9EEF5)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.3),
                blurRadius: 50,
                offset: const Offset(0, -20),
              ),
            ],
          ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).notificationsTitle,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    notificationService.markAllResidentAsRead(userId);
                  },
                  clipBehavior: Clip.none,
                  style: ButtonStyle(
                    foregroundColor:
                        WidgetStatePropertyAll(AppColors.primaryText),
                    overlayColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 14)),
                    minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
                    shape: const WidgetStatePropertyAll(StadiumBorder()),
                    backgroundBuilder: NeoSurface.background(NeoFill.raised),
                  ),
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: Text(
                    AppLocalizations.of(context).notificationsMarkAllRead,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification List
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: notificationService.streamResidentNotifications(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
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
                              color: AppColors.surfaceLight,
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 44,
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context).notificationsEmptyTitle,
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context).notificationsEmptyMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                      16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    final hasReport =
                        item.incidentId != null && item.incidentId!.isNotEmpty;

                    return ResidentNotificationTile(
                      item: item,
                      timeLabel: _formatRelativeTime(context, item.createdAt),
                      viewReportLabel: hasReport
                          ? AppLocalizations.of(context).notificationsViewReport
                          : null,
                      removeTooltip:
                          AppLocalizations.of(context).notificationsRemove,
                      onTap: () async {
                        // Mark as read
                        if (!item.isRead) {
                          notificationService.markAsReadForUser(item, userId);
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
                      onRemove: () {
                        notificationService.dismissForUser(item, userId);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

/// One notification: a type-colored icon, title with an unread dot, message,
/// time, an optional link to the report, and a remove button. Unread ones
/// are raised with a blue edge; read ones sit flat in the sheet.
class ResidentNotificationTile extends StatelessWidget {
  final NotificationModel item;
  final String timeLabel;
  final String? viewReportLabel;
  final String removeTooltip;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const ResidentNotificationTile({
    super.key,
    required this.item,
    required this.timeLabel,
    required this.viewReportLabel,
    required this.removeTooltip,
    required this.onTap,
    required this.onRemove,
  });

  static Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'status_change':
        return AppColors.primary;
      case 'upvote':
        return AppColors.pending;
      case 'siren':
        return AppColors.danger;
      case 'new_report':
        return AppColors.solved;
      default:
        return AppColors.primary;
    }
  }

  static IconData _typeIcon(String type) {
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
    final isDark = AppColors.isDarkMode;
    final unread = !item.isRead;
    final color = _typeColor(item.type);
    final deep = isDark
        ? Color.lerp(color, Colors.white, 0.35)!
        : Color.lerp(color, AppColors.ink, 0.3)!;
    final link = viewReportLabel;
    final radius = BorderRadius.circular(22);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: unread
                ? (isDark ? const Color(0xFF26334F) : Colors.white)
                : (isDark ? const Color(0xFF172036) : const Color(0xFFEEF2F7)),
            border: Border.all(
              color: unread
                  ? AppColors.primary.withValues(alpha: isDark ? 0.5 : 0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: unread ? AppColors.soft3dShadow : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_typeIcon(item.type), color: deep, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: unread
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                              fontWeight:
                                  unread ? FontWeight.w800 : FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF334155),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (link != null) ...[
                          Flexible(
                            child: Text(
                              link,
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                        ],
                        Icon(Icons.access_time_rounded,
                            size: 12, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: Icon(Icons.close, size: 18, color: AppColors.textLight),
                onPressed: onRemove,
                tooltip: removeTooltip,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
