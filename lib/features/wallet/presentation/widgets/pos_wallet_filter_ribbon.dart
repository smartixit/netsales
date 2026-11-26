import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/wallet/presentation/controllers/wallet_filter_controller.dart';
import 'package:netsales/features/wallet/presentation/widgets/pos_wallet_filter_chip.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// البحث والتصفية في سجل حركات المحفظة.
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller.searchController,
          label: 'البحث في الحركات',
          hint: 'ابحث في بيان الحركة...',
          prefixIcon: const Icon(Icons.search_rounded),
          isRequired: false,
          onChanged: controller.onSearchChanged,
        ),
        SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(
            () => Row(
              children: [
                PosWalletFilterChip(
                  label: 'كل الحركات',
                  isSelected: controller.selectedOperationType.value == null,
                  onTap: () => controller.setOperationFilter(null),
                ),
                SizedBox(width: AppSpacing.xs),
                PosWalletFilterChip(
                  label: depositPresentation.label,
                  icon: depositPresentation.icon,
                  accentColor: depositPresentation.tone.color(context),
                  isSelected:
                      controller.selectedOperationType.value ==
                      WalletOperationType.deposit,
                  onTap: () => controller.setOperationFilter(
                    WalletOperationType.deposit,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                PosWalletFilterChip(
                  label: withdrawPresentation.label,
                  icon: withdrawPresentation.icon,
                  accentColor: withdrawPresentation.tone.color(context),
                  isSelected:
                      controller.selectedOperationType.value ==
                      WalletOperationType.withdraw,
                  onTap: () => controller.setOperationFilter(
                    WalletOperationType.withdraw,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
