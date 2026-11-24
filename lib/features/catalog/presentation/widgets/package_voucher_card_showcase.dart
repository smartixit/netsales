import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/color_resolver.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// بطاقة المحاكاة الرقمية الفاخرة لكرت الإنترنت في رأس صفحة تفاصيل الباقة
/// (The Royal Emerald Metal Voucher Card — Haute FinTech Architecture)
///
/// معايير هندسية صارمة:
/// - الالتزام بنظام التصميم الموحد: AppSpacing, AppRadius, AppElevation, AppTypography.
/// - خلو كامل من الدوال المساعدة `_build...` ومنطق المعالجة غير الضروري.
/// - ويدجتس مستقلة ذات مسؤولية أحادية واضحة (Clean Code).
class PackageVoucherCardShowcase extends StatelessWidget {
  const PackageVoucherCardShowcase({
    super.key,
    required this.package,
    this.showPricingSummary = true,
    this.previewPricing,
  });

  final PackageEntity package;
  final bool showPricingSummary;
  final PackageVoucherPreviewPricing? previewPricing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accentColor = ColorResolver.resolve(
      package.packageColor,
      colors.primary,
    );
    final statusPres = EnumPresentationRegistry.resolvePackageStatus(
      package.packageStatus,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor,
            Color.lerp(accentColor, Colors.black, 0.45) ?? accentColor,
            Color.lerp(accentColor, Colors.black, 0.75) ?? Colors.black,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: AppElevation.tinted(context, accentColor),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.2.w,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── 1. الهالة الطيفية الزخرفية الدائرية ──
          Positioned(
            bottom: -45.r,
            left: -35.r,
            child: IgnorePointer(
              child: Container(
                width: 160.r,
                height: 160.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),

          // ── 2. العلامة المائية الفاخرة لفئة الكرت كرقم نقي ──
          Positioned(
            top: 60.h,
            left: 12.w,
            child: IgnorePointer(
              child: Text(
                AmountFormatter.formatValue(
                  package.packageVoucherPrice,
                  decimalPlaces: 0,
                ),
                style: TextStyle(
                  fontSize: 68.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.08),
                  letterSpacing: -2,
                  height: 0.9,
                ),
              ),
            ),
          ),

          // ── 3. المحتوى الهرمي الفاخر للكرت ──
          Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ═══ الصف العلوي: الشريحة + الشبكة والحالة + ختم فئة الكرت ═══
                _ShowcaseHeaderRow(
                  networkName: package.networkName,
                  voucherPrice: package.packageVoucherPrice,
                  statusLabel: statusPres.label,
                  statusTone: statusPres.tone,
                  statusIcon: statusPres.icon,
                ),

                AppSpacing.vMd,

                // ═══ سعة البيانات واسم الباقة بأسلوب الكتالوج ═══
                _ShowcaseHeroQuota(
                  balanceValue: package.balanceParts.value,
                  balanceUnit: package.balanceParts.unit,
                  packageName: package.packageName,
                ),

                AppSpacing.vMd,

                // ═══ مصفوفة المواصفات الزجاجية الشفافة ═══
                _ShowcaseGlassMatrix(
                  voucherCount: package.packageVoucherCount,
                  validityDisplay: package.validityDisplay,
                  uptimeDisplay:
                      package.packageUptime != null &&
                          package.packageUptime! > 0
                      ? package.uptimeDisplay
                      : 'مفتوح',
                ),

                if (showPricingSummary) ...[
                  AppSpacing.vMd,
                  _ShowcaseRoyalPricingBar(
                    accentColor: accentColor,
                    cashDiscount: package.packageDefaultCashDiscount,
                    cashVoucherPrice: package.effectiveCashPrice,
                    cashSavings: package.cashDiscountAmount,
                    cashTotalPrice: package.totalCashPrice,
                    creditDiscount: package.packageDefaultCreditDiscount,
                    creditVoucherPrice: package.effectiveCreditPrice,
                    creditSavings: package.creditDiscountAmount,
                    creditTotalPrice: package.totalCreditPrice,
                  ),
                ] else if (previewPricing != null) ...[
                  AppSpacing.vMd,
                  _ShowcaseRawPricingPreview(pricing: previewPricing!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// الصف العلوي للكرت: الشريحة الذكية، اسم الشبكة مع شارة الحالة، وختم فئة الكرت
class _ShowcaseHeaderRow extends StatelessWidget {
  const _ShowcaseHeaderRow({
    required this.networkName,
    required this.voucherPrice,
    required this.statusLabel,
    required this.statusTone,
    this.statusIcon,
  });

  final String? networkName;
  final double voucherPrice;
  final String statusLabel;
  final SemanticTone statusTone;
  final IconData? statusIcon;

  @override
  Widget build(BuildContext context) {
    final isSuccess = statusTone == SemanticTone.success;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              const _ShowcaseSmartChip(),
              AppSpacing.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      networkName != null && networkName!.isNotEmpty
                          ? networkName!
                          : 'NETSALES TELECOM',
                      style: AppTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vXxs,

                    // شارة الحالة عالية التباين كبديل لنص باقة كروت رقمية
                    CustomStatusBadge(
                      label: statusLabel,
                      icon: statusIcon,
                      tone: statusTone,
                      isCompact: true,
                      showDot: true,
                      backgroundColor: isSuccess
                          ? const Color(0xFF064E3B).withValues(alpha: 0.85)
                          : Colors.white.withValues(alpha: 0.15),
                      foregroundColor: isSuccess
                          ? const Color(0xFFA7F3D0)
                          : Colors.white,
                      borderColor: isSuccess
                          ? const Color(0xFF34D399).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.hSm,

        // ختم فئة الكرت الرسمية بدلاً من معرف الباقة
        _ShowcaseVoucherPriceBadge(voucherPrice: voucherPrice),
      ],
    );
  }
}

/// ختم فئة الكرت الرسمية (Emerald Tier Stamp)
class _ShowcaseVoucherPriceBadge extends StatelessWidget {
  const _ShowcaseVoucherPriceBadge({required this.voucherPrice});

  final double voucherPrice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.25),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'فئة ',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
          Text(
            '${AmountFormatter.formatValue(voucherPrice)} ر.ي',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// شريحة الكرت الذكية الذهبية (Microchip Emblem)
class _ShowcaseSmartChip extends StatelessWidget {
  const _ShowcaseSmartChip();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 38.w,
      height: 28.h,
      decoration: BoxDecoration(
        color: colors.executiveGoldAccent.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: colors.executiveGoldIcon, width: 1.2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: AppRadius.xs,
            offset: Offset(0, AppSpacing.xxs),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 20.w,
          height: 14.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.amberAccent.withValues(alpha: 0.7),
              width: 0.8.w,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
        ),
      ),
    );
  }
}

/// سعة البيانات الكبرى واسم الباقة بنفس أسلوب وهوية الكتالوج
class _ShowcaseHeroQuota extends StatelessWidget {
  const _ShowcaseHeroQuota({
    required this.balanceValue,
    required this.balanceUnit,
    required this.packageName,
  });

  final String balanceValue;
  final String balanceUnit;
  final String packageName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              balanceValue,
              style: AppTypography.displayMedium.copyWith(
                fontSize: 38.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: AppRadius.sm,
                    offset: Offset(0, AppSpacing.xxs),
                  ),
                ],
              ),
            ),
            if (balanceUnit.isNotEmpty) ...[
              AppSpacing.hXs,
              Text(
                balanceUnit,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.executiveGoldAccent,
                  height: 1.0,
                ),
              ),
            ],
          ],
        ),
        AppSpacing.vXs,
        Text(
          packageName,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// مصفوفة المواصفات الزجاجية الشفافة (Glass Matrix)
class _ShowcaseGlassMatrix extends StatelessWidget {
  const _ShowcaseGlassMatrix({
    required this.voucherCount,
    required this.validityDisplay,
    required this.uptimeDisplay,
  });

  final int voucherCount;
  final String validityDisplay;
  final String uptimeDisplay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.8.w,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _GlassMatrixCell(
              label: 'كروت الحزمة',
              value: '$voucherCount كرت',
            ),
          ),
          const _GlassMatrixDivider(),
          Expanded(
            child: _GlassMatrixCell(
              label: 'فترة الصلاحية',
              value: validityDisplay,
            ),
          ),
          const _GlassMatrixDivider(),
          Expanded(
            child: _GlassMatrixCell(
              label: 'وقت الاستخدام',
              value: uptimeDisplay,
            ),
          ),
        ],
      ),
    );
  }
}

