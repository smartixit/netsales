import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_entity.dart';
import 'package:netsales/features/partners/domain/usecases/approve_partner_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_networks_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_list_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/reject_partner_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/toggle_network_pos_status_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم الشركاء وشبكة التوزيع (PartnersController)
/// ============================================================================
/// يدير حالة شاشة الشركاء، التبويبات الثلاثية، التصفية المزدوجة، وعمليات الاعتماد/الرفض.
class PartnersController extends GetxController {
  final GetNetworksUseCase _getNetworksUseCase;
  final GetPosListUseCase _getPosListUseCase;
  final GetNetworkPosListUseCase _getNetworkPosListUseCase;
  final ToggleNetworkPosStatusUseCase _toggleNetworkPosStatusUseCase;
  final ApprovePartnerUseCase _approvePartnerUseCase;
  final RejectPartnerUseCase _rejectPartnerUseCase;

  PartnersController({
    required GetNetworksUseCase getNetworksUseCase,
    required GetPosListUseCase getPosListUseCase,
    required GetNetworkPosListUseCase getNetworkPosListUseCase,
    required ToggleNetworkPosStatusUseCase toggleNetworkPosStatusUseCase,
    required ApprovePartnerUseCase approvePartnerUseCase,
    required RejectPartnerUseCase rejectPartnerUseCase,
  })  : _getNetworksUseCase = getNetworksUseCase,
        _getPosListUseCase = getPosListUseCase,
        _getNetworkPosListUseCase = getNetworkPosListUseCase,
        _toggleNetworkPosStatusUseCase = toggleNetworkPosStatusUseCase,
        _approvePartnerUseCase = approvePartnerUseCase,
        _rejectPartnerUseCase = rejectPartnerUseCase;

  // ============================================================================
  // حالة الواجهة وحقول البحث
  // ============================================================================
  final RxInt activeSegmentIndex = 0.obs; // 0: Networks, 1: POS, 2: Links
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedStatusFilter = 'ALL'.obs;
  final RxBool isLoading = false.obs;

