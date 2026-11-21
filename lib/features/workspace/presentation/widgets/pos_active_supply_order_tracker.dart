import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_procurement_approval_progress.dart';
import 'package:netsales/core/themes/app_colors.dart';
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
              PosProcurementApprovalProgress(presentation: order.statusPresentation),
            ],
          ),
        ),
      );
    });
  }
}

