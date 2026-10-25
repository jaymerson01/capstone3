import 'package:flutter/material.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/landscape_backdrop.dart';
import 'package:community_safety_app/core/presentation/neo/live_indicator.dart';
import 'package:community_safety_app/core/presentation/neo/neo_status_pill.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

// Display-only pieces of the resident Home screen. They take plain values;
// DashboardPage keeps the data streams, counts and navigation.

/// A color one step deeper (lighter at night) than [color], for numbers
/// and icons on light tiles.
Color _deep(Color color) => AppColors.isDarkMode
    ? Color.lerp(color, Colors.white, 0.35)!
    : Color.lerp(color, AppColors.ink, 0.3)!;

const List<Shadow> _onLandscape = [
  Shadow(color: Color(0x730F172A), blurRadius: 14),
];

/// Dusk landscape (night in dark mode) behind the top of Home, fading into
/// the aurora below it.
class HomeHeroLandscape extends StatelessWidget {
  const HomeHeroLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0, 0.55, 1],
      ).createShader(rect),
      child: LandscapeBackdrop(
        time: AppColors.isDarkMode ? LandscapeTime.night : LandscapeTime.dusk,
      ),
    );
  }
}

/// Brand row with the notifications bell, then the welcome line, on the
/// hero landscape.
class HomeHeroHeader extends StatelessWidget {
  final String welcomeLabel;
  final String userName;
  final String placeLabel;
  final int unreadCount;
  final VoidCallback onNotificationsTap;

  const HomeHeroHeader({
    super.key,
    required this.welcomeLabel,
    required this.userName,
    required this.placeLabel,
    required this.unreadCount,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.primary,
                    child: const Icon(Icons.shield,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "RESQ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                shadows: _onLandscape,
              ),
            ),
            const Spacer(),
            _NotificationsBell(
              unreadCount: unreadCount,
              onTap: onNotificationsTap,
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          welcomeLabel,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: _onLandscape,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            shadows: _onLandscape,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.glassSmoke,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.secondaryLight),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  placeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.verified_user_outlined,
                  size: 14, color: AppColors.secondaryLight),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationsBell extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const _NotificationsBell({required this.unreadCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    final hasUnread = unreadCount > 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [Color(0xFF26334F), Color(0xFF1C2742)]
                      : const [Color(0xFFFFFFFF), Color(0xFFEDF1F6)],
                ),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: AppColors.raisedShadow,
              ),
              child: Icon(
                hasUnread
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: hasUnread ? AppColors.primaryText : AppColors.textDark,
                size: 22,
              ),
            ),
          ),
        ),
        if (hasUnread)
          Positioned(
            top: -4,
            right: -4,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The active municipal siren, on a dark tray with a live cyan glow.
class HomeSirenCard extends StatelessWidget {
  final String activeLabel;
  final String alertType;
  final String title;
  final String message;
  final String targetLabel;

  const HomeSirenCard({
    super.key,
    required this.activeLabel,
    required this.alertType,
    required this.title,
    required this.message,
    required this.targetLabel,
  });

  @override
  Widget build(BuildContext context) {
    const soft = Color(0xFFCBD5E1);
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF273246), Color(0xFF151C2A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 24,
          ),
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LiveIndicator.ring(
            size: 46,
            child: Icon(Icons.campaign_rounded),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    Text(
                      activeLabel,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(
                      alertType.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.dangerLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: soft,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 13, color: soft),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        targetLabel,
                        style: const TextStyle(
                          color: soft,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One count tile in [HomeMyReportsPanel].
class HomeStat {
  final String value;
  final String label;
  final String sublabel;
  final Color color;
  final IconData icon;
  final bool highlight;

  const HomeStat({
    required this.value,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.icon,
    this.highlight = false,
  });
}

/// "My reports status": the resident's own reports counted by stage. Every
/// tile, and "View All", opens My Reports.
class HomeMyReportsPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final String viewAllLabel;
  final List<HomeStat> stats;
  final VoidCallback onOpenMyReports;

  const HomeMyReportsPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.viewAllLabel,
    required this.stats,
    required this.onOpenMyReports,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onOpenMyReports,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        viewAllLabel,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppColors.primaryText),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(stat: stats[i], onTap: onOpenMyReports),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final HomeStat stat;
  final VoidCallback onTap;

  const _StatTile({required this.stat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final deep = _deep(stat.color);
    final radius = BorderRadius.circular(20);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: stat.color.withValues(alpha: 0.15),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.isDarkMode
                  ? const [Color(0xFF26334F), Color(0xFF1C2742)]
                  : const [Color(0xFFFFFFFF), Color(0xFFF4F7FB)],
            ),
            border: Border.all(
              color: stat.highlight
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.glassBorder,
              width: stat.highlight ? 1.5 : 1,
            ),
            boxShadow: AppColors.pressedShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(stat.icon, color: deep, size: 18),
              const SizedBox(height: 6),
              Text(
                stat.value,
                style: TextStyle(
                  color: deep,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat.label,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                stat.sublabel,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Community Incidents": a glass panel with an optional live count and
/// the incident rows (or a loading, error or empty state) as [children].
class HomeCommunityPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? activeLabel;
  final List<Widget> children;

  const HomeCommunityPanel({
    super.key,
    required this.title,
    required this.subtitle,
    this.activeLabel,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeLabel;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (active != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LiveIndicator(size: 7),
                      const SizedBox(width: 6),
                      Text(
                        active,
                        style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

/// One community incident: urgency-tinted icon, category, status, place,
/// time and description. Tapping it opens the incident on the map.
class HomeIncidentRow extends StatelessWidget {
  final IconData icon;
  final Color urgencyColor;
  final String title;
  final String status;
  final String statusLabel;
  final String location;
  final String time;
  final String description;
  final VoidCallback onTap;

  const HomeIncidentRow({
    super.key,
    required this.icon,
    required this.urgencyColor,
    required this.title,
    required this.status,
    required this.statusLabel,
    required this.location,
    required this.time,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.isDarkMode
                    ? const [Color(0xFF26334F), Color(0xFF1C2742)]
                    : const [Color(0xFFFFFFFF), Color(0xFFF4F7FB)],
              ),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: AppColors.pressedShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(
                        alpha: AppColors.isDarkMode ? 0.22 : 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: _deep(urgencyColor), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          NeoStatusPill.status(
                              status: status, label: statusLabel),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _MetaLine(icon: Icons.location_on_outlined, text: location),
                      const SizedBox(height: 3),
                      _MetaLine(icon: Icons.access_time, text: time),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 13, color: AppColors.textLight),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// "Video Instructions" with a dark play thumbnail whose glow pulses.
class HomeVideoCard extends StatefulWidget {
  final String title;
  final String subtitle;

  const HomeVideoCard({super.key, required this.title, required this.subtitle});

  @override
  State<HomeVideoCard> createState() => _HomeVideoCardState();
}

class _HomeVideoCardState extends State<HomeVideoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.commandGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                              alpha: 0.35 + 0.35 * _pulseController.value),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
