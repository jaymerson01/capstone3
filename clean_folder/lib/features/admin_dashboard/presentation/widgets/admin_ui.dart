import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';

/// Shared Neo command-center pieces for the admin pages: panels, titles,
/// buttons, pills, inputs, choice controls, dialogs and table styles.
/// Everything here is presentation only.

/// Colour families for pills, icon actions and tints.
enum AdminTone { blue, cyan, green, yellow, orange, red, violet, slate }

extension AdminToneColors on AdminTone {
  /// The full-strength colour, used for tints and solid fills.
  Color get base => switch (this) {
    AdminTone.blue => AdminColors.blue,
    AdminTone.cyan => AdminColors.cyan,
    AdminTone.green => AdminColors.success,
    AdminTone.yellow => AdminColors.yellow,
    AdminTone.orange => AdminColors.orange,
    AdminTone.red => AdminColors.critical,
    AdminTone.violet => AdminColors.violet,
    AdminTone.slate => AdminColors.neutral,
  };

  /// A light tint that reads well on [base] at low opacity.
  Color get text => switch (this) {
    AdminTone.blue => AdminColors.lightTint,
    AdminTone.cyan => AdminColors.cyanText,
    AdminTone.green => AdminColors.successText,
    AdminTone.yellow => AdminColors.pendingText,
    AdminTone.orange => AdminColors.orangeLight,
    AdminTone.red => AdminColors.dangerText,
    AdminTone.violet => AdminColors.violetText,
    AdminTone.slate => AdminColors.textBody,
  };
}

// ─── Surfaces ────────────────────────────────────────────────────────────────

/// The standard admin card: night slate, a faint edge and a soft shadow.
/// [accent] tints the edge (and adds a glow when [glow] is set); [raised]
/// uses the brighter dialog gradient, for side panels.
class AdminPanel extends StatelessWidget {
  const AdminPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 22,
    this.accent,
    this.glow = false,
    this.raised = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? accent;
  final bool glow;
  final bool raised;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: raised ? null : AdminColors.cardBackground,
        gradient: raised ? AdminColors.panelGradient : null,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color:
              accent?.withValues(alpha: 0.35) ??
              Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          if (glow && accent != null)
            BoxShadow(color: accent!.withValues(alpha: 0.12), blurRadius: 30),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A quieter inner surface for rows and grouped details inside a panel.
class AdminInset extends StatelessWidget {
  const AdminInset({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 16,
    this.tone,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Tints the fill and edge, for example red for an urgent row.
  final AdminTone? tone;

  @override
  Widget build(BuildContext context) {
    final Color? base = tone?.base;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color:
            base?.withValues(alpha: 0.1) ??
            Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color:
              base?.withValues(alpha: 0.35) ??
              Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: child,
    );
  }
}

// ─── Titles ──────────────────────────────────────────────────────────────────

/// The page heading: a large white title, an optional line under it and
/// actions that wrap to the right.
class AdminPageTitle extends StatelessWidget {
  const AdminPageTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AdminColors.textStrong,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AdminColors.textLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: trailing,
          ),
      ],
    );
  }
}

/// A panel heading with an optional tinted icon tile and trailing widget.
class AdminSectionTitle extends StatelessWidget {
  const AdminSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tone = AdminTone.blue,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final AdminTone tone;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          AdminIconTile(icon: icon!, tone: tone),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AdminColors.textStrong,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AdminColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

/// A small rounded square holding a tinted icon.
class AdminIconTile extends StatelessWidget {
  const AdminIconTile({
    super.key,
    required this.icon,
    this.tone = AdminTone.blue,
    this.size = 36,
  });

  final IconData icon;
  final AdminTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone.base.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(icon, size: size / 2, color: tone.text),
    );
  }
}

/// An uppercase form label, with an optional badge after it.
class AdminFieldLabel extends StatelessWidget {
  const AdminFieldLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: AdminColors.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

// ─── Status ──────────────────────────────────────────────────────────────────

/// A rounded status or priority badge. [solid] fills it with the tone, for
/// the most urgent level.
class AdminPill extends StatelessWidget {
  const AdminPill({
    super.key,
    required this.label,
    this.tone = AdminTone.slate,
    this.solid = false,
    this.icon,
  });

