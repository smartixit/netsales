import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_details_controller.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_directory_controller.dart';
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

class NetworkDetailsScreen extends GetView<NetworkDetailsController> {
  const NetworkDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomAppScaffold(
    appBarTitle: 'ملف الشبكة',
    body: Obx(() {
      final network = controller.network.value;
      if (controller.isLoading.value && network == null) {
        return const CustomStateView.loading();
      }
      if (controller.errorMessage.value != null && network == null) {
        return CustomErrorState(
          title: 'تعذر تحميل ملف الشبكة',
          subtitle: controller.errorMessage.value,
          onRetry: controller.load,
        );
      }
      if (network == null) return const SizedBox.shrink();
      return ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          CustomPageHeroCard(
            title: network.displayName,
            subtitle: 'ملف الكيان وبياناته الأساسية',
            icon: Icons.hub_rounded,
          ),
          AppSpacing.vMd,
          CustomSurfaceCard(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CustomCachedImage.logo(
                    url: network.networkProfileLogoUrl,
                    size: 68,
                    fallbackText: network.displayName,
                  ),
                  AppSpacing.hMd,
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(network.displayName, style: Theme.of(context).textTheme.titleLarge),
                      AppSpacing.vXs,
                      CustomStatusBadge(
                        label: network.statusLabel ?? network.typedStatus.label,
                        tone: network.typedStatus.tone,
                      ),
                    ],
                  )),
                ]),
                AppSpacing.vMd,
                _DetailLine(label: 'الرقم المرجعي', value: network.displayReference),
                _DetailLine(label: 'المالك', value: network.displayOwnerName),
                _DetailLine(label: 'رقم الهاتف', value: network.displayPhone),
                _DetailLine(label: 'البريد الإلكتروني', value: network.networkEmail ?? 'غير محدد'),
                _DetailLine(label: 'المحافظة والمديرية', value: [network.governorateName, network.directorateName].whereType<String>().where((v) => v.trim().isNotEmpty).join(' - ').isEmpty ? 'غير محدد' : [network.governorateName, network.directorateName].whereType<String>().where((v) => v.trim().isNotEmpty).join(' - ')),
                _DetailLine(label: 'العنوان', value: network.networkAddress ?? 'غير محدد'),
                _DetailLine(label: 'تاريخ الإنشاء', value: network.formattedCreatedAt),
              ],
            ),
          ),
          AppSpacing.vMd,
          if (controller.canEdit) CustomButton.secondary(
            text: 'تحديث البيانات',
            onPressed: () async {
              final saved = await Get.toNamed(AppRoutes.networkEntityEdit.replaceFirst(':id', network.networkId.toString()), arguments: network);
              if (saved == true) {
                await controller.load();
                if (Get.isRegistered<NetworkDirectoryController>()) {
                  await Get.find<NetworkDirectoryController>().refreshDirectory();
                }
              }
            },
            prefix: Icons.edit_outlined,
          ),
          if (controller.canDelete) ...[
            AppSpacing.vSm,
            CustomButton.danger(
              text: 'حذف الشبكة',
              prefix: Icons.delete_outline_rounded,
              onPressed: () => Get.dialog(
                CustomDialog.confirmation(
                  title: 'تأكيد حذف الشبكة',
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
