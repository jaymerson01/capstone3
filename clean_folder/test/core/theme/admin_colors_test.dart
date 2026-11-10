import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  test('admin text colors stay readable on every admin surface', () {
    const surfaces = {
      'background': AdminColors.background,
      'cardBackground': AdminColors.cardBackground,
      'surfaceRaised': AdminColors.surfaceRaised,
      'dialogBackground': AdminColors.dialogBackground,
    };
    const texts = {
      'textStrong': AdminColors.textStrong,
      'textDark': AdminColors.textDark,
      'textSoft': AdminColors.textSoft,
      'textLight': AdminColors.textLight,
      'textHint': AdminColors.textHint,
      'textMuted': AdminColors.textMuted,
    };

    for (final surface in surfaces.entries) {
      for (final text in texts.entries) {
        expect(
          _contrast(text.value, surface.value),
          greaterThanOrEqualTo(4.5),
          reason: '${text.key} on ${surface.key}',
        );
      }
    }
  });

  test('white labels stay readable on the blue and red buttons', () {
    for (final fill in [
      AdminColors.primary,
      AdminColors.critical,
      AdminColors.dangerDeep,
    ]) {
      expect(_contrast(Colors.white, fill), greaterThanOrEqualTo(4.5));
    }
  });
}
