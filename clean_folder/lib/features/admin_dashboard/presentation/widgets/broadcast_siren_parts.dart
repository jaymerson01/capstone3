import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';

/// The Municipal Emergency Broadcast dialog panel. Wide screens show the
/// active sirens and the transmit form side by side; narrow ones show one
/// at a time under two tabs.
class BroadcastSirenPanel extends StatelessWidget {
  const BroadcastSirenPanel({
    super.key,
    required this.tab,
    required this.onTabChanged,
    required this.onClose,
    required this.activeSirens,
    required this.transmitForm,
  });

  /// 0 shows the active sirens and 1 the transmit form, on narrow screens.
  final int tab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onClose;

  /// Builds the active sirens list. `sideBySide` is true when the transmit
  /// form is visible next to it.
  final Widget Function(BuildContext context, bool sideBySide) activeSirens;
  final Widget transmitForm;

  /// Narrower panels switch to tabs.
  static const double sideBySideWidth = 760;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1040),
      decoration: BoxDecoration(
        gradient: AdminColors.dialogGradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AdminColors.dangerSoft.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AdminColors.critical.withValues(alpha: 0.2),
            blurRadius: 50,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 90,
            offset: const Offset(0, 40),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth >= sideBySideWidth;

          final Widget body = wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _ActiveSirensLabel(),
                          const SizedBox(height: 12),
                          activeSirens(context, true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: transmitForm),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SirenTabs(tab: tab, onChanged: onTabChanged),
                    const SizedBox(height: 16),
                    if (tab == 0)
                      activeSirens(context, false)
                    else
                      transmitForm,
                  ],
                );

          return ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(wide ? 26 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PanelHeader(compact: !wide, onClose: onClose),
                  const SizedBox(height: 20),
                  body,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.compact, required this.onClose});

  final bool compact;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SirenOrb(size: compact ? 44 : 52),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Municipal Emergency Broadcast",
                style: TextStyle(
                  color: AdminColors.textStrong,
                  fontSize: compact ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                "Real-time Siren Transmission & Silence Controls",
                style: TextStyle(
                  color: AdminColors.textHint,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _SquareButton(
          icon: Icons.close_rounded,
          tooltip: "Close",
          size: 44,
          radius: 14,
          onPressed: onClose,
        ),
      ],
    );
  }
}

/// The glowing red siren badge.
class SirenOrb extends StatelessWidget {
  const SirenOrb({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(0, -0.4),
          colors: [AdminColors.danger, AdminColors.dangerDark],
          stops: [0, 0.75],
        ),
        boxShadow: [
          BoxShadow(
            color: AdminColors.danger.withValues(alpha: 0.55),
            blurRadius: 24,
          ),
        ],
      ),
      child: Icon(
        Icons.campaign_rounded,
        color: Colors.white,
        size: size * 0.46,
      ),
    );
  }
}

