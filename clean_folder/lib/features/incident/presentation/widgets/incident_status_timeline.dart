import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import '../../domain/entities/incident_entity.dart';
import '../helpers/safety_kits_provider.dart';

class IncidentStatusTimeline extends StatelessWidget {
  final IncidentEntity incident;

  const IncidentStatusTimeline({
    super.key,
    required this.incident,
  });

  @override
  Widget build(BuildContext context) {
    final instructions = SafetyKitsProvider.getInstructionsForCategory(incident.category);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Safety Action Protocol',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...instructions.map((instruction) => _buildInstructionRow(context, instruction)),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.progress.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.timeline, color: AppColors.progress, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Incident Resolution Stage',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (incident.isInProgress &&
              incident.estimatedResponseTime != null &&
              incident.estimatedResponseTime!.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFF00E5FF), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Responders on the way • Estimated Arrival: ${incident.estimatedResponseTime!}",
                      style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          _buildStatusTimeline(context),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: _parseMarkdownString(text, context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parseMarkdownString(String text, BuildContext context) {
    final spans = <TextSpan>[];
    final parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      
      if (i % 2 == 0) {
        // Normal text
        spans.add(TextSpan(
          text: parts[i],
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 13,
            height: 1.45,
          ),
        ));
      } else {
        // Bold keyword text
        spans.add(TextSpan(
          text: parts[i],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontSize: 13,
            height: 1.45,
          ),
        ));
      }
    }
    return spans;
  }

  Widget _buildStatusTimeline(BuildContext context) {
    final status = incident.status.toLowerCase();
    
    final n1Color = _getNode1Color(status);
    final l1Color = _getLine1Color(status);
    final n2Color = _getNode2Color(status);
    final l2Color = _getLine2Color(status);
    final n3Color = _getNode3Color(status);

    final isN1Active = status == 'pending' || status == 'inprogress' || status == 'in progress' || status == 'resolved' || status == 'solved';
    final isN2Active = status == 'inprogress' || status == 'in progress' || status == 'resolved' || status == 'solved';
    final isN3Active = status == 'resolved' || status == 'solved';

    final isN1Pulsing = status == 'pending';
    final isN2Pulsing = status == 'inprogress' || status == 'in progress';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNode('Pending', isN1Pulsing, isN1Active, n1Color),
        _buildLine(l1Color),
        _buildNode('In Progress', isN2Pulsing, isN2Active, n2Color),
        _buildLine(l2Color),
        _buildNode('Resolved', false, isN3Active, n3Color),
      ],
    );
  }

  Color _getNode1Color(String status) {
    if (status == 'resolved' || status == 'solved') return AppColors.solved;
    return AppColors.pending;
  }

  Color _getLine1Color(String status) {
    if (status == 'resolved' || status == 'solved') return AppColors.solved;
    if (status == 'inprogress' || status == 'in progress') return AppColors.progress;
    return AppColors.border;
  }

  Color _getNode2Color(String status) {
    if (status == 'resolved' || status == 'solved') return AppColors.solved;
    if (status == 'inprogress' || status == 'in progress') return AppColors.progress;
    return AppColors.border;
  }

  Color _getLine2Color(String status) {
    if (status == 'resolved' || status == 'solved') return AppColors.solved;
    return AppColors.border;
  }

  Color _getNode3Color(String status) {
    if (status == 'resolved' || status == 'solved') return AppColors.solved;
    return AppColors.border;
  }

  Widget _buildLine(Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 11),
        height: 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildNode(String label, bool isPulsating, bool isActive, Color activeColor) {
    final circle = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? activeColor : AppColors.surfaceLight,
        border: Border.all(
          color: isActive ? activeColor.withValues(alpha: 0.6) : AppColors.border,
          width: isActive ? 3 : 1.5,
        ),
        boxShadow: isActive && isPulsating
            ? [BoxShadow(color: activeColor.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)]
            : null,
      ),
      child: isActive && !isPulsating
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );

    return SizedBox(
      width: 68,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPulsating)
            _PulsatingNode(child: circle)
          else
            circle,
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : AppColors.textLight,
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
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
