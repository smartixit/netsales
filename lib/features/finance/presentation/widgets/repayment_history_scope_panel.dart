import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_history_controller.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class RepaymentHistoryScopePanel extends StatelessWidget {
  const RepaymentHistoryScopePanel({
    super.key,
    required this.controller,
  });

  final RepaymentHistoryController controller;

  static const _statuses = ['ALL', 'COMPLETED', 'REVERSED'];

  int _selectedIndex(String? status) {
    final index = _statuses.indexOf(status ?? 'ALL');
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSpacing.xxxl,
                height: AppSpacing.xxxl,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: AppRadius.mdRadius,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: colors.onPrimaryContainer,
                  size: AppSpacing.xl,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نطاق سجل السداد',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      'حدد الشبكة وحالة السندات التي تريد مراجعتها.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          Obx(() {
            if (controller.isLoadingNetworks.value ||
                controller.networks.isEmpty) {
              return const SizedBox.shrink();
            }

            final selected = controller.selectedNetwork;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.networks.length > 1)
                  CustomDropdown<int>(
                    label: 'الشبكة',
                    hint: 'اختر الشبكة',
                    prefixIcon: Icons.account_tree_outlined,
                    rxValue: controller.selectedNetworkId,
                    items: controller.networks
                        .map(
                          (network) => DropdownItem<int>(
                            value: network.networkId,
                            child: Text(
                              network.networkName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    itemSearchText: (networkId) =>
                        controller.networks
                            .firstWhereOrNull(
                              (network) => network.networkId == networkId,
                            )
                            ?.networkName ??
                        networkId.toString(),
                    onChanged: (networkId) {
                      if (networkId != null) {
                        controller.selectNetwork(networkId);
                      }
                    },
                  )
                else if (selected != null)
                  _SelectedNetworkValue(name: selected.networkName),
                AppSpacing.vMd,
                Text(
                  'حالة السند',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                AppSpacing.vXs,
                Obx(
                  () => CustomSegmentedBar(
                    selectedIndex:
                        _selectedIndex(controller.selectedStatus.value),
                    items: const [
                      CustomSegmentItem(
                        label: 'الكل',
                        icon: Icons.receipt_long_outlined,
                      ),
                      CustomSegmentItem(
                        label: 'مكتمل',
                        icon: Icons.check_circle_outline,
                      ),
                      CustomSegmentItem(
                        label: 'معكوس',
                        icon: Icons.undo_rounded,
                      ),
                    ],
                    onSegmentChanged: (index) {
                      controller.onStatusChanged(_statuses[index]);
                    },
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SelectedNetworkValue extends StatelessWidget {
  const _SelectedNetworkValue({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_tree_outlined,
            color: colors.primary,
            size: AppSpacing.lg,
          ),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
          Icon(
            Icons.verified_outlined,
            color: colors.success,
            size: AppSpacing.md,
          ),
        ],
      ),
    );
  }
}
