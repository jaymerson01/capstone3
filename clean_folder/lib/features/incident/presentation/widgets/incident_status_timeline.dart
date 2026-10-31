import 'package:flutter/material.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/neo_surface.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import '../../domain/entities/incident_entity.dart';
import '../helpers/safety_kits_provider.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';
import 'package:community_safety_app/core/presentation/neo/reduced_motion.dart';

/// The report's resolution stage (Pending → In Progress → Resolved) and the
/// safety steps for its category, as two glass cards.
class IncidentStatusTimeline extends StatelessWidget {
  final IncidentEntity incident;

  const IncidentStatusTimeline({
    super.key,
    required this.incident,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final instructions = SafetyKitsProvider.getInstructionsForCategory(
      l10n,
      incident.category,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitle(
                icon: Icons.timeline_rounded,
                color: AppColors.primary,
                title: l10n.timelineResolutionStage,
              ),
              const SizedBox(height: 16),
              _buildStages(l10n),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitle(
                icon: Icons.health_and_safety_outlined,
                color: AppColors.danger,
                title: l10n.timelineSafetyProtocol,
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < instructions.length; i++)
                _buildInstructionRow(i + 1, instructions[i]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStages(AppLocalizations l10n) {
    // How many stages are finished, and which one is happening now.
    final int done;
    final int? current;
    if (incident.isSolved) {
      done = 3;
      current = null;
    } else if (incident.isInProgress) {
      done = 1;
      current = 1;
    } else if (incident.isPending) {
      done = 0;
      current = 0;
    } else {
      done = 0;
      current = null;
    }

    final eta = incident.estimatedResponseTime;
    final stages = [
      (l10n.statusPending, null),
      (
        l10n.statusInProgress,
        incident.isInProgress && eta != null && eta.isNotEmpty
            ? l10n.timelineRespondersOnTheWay(eta)
            : null,
      ),
      (l10n.statusResolved, null),
    ];
    final doneColor = incident.isSolved ? AppColors.solved : AppColors.primary;
    bool reached(int i) => i < done || i == current;

    return Column(
      children: [
        for (var i = 0; i < stages.length; i++)
          _StageRow(
            label: stages[i].$1,
            detail: stages[i].$2,
            state: i < done
                ? _StageState.done
                : (i == current ? _StageState.current : _StageState.upcoming),
            doneColor: doneColor,
            lineColor: i == stages.length - 1
                ? null
                : (reached(i + 1) ? doneColor : AppColors.border),
          ),
      ],
    );
  }

  Widget _buildInstructionRow(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: NeoSurface.inset(),
            child: Text(
              '$number',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(TextSpan(children: _parseMarkdownString(text))),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parseMarkdownString(String text) {
    final spans = <TextSpan>[];
    final parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;

      // Odd parts sat between ** markers: the bold keywords.
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          color: i % 2 == 0
              ? AppColors.textDark.withValues(alpha: 0.85)
              : AppColors.textDark,
          fontSize: 13.5,
          height: 1.45,
          fontWeight: i % 2 == 0 ? FontWeight.w500 : FontWeight.w800,
        ),
      ));
    }
    return spans;
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const _CardTitle({
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 19,
            color: isDark ? Color.lerp(color, Colors.white, 0.4) : color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

enum _StageState { done, current, upcoming }

/// One stage: its node and the line down to the next one, then the label.
class _StageRow extends StatelessWidget {
  final String label;
  final String? detail;
  final _StageState state;
  final Color doneColor;

  /// The line to the next stage; null for the last one.
  final Color? lineColor;

  const _StageRow({
    required this.label,
    required this.detail,
    required this.state,
    required this.doneColor,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    final line = lineColor;
    final detailText = detail;

    final Widget node;
    switch (state) {
      case _StageState.done:
        node = Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [doneColor, Color.lerp(doneColor, AppColors.ink, 0.2)!],
            ),
            boxShadow: [
              BoxShadow(
                color: doneColor.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, size: 17, color: Colors.white),
        );
      case _StageState.current:
        node = _PulsatingNode(
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.ink,
              border: Border.all(color: AppColors.secondary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.7),
                  blurRadius: 14,
                ),
              ],
            ),
          ),
        );
      case _StageState.upcoming:
        node = Container(
          width: 30,
          height: 30,
          decoration: NeoSurface.inset(),
        );
    }

    final labelColor = switch (state) {
      _StageState.done => AppColors.textDark,
      _StageState.current =>
        isDark ? AppColors.secondaryLight : const Color(0xFF0E7490),
      _StageState.upcoming => AppColors.textLight,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                node,
                if (line != null)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: line,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: line == null ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: labelColor,
                    ),
                  ),
                  if (detailText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      detailText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsatingNode extends StatefulWidget {
  final Widget child;
  const _PulsatingNode({required this.child});

  @override
  State<_PulsatingNode> createState() => _PulsatingNodeState();
}

class _PulsatingNodeState extends State<_PulsatingNode> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncLoop(_controller, context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}
