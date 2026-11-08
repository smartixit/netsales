import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_debt_ledger_controller.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class DebtScopeSelector extends StatelessWidget {
  const DebtScopeSelector({super.key, required this.controller});

  final PosDebtLedgerController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.account_tree_outlined,
                  color: colors.onPrimaryContainer,
                  size: 20,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نطاق كشف الذمم',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      'حدد نقطة البيع ومزود الشبكة لمراجعة الحساب الصحيح.',
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
            if (controller.isLoadingScope.value) {
              return const CustomSkeletonFeed(itemCount: 1);
            }

            if (controller.scopeErrorMessage.value != null &&
                controller.posOptions.isEmpty) {
              return CustomErrorState.compact(
                title: 'تعذر تحديد نقاط البيع',
                subtitle: controller.scopeErrorMessage.value,
                onRetry: controller.initializeScope,
              );
            }

            if (controller.posOptions.isEmpty) {
              return CustomEmptyState(
                icon: Icons.store_mall_directory_outlined,
                title: 'لا توجد نقاط بيع متاحة',
                subtitle: 'لا توجد نقطة بيع مرتبطة بحسابك يمكن عرض ذممها.',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.posOptions.length > 1)
                  CustomDropdown<int>(
                    label: 'نقطة البيع',
                    hint: 'اختر نقطة البيع',
                    prefixIcon: Icons.storefront_outlined,
                    rxValue: controller.selectedPosId,
                    items: controller.posOptions
                        .map(
                          (pos) => DropdownItem<int>(
                            value: pos.posId,
                            child: Text(
                              pos.posName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    itemSearchText: (posId) => controller.posName(posId),
                    onChanged: (posId) {
                      if (posId != null) controller.selectPos(posId);
                    },
                  )
                else
                  _ScopeValue(
                    label: 'نقطة البيع',
                    value: controller.posName(controller.posOptions.single.posId),
                    icon: Icons.storefront_outlined,
                  ),
                if (controller.selectedPosId.value != null) ...[
                  AppSpacing.vSm,
                  _buildNetworkSelector(context),
                ] else
                  Padding(
                    padding: EdgeInsets.only(top: AppSpacing.sm),
                    child: _SelectionHint(
                      text: 'اختر نقطة البيع أولاً لعرض مزودي الشبكة المرتبطين بها.',
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNetworkSelector(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoadingNetworks.value) {
        return const CustomSkeletonFeed(itemCount: 1);
      }

      if (controller.networksErrorMessage.value != null &&
          controller.networkLinks.isEmpty) {
        return CustomErrorState.compact(
          title: 'تعذر تحميل مزودي الشبكة',
          subtitle: controller.networksErrorMessage.value,
          onRetry: controller.loadNetworksForSelectedPos,
        );
      }

      if (controller.networkLinks.isEmpty) {
        return CustomEmptyState(
          icon: Icons.link_off_outlined,
          title: 'لا يوجد مزود شبكة مرتبط',
          subtitle: 'لا يمكن استعراض ذمم هذه النقطة دون اختيار مزود مرتبط بها.',
        );
      }

      final needsSelection = controller.networkLinks.length > 1 ||
          controller.hasMoreNetworkOptions;

      if (!needsSelection) {
        final selected = controller.selectedNetwork;
        if (selected == null) {
          return const CustomSkeletonFeed(itemCount: 1);
        }
        return _ScopeValue(
          label: 'مزود الشبكة',
          value: controller.networkLabel(selected),
          icon: Icons.wifi_tethering_rounded,
        );
      }

      final selected = controller.selectedNetwork;
      final links = controller.networkLinks;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdown<int>(
            label: 'مزود الشبكة',
            hint: 'اختر مزود الشبكة',
            prefixIcon: Icons.wifi_tethering_rounded,
            rxValue: controller.selectedNetworkId,
            items: links
                .map(
                  (link) => DropdownItem<int>(
                    value: link.networkId,
                    child: Text(
                      controller.networkLabel(link),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            itemSearchText: controller.networkName,
            onRemoteSearch: controller.searchNetworks,
            isSearching: controller.isSearchingNetworks.value,
            selectedItemFallback: selected == null
                ? null
                : DropdownItem<int>(
                    value: selected.networkId,
                    child: Text(
                      controller.networkLabel(selected),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
            onChanged: (networkId) {
              if (networkId != null) controller.selectNetwork(networkId);
            },
          ),
          if (controller.networkSearchErrorMessage.value != null) ...[
            AppSpacing.vXs,
            CustomErrorState.compact(
              title: 'تعذر البحث عن مزود الشبكة',
              subtitle: controller.networkSearchErrorMessage.value,
              onRetry: () => controller.searchNetworks(
                controller.networkSearchQuery.value,
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _ScopeValue extends StatelessWidget {
  const _ScopeValue({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

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
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 19),
          AppSpacing.hSm,
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
          Icon(Icons.verified_outlined, color: colors.success, size: 17),
        ],
      ),
    );
  }
}

class _SelectionHint extends StatelessWidget {
  const _SelectionHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 17, color: colors.onSurfaceVariant),
        AppSpacing.hSm,
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
