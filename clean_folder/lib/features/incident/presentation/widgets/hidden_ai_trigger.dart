import 'dart:async';
import 'package:flutter/material.dart';

class HiddenAiTrigger extends StatefulWidget {
  final Widget child;
  final VoidCallback onTriggered;

  const HiddenAiTrigger({
    super.key,
    required this.child,
    required this.onTriggered,
  });

  @override
  State<HiddenAiTrigger> createState() => _HiddenAiTriggerState();
}

class _HiddenAiTriggerState extends State<HiddenAiTrigger> {
  int _tapCount = 0;
  Timer? _resetTimer;

  void _handleTap() {
    setState(() {
      _tapCount++;
    });

    // Cancel any existing timer to restart the countdown
    _resetTimer?.cancel();

    if (_tapCount == 5) {
      // Reached the target, reset and trigger
      _tapCount = 0;
      widget.onTriggered();
      
      // Provide immediate feedback via SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Intelligent Triage Engine Activated: Handshake Sequence Engaged."),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Start a 2-second timer to reset the count if they stop tapping
      _resetTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _tapCount = 0;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}
