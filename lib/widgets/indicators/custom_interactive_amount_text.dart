import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/amount_to_words_converter.dart';
import 'package:netsales/widgets/toasts/custom_toast.dart';

/// ويدجيت تفاعلية لعرض السعر الرقمي مع إمكانية النقر لإظهار تفقيط المبلغ في Tooltip منبثق
/// مصممة لتكون خفيفة وموحدة وقابلة لإعادة الاستخدام في أي مشروع (Reusable Interactive Price Tag).
class CustomInteractiveAmountText extends StatelessWidget {
  /// القيمة المالية (رقم أو نص)
  final dynamic amount;

  /// نمط الخط المخصص للسعر الرقمي
  final TextStyle? style;

  /// رمز العملة (افتراضياً: 'YER' أي ريال يمني)
  final String? currencyCode;

  /// الإعداد المخصص للعملة (اختياري)
  final CurrencyWordsConfig? currency;

  /// بادئة التفقيط (افتراضياً: 'فقط')
  final String prefix;

  /// لاحقة التفقيط (افتراضياً: 'لا غير')
  final String suffix;

  /// ما إذا كان يتم تنسيق الرقم تلقائياً بفاصل الآلاف (,)
  final bool autoFormat;

  /// عدد الخانات العشرية للتنسيق
  final int decimalPlaces;

  /// ما إذا كان يجب تمكين النقر لعرض التلميح
  final bool enableTooltip;

  /// نص لاحقة إضافية بجانب الرقم المالي (مثل 'ر.ي' أو '\$')
  final String? trailingText;

  const CustomInteractiveAmountText({
    super.key,
    required this.amount,
    this.style,
    this.currencyCode,
    this.currency,
    this.prefix = 'فقط',
    this.suffix = 'لا غير',
    this.autoFormat = true,
    this.decimalPlaces = 2,
    this.enableTooltip = true,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // استخراج النص المنسق
    final displayText = _getFormattedText();

    // استخراج نص التفقيط
    final words = AmountToWordsConverter.convert(
      amount,
      currency: currency,
      currencyCode: currencyCode,
      prefix: prefix,
      suffix: suffix,
    );

    final effectiveStyle = style ??
        AppTypography.titleMedium.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.bold,
        );

    // إذا كان التفقيط فارغاً (المبلغ صفر أو غير صالح) أو التلميح غير مفعّل، نعرض النص عادياً
    if (!enableTooltip || words.isEmpty) {
      return Text(
        trailingText != null ? '$displayText $trailingText' : displayText,
        style: effectiveStyle,
      );
    }

    return Tooltip(
      message: words,
      preferBelow: false,
      verticalOffset: 12.h,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      textStyle: AppTypography.bodySmall.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      triggerMode: TooltipTriggerMode.tap,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xs),
        onTap: () async {
          final success = await UrlLauncherService.copyToClipboard(words);
          if (success) {
            CustomToast.show(
              message: 'تم نسخ تفقيط المبلغ: $words',
              icon: Icons.copy_rounded,
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                trailingText != null ? '$displayText $trailingText' : displayText,
                style: effectiveStyle,
              ),
              SizedBox(width: 3.w),
              Icon(
                Icons.help_outline_rounded,
                size: (effectiveStyle.fontSize ?? 14.sp) * 0.75,
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedText() {
    if (amount == null) return '';
    if (!autoFormat) return amount.toString();

    if (amount is num) {
      return AmountFormatter.formatValue(
        amount as num,
        decimalPlaces: decimalPlaces,
      );
    }
    return AmountFormatter.format(
      amount.toString(),
      decimalPlaces: decimalPlaces,
    );
  }
}

