import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/contact_picker_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// زر موحد لاختيار رقم الجوال من جهات الاتصال (CustomContactPickerIconButton).
///
/// يُمكن استخدامه كـ `suffixIcon` داخل `CustomTextField` أو في صف بجانب الحقل:
/// ```dart
/// CustomTextField(
///   controller: controller.phoneController,
///   suffixIcon: CustomContactPickerIconButton(
///     controller: controller.phoneController,
///     nameController: controller.nameController,
///   ),
/// )
/// ```
class CustomContactPickerIconButton extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController? nameController;
  final VoidCallback? onSelected;
  final String tooltip;

  const CustomContactPickerIconButton({
    super.key,
    required this.controller,
    this.nameController,
    this.onSelected,
    this.tooltip = 'اختيار من جهات الاتصال',
  });

  @override
  Widget build(BuildContext context) {
    if (!ContactPickerService.isSupported) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: CustomButton.icon(
        icon: Icons.contact_phone_outlined,
        tooltip: tooltip,
        dimension: 36.r,
        iconSize: 20.r,
        foregroundColor: colors.primary,
        backgroundColor: Colors.transparent,
        onPressed: () {
          ContactPickerService.pickAndFill(
            phoneController: controller,
            nameController: nameController,
            onSelected: onSelected,
          );
        },
      ),
    );
  }
}
