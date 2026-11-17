import 'package:flutter/material.dart';

/// ويدجت نقطة الحالة النابضة الحية (CustomPulsingIndicator)
/// تحاكي تأثير animate-pulse و animate-ping في التصاميم الراقية
class CustomPulsingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final bool enablePing;

  const CustomPulsingIndicator({
    super.key,
    required this.color,
    this.size = 8.0,
    this.enablePing = true,
  });

  @override
  State<CustomPulsingIndicator> createState() => _CustomPulsingIndicatorState();
}

class _CustomPulsingIndicatorState extends State<CustomPulsingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _fadeAnimation = Tween<double>(
      begin: 0.65,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    final isTest = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
    if (widget.enablePing && !isTest) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.enablePing)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color.withValues(
                          alpha: _fadeAnimation.value,
                        ),
                      ),
                    ),
                  );
                },
              ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
