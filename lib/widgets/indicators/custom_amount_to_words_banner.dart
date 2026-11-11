import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_to_words_converter.dart';
import 'package:netsales/widgets/toasts/custom_toast.dart';

/// ويدجيت تفقيط وعرض المبلغ بالكلمات (CustomAmountToWordsBanner)
/// يختفي تلقائياً وبشكل قطعي عندما يكون المبلغ صفراً أو فارغاً أو غير صالح.
class CustomAmountToWordsBanner extends StatelessWidget {
  final dynamic amount;
  final CurrencyWordsConfig? currency;
  final String? currencyCode;
  final String prefix;
  final String suffix;
  final bool enableCopy;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;

  const CustomAmountToWordsBanner({
    super.key,
    required this.amount,
    this.currency,
    this.currencyCode,
    this.prefix = 'فقط',
    this.suffix = 'لا غير',
    this.enableCopy = true,
    this.textStyle,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final words = AmountToWordsConverter.convert(
      amount,
      currency: currency,
      currencyCode: currencyCode,
      prefix: prefix,
      suffix: suffix,
    );

    // إذا كانت القيمة صفرية أو فارغة يختفي الودجت تماماً دون شغل مساحة
    if (words.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    return Container(
      margin: margin ?? EdgeInsets.only(top: AppSpacing.xs),
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: borderColor ?? colors.primary.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 16.r,
            color: colors.primary,
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              words,
              style: textStyle ??
                  AppTypography.bodySmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5.sp,
                    height: 1.4,
                  ),
            ),
          ),
          if (enableCopy) ...[
            SizedBox(width: AppSpacing.xs),
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              onTap: () async {
                final success = await UrlLauncherService.copyToClipboard(words);
                if (success) {
                  CustomToast.show(
                    message: 'تم نسخ تفقيط المبلغ إلى الحافظة بنجاح.',
                    icon: Icons.check_circle_outline_rounded,
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.all(3.r),
                child: Icon(
                  Icons.copy_rounded,
                  size: 14.r,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
