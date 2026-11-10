import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/auth/domain/usecases/get_directorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/get_governorates_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/confirm_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/preview_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/revoke_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/toggle_network_pos_link_status_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_network_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_pos_details_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم إدارة الروابط التجارية ودليل نقاط البيع والشبكات
/// يدعم ترقيم المؤشر (Cursor Pagination) والبحث الخادمي المؤجل (Debounced Server Search)
class CommercialDirectoryController extends GetxController {
  CommercialDirectoryController({
    required this.getNetworkPosListUseCase,
    required this.getPosNetworksListUseCase,
    required this.createNetworkPosLinkUseCase,
    required this.toggleNetworkPosLinkStatusUseCase,
    required this.deleteNetworkPosLinkUseCase,
    required this.getMyNetworksUseCase,
    required this.getMyPosUseCase,
    this.getNetworkDetailsUseCase,
    this.getPosDetailsUseCase,
    this.updateNetworkDetailsUseCase,
    this.updatePosDetailsUseCase,
    this.createNetworkPosLinkChallengeUseCase,
    this.previewNetworkPosLinkChallengeUseCase,
    this.confirmNetworkPosLinkChallengeUseCase,
    this.revokeNetworkPosLinkChallengeUseCase,
    this.getGovernoratesUseCase,
    this.getDirectoratesUseCase,
  });

  final GetNetworkPosListUseCase getNetworkPosListUseCase;
  final GetPosNetworksListUseCase getPosNetworksListUseCase;
  final CreateNetworkPosLinkUseCase createNetworkPosLinkUseCase;
  final ToggleNetworkPosLinkStatusUseCase toggleNetworkPosLinkStatusUseCase;
  final DeleteNetworkPosLinkUseCase deleteNetworkPosLinkUseCase;
  final GetMyNetworksUseCase getMyNetworksUseCase;
  final GetMyPosUseCase getMyPosUseCase;
  final GetNetworkDetailsUseCase? getNetworkDetailsUseCase;
  final GetPosDetailsUseCase? getPosDetailsUseCase;
  final UpdateNetworkDetailsUseCase? updateNetworkDetailsUseCase;
  final UpdatePosDetailsUseCase? updatePosDetailsUseCase;
  final CreateNetworkPosLinkChallengeUseCase?
  createNetworkPosLinkChallengeUseCase;
  final PreviewNetworkPosLinkChallengeUseCase?
  previewNetworkPosLinkChallengeUseCase;
  final ConfirmNetworkPosLinkChallengeUseCase?
  confirmNetworkPosLinkChallengeUseCase;
  final RevokeNetworkPosLinkChallengeUseCase?
  revokeNetworkPosLinkChallengeUseCase;
  final GetGovernoratesUseCase? getGovernoratesUseCase;
  final GetDirectoratesUseCase? getDirectoratesUseCase;

  // ============================================================
  // البيانات الجغرافية الموحدة (المحافظات والمديريات)
  // ============================================================

  /// قائمة المحافظات المتاحة
  final RxList<GovernorateEntity> governorates = <GovernorateEntity>[].obs;

  /// حالة تحميل قائمة المحافظات
  final RxBool isLoadingGovernorates = false.obs;

  /// جلب المحافظات إذا لم تكن محملة مسبقاً
  Future<void> loadGovernorates() async {
    if (governorates.isNotEmpty) return;
    try {
      isLoadingGovernorates.value = true;
      final useCase = getGovernoratesUseCase ??
          (Get.isRegistered<GetGovernoratesUseCase>()
              ? Get.find<GetGovernoratesUseCase>()
              : null);
      if (useCase != null) {
        final list = await useCase.execute();
        governorates.assignAll(list);
      }
    } catch (_) {
    } finally {
      isLoadingGovernorates.value = false;
    }
  }

