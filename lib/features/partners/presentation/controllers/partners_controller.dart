import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/themes/app_motion.dart';
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
/// يدير حالة شاشة الشركاء، التبويبات الثلاثية، التصفية المزدوجة، وعمليات الاعتماد/الرفض
/// مصاغ وفق النمط المعماري القياسي الموحد المعتمد في OperationsController.
class PartnersController extends GetxController {
  final GetNetworksUseCase getNetworksUseCase;
  final GetPosListUseCase getPosListUseCase;
  final GetNetworkPosListUseCase getNetworkPosListUseCase;
  final ToggleNetworkPosStatusUseCase toggleNetworkPosStatusUseCase;
  final ApprovePartnerUseCase approvePartnerUseCase;
  final RejectPartnerUseCase rejectPartnerUseCase;

  PartnersController({
    required this.getNetworksUseCase,
    required this.getPosListUseCase,
    required this.getNetworkPosListUseCase,
    required this.toggleNetworkPosStatusUseCase,
    required this.approvePartnerUseCase,
    required this.rejectPartnerUseCase,
  });

  /// القطاع النشط: 0 للشبكات، 1 لنقاط البيع، 2 للارتباطات
  final RxInt activeSegmentIndex = 0.obs;

  /// حالات مزودي الشبكات
  final RxList<NetworkEntity> networks = <NetworkEntity>[].obs;
  final RxBool isLoadingNetworks = false.obs;
  final RxString networksErrorMessage = ''.obs;

  /// حالات نقاط البيع
  final RxList<PosEntity> posList = <PosEntity>[].obs;
  final RxBool isLoadingPosList = false.obs;
  final RxString posListErrorMessage = ''.obs;

  /// حالات ارتباطات الشبكات بنقاط البيع
  final RxList<NetworkPosEntity> networkPosList = <NetworkPosEntity>[].obs;
  final RxBool isLoadingNetworkPosList = false.obs;
  final RxString networkPosListErrorMessage = ''.obs;

  /// حالة التحميل العامة للشاشة ومؤشر الإجراءات
  final RxBool isLoading = false.obs;
  final RxBool isSubmittingAction = false.obs;

  /// فلتر الحالة المعتمد
  final RxString selectedStatusFilter = 'ALL'.obs;

  /// حقل البحث الموحد ومؤقت التهدئة للبحث الحي التلقائي
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _searchDebounceTimer;

