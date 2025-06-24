import 'dart:async';
import 'package:flutter/material.dart';

class TanosAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const TanosAnimation({required this.child, required this.delay, super.key});

  @override
  _TanosAnimationState createState() => _TanosAnimationState();
}

class _TanosAnimationState extends State<TanosAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final curve =
        CurvedAnimation(parent: _controller, curve: Curves.decelerate);

    _animOffset = Tween<Offset>(
      begin: const Offset(0.0, -0.35),
      end: Offset.zero,
    ).animate(curve);

    Timer(Duration(milliseconds: widget.delay), () => _controller.forward());
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _animOffset,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

