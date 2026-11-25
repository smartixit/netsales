import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_pos_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class PosDetailsController extends GetxController {
  PosDetailsController(this._getDetails, this._deleteEntity);
  final GetPosDetailsUseCase _getDetails;
  final DeletePosUseCase _deleteEntity;

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

  bool get canDelete => PermissionService.to.can(AppPermissions.posDelete);
  bool get canViewRelationships => PermissionService.to.can(AppPermissions.networksView);
  bool get canManageMembers => PermissionService.to.can(AppPermissions.posMembersView);

  Future<void> deleteEntity() async {
    final id = posId;
    if (id == null || !canDelete) return;
    try {
      await _deleteEntity(id);
      CustomSnackbar.show(
        type: SnackType.success,
        title: 'تم نقل نقطة البيع إلى المحذوفات',
        message: 'يمكن استعادتها وفق صلاحيات الاستعادة المعتمدة.',
      );
      Get.back(result: true);
    } catch (error) {
      CustomSnackbar.show(
        type: SnackType.error,
        title: 'تعذر حذف نقطة البيع',
        message: AppException.sanitizeMessage(error),
      );
    }
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
