import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netsales/core/themes/app_motion.dart';

/// ============================================================================
/// زر النطاط التفاعلي الموحد فائق الدقة (CustomInteractiveBounce)
/// ============================================================================
/// يوفر تأثير ضغط انبعاثي ميكرو-تفاعلي (Micro-interaction Scale Bounce) سلس وفاخر،
/// مع دعم الـ Hover والرفع الرأسي الخفيف (-2px) ومؤشر النقر والتغذية اللمسية.
class CustomInteractiveBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double lowerBound;
  final Duration duration;
  final bool enableHover;
  final bool enableHaptic;
  final double hoverTranslateY;

  const CustomInteractiveBounce({
    super.key,
    required this.child,
    this.onTap,
    this.lowerBound = 0.96,
    this.duration = const Duration(milliseconds: 100),
    this.enableHover = true,
    this.enableHaptic = true,
    this.hoverTranslateY = -2.0,
  });

  @override
  State<CustomInteractiveBounce> createState() =>
      _CustomInteractiveBounceState();
}

class _CustomInteractiveBounceState extends State<CustomInteractiveBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  /// تتبع ما إذا كان المستخدم يضغط حالياً باستمرار على العنصر
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.lowerBound).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.emphasized,
        reverseCurve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _isHolding = true;
    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _isHolding = false;
    _triggerBounceRelease();
  }

  void _handleTapCancel() {
    _isHolding = false;
    if (mounted) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    widget.onTap?.call();
  }

  /// يضمن اكتمال دورة الانكماش ثم الارتداد بسلاسة تامة حتى عند النقر الخاطف
  void _triggerBounceRelease() {
    if (_controller.isAnimating) {
      _controller.addStatusListener(_onAnimationStatusChanged);
    } else {
      if (mounted) {
        _controller.reverse();
      }
    }
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.removeStatusListener(_onAnimationStatusChanged);
      if (mounted && !_isHolding) {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return widget.child;
    }

    if (AppMotion.disabled(context)) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: widget.child,
      );
    }

    final isInteractive = widget.onTap != null;

    Widget content = ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          (_isHovered && widget.enableHover) ? widget.hoverTranslateY : 0.0,
          0,
        ),
        child: widget.child,
      ),
    );

    return MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) {
        if (mounted && widget.enableHover) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (mounted && widget.enableHover) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: content,
      ),
    );
  }
}
