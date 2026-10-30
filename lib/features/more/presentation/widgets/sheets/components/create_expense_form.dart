import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// ============================================================================
/// استمارة قيد مصروف تشغيلي جديد (CreateExpenseForm)
/// ============================================================================
/// تجمع مدخلات المستخدم فقط (الشبكة، المبلغ، البيان) وتُصدّر حدث الحفظ إلى
/// الشاشة الحاضنة. لا تُجري أي حساب مالي — الخادم هو المرجع الحصري للمجاميع.
class CreateExpenseForm extends StatelessWidget {
  const CreateExpenseForm({
    super.key,
    required this.amountController,
    required this.notesController,
    required this.onSubmit,
  });

  final TextEditingController amountController;
  final TextEditingController notesController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = Get.find<MoreController>();

    return Obx(() {
      final isSubmitting = controller.isSubmittingAction.value;
      final networks = controller.availableNetworks;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // اختيار الشبكة التابع لها المصروف (يظهر فقط عند تعدد الشبكات)
          if (networks.length > 1) ...[
            CustomDropdown<int>(
              label: 'الشبكة التابع لها المصروف',
              hint: 'اختر الشبكة',
              prefixIcon: Icons.cell_tower_rounded,
              valueListenable: controller.selectedExpenseNetworkId,
              items: networks
                  .map(
                    (network) => DropdownItem<int>(
                      value: network.networkId,
                      child: Text(network.networkName),
                    ),
                  )
                  .toList(),
              itemSearchText: (id) =>
                  networks
                      .cast<NetworkEntity?>()
                      .firstWhere(
                        (network) => network?.networkId == id,
                        orElse: () => null,
                      )
                      ?.networkName ??
                  '',
              onChanged: controller.onExpenseNetworkChanged,
            ),
            AppSpacing.vMd,
          ],

          CustomTextField(
            controller: amountController,
            label: 'مبلغ المصروف التشغيلي',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(Icons.monetization_on_outlined),
            suffixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'ر.ي',
                style: AppTypography.labelMedium.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          AppSpacing.vMd,

          CustomTextField(
            controller: notesController,
            label: 'بيان المصروف والملاحظات',
            hint: 'مثال: إيجار المقر، صيانة شبكة، نثريات...',
            prefixIcon: const Icon(Icons.notes_rounded),
            isRequired: false,
          ),

          AppSpacing.vXl,

          if (PermissionService.to.can(AppPermissions.expensesCreate))
            CustomButton.primary(
              text: 'تسجيل المصروف',
              icon: Icons.check_circle_outline_rounded,
              loading: isSubmitting,
              onPressed: isSubmitting ? null : onSubmit,
            ),
        ],
      );
    });
  }
}
