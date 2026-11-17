import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

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

  /// رابط صورة الشعار اختياري للأفاتار الموحد (CustomAvatarBadge)
  final String? avatarUrl;

  /// الحرف الرمز للأفاتار الموحد في حال عدم توفر الصورة (حرف واحد)
  final String? avatarInitial;

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
    this.avatarUrl,
    this.avatarInitial,
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
    this.showSmartChip = false,
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
          colors: [Color(0xFF064E3B), Color(0xFF03261D), Color(0xFF01140F)],
        );
      case CustomCarouselCardTheme.sapphire:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0F2B5C), Color(0xFF0A1938), Color(0xFF050B18)],
        );
      case CustomCarouselCardTheme.amethyst:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF381254), Color(0xFF1F0833), Color(0xFF10031C)],
        );
      case CustomCarouselCardTheme.titanium:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF242D3D), Color(0xFF131A26), Color(0xFF0A0E17)],
        );
      case CustomCarouselCardTheme.custom:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.xl;
    final effectiveGradient = _resolveGradient();
    final effectiveLogo =
        logo ??
        ((avatarUrl != null && avatarUrl!.isNotEmpty) ||
                (avatarInitial != null && avatarInitial!.isNotEmpty) ||
                title.isNotEmpty
            ? CustomAvatarBadge(
                imageUrl: avatarUrl,
                initials: (avatarInitial != null && avatarInitial!.isNotEmpty)
                    ? avatarInitial!
                    : TextFormatter.avatarInitial(title, fallback: 'ش'),
                size: AvatarBadgeSize.sm,
                customDimension: 40,
                hasPulse: false,
              )
            : null);

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
            // 1. الصف العلوي: الشعار + تفاصيل البطاقة + شارة الحالة الحية
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (effectiveLogo != null) ...[
                  effectiveLogo,
                  SizedBox(width: 10.w),
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
                          fontSize: 14.5.sp,
                          height: 1.2,
                        ),
                      ),
                      if (cardNumber != null && cardNumber!.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            UrlLauncherService.copyToClipboard(cardNumber!);
                            CustomSnackbar.show(
                              title: 'تم النسخ بنجاح',
                              message: 'تم نسخ الرمز: $cardNumber',
                              type: SnackType.info,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  TextFormatter.truncate(
                                    cardNumber!,
                                    10,
                                    ellipsis: '…',
                                  ),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.copy_rounded,
                                  size: 10.r,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else if (subtitle != null && subtitle!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w500,
                            fontSize: 10.5.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                // شارة الحالة (وشريحة البطاقة اختيارياً فقط عند تفعيلها)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSmartChip) ...[
                      Container(
                        width: 20.w,
                        height: 15.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    if (statusText != null && statusText!.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
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
                              size: 4.5.r,
                              enablePing: isStatusActive,
                            ),
                            SizedBox(width: 5.w),
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

            // 2. الصف الأوسط: المؤشر المالي الرئيسي
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  primaryLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          primaryValue,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22.sp,
                            letterSpacing: -0.3,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    if (currencyTag != null &&
                        currencyTag!.isNotEmpty &&
                        !primaryValue.contains(currencyTag!)) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          currencyTag!,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 9.5.sp,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // خط فاصل ناعم خافت
            Divider(
              color: Colors.white.withValues(alpha: 0.10),
              height: 1,
              thickness: 0.8,
            ),

            // 3. الصف السفلي: تفاصيل السقف الائتماني/الكيان التجاري وشارة المؤشر الفرعي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (secondaryValue != null && secondaryValue!.isNotEmpty)
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (secondaryLabel != null &&
                            secondaryLabel!.isNotEmpty)
                          Text(
                            '$secondaryLabel: ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                              fontSize: 9.5.sp,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            secondaryValue!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11.sp,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (metricText != null && metricText!.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
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
                            size: 12.r,
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
