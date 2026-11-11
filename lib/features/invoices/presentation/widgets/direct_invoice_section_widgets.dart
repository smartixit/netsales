import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// عنوان قسم الفاتورة المباشرة مع وصف إرشادي
class DirectInvoiceSectionHeading extends StatelessWidget {
  final String title;
  final String description;

  const DirectInvoiceSectionHeading({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vXxs,
        Text(
          description,
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// تنبيه سطحي رمادي توضيحي لمتطلبات الفاتورة
class DirectInvoiceInlineNotice extends StatelessWidget {
  final String message;
  final IconData icon;

  const DirectInvoiceInlineNotice({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// إشعار الحوكمة المالية والتسعير المعتمد حصراً من الخادم
class DirectInvoiceFinancialAuthorityNotice extends StatelessWidget {
  const DirectInvoiceFinancialAuthorityNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: colors.primary),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              'لن يحسب التطبيق أي سعر أو خصم أو إجمالي. سيعيد الخادم بيانات الفاتورة بعد التحقق من الباقات والأسعار التعاقدية والمحافظ والسقف الائتماني.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurface,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

