import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/base_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_action_dialogs.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/commercial_partner_details_sheet.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// تنسيق الحوارات وشيتات الشريك التجاري خارج Controllers.
class CommercialPresentationCoordinator {
  const CommercialPresentationCoordinator(this.controller);

  final BaseCommercialDirectoryController controller;

  void openPartnerDetails(NetworkPosLinkEntity link) {
    CustomBottomSheet.show<void>(
      title: controller.isNetworkView ? 'ملف نقطة البيع' : 'ملف مزود الشبكة',
      subtitle: 'البيانات التجارية المعتمدة للشريك',
      leadingIcon: controller.isNetworkView
          ? Icons.storefront_rounded
          : Icons.hub_rounded,
      child: CommercialPartnerDetailsSheet(
        link: link,
        isNetworkView: controller.isNetworkView,
      ),
    );
  }

  Future<void> togglePartnerStatus(NetworkPosLinkEntity link) async {
    if (!controller.canTogglePartnerLink) return;
    final partnerName = controller.isNetworkView
        ? link.displayPosName
        : link.displayNetworkName;

    await CommercialActionDialogs.showToggleStatusDialog(
      partnerName: partnerName,
      willDeactivate: link.isActive,
      onConfirm: () async {
        try {
          await controller.togglePartnerLink(link);
          await CustomAnimationOverlay.showSuccess(
            message: link.isActive
                ? 'تم تجميد الارتباط بنجاح'
                : 'تم تنشيط الارتباط بنجاح',
          );
        } catch (error) {
          CustomSnackbar.show(
            title: 'تعذر تحديث الارتباط',
            message: AppException.sanitizeMessage(error),
            type: SnackType.error,
          );
        }
      },
    );
  }

  Future<void> unlinkPartner(NetworkPosLinkEntity link) async {
    if (!controller.canDeletePartnerLink) return;
    final partnerName = controller.isNetworkView
        ? link.displayPosName
        : link.displayNetworkName;

    await CommercialActionDialogs.showUnlinkDialog(
      partnerName: partnerName,
      onConfirm: () async {
        try {
          await controller.deletePartnerLink(link);
          await CustomAnimationOverlay.showSuccess(
            message: 'تم فك الارتباط التجاري بنجاح',
          );
        } catch (error) {
          CustomSnackbar.show(
            title: 'تعذر فك الارتباط',
            message: AppException.sanitizeMessage(error),
            type: SnackType.error,
          );
        }
      },
    );
  }
}
