import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط الإجراءات السفلي المثبت في شيت تعديل طلب التوريد
class NetworkRequestModificationFooter
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestModificationFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isLoadingEditor = controller.isLoadingEditor.value;
      final isPreviewing = controller.isPreviewingModification.value;
      final isProcessing = controller.isProcessingDecision.value;
      final preview = controller.currentPreview.value;
      final hasLines = controller.modificationLines.isNotEmpty;
      final hasChanges = controller.hasModificationChanges;
      final isBusy = isLoadingEditor || isPreviewing || isProcessing;
      final canSubmit = hasLines && hasChanges && !isBusy;

      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.outlineVariant.withValues(alpha: .4)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: 'معاينة',
                  icon: Icons.calculate_outlined,
                  size: AppButtonSize.medium,
                  loading: isPreviewing,
                  onPressed: canSubmit
                      ? () => controller.previewModification()
                      : null,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                flex: 2,
                child: CustomButton.primary(
                  text: preview != null
                      ? 'اعتماد الطلب المعدل'
                      : 'اعتماد بالتعديل',
                  icon: Icons.check_circle_rounded,
                  size: AppButtonSize.medium,
                  loading: isProcessing,
                  onPressed: canSubmit
                      ? () => controller.confirmAndApproveModification()
                      : null,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
