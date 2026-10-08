import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/core/utils/direct_caller_helper.dart';

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
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
                color: AppColors.danger.withValues(alpha: 0.3), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.danger.withValues(alpha: 0.12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.danger.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(Icons.call,
                      color: AppColors.danger, size: 32),
                ),
                SizedBox(height: 16),
                Text(
                  'Call Dispatch Line?',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Are you sure you want to dial the official hotline for $title ($number) now?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.textLight),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.emergencyGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppColors.dangerGlowShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.pop(context);
                              _makeDirectCall(context, title, number);
                            },
                            child: Center(
                              child: Text(
                                'Call Now',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHotlineCard(
    BuildContext context, {
    required String title,
    required String number,
    required String description,
    required IconData icon,
    required int index,
  }) {
    return _AnimatedHotlineCard(
      delay: Duration(milliseconds: 80 * index),
      child: Custom3dCard(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        glowColor: AppColors.danger,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.danger.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.danger, size: 26),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _makeDirectCall(context, title, number),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone,
                                  size: 13, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text(
                                number,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      _CallButton(
                        onTap: () => _makeDirectCall(context, title, number),
                        onLongPress: () =>
                            _showCallConfirmation(context, title, number),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // ── Gradient Header Background ──────────────────────────────────
              Container(
                height: 220 + MediaQuery.of(context).padding.top,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1A0A0E), const Color(0xFF2D0A0F)]
                        : [const Color(0xFFFFF0F2), const Color(0xFFFFE5E9)],
                  ),
                  border: isDark
                      ? null
                      : Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: isDark ? 0.15 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),

              // Ambient danger glow
              Positioned(
                top: 0,
                right: -40,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.danger.withValues(alpha: isDark ? 0.1 : 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back + Title
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : AppColors.border,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back,
                                  color: AppColors.textDark, size: 18),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Emergency Hotlines',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.emergency,
                                    color: AppColors.danger, size: 18),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'EMERGENCY CALL PORTAL',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Unauthenticated guest access enabled. Dial emergency responders directly below.',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                SizedBox(height: 10),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 28),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildHotlineCard(
                          context,
                          index: 0,
                          title: 'Police Department Dispatch',
                          number: '911',
                          description:
                              'Immediate criminal activity reporting, neighborhood patrols, threat neutralization, and public order enforcement.',
                          icon: Icons.local_police_outlined,
                        ),
                        _buildHotlineCard(
                          context,
                          index: 1,
                          title: 'Fire Command Station',
                          number: '112',
                          description:
                              'Structural active fire emergencies, hazardous chemical leak containment, and immediate search and rescue ops.',
                          icon: Icons.local_fire_department_outlined,
                        ),
                        _buildHotlineCard(
                          context,
                          index: 2,
                          title: 'Ambulance Medical Team',
                          number: '143',
                          description:
                              'Severe medical trauma support, critical emergency patient transport, and emergency responder dispatch.',
                          icon: Icons.medical_services_outlined,
                        ),
                        _buildHotlineCard(
                          context,
                          index: 3,
                          title: 'Barangay Desk Center',
                          number: '888-9999',
                          description:
                              'Barangay Moonwalk local safety reports, minor community disputes, security desk coordination, and assistance.',
                          icon: Icons.phone_in_talk_outlined,
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _CallButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _CallButton({required this.onTap, this.onLongPress});

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
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        return Tooltip(
          message: 'Tap to call directly • Long-press for confirmation',
          child: GestureDetector(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                gradient: AppColors.emergencyGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.danger
                        .withValues(alpha: 0.35 + 0.2 * _pulseCtrl.value),
                    blurRadius: 12 + 8 * _pulseCtrl.value,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call, color: AppColors.textDark, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'CALL',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
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
