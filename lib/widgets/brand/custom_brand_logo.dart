import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';

/// أحجام الشعار القياسية الموحدة للنظام
enum BrandLogoSize {
  /// حجم مصغر للهيدر وشريط التطبيق العلوي (40r)
  sm(40, 6, 20),

  /// حجم متوسط لشاشات الترحيب والمصادقة (72r)
  md(72, 12, 36),

  /// حجم قياسي كبير لشاشة الإقلاع والبطاقات الرئيسية (104r)
  lg(104, 16, 54),

  /// حجم بارز (Hero) لشاشات النجاح والعروض الكبيرة (130r)
  hero(130, 20, 68);

  final double dimension;
  final double padding;
  final double iconSize;

  const BrandLogoSize(this.dimension, this.padding, this.iconSize);
}

/// ودجت الشعار الرسمي المركزي الموحد لنظام NetSales (CustomBrandLogo)
/// يُستخدم في كافة الواجهات (Splash, Onboarding, Welcome, Login, Profile)
/// بدلاً من إعادة كتابة حاوية الشعار يدوياً.
class CustomBrandLogo extends StatefulWidget {
  const CustomBrandLogo({
    super.key,
    this.size = BrandLogoSize.md,
    this.withHalo = false,
  });

  /// الحجم القياسي للشعار
  final BrandLogoSize size;

  /// تفعيل الهالة النابضة المضيئة المحيطة (لشاشات الإقلاع والـ Hero)
  final bool withHalo;

  /// منشئات مصنعية ميسرة
  const CustomBrandLogo.sm({super.key})
      : size = BrandLogoSize.sm,
        withHalo = false;

  const CustomBrandLogo.md({super.key, this.withHalo = false})
      : size = BrandLogoSize.md;

  const CustomBrandLogo.lg({super.key, this.withHalo = true})
      : size = BrandLogoSize.lg;

  const CustomBrandLogo.hero({super.key, this.withHalo = true})
      : size = BrandLogoSize.hero;

  @override
  State<CustomBrandLogo> createState() => _CustomBrandLogoState();
}

class _CustomBrandLogoState extends State<CustomBrandLogo>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.withHalo) {
      _pulseController = AnimationController(
        vsync: this,
        duration: AppMotion.shimmer,
      )..repeat(reverse: true);

      _scaleAnimation = Tween<double>(begin: 0.94, end: 1.14).animate(
        CurvedAnimation(
          parent: _pulseController!,
          curve: AppMotion.standard,
        ),
      );

      _fadeAnimation = Tween<double>(begin: 0.06, end: 0.16).animate(
        CurvedAnimation(
          parent: _pulseController!,
          curve: AppMotion.standard,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dim = widget.size.dimension.r;
    final pad = widget.size.padding.r;
    final iconSz = widget.size.iconSize.r;

    final logoContainer = Container(
      width: dim,
      height: dim,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(
          widget.size == BrandLogoSize.sm ? AppRadius.sm : AppRadius.xl,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: widget.size == BrandLogoSize.sm
            ? AppElevation.level1(context)
            : [
                ...AppElevation.level3(context),
                ...AppElevation.glow(
                  context,
                  colors.primary,
                  alpha: 0.18,
                  blur: 16,
                ),
              ],
      ),
      child: Image.asset(
        'assets/images/brand_icon.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.hub_rounded,
          size: iconSz,
          color: colors.primary,
        ),
      ),
    );

    if (!widget.withHalo || _pulseController == null) {
      return logoContainer;
    }

    final haloDim = dim * 1.62;
    final subHaloDim = dim * 1.30;

    return Stack(
      alignment: Alignment.center,
      children: [
        // هالة خارجية نابضة
        AnimatedBuilder(
          animation: _pulseController!,
          builder: (context, child) {
            final isReducedMotion = AppMotion.disabled(context);
            final scale = isReducedMotion ? 1.0 : (_scaleAnimation?.value ?? 1.0);
            final alpha = isReducedMotion ? 0.08 : (_fadeAnimation?.value ?? 0.08);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: haloDim,
                height: haloDim,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: alpha),
                ),
              ),
            );
          },
        ),

        // هالة وسيطة ثابتة
        Container(
          width: subHaloDim,
          height: subHaloDim,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primaryContainer.withValues(alpha: 0.18),
          ),
        ),

        // حاوية الشعار
        logoContainer,
      ],
    );
  }
}
