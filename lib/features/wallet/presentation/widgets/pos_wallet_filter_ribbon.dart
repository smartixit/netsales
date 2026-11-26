import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/wallet/presentation/controllers/wallet_filter_controller.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';

/// البحث والتصفية في سجل حركات المحفظة عبر المكون الموحد [CustomSearchFilterBar].
class PosWalletFilterRibbon extends StatelessWidget {
  const PosWalletFilterRibbon({super.key, required this.controller});

  final WalletFilterController controller;

  @override
  Widget build(BuildContext context) {
    final depositPresentation =
        EnumPresentationRegistry.resolveWalletOperationType(
      WalletOperationType.deposit,
    );
    final withdrawPresentation =
        EnumPresentationRegistry.resolveWalletOperationType(
      WalletOperationType.withdraw,
    );

    return Obx(
      () => CustomSearchFilterBar<WalletOperationType?>(
        searchController: controller.searchController,
        searchHint: 'ابحث في بيان الحركة...',
        onSearchChanged: controller.onSearchChanged,
        selectedFilter: controller.selectedOperationType.value,
        onFilterChanged: controller.setOperationFilter,
        filterOptions: [
          const CustomSearchFilterOption<WalletOperationType?>(
            label: 'كل الحركات',
            value: null,
          ),
          CustomSearchFilterOption<WalletOperationType?>(
            label: depositPresentation.label,
            icon: depositPresentation.icon,
            value: WalletOperationType.deposit,
          ),
          CustomSearchFilterOption<WalletOperationType?>(
            label: withdrawPresentation.label,
            icon: withdrawPresentation.icon,
            value: WalletOperationType.withdraw,
          ),
        ],
        onClearAll: () {
          controller.searchController.clear();
          controller.onSearchChanged('');
          controller.setOperationFilter(null);
        },
      ),
    );
  }
}
