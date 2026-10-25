import 'package:flutter/material.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/live_indicator.dart';
import 'package:community_safety_app/core/presentation/neo/neo_status_pill.dart';
import 'package:community_safety_app/core/presentation/neo/neo_tag.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';
import 'package:community_safety_app/features/incident/presentation/widgets/incident_category_visuals.dart';
import 'package:community_safety_app/core/presentation/neo/word_safe_text.dart';

/// One of the resident's own reports in My Reports: the category, where and
/// when, the status, whether it reached the command center, and any tags
/// (filed for someone else, the responders' ETA). The whole card opens it.
class MyReportCard extends StatelessWidget {
  final String storedCategory;
  final String categoryLabel;
  final String location;
  final String time;
  final String statusLabel;
  final Color statusColor;
  final bool isSynced;
  final String syncLabel;
  final String? onBehalfLabel;
  final String? etaLabel;
  final String viewDetailsLabel;

  /// Rings the card in blue, for reports the responders are working on.
  final bool highlight;
  final VoidCallback onTap;

  const MyReportCard({
    super.key,
    required this.storedCategory,
    required this.categoryLabel,
    required this.location,
    required this.time,
    required this.statusLabel,
    required this.statusColor,
    required this.isSynced,
    required this.syncLabel,
    this.onBehalfLabel,
    this.etaLabel,
    required this.viewDetailsLabel,
    this.highlight = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onBehalf = onBehalfLabel;
    final eta = etaLabel;
    // With large text the status pill joins the tags under the header, so
    // the category, place and time keep the card's width.
    final pillBelow = MediaQuery.textScalerOf(context).scale(15) > 15 * 1.15;
    final pill = NeoStatusPill(label: statusLabel, color: statusColor);

    Widget card = GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: NeoRadii.card,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IncidentCategoryTile(storedCategory: storedCategory),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WordSafeText(
                      categoryLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _MetaLine(icon: Icons.location_on_outlined, text: location),
                    const SizedBox(height: 2),
                    _MetaLine(icon: Icons.access_time_rounded, text: time),
                  ],
                ),
              ),
              if (!pillBelow) ...[
                const SizedBox(width: 8),
                pill,
              ],
            ],
          ),
          if (pillBelow || onBehalf != null || eta != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (pillBelow) pill,
                if (onBehalf != null)
                  NeoTag(
                    icon: Icons.person_pin_circle_outlined,
                    label: onBehalf,
                    color: AppColors.onBehalf,
                  ),
                if (eta != null)
                  NeoTag(
                    icon: Icons.timer_outlined,
                    label: eta,
                    color: AppColors.secondary,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SyncChip(isSynced: isSynced, label: syncLabel),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  viewDetailsLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.primaryText,
              ),
            ],
          ),
        ],
      ),
    );

    if (highlight) {
      card = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NeoRadii.card),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: card,
      );
    }
    return MergeSemantics(child: Semantics(button: true, child: card));
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textLight),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

/// "Live" (reached the command center, on an ink pill with the cyan dot) or
/// "Local" (still only on this phone, on a grey pill).
class SyncChip extends StatelessWidget {
  final bool isSynced;
  final String label;

  const SyncChip({super.key, required this.isSynced, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    final Color background;
    final Color foreground;
    if (isSynced) {
      background = AppColors.ink;
      foreground = const Color(0xFFF8FAFC);
    } else {
      background = isDark ? AppColors.surfaceLight : const Color(0xFFE2E8F0);
      foreground = isDark ? AppColors.textLight : const Color(0xFF334155);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(NeoRadii.pill),
        border: isSynced && isDark
            ? Border.all(color: AppColors.secondary.withValues(alpha: 0.35))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSynced)
            const LiveIndicator(size: 7)
          else
            Icon(Icons.smartphone_rounded, size: 12, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
