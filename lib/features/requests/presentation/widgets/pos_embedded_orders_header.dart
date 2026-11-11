import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// رأس شاشة طلبات التوريد المضمنة لنقطة البيع (Embedded Orders Header)
class PosEmbeddedOrdersHeader extends StatelessWidget {
  const PosEmbeddedOrdersHeader({super.key, required this.controller});

  final PosProcurementController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'طلبات التوريد والمشتريات',
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomButton.outline(
            text: 'طلب جديد',
            icon: Icons.add_shopping_cart_rounded,
            size: AppButtonSize.small,
            onPressed: controller.navigateToNewOrder,
          ),
          AppSpacing.hXs,
          CustomButton.icon(
            icon: Icons.refresh_rounded,
            tooltip: 'تحديث الطلبات',
            backgroundColor: Colors.transparent,
            foregroundColor: colors.onSurfaceVariant,
            onPressed: () => controller.loadRequests(isRefresh: true),
          ),
        ],
      ),
    );
  }
}

