import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/user_session_status.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/user_sessions/domain/entities/user_session_entity.dart';
import 'package:netsales/features/user_sessions/domain/usecases/get_user_sessions_use_case.dart';
import 'package:netsales/features/user_sessions/domain/usecases/terminate_user_session_use_case.dart';
import 'package:netsales/features/user_sessions/presentation/widgets/user_session_detail_sheet.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم وحدة جلسات تسجيل الدخول (UserSessionsController).
class UserSessionsController extends GetxController {
  UserSessionsController({
    required this._getSessionsUseCase,
    required this._terminateSessionUseCase,
  });

  final GetUserSessionsUseCase _getSessionsUseCase;
  final TerminateUserSessionUseCase _terminateSessionUseCase;

  // -------------------------------------------------------------------------
  // State
  // -------------------------------------------------------------------------

  final RxList<UserSessionEntity> sessions = <UserSessionEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxnString errorMessage = RxnString();

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final Rx<UserSessionStatus?> statusFilter = Rx<UserSessionStatus?>(null);

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
    loadSessions();
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
      loadSessions();
    });
  }

  // -------------------------------------------------------------------------
  // Computed
  // -------------------------------------------------------------------------

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty || statusFilter.value != null;

  List<CustomSearchFilterOption<UserSessionStatus?>> get filterOptions {
    final activePres = EnumPresentationRegistry.resolveUserSessionStatus(
      UserSessionStatus.active,
    );
    final expiredPres = EnumPresentationRegistry.resolveUserSessionStatus(
      UserSessionStatus.expired,
    );
    final revokedPres = EnumPresentationRegistry.resolveUserSessionStatus(
      UserSessionStatus.revoked,
    );

    return [
      const CustomSearchFilterOption<UserSessionStatus?>(
        value: null,
        label: 'الكل',
        icon: Icons.sensors_rounded,
      ),
      CustomSearchFilterOption<UserSessionStatus?>(
        value: UserSessionStatus.active,
        label: activePres.label,
        icon: activePres.icon,
      ),
      CustomSearchFilterOption<UserSessionStatus?>(
        value: UserSessionStatus.expired,
        label: expiredPres.label,
        icon: expiredPres.icon,
      ),
      CustomSearchFilterOption<UserSessionStatus?>(
        value: UserSessionStatus.revoked,
        label: revokedPres.label,
        icon: revokedPres.icon,
      ),
    ];
  }

  List<CustomKpiCardData> buildKpiCards(BuildContext context) {
    final colors = context.colors;
    final activePres = EnumPresentationRegistry.resolveUserSessionStatus(
      UserSessionStatus.active,
    );
    final expiredPres = EnumPresentationRegistry.resolveUserSessionStatus(
      UserSessionStatus.expired,
    );
    final revokedPres = EnumPresentationRegistry.resolveUserSessionStatus(
      UserSessionStatus.revoked,
    );

    final activeCount = sessions
        .where((s) => s.typedStatus == UserSessionStatus.active)
        .length;
    final expiredCount = sessions
        .where((s) => s.typedStatus == UserSessionStatus.expired)
        .length;
    final revokedCount = sessions
        .where((s) => s.typedStatus == UserSessionStatus.revoked)
        .length;

    return [
      CustomKpiCardData(
        label: 'الكل',
        count: sessions.length,
        icon: Icons.sensors_rounded,
        accentColor: colors.primary,
        statusKey: null,
      ),
      CustomKpiCardData(
        label: activePres.label,
        count: activeCount,
        icon: activePres.icon ?? Icons.sensors_rounded,
        accentColor: colors.primary,
        statusKey: UserSessionStatus.active.wireValue,
      ),
      CustomKpiCardData(
        label: expiredPres.label,
        count: expiredCount,
        icon: expiredPres.icon ?? Icons.schedule_rounded,
        accentColor: colors.onSurfaceVariant,
        statusKey: UserSessionStatus.expired.wireValue,
      ),
      CustomKpiCardData(
        label: revokedPres.label,
        count: revokedCount,
        icon: revokedPres.icon ?? Icons.sensors_off_rounded,
        accentColor: colors.error,
        statusKey: UserSessionStatus.revoked.wireValue,
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
    loadSessions();
  }

  void setStatusFilter(UserSessionStatus? status) {
    statusFilter.value = status;
    loadSessions();
  }

  void onKpiSelected(String? statusKey) {
    if (statusKey == null) {
      statusFilter.value = null;
    } else {
      final parsed = UserSessionStatus.fromWire(statusKey);
      statusFilter.value = statusFilter.value == parsed ? null : parsed;
    }
    loadSessions();
  }

  void clearFilters() {
    _debounce?.cancel();
    _suppressSearchListener = true;
    searchController.clear();
    _suppressSearchListener = false;
    searchQuery.value = '';
    statusFilter.value = null;
    loadSessions();
  }

  Future<void> loadSessions() async {
    final revision = ++_revision;
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _getSessionsUseCase(
        status: statusFilter.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      if (isClosed || revision != _revision) return;
      sessions.assignAll(result);
    } catch (e) {
      if (isClosed || revision != _revision) return;
      errorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر جلب جلسات تسجيل الدخول، يرجى المحاولة لاحقاً.',
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

  Future<void> openSessionDetails(UserSessionEntity session) async {
    await CustomBottomSheet.show<void>(
      title: 'تفاصيل الجلسة',
      leadingIcon: Icons.sensors_rounded,
      child: UserSessionDetailSheet(
        session: session,
        onCopyValue: copyValue,
        onTerminate: (!session.isCurrent && session.isActive)
            ? () {
                Get.back<void>();
                terminateSession(session);
              }
            : null,
      ),
    );
  }

  Future<void> terminateSession(UserSessionEntity session) async {
    if (session.isCurrent || !session.isActive) return;

    final confirmed = await CustomDialog.show(
      type: DialogType.danger,
      title: 'إنهاء الجلسة',
      message:
          'هل أنت متأكد من إنهاء هذه الجلسة (${session.displayClient})؟ سيتم تسجيل الخروج منها فوراً.',
      confirmLabel: 'إنهاء الجلسة',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    isActionLoading.value = true;
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جارٍ إنهاء الجلسة...',
      );
      await _terminateSessionUseCase(session.sessionId);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم إنهاء الجلسة بنجاح',
      );
      await loadSessions();
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر إنهاء الجلسة',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isActionLoading.value = false;
    }
  }
}
