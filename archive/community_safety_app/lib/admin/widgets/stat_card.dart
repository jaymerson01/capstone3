import 'package:flutter/material.dart';

/// RESQ Command Center StatCard — count-up animation, glassmorphism, glow
class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    this.textColor = Colors.white,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _countController;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;
  int _displayValue = 0;
  int _targetValue = 0;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _parseAndAnimate();
  }

  void _parseAndAnimate() {
    final parsed = int.tryParse(widget.value) ?? 0;
    _targetValue = parsed;

    _countController.addListener(() {
      setState(() {
        _displayValue =
            (_targetValue * _countController.value).round();
      });
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _countController.forward();
      }
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNumeric = int.tryParse(widget.value) != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translate(0.0, _isHovered ? -6.0 : 0.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.backgroundColor,
                  widget.backgroundColor.withValues(alpha: 0.78),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withValues(
                      alpha: _isHovered
                          ? 0.5 * _glowAnim.value
                          : 0.25 * _glowAnim.value),
                  blurRadius: _isHovered ? 28 : 16,
                  offset: Offset(0, _isHovered ? 10 : 6),
                  spreadRadius: _isHovered ? 2 : 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // ── Ambient Icon Background ───────────────────────────────
              Positioned(
                bottom: -20,
                right: -18,
                child: Icon(
                  widget.icon,
                  size: 110,
                  color: widget.textColor.withValues(alpha: 0.08),
                ),
              ),
              // ── Glossy top shine ──────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // ── Content ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon badge
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.textColor,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    // Animated count value
                    AnimatedBuilder(
                      animation: _countController,
                      builder: (context, _) {
                        return Text(
                          isNumeric ? _displayValue.toString() : widget.value,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: widget.textColor,
                            height: 1.0,
                            letterSpacing: -0.5,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: widget.textColor.withValues(alpha: 0.75),
                        letterSpacing: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
