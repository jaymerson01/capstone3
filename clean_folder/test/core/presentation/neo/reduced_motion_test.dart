import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/presentation/neo/reduced_motion.dart';

/// A pulse that follows the reduced-motion setting, like the app's.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.onController});

  final void Function(AnimationController) onController;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();
    widget.onController(_ctrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncLoop(_ctrl, context);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  late AnimationController ctrl;

  Widget app({required bool reduceMotion}) => MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: _Pulse(onController: (c) => ctrl = c),
      );

  testWidgets('it pulses when motion is allowed', (tester) async {
    await tester.pumpWidget(app(reduceMotion: false));
    expect(ctrl.isAnimating, isTrue);
  });

  testWidgets('it rests at the start with "Remove animations" on',
      (tester) async {
    await tester.pumpWidget(app(reduceMotion: true));
    expect(ctrl.isAnimating, isFalse);
    expect(ctrl.value, 0);
  });

  testWidgets('it follows the setting when it changes', (tester) async {
    await tester.pumpWidget(app(reduceMotion: false));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(app(reduceMotion: true));
    expect(ctrl.isAnimating, isFalse);
    expect(ctrl.value, 0);

    await tester.pumpWidget(app(reduceMotion: false));
    expect(ctrl.isAnimating, isTrue);
  });
}
