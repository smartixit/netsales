import 'package:netsales/core/themes/app_motion.dart';
import 'package:flutter/material.dart';

class CustomInteractiveBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const CustomInteractiveBounce({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<CustomInteractiveBounce> createState() =>
      _CustomInteractiveBounceState();
}

class _CustomInteractiveBounceState extends State<CustomInteractiveBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.fast);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.emphasized),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.disabled(context)) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: widget.child,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