/// فاصل رأسي شفاف داخل المصفوفة الزجاجية
class _GlassMatrixDivider extends StatelessWidget {
  const _GlassMatrixDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 22.h,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

/// خلية مفردة داخل مصفوفة المواصفات الزجاجية
class _GlassMatrixCell extends StatelessWidget {
  const _GlassMatrixCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        AppSpacing.vXxs,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// شريط التسعير الزجاجي الملكي المدمج (The Royal Emerald Pricing Bar)
class _ShowcaseRoyalPricingBar extends StatelessWidget {
  const _ShowcaseRoyalPricingBar({
    required this.accentColor,
    required this.cashDiscount,
    required this.cashVoucherPrice,
    required this.cashSavings,
    required this.cashTotalPrice,
    required this.creditDiscount,
    required this.creditVoucherPrice,
    required this.creditSavings,
    required this.creditTotalPrice,
  });

  final Color accentColor;
  final double cashDiscount;
  final double cashVoucherPrice;
  final double cashSavings;
  final double cashTotalPrice;
  final double creditDiscount;
  final double creditVoucherPrice;
  final double creditSavings;
  final double creditTotalPrice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          // مسار الشراء النقدي
          Expanded(
            child: _RoyalPriceTrack(
              title: '🟢 نقدي',
              themeColor: colors.success,
              discountPercent: cashDiscount,
              voucherPrice: cashVoucherPrice,
              voucherSavings: cashSavings,
              totalPrice: cashTotalPrice,
            ),
          ),

