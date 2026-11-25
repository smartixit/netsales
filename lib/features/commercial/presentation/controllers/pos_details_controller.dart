import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_details_use_case.dart';

class PosDetailsController extends GetxController {
  PosDetailsController(this._getDetails);
  final GetPosDetailsUseCase _getDetails;

  final pos = Rxn<PosEntity>();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  int? posId;
  bool get canEdit => PermissionService.to.can(AppPermissions.posEdit);
  int _revision = 0;

  @override
  void onInit() {
    super.onInit();
    posId = int.tryParse(Get.parameters['id'] ?? '');
    if (posId == null || posId! <= 0) {
      errorMessage.value = 'معرّف نقطة البيع غير صالح.';
      return;
    }
    load();
  }

  Future<void> load() async {
    final id = posId;
    if (id == null) return;
    final revision = ++_revision;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _getDetails(id);
      if (isClosed || revision != _revision) return;
      pos.value = result;
    } catch (error) {
      if (!isClosed && revision == _revision) {
        errorMessage.value = AppException.sanitizeMessage(error);
      }
    } finally {
      if (!isClosed && revision == _revision) isLoading.value = false;
    }
  }
}
