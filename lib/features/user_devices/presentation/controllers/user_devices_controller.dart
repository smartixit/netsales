import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/user_device_status.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/user_devices/domain/entities/user_device_entity.dart';
import 'package:netsales/features/user_devices/domain/usecases/disconnect_user_device_use_case.dart';
import 'package:netsales/features/user_devices/domain/usecases/get_user_devices_use_case.dart';
import 'package:netsales/features/user_devices/domain/usecases/logout_other_devices_use_case.dart';
import 'package:netsales/features/user_devices/presentation/widgets/user_device_detail_sheet.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم وحدة الأجهزة المقترنة (UserDevicesController).
class UserDevicesController extends GetxController {
  UserDevicesController({
    required this._getDevicesUseCase,
    required this._disconnectDeviceUseCase,
    required this._logoutOtherDevicesUseCase,
  });

  final GetUserDevicesUseCase _getDevicesUseCase;
  final DisconnectUserDeviceUseCase _disconnectDeviceUseCase;
  final LogoutOtherDevicesUseCase _logoutOtherDevicesUseCase;

  // -------------------------------------------------------------------------
  // State
  // -------------------------------------------------------------------------

  final RxList<UserDeviceEntity> allDevices = <UserDeviceEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxnString errorMessage = RxnString();

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final Rx<UserDeviceStatus?> statusFilter = Rx<UserDeviceStatus?>(null);

