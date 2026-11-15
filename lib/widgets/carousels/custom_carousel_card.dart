import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// السمات اللونية الفاخرة المحددة مسبقاً لبطاقات الكاروسيل (CustomCarouselCardTheme)
enum CustomCarouselCardTheme {
  /// زمرد إمبراطوري وأوبسيديان ملكي
  emerald,

  /// ياقوت أزرق وكوبالت ليلي
  sapphire,

  /// جمشت بنفسجي مخملي فاخر
  amethyst,

  /// كربون بلاتيني وتيتانيوم داكن
  titanium,

  /// تدرج مخصص يتم تمريره عبر customGradient
  custom,
}

/// بطاقة كاروسيل تنفيذية فاخرة عامة وقابلة لإعادة الاستخدام في أي مشروع (CustomCarouselCard)
/// خالية تماماً من أي تبعية لميزة محددة أو نماذج خاصة بالمشروع
/// تدعم التخصيص الكامل لجميع النصوص، الشعارات، التدرجات، والبيانات المالية والتعريفية
class CustomCarouselCard extends StatelessWidget {
  /// العنوان الرئيسي للبطاقة (اسم الشبكة / الكيان / المحفظة)
  final String title;

  /// العنوان الفرعي أو التصنيف (الموقع / الفرع / نوع الحساب)
  final String? subtitle;

  /// الشعار أو الأيقونة التعريفية في الزاوية العلوية
  final Widget? logo;

  /// رمز أو رقم الحساب / الكود التعريفي (UUID أو رقم البطاقة)
  final String? cardNumber;

  /// تسمية المؤشر الرئيسي (مثل: إجمالي المبيعات المحصلة / الرصيد المتاح)
  final String primaryLabel;

  /// القيمة الرئيسية للمؤشر المالي
  final String primaryValue;

  /// علامة العملة (مثل: YER أو SAR أو USD)
  final String? currencyTag;

  /// تسمية القسم الإضافي في الأسفل (مثل: الكيان التجاري / صاحب الحساب)
  final String? secondaryLabel;

  /// القيمة النصية للقسم الإضافي (اسم المالك / الشركة)
  final String? secondaryValue;

  /// نص شارة الحالة (مثل: مرخصة ونشطة / مفعل / معلق)
  final String? statusText;

  /// حالة الشارة لتحديد لون مؤشر النبض (أخضر للنشط، برتقالي لغير النشط)
  final bool isStatusActive;

  /// نص مؤشر فرعي إضافي بجانب التذييل (مثل: 18 نقطة بيع / 4 فروع)
  final String? metricText;

  /// أيقونة المؤشر الفرعي
  final IconData? metricIcon;

  /// السمة اللونية للبطاقة
  final CustomCarouselCardTheme theme;

  /// تدرج لوني مخصص في حال اختيار CustomCarouselCardTheme.custom
  final Gradient? customGradient;

  /// هل البطاقة محددة حالياً في الكاروسيل
  final bool isSelected;

  /// استدعاء عند النقر على البطاقة
  final VoidCallback? onTap;

  /// هل تظهر شريحة البطاقة الذهبية الذكية
  final bool showSmartChip;

  /// ارتفاع مخصص للبطاقة
  final double? height;

  /// انحناء الحواف
  final double? borderRadius;

  const CustomCarouselCard({
    super.key,
    required this.title,
    this.subtitle,
    this.logo,
    this.cardNumber,
    required this.primaryLabel,
    required this.primaryValue,
    this.currencyTag,
    this.secondaryLabel,
    this.secondaryValue,
    this.statusText,
    this.isStatusActive = true,
    this.metricText,
    this.metricIcon,
    this.theme = CustomCarouselCardTheme.emerald,
    this.customGradient,
    this.isSelected = false,
    this.onTap,
    this.showSmartChip = true,
    this.height,
    this.borderRadius,
  });

  Gradient _resolveGradient() {
    if (theme == CustomCarouselCardTheme.custom && customGradient != null) {
      return customGradient!;
    }

    switch (theme) {
      case CustomCarouselCardTheme.emerald:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF064E3B),
            Color(0xFF03261D),
            Color(0xFF01140F),
          ],
        );
      case CustomCarouselCardTheme.sapphire:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF0F2B5C),
            Color(0xFF0A1938),
            Color(0xFF050B18),
          ],
        );
      case CustomCarouselCardTheme.amethyst:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF381254),
            Color(0xFF1F0833),
            Color(0xFF10031C),
          ],
        );
      case CustomCarouselCardTheme.titanium:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF242D3D),
            Color(0xFF131A26),
            Color(0xFF0A0E17),
          ],
        );
      case CustomCarouselCardTheme.custom:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.xl;
    final effectiveGradient = _resolveGradient();

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        height: height?.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 1.5.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF10B981).withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.35),
              blurRadius: isSelected ? 20 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. الصف العلوي: الشعار + تفاصيل البطاقة + الشريحة والحالة
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (logo != null) ...[
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: logo,
                  ),
                  SizedBox(width: 8.w),
                ],

                // العنوان والتصنيف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5.sp,
                          height: 1.2,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w500,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 6.w),

                // الشريحة الذكية وشارة الحالة
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSmartChip) ...[
                      Container(
                        width: 22.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(3.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    if (statusText != null && statusText!.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomPulsingIndicator(
                              color: isStatusActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              size: 4.r,
                              enablePing: isStatusActive,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              statusText!,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 9.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // 2. الصف الأوسط: المؤشر المالي الرئيسي وكود البطاقة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        primaryLabel,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 9.5.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              primaryValue,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 17.sp,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (currencyTag != null &&
                              currencyTag!.isNotEmpty) ...[
                            SizedBox(width: 5.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                currencyTag!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9.5.sp,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (cardNumber != null && cardNumber!.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      cardNumber!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // خط فاصل ناعم
            Divider(
              color: Colors.white.withValues(alpha: 0.1),
              height: 1,
              thickness: 0.8,
            ),

            // 3. الصف السفلي: التسمية والقيمة الإضافية وشارة المؤشر الفرعي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (secondaryLabel != null &&
                          secondaryLabel!.isNotEmpty)
                        Text(
                          secondaryLabel!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w500,
                            fontSize: 9.sp,
                          ),
                        ),
                      if (secondaryValue != null &&
                          secondaryValue!.isNotEmpty)
                        Text(
                          secondaryValue!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.sp,
                          ),
                        ),
                    ],
                  ),
                ),
                if (metricText != null && metricText!.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (metricIcon != null) ...[
                          Icon(
                            metricIcon,
                            size: 13.r,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          SizedBox(width: 4.w),
                        ],
                        Text(
                          metricText!,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
