import 'package:get/get.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/toggle_network_pos_link_status_use_case.dart';
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
  });

  final GetNetworkPosListUseCase getNetworkPosListUseCase;
  final GetPosNetworksListUseCase getPosNetworksListUseCase;
  final CreateNetworkPosLinkUseCase createNetworkPosLinkUseCase;
  final ToggleNetworkPosLinkStatusUseCase toggleNetworkPosLinkStatusUseCase;
  final DeleteNetworkPosLinkUseCase deleteNetworkPosLinkUseCase;

  // الحالات التفاعلية
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<NetworkPosLinkEntity> links = <NetworkPosLinkEntity>[].obs;

  // حقول الفلترة والبحث
  final RxString searchQuery = ''.obs;
  final Rxn<bool> selectedStatusFilter = Rxn<bool>(); // null: الكل, true: نشط, false: معطل

  // معرفات الكيان الحالي (الشبكة أو نقطة البيع)
  final RxInt activeNetworkId = 0.obs;
  final RxInt activePosId = 0.obs;

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
  Future<void> fetchNetworkPosLinks({int? networkId, bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = null;

      var targetNetworkId = networkId ?? activeNetworkId.value;

      // إذا لم يكن معرف الشبكة محدداً، يتم استرجاعه من قائمة شبكات المستخدم
      if (targetNetworkId <= 0) {
        final networksResponse = await ApiService.instance.get<dynamic>(
          ApiConstants.networks,
        );
        if (networksResponse.success && networksResponse.data is List) {
          final list = networksResponse.data as List;
          if (list.isNotEmpty && list.first is Map) {
            targetNetworkId = (list.first['network_id'] as num?)?.toInt() ?? 0;
            activeNetworkId.value = targetNetworkId;
          }
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

  /// جلب الشبكات المزودة لنقطة البيع
  Future<void> fetchPosNetworks({int? posId, bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = null;

      var targetPosId = posId ?? activePosId.value;

      // إذا لم يكن معرف نقطة البيع محدداً، يتم استرجاعه من قائمة نقاط بيع المستخدم
      if (targetPosId <= 0) {
        final posResponse = await ApiService.instance.get<dynamic>(
          ApiConstants.pos,
        );
        if (posResponse.success && posResponse.data is List) {
          final list = posResponse.data as List;
          if (list.isNotEmpty && list.first is Map) {
            targetPosId = (list.first['pos_id'] as num?)?.toInt() ?? 0;
            activePosId.value = targetPosId;
          }
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
      await CustomAnimationOverlay.showLoading(message: 'جاري ربط نقطة البيع...');

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
      await CustomAnimationOverlay.showLoading(message: 'جاري تعديل حالة الارتباط...');

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

  /// تغيير فلتر الحالة
  void setStatusFilter(bool? status) {
    selectedStatusFilter.value = status;
  }
}
