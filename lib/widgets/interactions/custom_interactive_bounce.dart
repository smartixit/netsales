import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_motion.dart';

/// ============================================================================
/// زر النطاط التفاعلي الموحد (CustomInteractiveBounce)
/// ============================================================================
/// يوفر تأثير ضغط انبعاثي سلس متوافق مع كل السياقات البصرية سواء داخل قوائم
/// قابلة للتمرير أو بطاقات ثابتة، ويحل مشكلة تعارض إيماءات الـ Gesture Arena
/// (Scroll vs Tap Conflict) الشائعة في Flutter باستخدام [Listener] بدلاً من
/// [GestureDetector] لاستقبال أحداث المؤشر مباشرة (Pointer Events) بمعزل عن
/// التنافس على ملكية الإيماءة مع الـ Scrollable الأب.
class CustomInteractiveBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CustomInteractiveBounce({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<CustomInteractiveBounce> createState() =>
      _CustomInteractiveBounceState();
}

class _CustomInteractiveBounceState extends State<CustomInteractiveBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  /// تتبع زمن آخر ضغطة لتمييز النقر السريع عن الضغط المطول
  int _pointerDownTime = 0;

  /// تتبع موضع بدء الضغط لاكتشاف السحب وعدم تفعيل الـ onTap في حالته
  Offset _pointerDownPosition = Offset.zero;

  /// حد أقصى لمسافة الحركة بالـ pixels قبل اعتبار التفاعل سحباً لا نقراً
  static const double _maxDragDistance = 10.0;

  /// حد أقصى لمدة اللمس بالـ milliseconds قبل اعتباره ضغطاً مطولاً لا نقراً
  static const int _maxTapDuration = 200;

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

  void _onPointerDown(PointerDownEvent event) {
    _pointerDownTime = DateTime.now().millisecondsSinceEpoch;
    _pointerDownPosition = event.localPosition;
    _controller.duration = const Duration(milliseconds: 80);
    _controller.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    _controller.duration = AppMotion.fast;
    _controller.reverse();

    // التحقق من أن التفاعل كان نقرة سريعة وقصيرة (وليس سحباً أو ضغطاً مطولاً)
    final elapsed = DateTime.now().millisecondsSinceEpoch - _pointerDownTime;
    final distance = (event.localPosition - _pointerDownPosition).distance;

    if (elapsed < _maxTapDuration && distance < _maxDragDistance) {
      widget.onTap?.call();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _controller.duration = AppMotion.fast;
    _controller.reverse();
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

    // استخدام Listener بدلاً من GestureDetector لتجاوز تعارض الـ Gesture Arena
    // مع أي Scrollable أب، مما يضمن استقبال أحداث المؤشر فورياً عند كل نقرة.
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
