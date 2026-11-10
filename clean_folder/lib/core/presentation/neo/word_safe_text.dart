import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Text that never breaks a word in the middle.
///
/// When its longest word is wider than the space it gets (long Filipino
/// words, large text settings, small phones), the text shrinks just enough
/// for that word to fit, but not below [minScale]. Otherwise it is a plain
/// [Text]: it wraps between words and honours [maxLines] and [overflow].
/// Unlike a LayoutBuilder it answers intrinsic-size queries, so it is safe
/// inside IntrinsicHeight rows, dialogs and buttons.
class WordSafeText extends StatelessWidget {
  const WordSafeText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.minScale = 0.72,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  /// The smallest size it shrinks to, as a share of the normal size.
  final double minScale;

  @override
  Widget build(BuildContext context) {
    final defaults = DefaultTextStyle.of(context);
    var effective = defaults.style.merge(style);
    if (MediaQuery.boldTextOf(context)) {
      effective = effective.merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    final metrics = _WordSafeMetrics(
      text: data,
      style: effective,
      textAlign: textAlign ?? defaults.textAlign ?? TextAlign.start,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: maxLines ?? defaults.maxLines,
      overflow: overflow ?? effective.overflow ?? defaults.overflow,
      textWidthBasis: defaults.textWidthBasis,
      textHeightBehavior:
          defaults.textHeightBehavior ?? DefaultTextHeightBehavior.maybeOf(context),
      locale: Localizations.maybeLocaleOf(context),
      minScale: minScale,
    );
    return _WordSafeLayout(
      metrics: metrics,
      builder: (context, constraints) => Text(
        data,
        style: metrics.styleFor(constraints.maxWidth),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Measures the text the way [Text] lays it out, at the shrunk size.
@immutable
class _WordSafeMetrics {
  _WordSafeMetrics({
    required this.text,
    required this.style,
    required this.textAlign,
    required this.textDirection,
    required this.textScaler,
    required this.maxLines,
    required this.overflow,
    required this.textWidthBasis,
    required this.textHeightBehavior,
    required this.locale,
    required this.minScale,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final int? maxLines;
  final TextOverflow overflow;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Locale? locale;
  final double minScale;

  late final double longestWord = _measureLongestWord();

  double _measureLongestWord() {
    final probe = TextPainter(
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
      locale: locale,
    );
    var widest = 0.0;
    // Lines may also break after a hyphen ("Kahina-hinalang").
    for (final word in text.split(RegExp(r'\s+|(?<=-)'))) {
      if (word.isEmpty) continue;
      probe
        ..text = TextSpan(text: word, style: style)
        ..layout();
      widest = math.max(widest, probe.width);
    }
    probe.dispose();
    return widest;
  }

  /// The style that lets the widest word fit [width].
  TextStyle styleFor(double width) {
    if (!width.isFinite || longestWord <= width || longestWord == 0) {
      return style;
    }
    // A hair under the exact ratio, so rounding never pushes it back over.
    final scale = math.max(minScale, width / longestWord * 0.995);
    return style.copyWith(
      fontSize: (style.fontSize ?? 14) * scale,
      letterSpacing: style.letterSpacing == null
          ? null
          : style.letterSpacing! * scale,
    );
  }

  TextPainter _painterFor(BoxConstraints constraints) {
    return TextPainter(
      text: TextSpan(text: text, style: styleFor(constraints.maxWidth)),
      textAlign: textAlign,
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '…' : null,
      locale: locale,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    )..layout(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
  }

  Size sizeFor(BoxConstraints constraints) {
    final painter = _painterFor(constraints);
    final size = constraints.constrain(painter.size);
    painter.dispose();
    return size;
  }

  double? baselineFor(BoxConstraints constraints, TextBaseline baseline) {
    final painter = _painterFor(constraints);
    final distance = painter.computeDistanceToActualBaseline(baseline);
    painter.dispose();
    return distance;
  }

  double get maxIntrinsicWidth {
    final painter = _painterFor(const BoxConstraints());
    final width = painter.width;
    painter.dispose();
    return width;
  }

  @override
  bool operator ==(Object other) =>
      other is _WordSafeMetrics &&
      other.text == text &&
      other.style == style &&
      other.textAlign == textAlign &&
      other.textDirection == textDirection &&
      other.textScaler == textScaler &&
      other.maxLines == maxLines &&
      other.overflow == overflow &&
      other.textWidthBasis == textWidthBasis &&
      other.textHeightBehavior == textHeightBehavior &&
      other.locale == locale &&
      other.minScale == minScale;

  @override
  int get hashCode => Object.hash(
        text,
        style,
        textAlign,
        textDirection,
        textScaler,
        maxLines,
        overflow,
        textWidthBasis,
        textHeightBehavior,
        locale,
        minScale,
      );
}

/// A LayoutBuilder that answers intrinsic queries from [metrics] instead of
/// throwing.
class _WordSafeLayout extends ConstrainedLayoutBuilder<BoxConstraints> {
  const _WordSafeLayout({required this.metrics, required super.builder});

  final _WordSafeMetrics metrics;

  @override
  RenderAbstractLayoutBuilderMixin<BoxConstraints, RenderBox> createRenderObject(
    BuildContext context,
  ) => _RenderWordSafeLayout(metrics);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderWordSafeLayout renderObject,
  ) {
    renderObject.metrics = metrics;
  }
}

class _RenderWordSafeLayout extends RenderBox
    with
        RenderObjectWithChildMixin<RenderBox>,
        RenderObjectWithLayoutCallbackMixin,
        RenderAbstractLayoutBuilderMixin<BoxConstraints, RenderBox> {
  _RenderWordSafeLayout(this._metrics);

  _WordSafeMetrics _metrics;
  set metrics(_WordSafeMetrics value) {
    if (value == _metrics) return;
    _metrics = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _metrics.longestWord * _metrics.minScale;

  @override
  double computeMaxIntrinsicWidth(double height) => _metrics.maxIntrinsicWidth;

  @override
  double computeMinIntrinsicHeight(double width) =>
      _metrics.sizeFor(BoxConstraints(maxWidth: width)).height;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _metrics.sizeFor(constraints);

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) => _metrics.baselineFor(constraints, baseline);

  @override
  void performLayout() {
    runLayoutCallback();
    final child = this.child;
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child.size);
    } else {
      size = constraints.smallest;
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      child?.getDistanceToActualBaseline(baseline) ??
      super.computeDistanceToActualBaseline(baseline);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      child?.hitTest(result, position: position) ?? false;

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child != null) context.paintChild(child, offset);
  }
}
