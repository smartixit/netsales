import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// Displays the current server-confirmed pending request and its approval stage.
/// The visual stages describe only submission, pending approval and approval;
/// no unprovided shipping or delivery timestamps are inferred.
class PosActiveSupplyOrderTracker extends StatelessWidget {
  const PosActiveSupplyOrderTracker({super.key, required this.controller});

  final PosWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final order = controller.activeSupplyOrder;
      if (order == null) return const SizedBox.shrink();

      return CustomInteractiveBounce(
        onTap: () => controller.openProcurementOrder(order.request),
        child: CustomSurfaceCard(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: colors.primary,
                    size: 19.r,
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      'طلب التوريد النشط',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.vSm,
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.075),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: colors.warning.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طلب ${order.reference}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            order.formattedAmount,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hSm,
                    CustomStatusBadge.fromPresentation(
                      order.statusPresentation,
                      isCompact: true,
                    ),
                  ],
                ),
              ),
              AppSpacing.vMd,
              _ProcurementApprovalProgress(presentation: order.statusPresentation),
            ],
          ),
        ),
      );
    });
  }
}

class _ProcurementApprovalProgress extends StatelessWidget {
  const _ProcurementApprovalProgress({required this.presentation});

  final EnumPresentation presentation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusColor = presentation.tone.resolveColor(colors);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ProgressStep(
            label: 'تم الإرسال',
            icon: Icons.check_rounded,
            color: colors.success,
            isCurrent: false,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 11.h),
          child: Container(
            height: 2.h,
            width: 20.w,
            color: statusColor.withValues(alpha: 0.72),
          ),
        ),
        Expanded(
          child: _ProgressStep(
            label: presentation.label,
            icon: presentation.icon ?? Icons.help_outline_rounded,
            color: statusColor,
            isCurrent: true,
          ),
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.label,
    required this.icon,
    required this.color,
    required this.isCurrent,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 23.r,
          height: 23.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isCurrent ? 0.16 : 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.68)),
          ),
          child: Icon(icon, size: 13.r, color: color),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: isCurrent ? color : context.colors.onSurfaceVariant,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
