import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_linkable_pos_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/skeletons/custom_state_skeleton_view.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// Search and selection surface; all query state and pagination belong to GetX.
class NetworkPosInvitationTargetDialog extends StatelessWidget {
  const NetworkPosInvitationTargetDialog({
    super.key,
    required this.codeController,
    required this.targets,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.resolvedTarget,
    required this.onChanged,
    required this.onLoadMore,
    required this.onSelect,
    required this.onConfirm,
    required this.onCancel,
  });

  final TextEditingController codeController;
  final RxList<NetworkLinkablePosEntity> targets;
  final RxBool isLoading;
  final RxBool isLoadingMore;
  final RxBool hasMore;
  final RxnString errorMessage;
  final Rxn<NetworkLinkablePosEntity> resolvedTarget;
  final ValueChanged<String> onChanged;
  final VoidCallback onLoadMore;
  final ValueChanged<NetworkLinkablePosEntity> onSelect;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ابحث عن نقطة البيع باسمها أو بمعرفها التجاري، ثم اخترها لإصدار دعوة ارتباط جديدة.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: codeController,
            label: 'اسم نقطة البيع أو المعرف التجاري',
            hint: 'اكتب اسم نقطة البيع أو رمزها...',
            prefixIcon: const Icon(Icons.search_rounded),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
          ),
          SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Obx(() {
              if (isLoading.value) {
                return CustomStateView.loading(
                  title: 'جارٍ البحث عن نقاط البيع المؤهلة',
                  subtitle: 'يتم استبعاد المرتبطة مسبقاً والدعوات السارية.',
                  presentation: CustomStatePresentation.skeletonOnly,
                  skeleton: SkeletonRecipes.list(
                    itemCount: 3,
                    cardHeight: 68,
                    hasLeading: true,
                    hasTrailing: false,
                    lineCount: 2,
                  ),
                );
              }

              final error = errorMessage.value;
              if (error != null && targets.isEmpty) {
                return CustomStateView.error(
                  title: 'تعذر البحث عن نقاط البيع',
                  subtitle: error,
                  presentation: CustomStatePresentation.compact,
                );
              }

              if (codeController.text.trim().length < 2) {
                return CustomStateView.empty(
                  title: 'ابدأ بكتابة اسم نقطة البيع',
                  subtitle: 'أدخل حرفين على الأقل لعرض النتائج المطابقة.',
                  presentation: CustomStatePresentation.compact,
                  icon: Icons.storefront_outlined,
                );
              }

              if (targets.isEmpty) {
                return CustomStateView.empty(
                  title: 'لا توجد نقاط بيع مؤهلة',
                  subtitle: 'تحقق من الاسم أو الرمز التجاري. لن تظهر نقاط البيع المرتبطة أو التي لديها دعوة سارية.',
                  presentation: CustomStatePresentation.compact,
                  icon: Icons.search_off_rounded,
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (error != null)
                    CustomStateView.error(
                      title: 'تعذر تحميل بقية النتائج',
                      subtitle: error,
                      presentation: CustomStatePresentation.compact,
                    ),
                  SizedBox(
                    height: targets.length > 4 ? 280 : targets.length * 70,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: targets.length,
                separatorBuilder: (_, _) => SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final target = targets[index];
                  final selected = resolvedTarget.value?.posUuid == target.posUuid;

                  return CustomButton.secondary(
                    onPressed: () => onSelect(target),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    backgroundColor: selected
                        ? colors.primaryContainer
                        : colors.surfaceContainerLow,
                    foregroundColor: colors.onSurface,
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.storefront_rounded,
                          color: selected ? colors.primary : colors.onSurfaceVariant,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                target.posName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                target.posUuid,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_rounded, color: colors.primary),
                      ],
                    ),
                    );
                  },
                ),
              ],
            );
            }),
          ),
          Obx(() {
            if (isLoadingMore.value) {
              return Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm),
                child: CustomStateSkeletonView(
                  recipe: SkeletonRecipes.list(
                    itemCount: 2,
                    cardHeight: 54,
                    hasLeading: true,
                    lineCount: 2,
                  ),
                ),
              );
            }
            if (!hasMore.value || targets.isEmpty || isLoading.value) {
              return const SizedBox.shrink();
            }
            return Align(
              alignment: AlignmentDirectional.center,
              child: CustomButton.text(
                text: 'تحميل المزيد من النتائج',
                onPressed: onLoadMore,
                icon: Icons.expand_more_rounded,
                size: AppButtonSize.small,
              ),
            );
          }),
          Obx(() {
            final target = resolvedTarget.value;
            if (target == null) return const SizedBox.shrink();

            return Container(
              margin: EdgeInsets.only(top: AppSpacing.sm),
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.primary.withValues(alpha: .3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, color: colors.primary, size: 26),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نقطة البيع المحددة للدعوة',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          target.posName,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          target.posUuid,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: 'إلغاء',
                  onPressed: onCancel,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Obx(
                  () => CustomButton.primary(
                    text: 'إنشاء دعوة QR',
                    icon: Icons.qr_code_rounded,
                    enabled: resolvedTarget.value != null,
                    onPressed: resolvedTarget.value == null ? null : onConfirm,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
