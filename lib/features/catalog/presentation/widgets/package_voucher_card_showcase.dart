import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
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
/// تم بناء الهيكل المعماري وفق أعلى معايير Clean Code وهندسة الواجهات:
/// - لا توجد دوال مساعدة `_build...`، بل كائنات مستقلة قابلة لإعادة الاستخدام.
/// - هوية بصرية ملكية متكاملة موحدة (Bespoke Metal FinTech).
/// - علامة مائية شفافة نقية بالرقم المجرد في الخلفية.
/// - شريحة كرت ذكية ذهبية وهوية الشبكة وشارة الحالة في الصف العلوي.
/// - سعة البيانات البارزة واسم الباقة.
/// - مصفوفة المواصفات الزجاجية الشفافة (كروت الحزمة، فترة الصلاحية، وقت الاستخدام).
/// - شريط التسعير الزجاجي الملكي المدمج (The Royal Emerald Pricing Bar) للنقدي والآجل.
class PackageVoucherCardShowcase extends StatelessWidget {
  const PackageVoucherCardShowcase({super.key, required this.package});

  final PackageEntity package;

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

    final rawPrice = package.packageVoucherPrice;
    final priceWatermark = rawPrice == rawPrice.roundToDouble()
        ? rawPrice.toInt().toString()
        : rawPrice.toStringAsFixed(0);

    final balanceParts = _splitBalance(package.balanceDisplay);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
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
        boxShadow: AppElevation.tinted(
          context,
          accentColor,
          alpha: 0.35,
          blur: 24.r,
          dy: 10.h,
        ),
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
            top: -45.r,
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
            top: -10.h,
            left: 12.w,
            child: IgnorePointer(
              child: Text(
                priceWatermark,
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
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ═══ الصف العلوي: الشريحة + اسم الشبكة مع شارة الحالة + معرف الباقة ═══
                _ShowcaseHeaderRow(
                  networkName: package.networkName,
                  packageId: package.packageId,
                  statusLabel: statusPres.label,
                  statusTone: statusPres.tone,
                  statusIcon: statusPres.icon,
                ),

                SizedBox(height: 12.h),

                // ═══ سعة البيانات البارزة واسم الباقة ═══
                _ShowcaseHeroQuota(
                  number: balanceParts.number,
                  unit: balanceParts.unit,
                  packageName: package.packageName,
                ),

                SizedBox(height: 12.h),

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

                SizedBox(height: 12.h),

                // ═══ شريط التسعير الزجاجي الملكي المدمج ═══
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  static _BalanceParts _splitBalance(String display) {
    final trimmed = display.trim();
    final match = RegExp(r'^([\d.,]+)\s*(.*)$').firstMatch(trimmed);
    if (match != null) {
      return _BalanceParts(
        number: match.group(1) ?? trimmed,
        unit: match.group(2) ?? '',
      );
    }
    return _BalanceParts(number: trimmed, unit: '');
  }
}

class _BalanceParts {
  const _BalanceParts({required this.number, required this.unit});
  final String number;
  final String unit;
}

/// الصف العلوي للكرت: الشريحة الذكية، اسم الشبكة، وشارة الحالة
class _ShowcaseHeaderRow extends StatelessWidget {
  const _ShowcaseHeaderRow({
    required this.networkName,
    required this.packageId,
    required this.statusLabel,
    required this.statusTone,
    this.statusIcon,
  });

  final String? networkName;
  final int packageId;
  final String statusLabel;
  final SemanticTone statusTone;
  final IconData? statusIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              const _ShowcaseSmartChip(),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    SizedBox(height: 1.h),
                    Text(
                      'باقة كروت رقمية #$packageId',
                      style: AppTypography.badgeText.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        CustomStatusBadge(
          label: statusLabel,
          icon: statusIcon,
          tone: statusTone,
          isCompact: true,
          showDot: true,
        ),
      ],
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
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
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

/// سعة البيانات الكبرى مع اسم الباقة
class _ShowcaseHeroQuota extends StatelessWidget {
  const _ShowcaseHeroQuota({
    required this.number,
    required this.unit,
    required this.packageName,
  });

  final String number;
  final String unit;
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
              number,
              style: AppTypography.displayMedium.copyWith(
                fontSize: 38.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
            ),
            if (unit.isNotEmpty) ...[
              SizedBox(width: 6.w),
              Text(
                unit,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.success,
                  height: 1.0,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 6.h),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
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
        SizedBox(height: 2.h),
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14.r),
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
            margin: EdgeInsets.symmetric(horizontal: 10.w),
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
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
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

        SizedBox(height: 3.h),

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
              SizedBox(width: 3.w),
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

        SizedBox(height: 2.h),

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

        SizedBox(height: 2.h),

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
