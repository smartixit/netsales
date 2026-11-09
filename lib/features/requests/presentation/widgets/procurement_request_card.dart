import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة عرض طلب التوريد في القوائم التشغيلية (Procurement Request Card)
class ProcurementRequestCard extends StatelessWidget {
  final RequestEntity request;
  final bool isNetworkView;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onApprove;
  final VoidCallback? onModify;
  final VoidCallback? onReject;

  const ProcurementRequestCard({
    super.key,
    required this.request,
    this.isNetworkView = false,
    required this.onTap,
    this.onCancel,
    this.onApprove,
    this.onModify,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusPresentation = EnumPresentationRegistry.resolveRequestStatus(
      request.status,
      serverLabel: request.statusLabel,
    );

    final saleTypePresentation = EnumPresentationRegistry.resolveSaleType(
      request.saleType,
      serverLabel: request.saleTypeLabel,
    );

    final title = isNetworkView
        ? (request.posName ?? 'نقطة بيع #${request.posId}')
        : (request.networkName ?? 'شبكة #${request.networkId}');

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: AppElevation.level2(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة: المعرف + الشارة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 20.r,
                        color: colors.primary,
                      ),
                    ),
                    AppSpacing.hSm,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طلب توريد #${request.requestUuid}',
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (request.requestDate != null)
                          Text(
                            request.requestDate!,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                CustomStatusBadge(
                  label: statusPresentation.label,
                  tone: statusPresentation.tone,
                  icon: statusPresentation.icon,
                ),
              ],
            ),

            AppSpacing.vMd,
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
            AppSpacing.vSm,

            // الجهة المعنية ونوع الدفع
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    saleTypePresentation.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.vSm,

            // إجمالي الطلب السيادي المحسوب عبر الخادم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي الطلب:',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  AmountFormatter.format(request.requestTotalAmount.toString()),
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // أزرار العمليات السريعة حسب مساحة العمل وحالة الطلب
            if (request.isPending) ...[
              AppSpacing.vMd,
              if (isNetworkView)
                Column(
                  children: [
                    if (onModify != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton.outline(
                          text: 'تعديل البنود ومعاينة التسعير',
                          icon: Icons.edit_note_rounded,
                          onPressed: onModify,
                        ),
                      ),
                      AppSpacing.vSm,
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'اعتماد كما هو',
                            icon: Icons.check_circle_outline_rounded,
                            backgroundColor: colors.success,
                            foregroundColor: colors.onSuccess,
                            onPressed: onApprove,
                          ),
                        ),
                        AppSpacing.hSm,
                        Expanded(
                          child: CustomButton(
                            text: 'رفض',
                            icon: Icons.cancel_outlined,
                            backgroundColor: colors.error.withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor: colors.error,
                            onPressed: onReject,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else if (onCancel != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomButton(
                    text: 'إلغاء الطلب',
                    icon: Icons.close_rounded,
                    backgroundColor: colors.error.withValues(alpha: 0.1),
                    foregroundColor: colors.error,
                    onPressed: onCancel,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