  // قوائم البيانات الخام
  final RxList<NetworkEntity> networks = <NetworkEntity>[].obs;
  final RxList<PosEntity> posList = <PosEntity>[].obs;
  final RxList<NetworkPosEntity> networkPosList = <NetworkPosEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    loadAllData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ============================================================================
  // جلب البيانات من الخادم
  // ============================================================================
  Future<void> loadAllData({bool isRefresh = false}) async {
    if (!isRefresh) isLoading.value = true;
    try {
      await Future.wait([
        fetchNetworks(),
        fetchPosList(),
        fetchNetworkPosList(),
      ]);
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNetworks() async {
    try {
      final result = await _getNetworksUseCase();
      networks.assignAll(result);
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  Future<void> fetchPosList() async {
    try {
      final result = await _getPosListUseCase();
      posList.assignAll(result);
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  Future<void> fetchNetworkPosList() async {
    try {
      final result = await _getNetworkPosListUseCase();
      networkPosList.assignAll(result);
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  // ============================================================================
  // تغيير التبويب والتصفية
  // ============================================================================
  void changeSegment(int index) {
    activeSegmentIndex.value = index;
    selectedStatusFilter.value = 'ALL';
  }

  void filterByStatus(String status) {
    selectedStatusFilter.value = status;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void onSearchSubmitted(String query) {
    searchQuery.value = query;
  }

  // ============================================================================
  // القوائم المصفاة (Filtered Getters)
  // ============================================================================
  List<NetworkEntity> get filteredNetworks {
    final query = searchQuery.value.trim().toLowerCase();
    final status = selectedStatusFilter.value.toUpperCase();

    return networks.where((network) {
      final matchesSearch = query.isEmpty ||
          network.networkName.toLowerCase().contains(query) ||
          (network.networkPhoneNumber?.contains(query) ?? false) ||
          (network.ownerName?.toLowerCase().contains(query) ?? false) ||
          (network.governorateName?.toLowerCase().contains(query) ?? false) ||
          (network.directorateName?.toLowerCase().contains(query) ?? false);

      final matchesStatus = status == 'ALL' || network.status.toUpperCase() == status;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<PosEntity> get filteredPosList {
    final query = searchQuery.value.trim().toLowerCase();
    final status = selectedStatusFilter.value.toUpperCase();

    return posList.where((pos) {
      final matchesSearch = query.isEmpty ||
          pos.posName.toLowerCase().contains(query) ||
          (pos.posPhoneNumber?.contains(query) ?? false) ||
          (pos.agentName?.toLowerCase().contains(query) ?? false) ||
          (pos.governorateName?.toLowerCase().contains(query) ?? false) ||
          (pos.directorateName?.toLowerCase().contains(query) ?? false);

      final matchesStatus = status == 'ALL' || pos.status.toUpperCase() == status;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<NetworkPosEntity> get filteredNetworkPosList {
    final query = searchQuery.value.trim().toLowerCase();
    final status = selectedStatusFilter.value.toUpperCase();

    return networkPosList.where((link) {
      final matchesSearch = query.isEmpty ||
          (link.networkName?.toLowerCase().contains(query) ?? false) ||
          (link.posName?.toLowerCase().contains(query) ?? false) ||
          (link.posPhone?.contains(query) ?? false) ||
          (link.governorateName?.toLowerCase().contains(query) ?? false) ||
          (link.directorateName?.toLowerCase().contains(query) ?? false);

      final matchesStatus = status == 'ALL' ||
          (status == 'ACTIVE' && link.isActive) ||
          (status == 'INACTIVE' && !link.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ============================================================================
  // المؤشرات الرقمية الحيوية (KPI Counters)
  // ============================================================================
  int get totalNetworksCount => networks.length;
  int get activeNetworksCount => networks.where((n) => n.isActive).length;
  int get pendingNetworksCount => networks.where((n) => n.isPending).length;

  int get totalPosCount => posList.length;
  int get activePosCount => posList.where((p) => p.isActive).length;
  int get pendingPosCount => posList.where((p) => p.isPending).length;

  int get totalLinksCount => networkPosList.length;
  int get activeLinksCount => networkPosList.where((l) => l.isActive).length;

  // ============================================================================
  // العمليات والإجراءات الحساسة (Approve / Reject / Toggle)
  // ============================================================================

  /// تبديل حالة عقد الشراكة بين نشط ومجمد
  Future<void> toggleLinkStatus(int networkPosId) async {
    CustomAnimationOverlay.showLoading(message: 'جارٍ تحديث حالة الارتباط...');
    try {
      await _toggleNetworkPosStatusUseCase(networkPosId);
      await fetchNetworkPosList();
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تحديث حالة ارتباط نقطة البيع بالشبكة بنجاح.',
      );
    } catch (e) {
      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'خطأ',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  /// طلب تأكيد ثم اعتماد مزود شبكة
  Future<void> confirmApproveNetwork(NetworkEntity network) async {
    final confirmed = await CustomDialog.showConfirmation(
      title: 'اعتماد مزود الشبكة',
      message: 'هل أنت متأكد من اعتماد طلب مزود الشبكة "${network.networkName}" وتفعيل حسابه رسمياً؟',
      confirmLabel: 'تأكيد الاعتماد',
      cancelLabel: 'إلغاء',
    );

    if (confirmed == true) {
      CustomAnimationOverlay.showLoading(message: 'جارٍ اعتماد الشبكة وتفعيل الحساب...');
      try {
        await _approvePartnerUseCase(
          id: network.networkId,
          type: PartnerType.network,
        );
        await fetchNetworks();
        await CustomAnimationOverlay.showSuccess(
          message: 'تم اعتماد الشبكة "${network.networkName}" وتفعيل حسابها بنجاح.',
        );
      } catch (e) {
        await CustomAnimationOverlay.hide();
        CustomSnackbar.show(
          title: 'خطأ',
          message: AppException.sanitizeMessage(e),
          type: SnackType.error,
        );
      }
    }
  }

  /// طلب تأكيد ثم اعتماد نقطة بيع
  Future<void> confirmApprovePos(PosEntity pos) async {
    final confirmed = await CustomDialog.showConfirmation(
      title: 'اعتماد نقطة البيع',
      message: 'هل أنت متأكد من اعتماد طلب نقطة البيع "${pos.posName}" وتفعيل حسابها رسمياً؟',
      confirmLabel: 'تأكيد الاعتماد',
      cancelLabel: 'إلغاء',
    );

    if (confirmed == true) {
      CustomAnimationOverlay.showLoading(message: 'جارٍ اعتماد نقطة البيع...');
      try {
        await _approvePartnerUseCase(
          id: pos.posId,
          type: PartnerType.pos,
        );
        await fetchPosList();
        await CustomAnimationOverlay.showSuccess(
          message: 'تمت الموافقة على نقطة البيع "${pos.posName}" بنجاح.',
        );
      } catch (e) {
        await CustomAnimationOverlay.hide();
        CustomSnackbar.show(
          title: 'خطأ',
          message: AppException.sanitizeMessage(e),
          type: SnackType.error,
        );
      }
    }
  }

  /// تنفيذ رفض طلب شبكة أو نقطة بيع مع السبب
  Future<void> executeReject({
    required bool isNetwork,
    required int id,
    required String name,
    required String reason,
  }) async {
    CustomAnimationOverlay.showLoading(message: 'جارٍ تسجيل قرار الرفض...');
    try {
      await _rejectPartnerUseCase(
        id: id,
        type: isNetwork ? PartnerType.network : PartnerType.pos,
        reason: reason,
      );
      if (isNetwork) {
        await fetchNetworks();
      } else {
        await fetchPosList();
      }
      await CustomAnimationOverlay.showSuccess(
        message: 'تم رفض طلب "$name" وإشعار صاحبه بالسبب.',
      );
    } catch (e) {
      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'خطأ',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }
}