  /// حقل إدخال سبب الرفض المدار في دورة حياة المتحكم
  final TextEditingController rejectReasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    rejectReasonController.dispose();
    super.onClose();
  }

  /// التبديل بين التبويبات الثلاثية
  void changeSegment(int index) {
    if (activeSegmentIndex.value != index) {
      activeSegmentIndex.value = index;
      selectedStatusFilter.value = 'ALL';
    }
  }

  /// جلب كافة البيانات في آن واحد عند فتح الشاشة أو التحديث الشامل
  Future<void> loadAllData({bool isRefresh = false}) async {
    if (!isRefresh) isLoading.value = true;
    try {
      await Future.wait([
        loadNetworks(isRefresh: isRefresh),
        loadPosList(isRefresh: isRefresh),
        loadNetworkPosList(isRefresh: isRefresh),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب شبكات التوزيع
  Future<void> loadNetworks({bool isRefresh = false}) async {
    isLoadingNetworks.value = true;
    networksErrorMessage.value = '';

    try {
      final result = await getNetworksUseCase();
      networks.assignAll(result);
    } catch (e) {
      networksErrorMessage.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: networksErrorMessage.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  /// جلب نقاط البيع
  Future<void> loadPosList({bool isRefresh = false}) async {
    isLoadingPosList.value = true;
    posListErrorMessage.value = '';

    try {
      final result = await getPosListUseCase();
      posList.assignAll(result);
    } catch (e) {
      posListErrorMessage.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: posListErrorMessage.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoadingPosList.value = false;
    }
  }

  /// جلب عقود وارتباطات الشبكات بنقاط البيع
  Future<void> loadNetworkPosList({bool isRefresh = false}) async {
    isLoadingNetworkPosList.value = true;
    networkPosListErrorMessage.value = '';

    try {
      final result = await getNetworkPosListUseCase();
      networkPosList.assignAll(result);
    } catch (e) {
      networkPosListErrorMessage.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: networkPosListErrorMessage.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoadingNetworkPosList.value = false;
    }
  }

  /// تطبيق فلتر الحالة
  void filterByStatus(String status) {
    if (selectedStatusFilter.value != status) {
      selectedStatusFilter.value = status;
    }
  }

  /// تنفيذ البحث الحي بتهدئة تلقائية تمنع الحمل الزائد وتحدث العرض بسلاسة
  void onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(AppMotion.searchDebounce, () {
      searchQuery.value = query;
    });
  }

  /// تنفيذ البحث عند التقديم المباشر
  void onSearchSubmitted(String query) {
    _searchDebounceTimer?.cancel();
    searchQuery.value = query;
  }

  /// مسح نص البحث
  void clearSearch() {
    _searchDebounceTimer?.cancel();
    searchController.clear();
    searchQuery.value = '';
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

      final matchesStatus =
          status == 'ALL' || network.status.toUpperCase() == status;

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

      final matchesStatus =
          status == 'ALL' || pos.status.toUpperCase() == status;

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
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جارٍ تحديث حالة الارتباط...',
      );
      await toggleNetworkPosStatusUseCase(networkPosId);
      await loadNetworkPosList(isRefresh: true);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تحديث حالة ارتباط نقطة البيع بالشبكة بنجاح.',
      );
    } catch (e) {
      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تعذر تحديث الارتباط',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// طلب تأكيد ثم اعتماد مزود شبكة
  Future<void> confirmApproveNetwork(NetworkEntity network) async {
    final confirmed = await CustomDialog.showConfirmation(
      title: 'اعتماد مزود الشبكة',
      message:
          'هل أنت متأكد من اعتماد طلب مزود الشبكة "${network.networkName}" وتفعيل حسابه رسمياً؟',
      confirmLabel: 'تأكيد الاعتماد',
      cancelLabel: 'إلغاء',
    );

    if (confirmed == true) {
      isSubmittingAction.value = true;
      try {
        await CustomAnimationOverlay.showLoading(
          message: 'جارٍ اعتماد الشبكة وتفعيل الحساب...',
        );
        await approvePartnerUseCase(
          id: network.networkId,
          type: PartnerType.network,
        );
        await loadNetworks(isRefresh: true);
        await CustomAnimationOverlay.showSuccess(
          message:
              'تم اعتماد الشبكة "${network.networkName}" وتفعيل حسابها بنجاح.',
        );
      } catch (e) {
        await CustomAnimationOverlay.hide();
        CustomSnackbar.show(
          title: 'تعذر اعتماد الشبكة',
          message: AppException.sanitizeMessage(e),
          type: SnackType.error,
        );
      } finally {
        isSubmittingAction.value = false;
        if (CustomAnimationOverlay.isShowing) {
          await CustomAnimationOverlay.hide();
        }
      }
    }
  }

  /// طلب تأكيد ثم اعتماد نقطة بيع
  Future<void> confirmApprovePos(PosEntity pos) async {
    final confirmed = await CustomDialog.showConfirmation(
      title: 'اعتماد نقطة البيع',
      message:
          'هل أنت متأكد من اعتماد طلب نقطة البيع "${pos.posName}" وتفعيل حسابها رسمياً؟',
      confirmLabel: 'تأكيد الاعتماد',
      cancelLabel: 'إلغاء',
    );

    if (confirmed == true) {
      isSubmittingAction.value = true;
      try {
        await CustomAnimationOverlay.showLoading(
          message: 'جارٍ اعتماد نقطة البيع...',
        );
        await approvePartnerUseCase(
          id: pos.posId,
          type: PartnerType.pos,
        );
        await loadPosList(isRefresh: true);
        await CustomAnimationOverlay.showSuccess(
          message: 'تمت الموافقة على نقطة البيع "${pos.posName}" بنجاح.',
        );
      } catch (e) {
        await CustomAnimationOverlay.hide();
        CustomSnackbar.show(
          title: 'تعذر اعتماد نقطة البيع',
          message: AppException.sanitizeMessage(e),
          type: SnackType.error,
        );
      } finally {
        isSubmittingAction.value = false;
        if (CustomAnimationOverlay.isShowing) {
          await CustomAnimationOverlay.hide();
        }
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
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جارٍ تسجيل قرار الرفض...',
      );
      await rejectPartnerUseCase(
        id: id,
        type: isNetwork ? PartnerType.network : PartnerType.pos,
        reason: reason,
      );
      if (isNetwork) {
        await loadNetworks(isRefresh: true);
      } else {
        await loadPosList(isRefresh: true);
      }
      await CustomAnimationOverlay.showSuccess(
        message: 'تم رفض طلب "$name" وإشعار صاحبه بالسبب.',
      );
    } catch (e) {
      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تعذر رفض الطلب',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }
}
