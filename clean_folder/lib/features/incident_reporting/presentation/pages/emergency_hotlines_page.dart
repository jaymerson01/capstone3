import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/neo/aurora_background.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/neo_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_dialog.dart';
import 'package:community_safety_app/core/presentation/neo/neo_icon_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_tray.dart';
import 'package:community_safety_app/core/utils/direct_caller_helper.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class EmergencyHotlinesPage extends StatelessWidget {
  final void Function(String title, String number)? onCallPressed;

  const EmergencyHotlinesPage({
    super.key,
    this.onCallPressed,
  });

  Future<void> _makeDirectCall(
    BuildContext context,
    String title,
    String number,
  ) async {
    if (onCallPressed != null) {
      onCallPressed!(title, number);
      return;
    }

    await DirectCallerHelper.makeDirectCall(context, number, label: title);
  }

  void _showCallConfirmation(
    BuildContext context,
    String title,
    String number,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NeoDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoDialogIcon(icon: Icons.call_rounded, color: AppColors.danger),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).hotlinesConfirmTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).hotlinesConfirmMessage(title, number),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      label: AppLocalizations.of(context).commonCancel,
                      variant: NeoButtonVariant.standard,
                      height: 48,
                      expand: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      label: AppLocalizations.of(context).commonCallNow,
                      icon: Icons.call_rounded,
                      variant: NeoButtonVariant.emergency,
                      height: 48,
                      expand: true,
                      onPressed: () {
                        Navigator.pop(context);
                        _makeDirectCall(context, title, number);
                      },
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

  /// One service: its icon, name, what to call it for, the number and the
  /// CALL button. [featured] puts it on the dark tray (the barangay desk).
  Widget _buildHotlineCard(
    BuildContext context, {
    required String title,
    required String number,
    required String description,
    required IconData icon,
    required Color accent,
    required int index,
    bool featured = false,
  }) {
    final isDark = AppColors.isDarkMode;
    final iconColor = isDark ? Color.lerp(accent, Colors.white, 0.4)! : accent;

    final content = Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: featured
                ? AppColors.ink
                : accent.withValues(alpha: isDark ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(16),
            border: featured
                ? Border.all(color: AppColors.secondary, width: 2)
                : null,
            boxShadow: featured
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.55),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: featured ? AppColors.secondary : iconColor,
            size: 22,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: featured ? const Color(0xFFF8FAFC) : AppColors.textDark,
                ),
              ),
              SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: featured ? NeoTray.soft : AppColors.textLight,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 4),
              InkWell(
                onTap: () => _makeDirectCall(context, title, number),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: featured
                          ? AppColors.secondaryLight
                          : (isDark ? AppColors.primaryText : AppColors.deepBlue),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        _CallButton(
          live: featured,
          onTap: () => _makeDirectCall(context, title, number),
          onLongPress: () => _showCallConfirmation(context, title, number),
        ),
      ],
    );

    return _AnimatedHotlineCard(
      delay: Duration(milliseconds: 80 * index),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: featured
            ? NeoTray(padding: const EdgeInsets.all(14), child: content)
            : GlassCard(padding: const EdgeInsets.all(14), child: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        final l10n = AppLocalizations.of(context);
        return AuroraBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              bottom: false,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  32 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  // Back + Title
                  Row(
                    children: [
                      NeoIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: l10n.commonBack,
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.welcomeHotlines,
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              l10n.hotlinesPortal,
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    l10n.hotlinesGuestNote,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 18),
                  _buildHotlineCard(
                    context,
                    index: 0,
                    title: l10n.hotlinesPolice,
                    number: '911',
                    description: l10n.hotlinesPoliceDesc,
                    icon: Icons.local_police_outlined,
                    accent: const Color(0xFF1D4ED8),
                  ),
                  _buildHotlineCard(
                    context,
                    index: 1,
                    title: l10n.hotlinesFire,
                    number: '112',
                    description: l10n.hotlinesFireDesc,
                    icon: Icons.local_fire_department_outlined,
                    accent: AppColors.dangerDeep,
                  ),
                  _buildHotlineCard(
                    context,
                    index: 2,
                    title: l10n.hotlinesAmbulance,
                    number: '143',
                    description: l10n.hotlinesAmbulanceDesc,
                    icon: Icons.medical_services_outlined,
                    accent: const Color(0xFFBE185D),
                  ),
                  _buildHotlineCard(
                    context,
                    index: 3,
                    title: l10n.hotlinesBarangay,
                    number: '888-9999',
                    description: l10n.hotlinesBarangayDesc,
                    icon: Icons.phone_in_talk_outlined,
                    accent: AppColors.secondary,
                    featured: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

/// The CALL pill: emergency red with a breathing glow, or live cyan on the
/// dark tray. Tap calls; long-press asks first.
class _CallButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool live;
  const _CallButton({required this.onTap, this.onLongPress, this.live = false});

  @override
  State<_CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<_CallButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = widget.live ? AppColors.secondary : AppColors.danger;
    final foreground = widget.live ? AppColors.ink : Colors.white;
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        return Tooltip(
          message: AppLocalizations.of(context).hotlinesTooltip,
          child: GestureDetector(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: widget.live
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.secondaryLight, AppColors.secondary],
                      )
                    : AppColors.emergencyGradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: glow.withValues(alpha: 0.35 + 0.2 * _pulseCtrl.value),
                    blurRadius: 12 + 8 * _pulseCtrl.value,
                    offset: widget.live ? Offset.zero : const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call_rounded, color: foreground, size: 16),
                  SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).hotlinesCall,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedHotlineCard extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _AnimatedHotlineCard({required this.child, required this.delay});

  @override
  State<_AnimatedHotlineCard> createState() => _AnimatedHotlineCardState();
}

class _AnimatedHotlineCardState extends State<_AnimatedHotlineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
