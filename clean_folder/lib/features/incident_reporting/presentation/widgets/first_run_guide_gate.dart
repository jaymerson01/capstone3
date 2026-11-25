import 'package:flutter/material.dart';
import 'package:community_safety_app/core/services/first_run_guide.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/instruction_video_page.dart';

/// Opens the "How to use ResQ" guide over the app the first time it opens on
/// this device, before signing in. Once it is watched or skipped it only
/// opens from the Home screen.
class FirstRunGuideGate extends StatefulWidget {
  const FirstRunGuideGate({super.key, required this.child});

  final Widget child;

  @override
  State<FirstRunGuideGate> createState() => _FirstRunGuideGateState();
}

class _FirstRunGuideGateState extends State<FirstRunGuideGate> {
  @override
  void initState() {
    super.initState();
    if (FirstRunGuide.pending) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showGuide());
    }
  }

  Future<void> _showGuide() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const InstructionVideoPage(firstRun: true),
      ),
    );
    await FirstRunGuide.markSeen();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
