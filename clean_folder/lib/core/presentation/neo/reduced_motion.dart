import 'package:flutter/widgets.dart';

/// Runs a looping decorative animation (a pulse or a glow) only while the
/// system allows motion. With "Remove animations" on (Android), or reduced
/// motion in the browser, it rests at its start instead, which also spares
/// low-end phones a full redraw every frame. Call it from
/// `didChangeDependencies`, so it follows the setting when it changes.
void syncLoop(AnimationController controller, BuildContext context) {
  if (MediaQuery.disableAnimationsOf(context)) {
    // Setting the value also stops it.
    controller.value = 0;
  } else if (!controller.isAnimating) {
    controller.repeat(reverse: true);
  }
}
