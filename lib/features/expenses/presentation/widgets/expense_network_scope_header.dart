import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_operating_expenses_controller.dart';

class ExpenseNetworkScopeHeader extends StatelessWidget {
  const ExpenseNetworkScopeHeader({super.key, required this.controller});

  final NetworkOperatingExpensesController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final selected = controller.networks.where(
        (n) => n.networkId == controller.selectedNetworkId.value,
      );
      final current = selected.isEmpty ? null : selected.first;

      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: .55),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.account_tree_outlined, color: colors.primary),
            AppSpacing.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نطاق المصروفات',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    current?.networkName ?? 'حدد الشبكة',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (controller.networks.length > 1)
              PopupMenuButton<int>(
                tooltip: 'تغيير الشبكة',
                onSelected: controller.selectNetwork,
                itemBuilder: (_) => controller.networks
                    .map(
                      (n) => PopupMenuItem<int>(
                        value: n.networkId,
                        child: Text(n.networkName),
                      ),
                    )
                    .toList(),
                child: Icon(
                  Icons.unfold_more_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      );
    });
  }
}

