import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/features/auth/domain/entities/user_device_entity.dart';
import 'package:netsales/features/auth/domain/usecases/disconnect_device_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/get_devices_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/logout_other_devices_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شاشة إدارة الأجهزة والجلسات النشطة (ActiveSessionsController)
class ActiveSessionsController extends GetxController {
  final GetDevicesUseCase _getDevicesUseCase;
  final DisconnectDeviceUseCase _disconnectDeviceUseCase;
  final LogoutOtherDevicesUseCase _logoutOtherDevicesUseCase;

  ActiveSessionsController({
    required GetDevicesUseCase getDevicesUseCase,
    required DisconnectDeviceUseCase disconnectDeviceUseCase,
    required LogoutOtherDevicesUseCase logoutOtherDevicesUseCase,
  })  : _getDevicesUseCase = getDevicesUseCase,
        _disconnectDeviceUseCase = disconnectDeviceUseCase,
        _logoutOtherDevicesUseCase = logoutOtherDevicesUseCase;

  static ActiveSessionsController get to => Get.find<ActiveSessionsController>();

  final RxList<UserDeviceEntity> devices = <UserDeviceEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxnString errorMessage = RxnString();

  String get currentDeviceUuid => DeviceService.instance.deviceUuid;

  UserDeviceEntity? get currentDevice {
    final uuid = currentDeviceUuid;
    return devices.firstWhereOrNull((d) => d.deviceUuid == uuid) ??
        devices.firstWhereOrNull((d) => d.isPrimary);
  }

  List<UserDeviceEntity> get otherDevices {
    final current = currentDevice;
    if (current == null) return devices.toList();
    return devices.where((d) => d.deviceId != current.deviceId).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadDevices();
  }

  Future<void> loadDevices() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _getDevicesUseCase();
      devices.assignAll(result);
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر جلب قائمة الأجهزة المقترنة، يرجى المحاولة لاحقاً',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> disconnectDevice(UserDeviceEntity device) async {
    final confirmed = await CustomDialog.show(
      type: DialogType.warning,
      title: 'فصل الجهاز',
      message:
          'هل أنت متأكد من رغبتك في إلغاء اقتران وفصل هذا الجهاز (${device.deviceName ?? "جهاز غير معروف"})؟ سيتطلب منه تسجيل الدخول مجدداً.',
      confirmLabel: 'تأكيد الفصل',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    isActionLoading.value = true;
    try {
      await _disconnectDeviceUseCase(device.deviceId);
      devices.removeWhere((d) => d.deviceId == device.deviceId);
      CustomSnackbar.show(
        title: 'تم الفصل بنجاح',
        message: 'تم إلغاء اقتران الجهاز بنجاح',
        type: SnackType.success,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر فصل الجهاز',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> logoutOtherDevices() async {
    final confirmed = await CustomDialog.show(
      type: DialogType.danger,
      title: 'تسجيل الخروج من كافة الأجهزة الأخرى',
      message:
          'سيتم إنهاء كافة جلسات العمل الفعالة على جميع الأجهزة الأخرى فورياً، وستبقى جلستك الحالية فقط قيد التشغيل. هل تريد المتابعة؟',
      confirmLabel: 'تأكيد إنهاء الجلسات',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    isActionLoading.value = true;
    try {
      await _logoutOtherDevicesUseCase();
      CustomSnackbar.show(
        title: 'تمت العملية بنجاح',
        message: 'تم تسجيل الخروج من كافة الأجهزة الأخرى بنجاح',
        type: SnackType.success,
      );
      await loadDevices();
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر إنهاء الجلسات',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isActionLoading.value = false;
    }
  }
}
