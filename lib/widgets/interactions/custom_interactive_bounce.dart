import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_motion.dart';

/// ============================================================================
/// زر النطاط التفاعلي الموحد فائق الدقة (CustomInteractiveBounce)
/// ============================================================================
/// يوفر تأثير ضغط انبعاثي ميكرو-تفاعلي (Micro-interaction Scale Bounce) سلس وفاخر،
/// متوافق تماماً مع كافة سياقات الواجهة والقوائم القابلة للتمرير.
///
/// المميزات المعمارية الصارمة:
/// 1. يعتمد على نظام الـ GestureArena الأصيل في Flutter لمنع أي تضارب بين
///    المكونات المتداخلة (Nested Interactive Elements) نهائياً:
///    عند النقر على زر أو مكون ابن تفاعلي داخل بطاقة أو حاوية تمتلك هذا التأثير،
///    يفوز الابن حصراً بالنقرة، ولا يتم استدعاء onTap للأب مطلقاً.
///
/// 2. يحل مشكلة اختفاء حركة الارتداد في النقر السريع عبر ضمان دورة انكماش
///    وارتداد مرنة كاملة (Minimum Animation Cycle) حتى عند أسرع النقرات.
class CustomInteractiveBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double lowerBound;
  final Duration duration;

  const CustomInteractiveBounce({
    super.key,
    required this.child,
    this.onTap,
    this.lowerBound = 0.94,
    this.duration = const Duration(milliseconds: 90),
  });

  @override
  State<CustomInteractiveBounce> createState() =>
      _CustomInteractiveBounceState();
}

class _CustomInteractiveBounceState extends State<CustomInteractiveBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

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
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.lowerBound,
    ).animate(
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
      // إذا كان لا يزال ينكمش، ننتظر وصوله للنهاية ثم يرتد فوراً
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
