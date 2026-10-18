import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:netsales/core/themes/app_motion.dart';

/// ============================================================================
/// محول المظهر بأسلوب تليجرام (Telegram Circular Reveal Theme Switcher)
/// ============================================================================
/// يوفر حركة انتشار دائرية خاطفة للأنفاس (Circular Ripple Reveal) تنبثق من موضع
/// زر النقر وتتسع لتغطي الشاشة كاملة كاشفةً المظهر الجديد بنعومة فائقة (60/120fps).
class CustomThemeSwitcher extends StatefulWidget {
  final Widget child;

  const CustomThemeSwitcher({super.key, required this.child});

  /// الوصول لطبقة التحويل من أي مكان في شجرة الودجات
  static CustomThemeSwitcherState? of(BuildContext context) {
    return context.findAncestorStateOfType<CustomThemeSwitcherState>();
  }

  @override
  State<CustomThemeSwitcher> createState() => CustomThemeSwitcherState();
}

class CustomThemeSwitcherState extends State<CustomThemeSwitcher>
    with SingleTickerProviderStateMixin {
  final GlobalKey _boundaryKey = GlobalKey();

  late final AnimationController _controller;
  late final Animation<double> _animation;

  ui.Image? _snapshotImage;
  Offset _clipOrigin = Offset.zero;
  double _maxRadius = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.page, // 400ms متوافق مع معايير Material 3
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _snapshotImage?.dispose();
    super.dispose();
  }

  /// تنفيذ التبديل مع حركة الانتشار الدائري انطلاقاً من موضع [origin]
  Future<void> switchTheme({
    required Offset origin,
    required VoidCallback onThemeChange,
  }) async {
    if (_controller.isAnimating) return;

    try {
      final boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null || !boundary.attached) {
        onThemeChange();
        return;
      }

      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: pixelRatio);

      final size = boundary.size;
      final dxMax = math.max(origin.dx, size.width - origin.dx);
      final dyMax = math.max(origin.dy, size.height - origin.dy);
      final radius = math.sqrt(dxMax * dxMax + dyMax * dyMax);

      setState(() {
        _snapshotImage?.dispose();
        _snapshotImage = image;
        _clipOrigin = origin;
        _maxRadius = radius;
      });

      // تغيير الثيم فوراً في الخلفية تحت اللقطة
      onThemeChange();

      // تشغيل حركة اتساع الدائرة
      await _controller.forward(from: 0.0);

      // تنظيف الذاكرة بعد اكتمال الحركة
      if (mounted) {
        setState(() {
          _snapshotImage?.dispose();
          _snapshotImage = null;
        });
        _controller.reset();
      }
    } catch (_) {
      // ملاذ آمن في حال حدوث أي خطأ في التقاط الصورة
      onThemeChange();
      if (mounted) {
        setState(() {
          _snapshotImage?.dispose();
          _snapshotImage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(key: _boundaryKey, child: widget.child),
        if (_snapshotImage != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return ClipPath(
                    clipper: _InvertedCircularRevealClipper(
                      center: _clipOrigin,
                      radius: _maxRadius * _animation.value,
                    ),
                    child: RawImage(image: _snapshotImage, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// قناع تفريغ دائري (Inverted Circle Clipper):
/// يقتطع دائرة متسعة من مركز النقر ليكشف ما تحتها عبر خاصية PathFillType.evenOdd
class _InvertedCircularRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _InvertedCircularRevealClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(_InvertedCircularRevealClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