  final String label;
  final AdminTone tone;
  final bool solid;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color foreground = solid ? Colors.white : tone.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: solid
            ? tone.base
            : tone.base.withValues(
                alpha: tone == AdminTone.orange ? 0.22 : 0.18,
              ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The cyan "live" badge with a glowing dot.
class AdminLiveBadge extends StatelessWidget {
  const AdminLiveBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AdminColors.cyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AdminColors.cyan.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AdminColors.cyan,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AdminColors.cyan.withValues(alpha: 0.9),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AdminColors.cyanText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Buttons ─────────────────────────────────────────────────────────────────

enum AdminButtonStyle {
  /// Blue gradient with a cyan ring: the main action.
  primary,

  /// Emergency red: delete, ban, siren.
  danger,

  /// Faint glass: cancel and secondary actions.
  ghost,

  /// Raised slate, like the header buttons: filters and tools.
  slate,

  /// Raised slate with a cyan edge: the highlighted filter.
  cyan,
}

/// The admin button. [onPressed] null disables it; [busy] swaps the icon
/// for a spinner.
class AdminButton extends StatelessWidget {
  const AdminButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AdminButtonStyle.primary,
    this.busy = false,
    this.height = 46,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AdminButtonStyle style;
  final bool busy;
  final double height;

  /// Fills the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final bool filled =
        style == AdminButtonStyle.primary || style == AdminButtonStyle.danger;
    final Color foreground = switch (style) {
      AdminButtonStyle.primary || AdminButtonStyle.danger => Colors.white,
      AdminButtonStyle.cyan => AdminColors.cyanText,
      _ => AdminColors.textBody,
    };

    final BoxDecoration decoration = switch (style) {
      AdminButtonStyle.primary => BoxDecoration(
        gradient: AdminColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AdminColors.cyan.withValues(alpha: 0.4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AdminColors.primaryDeep.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      AdminButtonStyle.danger => BoxDecoration(
        gradient: const LinearGradient(
          colors: [AdminColors.critical, AdminColors.dangerDark],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AdminColors.dangerSoft.withValues(alpha: 0.5),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AdminColors.critical.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      AdminButtonStyle.ghost => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      AdminButtonStyle.slate || AdminButtonStyle.cyan => BoxDecoration(
        gradient: AdminColors.buttonGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: style == AdminButtonStyle.cyan
              ? AdminColors.cyan.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: AdminColors.buttonShadow,
      ),
    };

    final Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (busy)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        else if (icon != null)
          Icon(icon, size: 18, color: foreground),
        if (busy || icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 13.5,
              fontWeight: filled ? FontWeight.w800 : FontWeight.w700,
              letterSpacing: filled ? 0.3 : 0,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: Opacity(
        opacity: enabled || busy ? 1 : 0.5,
        child: Container(
          height: height,
          decoration: decoration,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: busy ? null : onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A 34px square icon button for table rows and toolbars. [tone] null is
/// the neutral glass style.
class AdminIconAction extends StatelessWidget {
  const AdminIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.tone,
    this.size = 34,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AdminTone? tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final AdminTone? t = tone;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: t == null
                    ? Colors.white.withValues(alpha: 0.06)
                    : t.base.withValues(alpha: t == AdminTone.red ? 0.1 : 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: t == null
                      ? Colors.white.withValues(alpha: 0.14)
                      : t == AdminTone.red
                      ? AdminColors.dangerSoft.withValues(alpha: 0.35)
                      : t.base.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                icon,
                size: size * 0.5,
                color: onPressed == null
                    ? AdminColors.textFaint
                    : (t?.text ?? AdminColors.textBody),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Inputs ──────────────────────────────────────────────────────────────────

/// The dark input well used by every admin form field. [accent] tints the
/// edge at rest.
InputDecoration adminInputDecoration({
  String? hint,
  IconData? icon,
  Color? accent,
  Widget? suffix,
  String? errorText,
}) {
  OutlineInputBorder outline(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  final Color rest =
      accent?.withValues(alpha: 0.35) ?? Colors.white.withValues(alpha: 0.1);

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: AdminColors.textHint,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    prefixIcon: icon == null
        ? null
        : Icon(icon, size: 18, color: AdminColors.textHint),
    suffixIcon: suffix,
    errorText: errorText,
    filled: true,
    fillColor: Colors.black.withValues(alpha: 0.3),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: outline(rest),
    enabledBorder: outline(rest),
    focusedBorder: outline(accent ?? AdminColors.cyan, 1.5),
    errorBorder: outline(AdminColors.dangerSoft),
    focusedErrorBorder: outline(AdminColors.dangerSoft, 1.5),
    disabledBorder: outline(Colors.white.withValues(alpha: 0.06)),
  );
}

/// Text style for typing inside [adminInputDecoration] fields.
const TextStyle adminInputText = TextStyle(
  color: AdminColors.textDark,
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

/// The inset search bar with a magnifier.
class AdminSearchField extends StatelessWidget {
  const AdminSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.hint = 'Search...',
    this.trailing,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hint;

  /// For example a clear button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 18,
            color: AdminColors.textHint,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: AdminColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: AdminColors.cyan,
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AdminColors.textHint,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A raised slate dropdown for filters. [accent] gives it the cyan edge.
class AdminSelect<T> extends StatelessWidget {
  const AdminSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.accent = false,
    this.height = 46,
  });

  final T value;

  /// Each value with the text shown for it.
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;
  final IconData? icon;
  final bool accent;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Color foreground = accent
        ? AdminColors.cyanText
        : AdminColors.textBody;
    const TextStyle menuText = TextStyle(
      color: AdminColors.textBody,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        gradient: AdminColors.buttonGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent
              ? AdminColors.cyan.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: AdminColors.buttonShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isDense: true,
                dropdownColor: AdminColors.dialogBackground,
                borderRadius: BorderRadius.circular(12),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: foreground,
                ),
                selectedItemBuilder: (context) => [
                  for (final item in items)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        item.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
                items: [
                  for (final item in items)
                    DropdownMenuItem<T>(
                      value: item.$1,
                      child: Text(item.$2, style: menuText),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A pill-shaped segmented control. The selected segment is blue.
class AdminSegmented<T> extends StatelessWidget {
  const AdminSegmented({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  /// Each value with its label.
  final List<(T, String)> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final segment in segments)
            _Segment(
              label: segment.$2,
              selected: segment.$1 == value,
              onTap: () => onChanged(segment.$1),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AdminColors.primary, Color(0xFF2353D6)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(999),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AdminColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AdminColors.textSoft,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A radio-style option row, for picking one stage or role from a list.
class AdminChoiceTile extends StatelessWidget {
  const AdminChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: selected
                  ? AdminColors.primary.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AdminColors.cyan.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AdminColors.cyan : AdminColors.textHint,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AdminColors.cyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: selected
                        ? AdminColors.cyanText
                        : AdminColors.textLight,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: selected
                              ? AdminColors.textStrong
                              : AdminColors.textBody,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: AdminColors.textLight,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small pill choice, for presets such as ETA times. Selected is cyan.
class AdminChoiceChip extends StatelessWidget {
  const AdminChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AdminColors.cyanSoft, AdminColors.cyan],
                    )
                  : null,
              color: selected ? null : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(999),
              border: selected
                  ? null
                  : Border.all(color: Colors.white.withValues(alpha: 0.14)),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AdminColors.cyan.withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF0F172A)
                      : AdminColors.textBody,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A settings row with a title, a line of help and a switch.
class AdminSwitchTile extends StatelessWidget {
  const AdminSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.tone = AdminTone.blue,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;
  final AdminTone tone;

  @override
  Widget build(BuildContext context) {
    return AdminInset(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Row(
        children: [
          if (icon != null) ...[
            AdminIconTile(icon: icon!, tone: tone, size: 34),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AdminColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AdminColors.textLight,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// A label and value line for details views.
class AdminDetailRow extends StatelessWidget {
  const AdminDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.labelWidth = 130,
  });

  final String label;
  final String value;
  final IconData? icon;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AdminColors.textHint),
            const SizedBox(width: 10),
          ],
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: const TextStyle(
                color: AdminColors.textHint,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AdminColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when a list has nothing in it.
class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, size: 28, color: AdminColors.textLight),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AdminColors.textStrong,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AdminColors.textLight,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

// ─── Dialogs ─────────────────────────────────────────────────────────────────

/// The admin dialog panel. Use it as the `builder` result of `showDialog`
/// in place of an `AlertDialog`: a header with an icon tile, title and close
/// button, a scrolling body and a row of [actions].
class AdminDialog extends StatelessWidget {
  const AdminDialog({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.tone = AdminTone.blue,
    this.actions = const [],
    this.onClose,
    this.maxWidth = 560,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Tints the icon tile, the edge and the glow.
  final AdminTone tone;
  final Widget child;
  final List<Widget> actions;

  /// Shows a close button in the header.
  final VoidCallback? onClose;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final Color accent = tone == AdminTone.slate ? Colors.white : tone.base;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          decoration: BoxDecoration(
            gradient: AdminColors.panelGradient,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: accent.withValues(
                alpha: tone == AdminTone.slate ? 0.12 : 0.35,
              ),
            ),
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 30),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 60,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    20,
                    onClose == null ? 22 : 14,
                    0,
                  ),
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        AdminIconTile(icon: icon!, tone: tone, size: 42),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: AdminColors.textStrong,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                subtitle!,
                                style: const TextStyle(
                                  color: AdminColors.textLight,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (onClose != null) ...[
                        const SizedBox(width: 10),
                        AdminIconAction(
                          icon: Icons.close_rounded,
                          tooltip: 'Close',
                          onPressed: onClose,
                          size: 40,
                        ),
                      ],
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
                    child: child,
                  ),
                ),
                if (actions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      runSpacing: 10,
                      children: actions,
                    ),
                  ),
                if (actions.isEmpty) const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tables ──────────────────────────────────────────────────────────────────

/// Shared text and line styles for admin tables and table-like lists.
abstract final class AdminTable {
  static const TextStyle header = TextStyle(
    color: AdminColors.textHint,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
  );
  static const TextStyle cell = TextStyle(
    color: AdminColors.textBody,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle cellStrong = TextStyle(
    color: AdminColors.textStrong,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle cellMuted = TextStyle(
    color: AdminColors.textSoft,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
  );

  /// The line between rows.
  static const Color divider = Color(0x12FFFFFF);

  /// The fill of a selected or highlighted row (pair it with a cyan edge).
  static const Color selectedRow = Color(0x1F2F6BF0);
  static const Color hoverRow = Color(0x0AFFFFFF);
}