class _ActiveSirensLabel extends StatelessWidget {
  const _ActiveSirensLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AdminColors.danger,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AdminColors.danger.withValues(alpha: 0.9),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          "ACTIVE SIRENS",
          style: TextStyle(
            color: AdminColors.dangerText,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _SirenTabs extends StatelessWidget {
  const _SirenTabs({required this.tab, required this.onChanged});

  final int tab;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SirenTab(
              icon: Icons.campaign_rounded,
              label: "Active Sirens",
              accent: AdminColors.danger,
              selected: tab == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SirenTab(
              icon: Icons.add_alert_rounded,
              label: "Transmit New",
              accent: AdminColors.primary,
              selected: tab == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SirenTab extends StatelessWidget {
  const _SirenTab({
    required this.icon,
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
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
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? accent : AdminColors.textLight,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? AdminColors.textStrong
                          : AdminColors.textLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
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

/// One live siren with its silence and delete controls.
class ActiveSirenCard extends StatelessWidget {
  const ActiveSirenCard({
    super.key,
    required this.type,
    required this.title,
    required this.sector,
    required this.message,
    required this.timeLabel,
    required this.onSilence,
    required this.onDelete,
  });

  final String type;
  final String title;
  final String sector;
  final String message;
  final String timeLabel;
  final VoidCallback onSilence;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AdminColors.critical.withValues(alpha: 0.18),
            AdminColors.critical.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AdminColors.dangerSoft.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AdminColors.dangerPale,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeLabel,
                style: const TextStyle(
                  color: AdminColors.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AdminColors.textStrong,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AdminColors.cyanSoft,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  sector,
                  style: const TextStyle(
                    color: AdminColors.textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: AdminColors.textSoft,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _SilenceButton(onPressed: onSilence)),
              const SizedBox(width: 8),
              _SquareButton(
                icon: Icons.delete_outline_rounded,
                tooltip: "Delete Record",
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SilenceButton extends StatelessWidget {
  const _SilenceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AdminColors.critical.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AdminColors.dangerSoft.withValues(alpha: 0.7),
                width: 1.5,
              ),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.volume_off_rounded,
                    size: 16,
                    color: AdminColors.dangerPale,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "SILENCE & CLEAR SIREN",
                    style: TextStyle(
                      color: AdminColors.dangerPale,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A square outlined icon button (close, delete).
class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 42,
    this.radius = 12,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Icon(icon, size: 18, color: AdminColors.textSoft),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown when no siren is active.
class SirensClearNotice extends StatelessWidget {
  const SirensClearNotice({super.key, this.onTransmitNew});

  /// Opens the transmit form. Leave null when the form is already visible.
  final VoidCallback? onTransmitNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: AdminColors.success.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AdminColors.success.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AdminColors.successText,
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "All Municipal Sectors Clear",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AdminColors.textStrong,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "There are no active sirens currently broadcasting to citizens.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AdminColors.textLight,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          if (onTransmitNew != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminColors.primaryText,
                side: BorderSide(
                  color: AdminColors.primary.withValues(alpha: 0.7),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              icon: const Icon(Icons.add_alert_rounded, size: 15),
              label: const Text(
                "Transmit New Alert",
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              onPressed: onTransmitNew,
            ),
          ],
        ],
      ),
    );
  }
}

/// The "Transmit new alert" form: title, alert type, target sector and
/// message, then the big red transmit button.
class BroadcastTransmitForm extends StatelessWidget {
  const BroadcastTransmitForm({
    super.key,
    required this.titleController,
    required this.messageController,
    required this.alertTypes,
    required this.alertType,
    required this.onAlertTypeChanged,
    required this.sectors,
    required this.sector,
    required this.onSectorChanged,
    required this.busy,
    required this.onTransmit,
  });

  final TextEditingController titleController;
  final TextEditingController messageController;
  final List<String> alertTypes;
  final String alertType;
  final ValueChanged<String> onAlertTypeChanged;

  /// Stored sector value → the shorter name shown in the picker.
  final Map<String, String> sectors;
  final String sector;
  final ValueChanged<String> onSectorChanged;
  final bool busy;
  final VoidCallback onTransmit;

  static const TextStyle _fieldText = TextStyle(
    color: AdminColors.textDark,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "TRANSMIT NEW ALERT",
            style: TextStyle(
              color: AdminColors.cyanSoft,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          const _FieldLabel("BROADCAST TITLE"),
          TextField(
            controller: titleController,
            style: _fieldText,
            cursorColor: AdminColors.cyan,
            decoration: sirenInputDecoration(
              hint: "e.g. FLASH FLOOD RED ALERT - SAN JOSE",
            ),
          ),
          const SizedBox(height: 14),
          const _FieldLabel("ALERT TYPE"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in alertTypes)
                _AlertTypeChip(
                  label: type,
                  selected: type == alertType,
                  onTap: () => onAlertTypeChanged(type),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const _FieldLabel("TARGET SECTOR"),
          DropdownButtonFormField<String>(
            initialValue: sector,
            dropdownColor: AdminColors.dialogBackground,
            borderRadius: BorderRadius.circular(12),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AdminColors.cyanText,
            ),
            decoration: sirenInputDecoration(accent: AdminColors.cyan),
            selectedItemBuilder: (context) => [
              for (final label in sectors.values)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AdminColors.cyanText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
            items: [
              for (final entry in sectors.entries)
                DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value, style: _fieldText),
                ),
            ],
            onChanged: (v) {
              if (v != null) onSectorChanged(v);
            },
          ),
          const SizedBox(height: 14),
          const _FieldLabel("BROADCAST MESSAGE / INSTRUCTIONS"),
          TextField(
            controller: messageController,
            maxLines: 4,
            style: _fieldText.copyWith(height: 1.45),
            cursorColor: AdminColors.cyan,
            decoration: sirenInputDecoration(
              hint:
                  "State mandatory instructions, evacuation points, emergency hotlines...",
            ),
          ),
          const SizedBox(height: 18),
          SirenTransmitButton(busy: busy, onPressed: busy ? null : onTransmit),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: AdminColors.textHint,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// The dark input wells of the broadcast form. [accent] tints the edge.
InputDecoration sirenInputDecoration({String? hint, Color? accent}) {
  OutlineInputBorder outline(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  final Color rest =
      accent?.withValues(alpha: 0.35) ?? Colors.white.withValues(alpha: 0.12);

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: AdminColors.textHint,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: Colors.black.withValues(alpha: 0.3),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: outline(rest),
    enabledBorder: outline(rest),
    focusedBorder: outline(accent ?? AdminColors.cyan, 1.5),
  );
}

class _AlertTypeChip extends StatelessWidget {
  const _AlertTypeChip({
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
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: selected ? AdminColors.sirenGradient : null,
              color: selected ? null : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: selected
                  ? null
                  : Border.all(color: Colors.white.withValues(alpha: 0.14)),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AdminColors.critical.withValues(alpha: 0.45),
                        blurRadius: 14,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AdminColors.textDark,
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

/// The big red "TRANSMIT SIREN BROADCAST" button.
class SirenTransmitButton extends StatelessWidget {
  const SirenTransmitButton({
    super.key,
    required this.busy,
    required this.onPressed,
  });

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AdminColors.critical, AdminColors.dangerDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AdminColors.dangerSoft.withValues(alpha: 0.5),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: AdminColors.critical.withValues(alpha: 0.45),
              blurRadius: 30,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.campaign_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                    const SizedBox(width: 10),
                    Text(
                      busy ? "TRANSMITTING..." : "TRANSMIT SIREN BROADCAST",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
