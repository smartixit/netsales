import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/revoke_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/network_pos_qr_invitation_sheet.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// Coordinates the network invitation QR presentation flow.
class NetworkPosInviteFlow {
  const NetworkPosInviteFlow(this.controller);

  final NetworkWorkspaceController controller;

  Future<void> start() async {
    final network =
        controller.selectedNetwork ?? controller.networks.firstOrNull;
    if (network == null) {
      CustomSnackbar.show(
        title: 'تنبيه',
        message: 'يرجى اختيار شبكة أولاً لمشاركة رمز الدعوة',
        type: SnackType.warning,
      );
      return;
    }

    await HapticFeedback.lightImpact();

    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري توليد رمز الدعوة المشفر (QR)...',
      );

      final createChallengeUseCase =
          Get.find<CreateNetworkPosLinkChallengeUseCase>();
      final challenge = await createChallengeUseCase(
        networkId: network.networkId,
      );

      await CustomAnimationOverlay.hide();

      await CustomBottomSheet.show<void>(
        title: 'رمز دعوة الارتباط التجاري',
        subtitle: 'شارك الرمز مع نقطة البيع لإتمام الارتباط فورياً',
        leadingIcon: Icons.qr_code_2_rounded,
        child: NetworkPosQrInvitationSheet(
          challenge: challenge,
          onRevoke: () async {
            try {
              final revokeUseCase =
                  Get.find<RevokeNetworkPosLinkChallengeUseCase>();
              await revokeUseCase(challenge.challengeUuid);
              CustomSnackbar.show(
                title: 'تم الإلغاء',
                message: 'تم إلغاء صلاحية رمز الدعوة بنجاح',
                type: SnackType.info,
              );
            } catch (error) {
              CustomSnackbar.show(
                title: 'تعذر إلغاء الدعوة',
                message: AppException.sanitizeMessage(error),
                type: SnackType.error,
              );
            }
          },
        ),
      );
    } catch (error) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر توليد رمز الدعوة',
        message: AppException.sanitizeMessage(error),
        type: SnackType.error,
      );
    }
  }
}

