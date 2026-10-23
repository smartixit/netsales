import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class VoucherRequestCard extends StatelessWidget {
  const VoucherRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onApprove,
    this.onReject,
  });

  final VoucherRequestEntity request;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Widget card = Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'طلب #${request.requestUuid}',
                  style: AppTypography.titleSmall.copyWith(color: colors.onSurface),
                ),
              ),
              _StatusChip(status: request.status, label: request.statusLabel),
            ],
          ),
          AppSpacing.vXs,
          Text(
            'الشبكة: ${request.networkName ?? request.networkId} • نقطة البيع: ${request.posName ?? request.posId}',
            style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant),
          ),
          AppSpacing.vXs,
          Text(
            'الإجمالي: ${AmountFormatter.formatValue(request.requestTotalAmount)} • بطاقات: ${request.totalCardsCount}',
            style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant),
          ),
          if (request.isPending && (onApprove != null || onReject != null)) ...[
            AppSpacing.vSm,
            Row(
              children: [
                if (onApprove != null)
                  Expanded(
                    child: CustomButton.primary(
                      text: 'اعتماد',
                      icon: Icons.check_rounded,
                      onPressed: onApprove!,
                    ),
                  ),
                if (onApprove != null && onReject != null) AppSpacing.hSm,
                if (onReject != null)
                  Expanded(
                    child: CustomButton.outline(
                      text: 'رفض',
                      icon: Icons.close_rounded,
                      onPressed: onReject!,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return CustomInteractiveBounce(
      onTap: onTap!,
      child: card,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.label});

  final String status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = status == 'PENDING'
        ? colors.warning
        : status == 'APPROVED'
            ? colors.success
            : colors.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full.r),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}