  /// جلب مديريات محافظة معينة
  Future<List<DirectorateEntity>> loadDirectorates(int governorateId) async {
    try {
      final useCase = getDirectoratesUseCase ??
          (Get.isRegistered<GetDirectoratesUseCase>()
              ? Get.find<GetDirectoratesUseCase>()
              : null);
      if (useCase != null) {
        return await useCase.execute(governorateId);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // حالات القائمة التفاعلية مع دعم الترقيم بالمؤشر
  // ============================================================

  /// قائمة الروابط المحملة تتراكم عبر صفحات التحميل الإضافية
  final RxList<NetworkPosLinkEntity> links = <NetworkPosLinkEntity>[].obs;

  /// حالة التحميل الأولي (يظهر shimmer skeleton كامل)
  final RxBool isLoading = false.obs;

  /// حالة تحميل المزيد في نهاية القائمة
  final RxBool isLoadingMore = false.obs;

  /// حالة تحميل الإجراءات (ربط / تبديل / حذف)
  final RxBool isActionLoading = false.obs;

  /// حالة تحميل التفاصيل
  final RxBool isDetailsLoading = false.obs;

  /// رسالة الخطأ الحالية
  final RxnString errorMessage = RxnString();

  /// مؤشر الصفحة التالية — null يعني لا توجد صفحات إضافية
  final RxnString nextCursorNetwork = RxnString();
  final RxnString nextCursorPos = RxnString();

  /// الكيانات التفصيلية المحددة
  final Rxn<NetworkEntity> selectedNetworkDetails = Rxn<NetworkEntity>();
  final Rxn<PosEntity> selectedPosDetails = Rxn<PosEntity>();

  // ============================================================
  // البحث الخادمي المؤجل (Server-Side Search with Debounce)
  // ============================================================

  /// نص البحث الحالي (يُرسل إلى الخادم بعد تأخير 300ms)
  final RxString searchQuery = ''.obs;

  /// فلتر الحالة: null=الكل, true=نشط, false=معطل
  final Rxn<bool> selectedStatusFilter = Rxn<bool>();

  /// متحكم نص البحث — مرتبط بحقل الإدخال في الواجهة
  final TextEditingController searchController = TextEditingController();

  /// متحكم نص هوية نقطة البيع لنافذة ربط جديدة
  final TextEditingController posIdentifierController = TextEditingController();

  /// حالة تفعيل الارتباط الافتراضية عند إنشاء رابط جديد
  final RxBool linkStatusInitial = true.obs;

  // حالات تحديات الربط عبر رمز QR
  final Rxn<NetworkPosLinkChallengeEntity> activeChallenge =
      Rxn<NetworkPosLinkChallengeEntity>();
  final Rxn<NetworkPosLinkPreviewEntity> activePreview =
      Rxn<NetworkPosLinkPreviewEntity>();
  final RxBool isChallengeLoading = false.obs;

  // معرفات الكيان الحالي
  final RxInt activeNetworkId = 0.obs;
  final RxInt activePosId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Worker مؤجل 300ms: إعادة البحث الخادمي عند تغيير نص البحث
    debounce<String>(
      searchQuery,
      _onSearchQueryChanged,
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    posIdentifierController.dispose();
    super.onClose();
  }

  // ============================================================
  // إدارة البحث والفلترة
  // ============================================================

  /// استدعاء داخلي من Worker عند تغيير نص البحث بعد التأخير
  void _onSearchQueryChanged(String _) {
    if (activeNetworkId.value > 0) {
      fetchNetworkPosLinks(networkId: activeNetworkId.value);
    } else if (activePosId.value > 0) {
      fetchPosNetworks(posId: activePosId.value);
    }
  }

  /// تحديث نص البحث (يُطلق Worker المؤجل)
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// تفريغ نص البحث وإعادة تحميل القائمة
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  /// تغيير فلتر الحالة وإعادة التحميل فوراً
  void setStatusFilter(bool? status) {
    selectedStatusFilter.value = status;
    if (activeNetworkId.value > 0) {
      fetchNetworkPosLinks(networkId: activeNetworkId.value);
    } else if (activePosId.value > 0) {
      fetchPosNetworks(posId: activePosId.value);
    }
  }

  // ============================================================
  // جلب روابط نقاط البيع لشبكة (مع إعادة ضبط المؤشر)
  // ============================================================

  /// جلب الصفحة الأولى من روابط نقاط البيع لشبكة
  /// — يُعيد ضبط المؤشر والقائمة ويبدأ تحميل جديد
  Future<void> fetchNetworkPosLinks({
    int? networkId,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = null;

      var targetNetworkId = networkId ?? activeNetworkId.value;

      if (targetNetworkId <= 0) {
        final networks = await getMyNetworksUseCase();
        if (networks.isNotEmpty) {
          targetNetworkId = networks.first.networkId;
          activeNetworkId.value = targetNetworkId;
        }
      }

      if (targetNetworkId <= 0) {
        errorMessage.value = 'لم يتم العثور على شبكة نشطة تابعة لحسابك.';
        links.clear();
        nextCursorNetwork.value = null;
        return;
      }

      final page = await getNetworkPosListUseCase(
        targetNetworkId,
        search: searchQuery.value.trim().isNotEmpty
            ? searchQuery.value.trim()
            : null,
        status: selectedStatusFilter.value,
      );

      links.assignAll(page.items);
      nextCursorNetwork.value = page.nextCursor;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      CustomSnackbar.show(
        title: 'خطأ في جلب نقاط البيع',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      final msg = 'تعذر استرجاع نقاط البيع المرتبطة: $e';
      errorMessage.value = msg;
      CustomSnackbar.show(
        title: 'خطأ في النظام',
        message: msg,
        type: SnackType.error,
      );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  /// تحميل الصفحة التالية من روابط نقاط البيع (تُضاف إلى النهاية)
  Future<void> loadMoreNetworkPosLinks() async {
    final cursor = nextCursorNetwork.value;
    if (cursor == null || isLoadingMore.value || isLoading.value) return;

    try {
      isLoadingMore.value = true;

      final page = await getNetworkPosListUseCase(
        activeNetworkId.value,
        cursor: cursor,
        search: searchQuery.value.trim().isNotEmpty
            ? searchQuery.value.trim()
            : null,
        status: selectedStatusFilter.value,
      );

      links.addAll(page.items);
      nextCursorNetwork.value = page.nextCursor;
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'تعذر تحميل المزيد',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ',
        message: 'تعذر تحميل المزيد من نقاط البيع: $e',
        type: SnackType.error,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ============================================================
  // جلب الشبكات المرتبطة بنقطة بيع (مع إعادة ضبط المؤشر)
  // ============================================================

  /// جلب الصفحة الأولى من الشبكات المرتبطة بنقطة بيع
  Future<void> fetchPosNetworks({int? posId, bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = null;

      var targetPosId = posId ?? activePosId.value;

      if (targetPosId <= 0) {
        final posList = await getMyPosUseCase();
        if (posList.isNotEmpty) {
          targetPosId = posList.first.posId;
          activePosId.value = targetPosId;
        }
      }

      if (targetPosId <= 0) {
        errorMessage.value = 'لم يتم العثور على نقطة بيع نشطة تابعة لحسابك.';
        links.clear();
        nextCursorPos.value = null;
        return;
      }

      final page = await getPosNetworksListUseCase(
        targetPosId,
        search: searchQuery.value.trim().isNotEmpty
            ? searchQuery.value.trim()
            : null,
        status: selectedStatusFilter.value,
      );

      links.assignAll(page.items);
      nextCursorPos.value = page.nextCursor;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      CustomSnackbar.show(
        title: 'خطأ في جلب الشبكات',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      final msg = 'تعذر استرجاع الشبكات المرتبطة: $e';
      errorMessage.value = msg;
      CustomSnackbar.show(
        title: 'خطأ في النظام',
        message: msg,
        type: SnackType.error,
      );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  /// تحميل الصفحة التالية من الشبكات المرتبطة (تُضاف إلى النهاية)
  Future<void> loadMorePosNetworks() async {
    final cursor = nextCursorPos.value;
    if (cursor == null || isLoadingMore.value || isLoading.value) return;

    try {
      isLoadingMore.value = true;

      final page = await getPosNetworksListUseCase(
        activePosId.value,
        cursor: cursor,
        search: searchQuery.value.trim().isNotEmpty
            ? searchQuery.value.trim()
            : null,
        status: selectedStatusFilter.value,
      );

      links.addAll(page.items);
      nextCursorPos.value = page.nextCursor;
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'تعذر تحميل المزيد',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ',
        message: 'تعذر تحميل المزيد من الشبكات: $e',
        type: SnackType.error,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ============================================================
  // هل توجد المزيد من العناصر لكل نوع من القوائم
  // ============================================================

  /// هل تتوفر صفحات إضافية لروابط نقاط البيع
  bool get hasMoreNetworkPosLinks => nextCursorNetwork.value != null;

  /// هل تتوفر صفحات إضافية للشبكات المرتبطة بنقطة بيع
  bool get hasMorePosNetworks => nextCursorPos.value != null;

  // ============================================================
  // عمليات إدارة الروابط
  // ============================================================

  /// جلب تفاصيل شبكة محددة
  Future<NetworkEntity?> fetchNetworkDetails(int networkId) async {
    if (getNetworkDetailsUseCase == null) return null;
    try {
      isDetailsLoading.value = true;
      final details = await getNetworkDetailsUseCase!(networkId);
      selectedNetworkDetails.value = details;
      return details;
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'خطأ في جلب بيانات الشبكة',
        message: e.message,
        type: SnackType.error,
      );
      return null;
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر جلب تفاصيل الشبكة: $e',
        type: SnackType.error,
      );
      return null;
    } finally {
      isDetailsLoading.value = false;
    }
  }

  /// تحديث بيانات شبكة قائمة
  Future<bool> updateNetworkDetails(
    int networkId,
    Map<String, dynamic> data,
  ) async {
    if (updateNetworkDetailsUseCase == null) return false;
    try {
      isActionLoading.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تحديث بيانات الشبكة...',
      );

      final updated = await updateNetworkDetailsUseCase!(networkId, data);
      selectedNetworkDetails.value = updated;

      for (var i = 0; i < links.length; i++) {
        if (links[i].networkId == networkId) {
          links[i] = links[i].copyWith(network: updated);
        }
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تحديث بيانات الشبكة بنجاح',
      );
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'فشل تحديث الشبكة',
        message: e.message,
        type: SnackType.error,
      );
      return false;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ في التحديث',
        message: 'تعذر تعديل بيانات الشبكة: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      isActionLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// جلب تفاصيل نقطة بيع محددة
  Future<PosEntity?> fetchPosDetails(int posId) async {
    if (getPosDetailsUseCase == null) return null;
    try {
      isDetailsLoading.value = true;
      final details = await getPosDetailsUseCase!(posId);
      selectedPosDetails.value = details;
      return details;
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'خطأ في جلب بيانات نقطة البيع',
        message: e.message,
        type: SnackType.error,
      );
      return null;
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر جلب تفاصيل نقطة البيع: $e',
        type: SnackType.error,
      );
      return null;
    } finally {
      isDetailsLoading.value = false;
    }
  }

  /// تحديث بيانات نقطة بيع قائمة
  Future<bool> updatePosDetails(int posId, Map<String, dynamic> data) async {
    if (updatePosDetailsUseCase == null) return false;
    try {
      isActionLoading.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تحديث بيانات نقطة البيع...',
      );

      final updated = await updatePosDetailsUseCase!(posId, data);
      selectedPosDetails.value = updated;

      for (var i = 0; i < links.length; i++) {
        if (links[i].posId == posId) {
          links[i] = links[i].copyWith(pos: updated);
        }
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تحديث بيانات نقطة البيع بنجاح',
      );
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'فشل تحديث نقطة البيع',
        message: e.message,
        type: SnackType.error,
      );
      return false;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ في التحديث',
        message: 'تعذر تعديل بيانات نقطة البيع: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      isActionLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// ربط نقطة بيع جديدة بالشبكة
  Future<bool> linkPos({
    required int networkId,
    int? posId,
    String? posUuid,
    bool status = true,
  }) async {
    try {
      isActionLoading.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري ربط نقطة البيع...',
      );

      final newLink = await createNetworkPosLinkUseCase(
        networkId: networkId,
        posId: posId,
        posUuid: posUuid,
        status: status,
      );

      links.insert(0, newLink);

      await CustomAnimationOverlay.showSuccess(
        message: 'تم ربط نقطة البيع بالشبكة بنجاح',
      );
      posIdentifierController.clear();
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'فشل ربط نقطة البيع',
        message: e.message,
        type: SnackType.error,
      );
      return false;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'فشل ربط نقطة البيع: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      isActionLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// تبديل حالة تفعيل الارتباط
  Future<void> toggleLinkStatus(int linkId) async {
    try {
      isActionLoading.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تعديل حالة الارتباط...',
      );

      final updated = await toggleNetworkPosLinkStatusUseCase(linkId);

      final index = links.indexWhere((l) => l.networkPosId == linkId);
      if (index != -1) {
        links[index] = updated;
      }

      await CustomAnimationOverlay.showSuccess(
        message: updated.status
            ? 'تم تفعيل الارتباط بنجاح'
            : 'تم إلغاء تفعيل الارتباط بنجاح',
      );
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر تعديل الحالة',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ في العملية',
        message: 'فشل تغيير حالة الارتباط: $e',
        type: SnackType.error,
      );
    } finally {
      isActionLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// فك الارتباط بين الشبكة ونقطة البيع
  Future<void> unlinkPos(int linkId) async {
    try {
      isActionLoading.value = true;
      await CustomAnimationOverlay.showLoading(message: 'جاري فك الارتباط...');

      await deleteNetworkPosLinkUseCase(linkId);

      links.removeWhere((l) => l.networkPosId == linkId);

      await CustomAnimationOverlay.showSuccess(
        message: 'تم فك ارتباط نقطة البيع بنجاح',
      );
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر فك الارتباط',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ في العملية',
        message: 'فشل فك الارتباط: $e',
        type: SnackType.error,
      );
    } finally {
      isActionLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  // ==========================================================================
  // عمليات دعوات وتحديات الربط عبر رمز QR (QR-Based POS–Network Linking)
  // ==========================================================================

  /// إنشاء تحدي ربط مشفر جديد لشبكة معينة
  Future<NetworkPosLinkChallengeEntity?> createQrChallenge({
    required int networkId,
    int? posId,
    int? durationMinutes,
  }) async {
    if (createNetworkPosLinkChallengeUseCase == null) return null;

    try {
      isChallengeLoading.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري إنشاء رمز الربط المشفر...',
      );

      final challenge = await createNetworkPosLinkChallengeUseCase!(
        networkId: networkId,
        posId: posId,
        durationMinutes: durationMinutes,
      );

      activeChallenge.value = challenge;
      await CustomAnimationOverlay.hide();
      return challenge;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر إنشاء رمز الربط',
        message: e.message,
        type: SnackType.error,
      );
      return null;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ',
        message: 'فشل إنشاء رمز الربط: $e',
        type: SnackType.error,
      );
      return null;
    } finally {
      isChallengeLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// إلغاء وإبطال دعوة الربط المشفرة النشطة
  Future<void> revokeActiveChallenge() async {
    final challenge = activeChallenge.value;
    if (challenge == null || revokeNetworkPosLinkChallengeUseCase == null) {
      return;
    }

    try {
      await CustomAnimationOverlay.showLoading(message: 'جاري إلغاء الدعوة...');
      await revokeNetworkPosLinkChallengeUseCase!(challenge.challengeUuid);
      activeChallenge.value = null;

      await CustomAnimationOverlay.showSuccess(
        message: 'تم إلغاء دعوة الربط بنجاح',
      );
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر إلغاء الدعوة',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ',
        message: 'فشل إلغاء الدعوة: $e',
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// معاينة وفحص التحدي المشفر من جانب نقطة البيع
  Future<NetworkPosLinkPreviewEntity?> previewQrChallenge(
    String payload, {
    int? posId,
    String? posUuid,
  }) async {
    if (previewNetworkPosLinkChallengeUseCase == null) return null;

    try {
      isChallengeLoading.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري فحص وتأكيد رمز الدعوة...',
      );

      final preview = await previewNetworkPosLinkChallengeUseCase!(
        payload: payload,
        posId: posId,
        posUuid: posUuid,
      );

      activePreview.value = preview;
      await CustomAnimationOverlay.hide();
      return preview;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'رمز غير صالح أو منتهي الصلاحية',
        message: e.message,
        type: SnackType.error,
      );
      return null;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ في فحص الرمز',
        message: 'تعذر التحقق من التحدي: $e',
        type: SnackType.error,
      );
      return null;
    } finally {
      isChallengeLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// تأكيد واعتماد ربط نقطة البيع بالشبكة عبر التحدي المشفر
  Future<bool> confirmQrChallenge({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  }) async {
    if (confirmNetworkPosLinkChallengeUseCase == null) return false;

    try {
      isChallengeLoading.value = true;
      await CustomAnimationOverlay.showLoading(message: 'جاري اعتماد الربط...');

      final link = await confirmNetworkPosLinkChallengeUseCase!(
        challengeUuid: challengeUuid,
        posId: posId,
        posUuid: posUuid,
      );

      if (activeNetworkId.value == link.networkId ||
          activePosId.value == link.posId) {
        if (!links.any((l) => l.networkPosId == link.networkPosId)) {
          links.insert(0, link);
        }
      }

      activePreview.value = null;
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تأكيد وربط نقطة البيع بالشبكة بنجاح',
      );
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'فشل اعتماد الربط',
        message: e.message,
        type: SnackType.error,
      );
      return false;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ',
        message: 'تعذر اعتماد الربط: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      isChallengeLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }
}
