import 'package:flutter/material.dart';
import '../constants/admin_colors.dart';
import '../services/admin_data_service.dart';

import 'notifications_modal.dart';

class AdminHeader extends StatefulWidget {
  final String title;
  final VoidCallback onMenuPressed;
  final bool isMobile;
  final Function(String incidentId)? onNotificationSelected;

  const AdminHeader({
    super.key,
    required this.title,
    required this.onMenuPressed,
    required this.isMobile,
    this.onNotificationSelected,
  });

  @override
  State<AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends State<AdminHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _notifPulse;

  @override
  void initState() {
    super.initState();
    _notifPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _notifPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminService = AdminDataService();

    return ListenableBuilder(
      listenable: adminService,
      builder: (context, _) {
        final unreadCount = adminService.unreadNotificationsCount;

        return Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1627),
            border: const Border(
              bottom: BorderSide(color: Color(0xFF1E2D4A), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Menu toggle ──────────────────────────────────────────────
              GestureDetector(
                onTap: widget.onMenuPressed,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A84FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF0A84FF).withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    widget.isMobile ? Icons.menu : Icons.menu_open,
                    color: const Color(0xFF0A84FF),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ── Page Title ──────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE8F0FE),
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "RESQ Admin Command Center",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7B8DB0),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Right Actions ─────────────────────────────────────────
              Row(
                children: [
                  // Notification bell with animated pulse badge
                  GestureDetector(
                    onTap: () {
                      NotificationsModal.show(
                        context,
                        onIncidentSelected: widget.onNotificationSelected,
                      );
                    },
                    child: AnimatedBuilder(
                      animation: _notifPulse,
                      builder: (context, _) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A2540),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: unreadCount > 0
                                        ? const Color(0xFF0A84FF).withValues(alpha: 0.5)
                                        : const Color(0xFF1E2D4A)),
                              ),
                              child: Icon(
                                unreadCount > 0
                                    ? Icons.notifications_active_rounded
                                    : Icons.notifications_none_outlined,
                                color: unreadCount > 0
                                    ? const Color(0xFF0A84FF)
                                    : const Color(0xFF7B8DB0),
                                size: 20,
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFF3B30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF3B30).withValues(
                                            alpha: 0.7 * _notifPulse.value),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFF1E2D4A),
                  ),
                  const SizedBox(width: 12),

                  if (!widget.isMobile) ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          adminService.adminName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8F0FE),
                          ),
                        ),
                        const Text(
                          "System Admin",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF0A84FF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0A84FF), Color(0xFF00D4FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0A84FF).withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        adminService.adminName.isNotEmpty
                            ? adminService.adminName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