  Timer? _debounce;
  bool _suppressSearchListener = false;
  int _revision = 0;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    loadDevices();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    if (_suppressSearchListener) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchQuery.value = searchController.text.trim();
    });
  }

  // -------------------------------------------------------------------------
  // Computed / Filtering
  // -------------------------------------------------------------------------

  String get currentDeviceUuid => DeviceService.instance.deviceUuid;

  bool isCurrentDevice(UserDeviceEntity device) =>
      device.deviceUuid == currentDeviceUuid;

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty || statusFilter.value != null;

  List<UserDeviceEntity> get filteredDevices {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = statusFilter.value;

    return allDevices.where((device) {
      if (filter != null && device.typedStatus != filter) {
        return false;
      }
      if (query.isNotEmpty) {
        final name = device.displayName.toLowerCase();
        final uuid = device.deviceUuid.toLowerCase();
        final typeLabel = EnumPresentationRegistry.resolveDeviceType(
          device.typedDeviceType,
          serverLabel: device.deviceTypeLabel,
        ).label.toLowerCase();

        return name.contains(query) ||
            uuid.contains(query) ||
            typeLabel.contains(query);
      }
      return true;
    }).toList(growable: false);
  }

  List<UserDeviceEntity> get otherDevices => allDevices
      .where((device) => !isCurrentDevice(device))
      .toList(growable: false);

  List<CustomSearchFilterOption<UserDeviceStatus?>> get filterOptions {
    final activePres = EnumPresentationRegistry.resolveUserDeviceStatus(
      UserDeviceStatus.active,
    );
    final inactivePres = EnumPresentationRegistry.resolveUserDeviceStatus(
      UserDeviceStatus.inactive,
    );
    final bannedPres = EnumPresentationRegistry.resolveUserDeviceStatus(
      UserDeviceStatus.banned,
    );

    return [
      const CustomSearchFilterOption<UserDeviceStatus?>(
        value: null,
        label: 'الكل',
        icon: Icons.devices_rounded,
      ),
      CustomSearchFilterOption<UserDeviceStatus?>(
        value: UserDeviceStatus.active,
        label: activePres.label,
        icon: activePres.icon,
      ),
      CustomSearchFilterOption<UserDeviceStatus?>(
        value: UserDeviceStatus.inactive,
        label: inactivePres.label,
        icon: inactivePres.icon,
      ),
      CustomSearchFilterOption<UserDeviceStatus?>(
        value: UserDeviceStatus.banned,
        label: bannedPres.label,
        icon: bannedPres.icon,
      ),
    ];
  }

  List<CustomKpiCardData> buildKpiCards(BuildContext context) {
    final colors = context.colors;
    final activePres = EnumPresentationRegistry.resolveUserDeviceStatus(
      UserDeviceStatus.active,
    );
    final inactivePres = EnumPresentationRegistry.resolveUserDeviceStatus(
      UserDeviceStatus.inactive,
    );
    final bannedPres = EnumPresentationRegistry.resolveUserDeviceStatus(
      UserDeviceStatus.banned,
    );

    final activeCount = allDevices
        .where((d) => d.typedStatus == UserDeviceStatus.active)
        .length;
    final inactiveCount = allDevices
        .where((d) => d.typedStatus == UserDeviceStatus.inactive)
        .length;
    final bannedCount = allDevices
        .where((d) => d.typedStatus == UserDeviceStatus.banned)
        .length;

    return [
      CustomKpiCardData(
        label: 'الكل',
        count: allDevices.length,
        icon: Icons.devices_rounded,
        accentColor: colors.primary,
        statusKey: null,
      ),
      CustomKpiCardData(
        label: activePres.label,
        count: activeCount,
        icon: activePres.icon ?? Icons.check_circle_rounded,
        accentColor: colors.primary,
        statusKey: UserDeviceStatus.active.wireValue,
      ),
      CustomKpiCardData(
        label: inactivePres.label,
        count: inactiveCount,
        icon: inactivePres.icon ?? Icons.pause_circle_outline_rounded,
        accentColor: colors.onSurfaceVariant,
        statusKey: UserDeviceStatus.inactive.wireValue,
      ),
      if (bannedCount > 0)
        CustomKpiCardData(
          label: bannedPres.label,
          count: bannedCount,
          icon: bannedPres.icon ?? Icons.block_rounded,
          accentColor: colors.error,
          statusKey: UserDeviceStatus.banned.wireValue,
        ),
    ];
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  void clearSearch() {
    _debounce?.cancel();
    _suppressSearchListener = true;
    searchController.clear();
    _suppressSearchListener = false;
    searchQuery.value = '';
  }

  void setStatusFilter(UserDeviceStatus? status) => statusFilter.value = status;

  void onKpiSelected(String? statusKey) {
    if (statusKey == null) {
      statusFilter.value = null;
      return;
    }
    final parsed = UserDeviceStatus.fromWire(statusKey);
    statusFilter.value = statusFilter.value == parsed ? null : parsed;
  }

  void clearFilters() {
    _debounce?.cancel();
    _suppressSearchListener = true;
    searchController.clear();
    _suppressSearchListener = false;
    searchQuery.value = '';
    statusFilter.value = null;
  }

  Future<void> loadDevices() async {
    final revision = ++_revision;
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _getDevicesUseCase();
      if (isClosed || revision != _revision) return;
      allDevices.assignAll(result);
    } catch (e) {
      if (isClosed || revision != _revision) return;
      errorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر جلب قائمة الأجهزة المقترنة، يرجى المحاولة لاحقاً.',
      );
    } finally {
      if (!isClosed && revision == _revision) {
        isLoading.value = false;
      }
    }
  }

  Future<void> copyValue(String label, String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    await UrlLauncherService.copyToClipboard(trimmed);
    await HapticFeedback.lightImpact();
    CustomSnackbar.show(
      title: 'تم النسخ',
      message: 'تم نسخ $label إلى الحافظة.',
      type: SnackType.info,
    );
  }

  Future<void> openDeviceDetails(UserDeviceEntity device) async {
    await CustomBottomSheet.show<void>(
      title: 'تفاصيل الجهاز',
      leadingIcon: Icons.devices_other_rounded,
      child: UserDeviceDetailSheet(
        device: device,
        isCurrent: isCurrentDevice(device),
        onCopyValue: copyValue,
        onDisconnect: isCurrentDevice(device)
            ? null
            : () {
                Get.back<void>();
                disconnectDevice(device);
              },
      ),
    );
  }

  Future<void> disconnectDevice(UserDeviceEntity device) async {
    if (isCurrentDevice(device)) return;

    final confirmed = await CustomDialog.show(
      type: DialogType.warning,
      title: 'فصل الجهاز',
      message:
          'هل أنت متأكد من إلغاء اقتران وفصل هذا الجهاز (${device.displayName})؟ سيتطلب منه تسجيل الدخول مجدداً.',
      confirmLabel: 'تأكيد الفصل',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    isActionLoading.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جارٍ فصل الجهاز...');
      await _disconnectDeviceUseCase(device.deviceId);
      allDevices.removeWhere((d) => d.deviceId == device.deviceId);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم إلغاء اقتران الجهاز بنجاح',
      );
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
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
      await CustomAnimationOverlay.showLoading(
        message: 'جارٍ إنهاء الجلسات الأخرى...',
      );
      await _logoutOtherDevicesUseCase();
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تسجيل الخروج من كافة الأجهزة الأخرى بنجاح',
      );
      await loadDevices();
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
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
