import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/presentation/controllers/pos_details_controller.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';

class PosDetailsScreen extends GetView<PosDetailsController> {
  const PosDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomAppScaffold(
    appBarTitle: 'ملف نقطة البيع',
    body: Obx(() {
      final pos = controller.pos.value;
      if (controller.isLoading.value && pos == null) {
        return const CustomStateView.loading();
      }
      if (controller.errorMessage.value != null && pos == null) {
        return CustomErrorState(
          title: 'تعذر تحميل ملف نقطة البيع',
          subtitle: controller.errorMessage.value,
          onRetry: controller.load,
        );
      }
      if (pos == null) return const SizedBox.shrink();
      final location = [pos.governorateName, pos.directorateName]
          .whereType<String>().where((v) => v.trim().isNotEmpty).join(' - ');
      return ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          CustomPageHeroCard(
            title: pos.displayName,
            subtitle: 'ملف الكيان وبياناته الأساسية',
            icon: Icons.storefront_rounded,
          ),
          AppSpacing.vMd,
          CustomSurfaceCard(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CustomCachedImage.logo(
                    url: pos.posProfileLogoUrl,
                    size: 68,
                    fallbackText: pos.displayName,
                  ),
                  AppSpacing.hMd,
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pos.displayName, style: Theme.of(context).textTheme.titleLarge),
                      AppSpacing.vXs,
                      CustomStatusBadge(
                        label: pos.statusLabel ?? pos.typedStatus.label,
                        tone: pos.typedStatus.tone,
                      ),
                    ],
                  )),
                ]),
                AppSpacing.vMd,
                _DetailLine(label: 'الرقم المرجعي', value: pos.displayReference),
                _DetailLine(label: 'المالك', value: pos.displayOwnerName),
                _DetailLine(label: 'رقم الهاتف', value: pos.displayPhone),
                _DetailLine(label: 'البريد الإلكتروني', value: pos.posEmail ?? 'غير محدد'),
                _DetailLine(label: 'المحافظة والمديرية', value: location.isEmpty ? 'غير محدد' : location),
                _DetailLine(label: 'العنوان', value: pos.posAddress ?? 'غير محدد'),
                _DetailLine(label: 'تاريخ الإنشاء', value: pos.formattedCreatedAt),
              ],
            ),
          ),
          AppSpacing.vMd,
          if (controller.canEdit) CustomButton.secondary(
            text: 'تحديث البيانات',
            onPressed: () async {
              final saved = await Get.toNamed('/pos/entities/${pos.posId}/edit', arguments: pos);
              if (saved == true) await controller.load();
            },
            prefix: Icons.edit_outlined,
          ),
          if (controller.canDelete) ...[
            AppSpacing.vSm,
            CustomButton.danger(
              text: 'حذف نقطة البيع',
              prefix: Icons.delete_outline_rounded,
              onPressed: () => Get.dialog(
                CustomDialog.confirmation(
                  title: 'تأكيد حذف نقطة البيع',
                  message: 'سيتم نقل الكيان إلى المحذوفات مؤقتاً. لن يتم حذف علاقاته أو سجلاته المالية من خلال هذا الإجراء.',
                  confirmLabel: 'نقل إلى المحذوفات',
                  onConfirm: controller.deleteEntity,
                ),
              ),
            ),
          ],
        ],
      );
    }),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(children: [
      Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant))),
      AppSpacing.hMd,
      Flexible(child: Text(value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodyMedium)),
    ]),
  );
}
