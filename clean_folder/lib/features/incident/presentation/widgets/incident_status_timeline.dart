import 'package:flutter/material.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Safety Action Kit',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 16),
          ...instructions.map((instruction) => _buildInstructionRow(context, instruction)),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          Text(
            'Incident Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 20),
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
          Icon(
            Icons.check_circle_rounded,
            color: Colors.redAccent.shade400,
            size: 22,
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                height: 1.4,
              ),
        ));
      } else {
        // Bold keyword text
        spans.add(TextSpan(
          text: parts[i],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.4,
              ),
        ));
      }
    }
    return spans;
  }

  Widget _buildStatusTimeline(BuildContext context) {
    final status = incident.status;
    
    final n1Color = _getNode1Color(status);
    final l1Color = _getLine1Color(status);
    final n2Color = _getNode2Color(status);
    final l2Color = _getLine2Color(status);
    final n3Color = _getNode3Color(status);

    final isN1Active = status == 'pending' || status == 'inProgress' || status == 'resolved';
    final isN2Active = status == 'inProgress' || status == 'resolved';
    final isN3Active = status == 'resolved';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNode('Pending', status == 'pending', isN1Active, n1Color),
        _buildLine(l1Color),
        _buildNode('In Progress', status == 'inProgress', isN2Active, n2Color),
        _buildLine(l2Color),
        _buildNode('Resolved', false, isN3Active, n3Color),
      ],
    );
  }

  Color _getNode1Color(String status) {
    if (status == 'resolved') return Colors.green;
    return Colors.amber.shade600;
  }

  Color _getLine1Color(String status) {
    if (status == 'resolved') return Colors.green;
    if (status == 'inProgress') return Colors.blue.shade800;
    return Colors.grey.shade300;
  }

  Color _getNode2Color(String status) {
    if (status == 'resolved') return Colors.green;
    if (status == 'inProgress') return Colors.blue.shade800;
    return Colors.grey.shade300;
  }

  Color _getLine2Color(String status) {
    if (status == 'resolved') return Colors.green;
    return Colors.grey.shade300;
  }

  Color _getNode3Color(String status) {
    if (status == 'resolved') return Colors.green;
    return Colors.grey.shade300;
  }

  Widget _buildLine(Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 10), // Offset 10px down to align perfectly with the 24px circle center
        height: 4,
        color: color,
      ),
    );
  }

  Widget _buildNode(String label, bool isPulsating, bool isActive, Color activeColor) {
    final circle = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? activeColor : Colors.white,
        border: Border.all(
          color: isActive ? activeColor.withOpacity(0.5) : Colors.grey.shade300,
          width: isActive ? 4 : 2,
        ),
        boxShadow: isActive && isPulsating
            ? [BoxShadow(color: activeColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)]
            : null,
      ),
      child: isActive && !isPulsating
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );

    return SizedBox(
      width: 60, // Fixed width to ensure the text centers cleanly under the node
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
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? activeColor : Colors.grey,
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
    _animation = Tween<double>(begin: 1.0, end: 1.25).animate(
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
