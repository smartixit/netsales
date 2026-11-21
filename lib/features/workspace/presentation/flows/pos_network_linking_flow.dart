import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/network_pos_link_confirm_sheet.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/qr/custom_qr_scanner.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// Coordinates the QR scanner and confirmation UI for linking a POS to a network.
class PosNetworkLinkingFlow {
  const PosNetworkLinkingFlow(this.controller);

  final PosWorkspaceController controller;

  Future<void> start() async {
    final posId = controller.activePos.value?.posId;
    if (posId == null || posId <= 0) {
      CustomSnackbar.show(
        title: 'تنبيه',
        message: 'يرجى اختيار وتفعيل نقطة البيع أولاً قبل مسح رمز الارتباط',
        type: SnackType.warning,
      );
      return;
    }

    await HapticFeedback.mediumImpact();
    await Get.to<void>(
      () => CustomQrScanner(
        title: 'مسح رمز ربط شبكة',
        instruction: 'وجّه الكاميرا نحو رمز QR لدعوة شبكة المزود',
        onClose: () => Get.back<void>(),
        onScan: (result) async {
          Get.back<void>();
          await _handleScannedPayload(result.rawValue, posId);
        },
      ),
      fullscreenDialog: true,
    );
  }

  Future<void> _handleScannedPayload(String payload, int posId) async {
    try {
      await HapticFeedback.lightImpact();
      final preview = await controller.previewNetworkLinkChallenge(
        payload: payload,
        posId: posId,
      );
      final confirmed = await NetworkPosLinkConfirmSheet.show(
        preview: preview,
        onConfirm: () async {
          try {
            final linked = await controller.confirmNetworkLinkChallenge(
              challengeUuid: preview.challengeUuid,
              posId: posId,
            );
            if (linked) {
              await CustomAnimationOverlay.showSuccess(
                message:
                    'تم ربط نقطة البيع بنجاح مع شبكة ${preview.displayNetworkName}',
              );
            }
            return linked;
          } catch (error) {
            CustomSnackbar.show(
              title: 'تعذر تأكيد الارتباط',
              message: AppException.sanitizeMessage(error.toString()),
              type: SnackType.error,
            );
            return false;
          }
        },
      );

      if (confirmed == true) {
        await controller.loadNetworks(posId, refresh: true);
      }
    } catch (error) {
      CustomSnackbar.show(
        title: 'رمز غير صالح أو منتهي',
        message: AppException.sanitizeMessage(error.toString()),
        type: SnackType.error,
      );
    }
  }
}
