import 'package:flutter/services.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_qr_challenge_sheet.dart';

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
    await NetworkPosQrChallengeSheet.show(
      networkId: network.networkId,
      networkName: network.networkName,
      networkPhone: network.networkPhoneNumber,
    );
  }
}
