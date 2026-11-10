import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';

/// A raised slate button for the admin header (menu, notifications).
class AdminHeaderButton extends StatelessWidget {
  const AdminHeaderButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.semanticLabel,
    this.iconColor = AdminColors.textDark,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final String? semanticLabel;
  final Color iconColor;

  /// Shown on the top-right corner, such as an unread count.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: AdminColors.buttonGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: AdminColors.buttonShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(child: Icon(icon, color: iconColor, size: 20)),
        ),
      ),
    );

    if (badge != null) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            top: -5,
            right: -5,
            child: ExcludeSemantics(child: badge!),
          ),
        ],
      );
    }
    if (tooltip != null) button = Tooltip(message: tooltip!, child: button);

    return Semantics(button: true, label: semanticLabel, child: button);
  }
}

/// The header's "BROADCAST SIREN" button. While sirens are active it names
/// how many and glows brighter.
class AdminSirenButton extends StatelessWidget {
  const AdminSirenButton({
    super.key,
    required this.activeCount,
    required this.compact,
    required this.onTap,
  });

  final int activeCount;

  /// Icon only, for phone widths.
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool active = activeCount > 0;
    final String label = active
        ? "$activeCount ACTIVE SIREN • MANAGE"
        : "BROADCAST SIREN";

    return Semantics(
      button: true,
      label: compact ? label : null,
      child: Container(
        height: 44,
        constraints: const BoxConstraints(minWidth: 44),
        decoration: BoxDecoration(
          gradient: AdminColors.sirenGradient,
          borderRadius: BorderRadius.circular(14),
          border: active
              ? Border.all(color: AdminColors.dangerPale, width: 1.5)
              : null,
          boxShadow: AdminColors.sirenGlow(strength: active ? 1.4 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    active
                        ? Icons.crisis_alert_rounded
                        : Icons.campaign_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The dispatch notifications bell, with a cyan count while any are unread.
class AdminBellButton extends StatelessWidget {
  const AdminBellButton({
    super.key,
    required this.unreadCount,
    required this.onTap,
  });

  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool unread = unreadCount > 0;

    return AdminHeaderButton(
      icon: unread
          ? Icons.notifications_active_rounded
          : Icons.notifications_none_rounded,
      iconColor: unread ? AdminColors.cyanSoft : AdminColors.textDark,
      semanticLabel: unread
          ? "Dispatch notifications, $unreadCount new"
          : "Dispatch notifications",
      onPressed: onTap,
      badge: unread
          ? Container(
              constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: AdminColors.cyan,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AdminColors.background, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AdminColors.cyan.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: AdminColors.background,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

/// A round profile picture, or the first letter on ResQuick blue.
class AdminAvatar extends StatelessWidget {
  const AdminAvatar({
    super.key,
    required this.initial,
    this.photoUrl,
    this.size = 36,
    this.online = false,
  });

  final String initial;
  final String? photoUrl;
  final double size;

  /// Adds a small green "on duty" dot.
  final bool online;

  @override
  Widget build(BuildContext context) {
    final letter = Center(
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
        ),
      ),
    );

    final face = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AdminColors.primary, AdminColors.primaryDeep],
        ),
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (context, error, stackTrace) => letter,
              )
            : letter,
      ),
    );

    if (!online) return face;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        face,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: size * 0.32,
            height: size * 0.32,
            decoration: BoxDecoration(
              color: AdminColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: AdminColors.background, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// The signed-in admin's pill in the header: picture, name and role.
class AdminUserChip extends StatelessWidget {
  const AdminUserChip({
    super.key,
    required this.displayName,
    required this.initial,
    this.photoUrl,
    required this.compact,
  });

  final String displayName;
  final String initial;
  final String? photoUrl;

  /// Picture only, for phone widths.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: EdgeInsets.fromLTRB(4, 4, compact ? 6 : 12, 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdminAvatar(initial: initial, photoUrl: photoUrl, online: true),
          if (!compact) ...[
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textDark,
                      height: 1.2,
                    ),
                  ),
                ),
                const Text(
                  "Municipal Dispatcher",
                  style: TextStyle(
                    fontSize: 11,
                    color: AdminColors.textLight,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AdminColors.textLight,
          ),
        ],
      ),
    );
  }
}
