import 'package:flutter/material.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/neo_button.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_text_field.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/domain/repositories/incident_repository.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// On the reporter's own resolved report: rate the barangay's response with
/// 1-5 stars and an optional comment, once. Afterwards shows the rating.
class RateResponseCard extends StatefulWidget {
  const RateResponseCard({super.key, required this.incident, this.repository});

  final IncidentEntity incident;

  /// Defaults to the registered repository.
  final IncidentRepository? repository;

  @override
  State<RateResponseCard> createState() => _RateResponseCardState();
}

class _RateResponseCardState extends State<RateResponseCard> {
  final TextEditingController _comment = TextEditingController();
  int _stars = 0;
  bool _sending = false;

  /// The rating just sent, shown before the live report catches up.
  int? _sent;
  String? _sentComment;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      await (widget.repository ?? sl<IncidentRepository>())
          .rateIncident(widget.incident.id, _stars, comment: _comment.text);
      if (mounted) {
        setState(() {
          _sent = _stars;
          _sentComment = _comment.text.trim();
        });
      }
    } catch (e) {
      debugPrint('[RateResponse] $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).rateFailed),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rated = _sent ?? widget.incident.rating;
    final comment = _sent != null ? _sentComment : widget.incident.ratingComment;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rated == null ? l10n.rateTitle : l10n.rateYourRating,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            rated == null ? l10n.rateSubtitle : l10n.rateThanks,
            style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.4),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: l10n.rateStars(rated ?? _stars),
            child: Row(
              children: [
                for (var star = 1; star <= 5; star++)
                  IconButton(
                    key: Key('rate-star-$star'),
                    tooltip: l10n.rateStars(star),
                    iconSize: 34,
                    visualDensity: VisualDensity.compact,
                    onPressed: rated != null || _sending ? null : () => setState(() => _stars = star),
                    icon: Icon(
                      star <= (rated ?? _stars) ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: star <= (rated ?? _stars) ? const Color(0xFFF59E0B) : AppColors.textLight,
                    ),
                  ),
              ],
            ),
          ),
          if (rated != null && comment != null && comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('“$comment”', style: TextStyle(fontSize: 13.5, color: AppColors.textDark, height: 1.4)),
          ],
          if (rated == null && _stars > 0) ...[
            const SizedBox(height: 10),
            Custom3dTextField(
              controller: _comment,
              labelText: l10n.rateCommentLabel,
              hintText: l10n.rateCommentHint,
              prefixIcon: Icons.rate_review_outlined,
              maxLines: 3,
              inset: true,
            ),
            const SizedBox(height: 12),
            NeoButton(
              label: _sending ? l10n.rateSending : l10n.rateSubmit,
              icon: Icons.send_rounded,
              expand: true,
              onPressed: _sending ? null : _send,
            ),
          ],
        ],
      ),
    );
  }
}
