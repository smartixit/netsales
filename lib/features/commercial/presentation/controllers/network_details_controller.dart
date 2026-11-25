import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkDetailsController extends GetxController {
  NetworkDetailsController(this._getDetails, this._deleteEntity);
  final GetNetworkDetailsUseCase _getDetails;
  final DeleteNetworkUseCase _deleteEntity;

  final network = Rxn<NetworkEntity>();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  int? networkId;
  bool get canEdit => PermissionService.to.can(AppPermissions.networksEdit);
  int _revision = 0;

  @override
  void onInit() {
    super.onInit();
    networkId = int.tryParse(Get.parameters['id'] ?? '');
    if (networkId == null || networkId! <= 0) {
      errorMessage.value = 'معرّف الشبكة غير صالح.';
      return;
    }
    load();
  }

  bool get canDelete => PermissionService.to.can(AppPermissions.networksDelete);

  Future<void> deleteEntity() async {
    final id = networkId;
    if (id == null || !canDelete) return;
    try {
      await _deleteEntity(id);
      CustomSnackbar.show(
        type: SnackType.success,
        title: 'تم نقل الشبكة إلى المحذوفات',
        message: 'يمكن استعادتها وفق صلاحيات الاستعادة المعتمدة.',
      );
      Get.back(result: true);
    } catch (error) {
      CustomSnackbar.show(
        type: SnackType.error,
        title: 'تعذر حذف الشبكة',
        message: AppException.sanitizeMessage(error),
      );
    }
  }

  Future<void> load() async {
    final id = networkId;
    if (id == null) return;
    final revision = ++_revision;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _getDetails(id);
      if (isClosed || revision != _revision) return;
      network.value = result;
    } catch (error) {
      if (!isClosed && revision == _revision) {
        errorMessage.value = AppException.sanitizeMessage(error);
      }
    } finally {
      if (!isClosed && revision == _revision) isLoading.value = false;
    }
  }
}
