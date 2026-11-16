// lib/widgets/pro/scroll_reveal.dart
// Universal Scroll-Triggered Animation Wrapper for Seuma.Koffie v3.0
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum RevealEffect { fadeUp, fadeDown, fadeLeft, fadeRight, zoomIn, flipIn }

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final RevealEffect effect;
  final Duration delay;
  final Duration duration;
  final double visibilityThreshold;

  const ScrollReveal({
    super.key,
    required this.child,
    this.effect = RevealEffect.fadeUp,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 650),
    this.visibilityThreshold = 0.08,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  late Animation<double> _scale;
  bool _hasRevealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
    );

    _scale = Tween<double>(begin: 0.84, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Offset beginSlide;
    switch (widget.effect) {
      case RevealEffect.fadeUp:
        beginSlide = const Offset(0, 0.18);
        break;
      case RevealEffect.fadeDown:
        beginSlide = const Offset(0, -0.18);
        break;
      case RevealEffect.fadeLeft:
        beginSlide = const Offset(0.18, 0);
        break;
      case RevealEffect.fadeRight:
        beginSlide = const Offset(-0.18, 0);
        break;
      default:
        beginSlide = Offset.zero;
    }

    _slide = Tween<Offset>(begin: beginSlide, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_hasRevealed && info.visibleFraction >= widget.visibilityThreshold) {
      _hasRevealed = true;
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? ValueKey(widget.child.hashCode),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          Widget animated;

          switch (widget.effect) {
            case RevealEffect.zoomIn:
              animated = ScaleTransition(
                scale: _scale,
                child: FadeTransition(opacity: _opacity, child: child),
              );
              break;
            case RevealEffect.flipIn:
              animated = Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY((1 - _controller.value) * 0.25),
                child: FadeTransition(opacity: _opacity, child: child),
              );
              break;
            default:
              animated = SlideTransition(
                position: _slide,
                child: FadeTransition(opacity: _opacity, child: child),
              );
          }

          return animated;
        },
        child: widget.child,
      ),
    );
  }
}
