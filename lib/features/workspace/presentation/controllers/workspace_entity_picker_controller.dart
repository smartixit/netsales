import 'dart:async';

import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_coordinator_controller.dart';

/// متحكم نافذة اختيار الكيانات والمساحات المرتبطة بالمستخدم (WorkspaceEntityPickerController)
class WorkspaceEntityPickerController extends GetxController {
  final GetMyNetworksUseCase getMyNetworksUseCase;
  final GetMyPosUseCase getMyPosUseCase;

  WorkspaceEntityPickerController({
    required this.getMyNetworksUseCase,
    required this.getMyPosUseCase,
  });

  static WorkspaceEntityPickerController get to =>
      Get.find<WorkspaceEntityPickerController>();

  final RxList<NetworkEntity> networks = <NetworkEntity>[].obs;
  final RxList<PosEntity> pointsOfSale = <PosEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxInt selectedSegment = 0.obs; // 0: شبكات, 1: نقاط بيع

  void prepareForWorkspace(AppWorkspace workspace) {
    selectedSegment.value = workspace == AppWorkspace.network ? 0 : 1;
    unawaited(loadEntities());
  }

  Future<void> loadEntities({bool forceSkeleton = true}) async {
    if (forceSkeleton) {
      isLoading.value = true;
    }
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        getMyNetworksUseCase(),
        getMyPosUseCase(),
      ]);
      networks.assignAll(results[0] as List<NetworkEntity>);
      pointsOfSale.assignAll(results[1] as List<PosEntity>);
    } catch (e) {
      if (networks.isEmpty && pointsOfSale.isEmpty) {
        errorMessage.value = 'تعذر تحميل الكيانات المرتبطة بحسابك.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool get canSwitchWorkspace =>
      Get.isRegistered<WorkspaceCoordinatorController>() &&
      WorkspaceCoordinatorController.to.canSwitchWorkspace;

  String get switchWorkspaceTooltip =>
      WorkspaceCoordinatorController.to.switchWorkspaceTooltip;

  Future<void> toggleWorkspace() async {
    if (!Get.isRegistered<WorkspaceCoordinatorController>()) return;
    Get.back<void>();
    await WorkspaceCoordinatorController.to.toggleWorkspace();
  }

  int? get activeNetworkId {
    if (Get.isRegistered<NetworkWorkspaceController>()) {
      return Get.find<NetworkWorkspaceController>().selectedNetworkId.value;
    }
    return WorkspaceService.to.savedActiveNetworkId;
  }

  int? get activePosId {
    if (Get.isRegistered<PosWorkspaceController>()) {
      return Get.find<PosWorkspaceController>().activePos.value?.posId;
    }
    return WorkspaceService.to.savedActivePosId;
  }

  Future<void> selectNetwork(NetworkEntity network) async {
    await WorkspaceService.to.saveActiveNetworkId(network.networkId);
    if (Get.isRegistered<NetworkWorkspaceController>()) {
      await Get.find<NetworkWorkspaceController>().selectNetwork(
        network.networkId,
      );
      Get.back<void>();
    } else if (Get.isRegistered<WorkspaceCoordinatorController>()) {
      Get.back<void>();
      await WorkspaceCoordinatorController.to.switchWorkspace(
        AppWorkspace.network,
      );
    } else {
      Get.back<void>();
    }
  }

  Future<void> selectPos(PosEntity pos) async {
    await WorkspaceService.to.saveActivePosId(pos.posId);
    if (Get.isRegistered<PosWorkspaceController>()) {
      await Get.find<PosWorkspaceController>().selectPos(pos);
      Get.back<void>();
    } else if (Get.isRegistered<WorkspaceCoordinatorController>()) {
      Get.back<void>();
      await WorkspaceCoordinatorController.to.switchWorkspace(AppWorkspace.pos);
    } else {
      Get.back<void>();
    }
  }
}
