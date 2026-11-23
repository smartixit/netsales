import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_package_details_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_status_use_case.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم تفاصيل باقة كروت الإنترنت المستقل (PackageDetailsController)
class PackageDetailsController extends GetxController {
  final GetPackageDetailsUseCase getPackageDetailsUseCase;
  final TogglePackageStatusUseCase togglePackageStatusUseCase;
  final DeletePackageUseCase deletePackageUseCase;

  PackageDetailsController({
    required this.getPackageDetailsUseCase,
    required this.togglePackageStatusUseCase,
    required this.deletePackageUseCase,
  });

  final package = Rxn<PackageEntity>();
  final isLoading = false.obs;
  final isTogglingStatus = false.obs;
  final isDeleting = false.obs;
  final errorMessage = RxnString();

  bool get canEditPackage =>
      PermissionService.instance.can(AppPermissions.voucherPackagesEdit);

  bool get canDeletePackage =>
      PermissionService.instance.can(AppPermissions.voucherPackagesDelete);

  @override
  void onInit() {
    super.onInit();
    _initializeDetails();
  }

  void _initializeDetails() {
    final dynamic args = Get.arguments;
    if (args is PackageEntity) {
      package.value = args;
      fetchDetails(args.packageId, showSkeleton: false);
      return;
    }

    final idParam = Get.parameters['id'];
    if (idParam != null && int.tryParse(idParam) != null) {
      fetchDetails(int.parse(idParam), showSkeleton: true);
    }
  }

  /// جلب تفاصيل الباقة المحدثة من الخادم
  Future<void> fetchDetails(int packageId, {bool showSkeleton = true}) async {
    try {
      if (showSkeleton) isLoading.value = true;
      errorMessage.value = null;

      final result = await getPackageDetailsUseCase(packageId);
      package.value = result;
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'تعذر استرجاع تفاصيل الباقة: $e';
    } finally {
      if (showSkeleton) isLoading.value = false;
    }
  }

  /// تحديث التفاصيل
  Future<void> refreshDetails() async {
    final pkg = package.value;
    if (pkg != null) {
      await fetchDetails(pkg.packageId, showSkeleton: false);
    }
  }

  /// تبديل حالة تفعيل الباقة
  Future<void> toggleStatus() async {
    final current = package.value;
    if (current == null) return;

    try {
      isTogglingStatus.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تحديث حالة الباقة...',
      );

      final updated = await togglePackageStatusUseCase(current.packageId);
      package.value = updated;

      if (Get.isRegistered<PackageCatalogController>()) {
        final catalogCtrl = Get.find<PackageCatalogController>();
        final idx = catalogCtrl.packages.indexWhere(
          (p) => p.packageId == updated.packageId,
        );
        if (idx != -1) {
          catalogCtrl.packages[idx] = updated;
        }
      }

      CustomSnackbar.show(
        title: 'تم التحديث بنجاح',
        message: updated.isActive
            ? 'تم تفعيل باقة "${updated.packageName}" بنجاح'
            : 'تم تعطيل باقة "${updated.packageName}" بنجاح',
        type: SnackType.success,
      );
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'تعذر تعديل الحالة',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: e.toString(),
        type: SnackType.error,
      );
    } finally {
      isTogglingStatus.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// حذف الباقة
  Future<void> deletePackage() async {
    final current = package.value;
    if (current == null) return;

    try {
      isDeleting.value = true;
      await CustomAnimationOverlay.showLoading(message: 'جاري حذف الباقة...');

      final success = await deletePackageUseCase(current.packageId);

      if (success) {
        if (Get.isRegistered<PackageCatalogController>()) {
          Get.find<PackageCatalogController>().packages.removeWhere(
            (p) => p.packageId == current.packageId,
          );
        }

        CustomSnackbar.show(
          title: 'تم الحذف بنجاح',
          message: 'تم حذف باقة "${current.packageName}" بنجاح',
          type: SnackType.success,
        );

        Get.back<void>();
      }
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'تعذر حذف الباقة',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: e.toString(),
        type: SnackType.error,
      );
    } finally {
      isDeleting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// الانتقال لشاشة التعديل
  void navigateToEdit() {
    final current = package.value;
    if (current == null) return;
    Get.toNamed<void>(AppRoutes.packageForm, arguments: current);
  }
}
