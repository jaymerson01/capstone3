import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

/// The full-screen municipal siren alert: rings around a siren, the
/// advisory, where it applies and who sent it, and a big acknowledge button.
/// `EmergencyBroadcastListener` decides when to show it and what it says.
class EmergencySirenAlert extends StatelessWidget {
  final String header;
  final String alertType;
  final String title;
  final String message;
  final String targetLabel;
  final String originLabel;
  final String timeLabel;
  final String acknowledgeLabel;
  final VoidCallback onAcknowledge;

  const EmergencySirenAlert({
    super.key,
    required this.header,
    required this.alertType,
    required this.title,
    required this.message,
    required this.targetLabel,
    required this.originLabel,
    required this.timeLabel,
    required this.acknowledgeLabel,
    required this.onAcknowledge,
  });

  static const Color _soft = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.32),
            radius: 0.95,
            colors: [Color(0xFF4A1420), Color(0xFF1B1424), Color(0xFF0B0F1A)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFF87171).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEF4444),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFFEF4444), blurRadius: 10),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              header,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFFECACA),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 34),
                    const _SirenRings(),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_rounded,
                              size: 15, color: AppColors.warningLight),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              alertType,
                              style: const TextStyle(
                                color: _soft,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _soft,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailLine(
                              icon: Icons.place_outlined, text: targetLabel),
                          const SizedBox(height: 8),
                          _DetailLine(
                              icon: Icons.shield_outlined, text: originLabel),
                          const SizedBox(height: 8),
                          _DetailLine(
                              icon: Icons.access_time_rounded, text: timeLabel),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: AppColors.danger.withValues(alpha: 0.45),
                            blurRadius: 34,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size.fromHeight(60),
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          icon: const Icon(Icons.check_circle_outline,
                              size: 20),
                          label: Text(acknowledgeLabel),
                          onPressed: onAcknowledge,
                        ),
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

/// Red rings around the siren disc, with a live cyan ring in between.
class _SirenRings extends StatelessWidget {
  const _SirenRings();

  @override
  Widget build(BuildContext context) {
    Widget ring(double size, Color color, double width,
            [List<BoxShadow>? glow]) =>
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: width),
            boxShadow: glow,
          ),
        );

    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ring(210, const Color(0xFFEF4444).withValues(alpha: 0.25), 2),
          ring(164, const Color(0xFFEF4444).withValues(alpha: 0.45), 2, [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.25),
              blurRadius: 30,
            ),
          ]),
          ring(120, AppColors.secondary, 3, [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.55),
              blurRadius: 26,
            ),
          ]),
          Container(
            width: 98,
            height: 98,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(0, -0.4),
                radius: 0.75,
                colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.6),
                  blurRadius: 40,
                ),
              ],
            ),
            child: const Icon(Icons.campaign_rounded,
                color: Colors.white, size: 46),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryLight),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: EmergencySirenAlert._soft,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
