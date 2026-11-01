import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/features/wallets/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/wallets/domain/entities/network_wallet_log_entity.dart';
import 'package:netsales/features/wallets/domain/usecases/get_network_wallet_logs_use_case.dart';
import 'package:netsales/features/wallets/domain/usecases/get_network_wallet_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم كشف حركات محفظة الشبكة والحسابات (NetworkWalletController) — NET-04
/// ============================================================================
/// يدير حالة شاشة كشف حساب محفظة مزود الشبكة، الرصيد المعتمد حصراً من الخادم،
/// وسجل القيود المحاسبية مع الفلترة والترقيم وحجب الخصوصية.
/// يلتزم بالامتناع الكامل عن أي عمليات حسابية محلية أو طفرات مالية.
class NetworkWalletController extends GetxController {
  final GetNetworkWalletUseCase getNetworkWalletUseCase;
  final GetNetworkWalletLogsUseCase getNetworkWalletLogsUseCase;

  NetworkWalletController({
    required this.getNetworkWalletUseCase,
    required this.getNetworkWalletLogsUseCase,
  });

  /// الكيان المالي لمحفظة الشبكة
  final Rxn<NetworkWalletEntity> wallet = Rxn<NetworkWalletEntity>();

  /// سجل الحركات المالية (دفتر الأستاذ)
  final RxList<NetworkWalletLogEntity> logs = <NetworkWalletLogEntity>[].obs;

  /// مؤشرات التحميل والخطأ
  final RxBool isLoadingWallet = true.obs;
  final RxBool isLoadingLogs = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  /// وضع إخفاء الرصيد لخصوصية التاجر
  final RxBool isBalanceHidden = false.obs;

  /// تصفية العمليات المالية
  final RxString selectedOperation = 'ALL'.obs;

  /// مؤشرات الترقيم والصفحات
  int _currentPage = 1;
  final RxBool hasMoreLogs = true.obs;
  static const int _perPage = 20;

  /// حقل البحث ومؤقت التهدئة
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  /// تمرير التمرير اللانهائي
  final ScrollController scrollController = ScrollController();

  /// استخلاص معرف الشبكة النشط من المدخلات أو سياق لوحة القيادة
  int get networkId {
    if (Get.arguments is int) {
      return Get.arguments as int;
    }
    if (Get.parameters['network_id'] != null) {
      final parsed = int.tryParse(Get.parameters['network_id']!);
      if (parsed != null && parsed > 0) return parsed;
    }
    if (Get.isRegistered<DashboardController>()) {
      final dashContext = Get.find<DashboardController>().overview.value?.context;
      if (dashContext?.networkId != null && dashContext!.networkId! > 0) {
        return dashContext.networkId!;
      }
      final networks = Get.find<DashboardController>().overview.value?.networks;
      if (networks != null && networks.isNotEmpty) {
        return networks.first.networkId;
      }
    }
    return 1;
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadData();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingLogs.value &&
        !isLoadingMore.value &&
        hasMoreLogs.value) {
      loadMoreLogs();
    }
  }

  /// تبديل إخفاء الرصيد المالي
  void togglePrivacy() {
    isBalanceHidden.toggle();
  }

  /// تحميل بيانات المحفظة وسجل الحركات الأول
  Future<void> loadData() async {
    errorMessage.value = '';
    await Future.wait([
      loadWallet(),
      loadLogs(refresh: true),
    ]);
  }

  /// جلب محفظة الشبكة من الخادم
  Future<void> loadWallet() async {
    isLoadingWallet.value = true;
    try {
      final response = await getNetworkWalletUseCase(networkId);
      if (response.success && response.data != null) {
        wallet.value = response.data;
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'تعذر تحميل بيانات محفظة الشبكة من الخادم.';
      }
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(e);
    } finally {
      isLoadingWallet.value = false;
    }
  }

  /// جلب سجل الحركات المالية مع التصفية والبحث
  Future<void> loadLogs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMoreLogs.value = true;
      isLoadingLogs.value = true;
    }

    final targetWalletId = wallet.value?.walletId;

    try {
      final response = await getNetworkWalletLogsUseCase(
        walletId: targetWalletId ?? networkId,
        page: _currentPage,
        perPage: _perPage,
        logOperation: selectedOperation.value == 'ALL' ? null : selectedOperation.value,
        search: searchController.text.trim().isEmpty ? null : searchController.text.trim(),
      );

      if (response.success && response.data != null) {
        final newItems = response.data!;
        if (refresh) {
          logs.assignAll(newItems);
        } else {
          logs.addAll(newItems);
        }
        hasMoreLogs.value = newItems.length >= _perPage;
      } else {
        if (refresh) logs.clear();
      }
    } catch (e) {
      if (refresh) {
        errorMessage.value = AppException.sanitizeMessage(e);
      }
    } finally {
      isLoadingLogs.value = false;
    }
  }

  /// تحميل المزيد من الحركات (Infinite Scrolling)
  Future<void> loadMoreLogs() async {
    if (isLoadingMore.value || !hasMoreLogs.value) return;
    isLoadingMore.value = true;
    _currentPage++;
    await loadLogs(refresh: false);
    isLoadingMore.value = false;
  }

  /// تغيير فلتر نوع العملية
  void setOperationFilter(String operation) {
    if (selectedOperation.value == operation) return;
    selectedOperation.value = operation;
    loadLogs(refresh: true);
  }

  /// البحث النصي اللحظي مع مؤقت التهدئة لمنع الضغط على السيرفر
  void onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      loadLogs(refresh: true);
    });
  }

  /// مسح نص البحث
  void clearSearch() {
    searchController.clear();
    loadLogs(refresh: true);
  }

  /// تنبيه إيقاف الطفرات المالية
  void showDisabledMutationNotice(BuildContext context, String actionTitle) {
    CustomSnackbar.show(
      title: 'العمليات المالية مغلقة برمجياً',
      message: 'عملية ($actionTitle) للقراءة والتدقيق فقط في هذه المرحلة وفق بروتوكول الأمان الصارم.',
      type: SnackType.info,
    );
  }
}
