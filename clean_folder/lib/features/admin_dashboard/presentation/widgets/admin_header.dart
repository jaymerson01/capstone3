import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
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
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        gradient: AdminColors.headerGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: const Border(
          bottom: BorderSide(
            color: AdminColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Title and Toggle Menu Menu Icon
          Row(
            children: [
              if (isMobile)
                IconButton(
                  icon: Icon(Icons.menu, color: AdminColors.primaryGreen, size: 22),
                  onPressed: onMenuPressed,
                )
              else
                IconButton(
                  icon: Icon(Icons.menu_open, color: AdminColors.primaryGreen, size: 22),
                  onPressed: onMenuPressed,
                  tooltip: "Toggle Sidebar",
                ),
              SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AdminColors.textDark,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          // Right: Emergency Siren, Profile Avatar and Admin Title
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Emergency Broadcast Siren Button with Live Active Counter
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('broadcasts')
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  final activeDocs = snapshot.data?.docs ?? [];
                  final hasActive = activeDocs.isNotEmpty;

                  return InkWell(
                    onTap: () => _showBroadcastModal(context,
                        initialTab: hasActive ? 0 : 1),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: hasActive
                              ? const [Color(0xFFFF3B30), Color(0xFFC92A2A)]
                              : const [Color(0xFF2A0A10), Color(0xFF1E2D4A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: hasActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF3B30)
                                      .withValues(alpha: 0.55),
                                  blurRadius: 14,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                        border: Border.all(
                          color: hasActive
                              ? const Color(0xFFFF3B30)
                              : const Color(0xFF1E2D4A),
                          width: hasActive ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasActive
                                ? Icons.crisis_alert_rounded
                                : Icons.campaign_rounded,
                            color: hasActive
                                ? Colors.white
                                : const Color(0xFFFF3B30),
                            size: 18,
                          ),
                          if (!isMobile) ...[
                            SizedBox(width: 8),
                            Text(
                              hasActive
                                  ? "${activeDocs.length} ACTIVE SIREN • MANAGE"
                                  : "BROADCAST SIREN",
                              style: TextStyle(
                                color: hasActive
                                    ? Colors.white
                                    : const Color(0xFFE8F0FE),
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 16),

              // Interactive Dispatch Notifications Bell
              StreamBuilder<List<NotificationModel>>(
                stream: NotificationService().streamAdminNotifications(),
                builder: (context, snapshot) {
                  final notifications = snapshot.data ?? [];
                  final unreadCount =
                      notifications.where((n) => !n.isRead).length;

                  return InkWell(
                    onTap: () => _showAdminNotificationsModal(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: unreadCount > 0
                                ? const Color(0xFF0A84FF)
                                    .withValues(alpha: 0.15)
                                : const Color(0xFF0D1627),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: unreadCount > 0
                                  ? const Color(0xFF0A84FF)
                                  : const Color(0xFF1E2D4A),
                            ),
                          ),
                          child: Center(
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
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              constraints: const BoxConstraints(
                                  minWidth: 17, minHeight: 17),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFF060D1A), width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(width: 16),
              
              // Divider
              Container(
                height: 24,
                width: 1,
                color: Colors.grey.shade200,
              ),
              SizedBox(width: 16),
              
              // Interactive Admin Profile Dropdown Menu
              _buildAdminUserMenu(context),
            ],
          ),
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
      height: 48,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: PopupMenuButton<int>(
          tooltip: "Admin Account & Station Options",
          padding: EdgeInsets.zero,
          color: const Color(0xFF0D1627),
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF1E2D4A), width: 1.2),
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
                  backgroundColor: const Color(0xFF0D1627),
                  behavior: SnackBarBehavior.floating,
                  content: Row(
                    children: [
                      Icon(Icons.volume_up_rounded,
                          color: Color(0xFF30D158), size: 20),
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
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2D4A),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF30D158),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: photoUrl != null && photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
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
                          color: Color(0xFF7B8DB0),
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
                          color: const Color(0xFF30D158).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                const Color(0xFF30D158).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                color: Color(0xFF30D158), size: 11),
                            SizedBox(width: 4),
                            Text(
                              "Admin",
                              style: TextStyle(
                                color: Color(0xFF30D158),
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
                    color: Color(0xFF0A84FF), size: 18),
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
                    color: Color(0xFF30D158), size: 18),
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
                    color: Color(0xFFFF9500), size: 18),
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
                    color: Color(0xFFFF3B30), size: 18),
                SizedBox(width: 12),
                Text(
                  "Log Out",
                  style: TextStyle(
                    color: Color(0xFFFF3B30),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1627),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF1E2D4A),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isMobile) ...[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.textDark,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Color(0xFF30D158),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Municipal Dispatcher",
                          style: TextStyle(
                            fontSize: 10,
                            color: AdminColors.textLight,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 10),
              ],
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2540),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF30D158),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF30D158).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AdminColors.textLight,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  void _showBroadcastModal(BuildContext context, {int initialTab = 0}) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String alertType = "Fire Alarm";
    String targetSector = "All Barangay Moonwalk";
    bool isBroadcasting = false;
    int currentTab = initialTab;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1627),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.crisis_alert,
                            color: Color(0xFFFF3B30), size: 22),
                      ),
                      SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Municipal Emergency Broadcast",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              "Real-time Siren Transmission & Silence Controls",
                              style: TextStyle(
                                color: Color(0xFF7B8DB0),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Segmented Tabs: Active Sirens vs New Broadcast
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF060D1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E2D4A)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setDialogState(() => currentTab = 0),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: currentTab == 0
                                    ? const Color(0xFFFF3B30)
                                        .withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: currentTab == 0
                                    ? Border.all(
                                        color: const Color(0xFFFF3B30)
                                            .withValues(alpha: 0.5))
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.campaign,
                                    size: 16,
                                    color: currentTab == 0
                                        ? const Color(0xFFFF3B30)
                                        : const Color(0xFF7B8DB0),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Active Sirens",
                                    style: TextStyle(
                                      color: currentTab == 0
                                          ? Colors.white
                                          : const Color(0xFF7B8DB0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setDialogState(() => currentTab = 1),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: currentTab == 1
                                    ? const Color(0xFF0A84FF)
                                        .withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: currentTab == 1
                                    ? Border.all(
                                        color: const Color(0xFF0A84FF)
                                            .withValues(alpha: 0.5))
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_alert_rounded,
                                    size: 16,
                                    color: currentTab == 1
                                        ? const Color(0xFF0A84FF)
                                        : const Color(0xFF7B8DB0),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Transmit New",
                                    style: TextStyle(
                                      color: currentTab == 1
                                          ? Colors.white
                                          : const Color(0xFF7B8DB0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: currentTab == 0
                    // ── Tab 0: Active Sirens List & Silence Controls ──
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('broadcasts')
                            .where('isActive', isEqualTo: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(32.0),
                              child:
                                  Center(child: CircularProgressIndicator()),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 36.0, horizontal: 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF30D158)
                                          .withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                        Icons.check_circle_outline,
                                        color: Color(0xFF30D158),
                                        size: 40),
                                  ),
                                  SizedBox(height: 14),
                                  Text(
                                    "All Municipal Sectors Clear",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "There are no active sirens currently broadcasting to citizens.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color(0xFF7B8DB0),
                                        fontSize: 12),
                                  ),
                                  SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          const Color(0xFF0A84FF),
                                      side: const BorderSide(
                                          color: Color(0xFF0A84FF)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                    icon: Icon(Icons.add_alert_rounded,
                                        size: 14),
                                    label: Text("Transmit New Alert",
                                        style: TextStyle(fontSize: 12)),
                                    onPressed: () => setDialogState(
                                        () => currentTab = 1),
                                  ),
                                ],
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: docs.map((doc) {
                                final data =
                                    doc.data() as Map<String, dynamic>;
                                final title = data['title'] as String? ??
                                    "Emergency Broadcast";
                                final type = data['alertType'] as String? ??
                                    "Siren";
                                final sector = data['sector'] as String? ??
                                    "All Sectors";
                                final message =
                                    data['message'] as String? ?? "";
                                final createdAt =
                                    data['createdAt'] as Timestamp?;
                                final dateStr = createdAt != null
                                    ? "${createdAt.toDate().hour > 12 ? createdAt.toDate().hour - 12 : (createdAt.toDate().hour == 0 ? 12 : createdAt.toDate().hour)}:${createdAt.toDate().minute.toString().padLeft(2, '0')} ${createdAt.toDate().hour >= 12 ? 'PM' : 'AM'}"
                                    : "Just now";

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF060D1A),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xFFFF3B30)
                                            .withValues(alpha: 0.6),
                                        width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF3B30)
                                            .withValues(alpha: 0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF9500)
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFFFF9500)
                                                          .withValues(
                                                              alpha: 0.4)),
                                            ),
                                            child: Text(
                                              type.toUpperCase(),
                                              style: const TextStyle(
                                                color: Color(0xFFFF9500),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0A84FF)
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFF0A84FF)
                                                          .withValues(
                                                              alpha: 0.4)),
                                            ),
                                            child: Text(
                                              sector,
                                              style: const TextStyle(
                                                color: Color(0xFF0A84FF),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            dateStr,
                                            style: const TextStyle(
                                                color: Color(0xFF7B8DB0),
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (message.isNotEmpty) ...[
                                        SizedBox(height: 6),
                                        Text(
                                          message,
                                          style: const TextStyle(
                                            color: Color(0xFFE8F0FE),
                                            fontSize: 12.5,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                      SizedBox(height: 14),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                                Icons.delete_outline,
                                                color: Color(0xFFFF3B30),
                                                size: 20),
                                            tooltip: "Delete Record",
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('broadcasts')
                                                  .doc(doc.id)
                                                  .delete();
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    backgroundColor:
                                                        Color(0xFF0D1627),
                                                    content: Text(
                                                      "Broadcast record deleted.",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white),
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFFF9500),
                                              foregroundColor: Colors.black,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            icon: Icon(Icons.volume_off,
                                                size: 16),
                                            label: Text(
                                              "SILENCE & CLEAR SIREN",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 11),
                                            ),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('broadcasts')
                                                  .doc(doc.id)
                                                  .update({
                                                'isActive': false,
                                                'silencedAt': FieldValue
                                                    .serverTimestamp(),
                                              });

                                              await sl<AuditLogRemoteDataSource>().recordLog(
                                                actionType: 'Emergency Siren',
                                                details: 'Silenced and cleared emergency siren broadcast: "$title" (Sector: $sector)',
                                                targetId: doc.id,
                                              );

                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        const Color(0xFF0D1627),
                                                    content: Text(
                                                      "🚨 Siren '$title' silenced and removed from citizen devices!",
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF30D158),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      )
                    // ── Tab 1: Transmit New Siren Form ──
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "BROADCAST TITLE",
                              style: TextStyle(
                                color: Color(0xFF7B8DB0),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            TextField(
                              controller: titleController,
                              style: const TextStyle(
                                  color: Color(0xFFE8F0FE), fontSize: 13),
                              decoration: InputDecoration(
                                hintText:
                                    "e.g. FLASH FLOOD RED ALERT - SAN JOSE",
                                hintStyle: const TextStyle(
                                    color: Color(0xFF4A5568), fontSize: 12),
                                filled: true,
                                fillColor: const Color(0xFF060D1A),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E2D4A)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E2D4A)),
                                ),
                              ),
                            ),
                            SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "ALERT TYPE",
                                        style: TextStyle(
                                          color: Color(0xFF7B8DB0),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        initialValue: alertType,
                                        dropdownColor:
                                            const Color(0xFF0D1627),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFF060D1A),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Color(0xFF1E2D4A)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Color(0xFF1E2D4A)),
                                          ),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                              value: "Fire Alarm",
                                              child: Text("Fire Alarm")),
                                          DropdownMenuItem(
                                              value: "Flood Evacuation",
                                              child:
                                                  Text("Flood Evacuation")),
                                          DropdownMenuItem(
                                              value: "Earthquake Advisory",
                                              child: Text(
                                                  "Earthquake Advisory")),
                                          DropdownMenuItem(
                                              value: "Severe Weather",
                                              child:
                                                  Text("Severe Weather")),
                                          DropdownMenuItem(
                                              value: "Security Curfew",
                                              child:
                                                  Text("Security Curfew")),
                                          DropdownMenuItem(
                                              value: "General Notice",
                                              child:
                                                  Text("General Notice")),
                                        ],
                                        onChanged: (v) {
                                          if (v != null) {
                                            setDialogState(
                                                () => alertType = v);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "TARGET SECTOR",
                                        style: TextStyle(
                                          color: Color(0xFF7B8DB0),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        initialValue: targetSector,
                                        dropdownColor:
                                            const Color(0xFF0D1627),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFF060D1A),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Color(0xFF1E2D4A)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Color(0xFF1E2D4A)),
                                          ),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                              value:
                                                  "All Barangay Moonwalk",
                                              child: Text("All Moonwalk")),
                                          DropdownMenuItem(
                                              value: "Area 1 - San Jose",
                                              child: Text("Area 1")),
                                          DropdownMenuItem(
                                              value: "Area 2 - Airborne",
                                              child: Text("Area 2")),
                                          DropdownMenuItem(
                                              value:
                                                  "Area 3 - Multinational",
                                              child: Text("Area 3")),
                                          DropdownMenuItem(
                                              value: "Area 4 - San Agustin",
                                              child: Text("Area 4")),
                                          DropdownMenuItem(
                                              value:
                                                  "Area 5 - Moonwalk Proper",
                                              child: Text("Area 5")),
                                        ],
                                        onChanged: (v) {
                                          if (v != null) {
                                            setDialogState(
                                                () => targetSector = v);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14),
                            Text(
                              "BROADCAST MESSAGE / INSTRUCTIONS",
                              style: TextStyle(
                                color: Color(0xFF7B8DB0),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            TextField(
                              controller: messageController,
                              maxLines: 3,
                              style: const TextStyle(
                                  color: Color(0xFFE8F0FE), fontSize: 13),
                              decoration: InputDecoration(
                                hintText:
                                    "State mandatory instructions, evacuation points, emergency hotlines...",
                                hintStyle: const TextStyle(
                                    color: Color(0xFF4A5568), fontSize: 12),
                                filled: true,
                                fillColor: const Color(0xFF060D1A),
                                contentPadding: const EdgeInsets.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E2D4A)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E2D4A)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text("Close",
                      style: TextStyle(color: Color(0xFF7B8DB0))),
                ),
                if (currentTab == 1)
                  ElevatedButton.icon(
                    icon: isBroadcasting
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Icon(Icons.send_rounded, size: 16),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isBroadcasting
                        ? null
                        : () async {
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
                                    backgroundColor: Color(0xFFFF3B30),
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
                          },
                    label: Text(
                      isBroadcasting
                          ? "TRANSMITTING..."
                          : "TRANSMIT SIREN BROADCAST",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
              ],
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
          backgroundColor: const Color(0xFF0D1627),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF1E2D4A), width: 1.5),
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
                        color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF0A84FF)
                                .withValues(alpha: 0.4)),
                      ),
                      child: Icon(Icons.notifications_active_rounded,
                          color: Color(0xFF0A84FF), size: 20),
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
                          size: 16, color: Color(0xFF7B8DB0)),
                      label: Text(
                        "Mark all read",
                        style: TextStyle(
                            color: Color(0xFF7B8DB0),
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Color(0xFF7B8DB0)),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: Color(0xFF1E2D4A), height: 1),
                SizedBox(height: 12),

                // Notifications Stream
                Flexible(
                  child: StreamBuilder<List<NotificationModel>>(
                    stream: notificationService.streamAdminNotifications(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF0A84FF)),
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
                                    size: 48, color: Color(0xFF7B8DB0)),
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
                                      color: Color(0xFF7B8DB0),
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
                                    ? const Color(0xFF101E38)
                                    : const Color(0xFF080F1E),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isUnread
                                      ? const Color(0xFF0A84FF)
                                          .withValues(alpha: 0.5)
                                      : const Color(0xFF1E2D4A),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A84FF)
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.campaign_rounded,
                                        color: Color(0xFF0A84FF), size: 18),
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
                                                : const Color(0xFFE8F0FE),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          item.message,
                                          style: const TextStyle(
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close,
                                        size: 16, color: Color(0xFF7B8DB0)),
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
