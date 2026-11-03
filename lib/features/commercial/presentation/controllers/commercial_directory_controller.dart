import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/toggle_network_pos_link_status_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_network_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_pos_details_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم إدارة الروابط التجارية ودليل نقاط البيع والشبكات
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

  // الحالات التفاعلية للقوائم
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<NetworkPosLinkEntity> links = <NetworkPosLinkEntity>[].obs;

  // الكيانات التفصيلية المحددة للعرض والتحديث
  final Rxn<NetworkEntity> selectedNetworkDetails = Rxn<NetworkEntity>();
  final Rxn<PosEntity> selectedPosDetails = Rxn<PosEntity>();

  // متحكمات النصوص ومفاتيح النماذج
  final TextEditingController searchController = TextEditingController();
  final TextEditingController posIdentifierController = TextEditingController();
  final RxBool linkStatusInitial = true.obs;

  // حقول الفلترة والبحث
  final RxString searchQuery = ''.obs;
  final Rxn<bool> selectedStatusFilter =
      Rxn<bool>(); // null: الكل, true: نشط, false: معطل

  // معرفات الكيان الحالي (الشبكة أو نقطة البيع)
  final RxInt activeNetworkId = 0.obs;
  final RxInt activePosId = 0.obs;

  @override
  void onClose() {
    searchController.dispose();
    posIdentifierController.dispose();
    super.onClose();
  }

  /// القائمة المفلترة حسب البحث وحالة التفعيل
  List<NetworkPosLinkEntity> get filteredLinks {
    return links.where((link) {
      // 1. فلترة الحالة
      if (selectedStatusFilter.value != null) {
        if (link.status != selectedStatusFilter.value) {
          return false;
        }
      }

      // 2. فلترة البحث النصي
      final query = searchQuery.value.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }

      final posName = link.pos?.posName.toLowerCase() ?? '';
      final posUuid = link.pos?.posUuid.toLowerCase() ?? '';
      final posPhone = link.pos?.posPhoneNumber.toLowerCase() ?? '';
      final networkName = link.network?.networkName.toLowerCase() ?? '';

      return posName.contains(query) ||
          posUuid.contains(query) ||
          posPhone.contains(query) ||
          networkName.contains(query);
    }).toList();
  }

  /// جلب روابط نقاط البيع لشبكة المزود
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

      // إذا لم يكن معرف الشبكة محدداً، يتم استرجاعه عبر Use Case
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
        return;
      }

      final result = await getNetworkPosListUseCase(targetNetworkId);
      links.assignAll(result);
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

      // تحديث بيانات الشبكة في القوائم المعروضة إن وجدت
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

      // تحديث بيانات نقطة البيع في القوائم المعروضة إن وجدت
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

  /// جلب الشبكات المزودة لنقطة البيع
  Future<void> fetchPosNetworks({int? posId, bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = null;

      var targetPosId = posId ?? activePosId.value;

      // إذا لم يكن معرف نقطة البيع محدداً، يتم استرجاعه عبر Use Case
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
        return;
      }

      final result = await getPosNetworksListUseCase(targetPosId);
      links.assignAll(result);
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

  /// ربط نقطة بيع جديدة بالشبكة مع نافذة التحميل والتنبيهات
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

  /// تبديل حالة تفعيل الارتباط بين الشبكة ونقطة البيع
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

  /// تحديث نص البحث
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// تفريغ نص البحث
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  /// تغيير فلتر الحالة
  void setStatusFilter(bool? status) {
    selectedStatusFilter.value = status;
  }
}