          // فاصل رأسي زجاجي
          Container(
            width: 1.w,
            height: 44.h,
            color: Colors.white.withValues(alpha: 0.15),
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),

          // مسار الشراء الآجل
          Expanded(
            child: _RoyalPriceTrack(
              title: '🔵 آجل',
              themeColor: const Color(0xFF38BDF8),
              discountPercent: creditDiscount,
              voucherPrice: creditVoucherPrice,
              voucherSavings: creditSavings,
              totalPrice: creditTotalPrice,
            ),
          ),
        ],
      ),
    );
  }
}

/// مسار السعر الملكي الشفاف (نقدي أو آجل)
class _RoyalPriceTrack extends StatelessWidget {
  const _RoyalPriceTrack({
    required this.title,
    required this.themeColor,
    required this.discountPercent,
    required this.voucherPrice,
    required this.voucherSavings,
    required this.totalPrice,
  });

  final String title;
  final Color themeColor;
  final double discountPercent;
  final double voucherPrice;
  final double voucherSavings;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── السطر 1: عنوان المسار + شارة الخصم ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: themeColor,
              ),
            ),
            if (discountPercent > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 1.h,
                ),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'خصم ${discountPercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),

        AppSpacing.vXxs,

        // ── السطر 2: سعر الكرت الصافي ──
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AmountFormatter.formatValue(voucherPrice),
                style: TextStyle(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              AppSpacing.hXxs,
              Text(
                'ر.ي / كرت',
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        AppSpacing.vXxs,

        // ── السطر 3: مقدار الوفر بالكرت ──
        Text(
          voucherSavings > 0
              ? 'وفر ${AmountFormatter.formatValue(voucherSavings)} بالكرت'
              : 'السعر الصافي',
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: voucherSavings > 0 ? themeColor : Colors.white60,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        AppSpacing.vXxs,

        // ── السطر 4: إجمالي الحزمة ──
        Text(
          'حزمة: ${AmountFormatter.formatValue(totalPrice)} ر.ي',
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}


/// مدخلات التسعير الخام للمعاينة فقط؛ لا تحتوي على أي أسعار مشتقة.
class PackageVoucherPreviewPricing {
  const PackageVoucherPreviewPricing({
    required this.basePrice,
    required this.cashDiscountRate,
    required this.creditDiscountRate,
  });

  final double basePrice;
  final double cashDiscountRate;
  final double creditDiscountRate;
}

/// يعرض ما أدخله المستخدم كما هو، دون حساب سعر صافٍ أو وفورات أو إجماليات.
class _ShowcaseRawPricingPreview extends StatelessWidget {
  const _ShowcaseRawPricingPreview({required this.pricing});

  final PackageVoucherPreviewPricing pricing;

  @override
  Widget build(BuildContext context) {
    final cashRate = pricing.cashDiscountRate;
    final creditRate = pricing.creditDiscountRate;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RawPricingValue(
              label: 'السعر الأساسي',
              value: '${AmountFormatter.formatValue(pricing.basePrice)} ر.ي',
            ),
          ),
          Container(
            width: 1.w,
            height: 38.h,
            color: Colors.white.withValues(alpha: 0.16),
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          Expanded(
            child: _RawPricingValue(
              label: 'خصم نقدي',
              value: '${cashRate == cashRate.roundToDouble() ? cashRate.toInt() : cashRate}%',
            ),
          ),
          Container(
            width: 1.w,
            height: 38.h,
            color: Colors.white.withValues(alpha: 0.16),
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          Expanded(
            child: _RawPricingValue(
              label: 'خصم آجل',
              value: '${creditRate == creditRate.roundToDouble() ? creditRate.toInt() : creditRate}%',
            ),
          ),
        ],
      ),
    );
  }

}

/// خلية قيمة خام داخل معاينة التسعير.
class _RawPricingValue extends StatelessWidget {
  const _RawPricingValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.white.withValues(alpha: 0.72),
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.vXxs,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
