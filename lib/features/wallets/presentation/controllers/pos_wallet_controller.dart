import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallets/domain/usecases/get_pos_linked_networks_use_case.dart';
import 'package:netsales/features/wallets/domain/usecases/get_pos_wallet_logs_use_case.dart';
import 'package:netsales/features/wallets/domain/usecases/get_pos_wallet_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم كشف الحساب الجاري والمديونية لنقطة البيع (PosWalletController) — POS-04
/// ============================================================================
/// يدير الحسابات الجارية الثنائية بين نقطة البيع والشبكات المزودة المرتبطة بها.
/// 
/// قواعد السلامة المالية الصارمة المطبقة:
/// 1. الفصل المطلق بين الشبكات: لا يتم إطلاقاً دمج أو جمع أرصدة شبكات مختلفة.
/// 2. عدم حساب المديونية محلياً: المديونية تؤخذ 100% من رصيد المحفظة السلبي المعطى من الخادم.
/// 3. القفل التام للطفرات المالية: لا يمكن شحن أو سحب أو إنشاء فواتير من هذه الواجهة.
class PosWalletController extends GetxController {
  final GetPosLinkedNetworksUseCase getPosLinkedNetworksUseCase;
  final GetPosWalletUseCase getPosWalletUseCase;
  final GetPosWalletLogsUseCase getPosWalletLogsUseCase;

  PosWalletController({
    required this.getPosLinkedNetworksUseCase,
    required this.getPosWalletUseCase,
    required this.getPosWalletLogsUseCase,
  });

  /// قائمة الشبكات المزودة المرتبطة بنقطة البيع
  final RxList<NetworkPosEntity> linkedNetworks = <NetworkPosEntity>[].obs;

  /// الشبكة المزودة المحددة حالياً لفحص الحساب الجاري المنفصل معها
  final Rxn<NetworkPosEntity> selectedNetwork = Rxn<NetworkPosEntity>();

  /// محفظة الحساب الجاري الثنائي مع الشبكة المحددة
  final Rxn<PosWalletEntity> wallet = Rxn<PosWalletEntity>();

  /// سجل القيود المحاسبية الثنائية
  final RxList<PosWalletLogEntity> logs = <PosWalletLogEntity>[].obs;

  /// حالات التحميل والخطأ
  final RxBool isLoadingNetworks = true.obs;
  final RxBool isLoadingWallet = false.obs;
  final RxBool isLoadingLogs = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  /// وضع إخفاء الرصيد لخصوصية التاجر
  final RxBool isBalanceHidden = false.obs;

  /// فلتر نوع العملية المالية
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

  /// استخلاص معرف نقطة البيع النشطة من المدخلات أو السياق التشغيلي
  int get posId {
    if (Get.arguments is int) {
      return Get.arguments as int;
    }
    if (Get.parameters['pos_id'] != null) {
      final parsed = int.tryParse(Get.parameters['pos_id']!);
      if (parsed != null && parsed > 0) return parsed;
    }
    if (Get.isRegistered<DashboardController>()) {
      final dashContext = Get.find<DashboardController>().overview.value?.context;
      if (dashContext?.posId != null && dashContext!.posId! > 0) {
        return dashContext.posId!;
      }
    }
    return 1;
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadLinkedNetworks();
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

  void togglePrivacy() {
    isBalanceHidden.toggle();
  }

  /// جلب قائمة الشبكات المرتبطة بنقطة البيع
  Future<void> loadLinkedNetworks() async {
    isLoadingNetworks.value = true;
    errorMessage.value = '';
    try {
      final response = await getPosLinkedNetworksUseCase(posId);
      if (response.success && response.data != null) {
        linkedNetworks.assignAll(response.data!);
        if (linkedNetworks.isNotEmpty) {
          // اختيار الشبكة الأولى تلقائياً إن لم تكن محددة مسبقاً
          selectNetwork(linkedNetworks.first);
        } else {
          errorMessage.value = 'لا توجد شبكات مزودة مرتبطة بنقطة البيع هذه حالياً.';
        }
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب قائمة الشبكات المرتبطة.';
      }
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(e);
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  /// اختيار شبكة معينة لتصفح حسابها الجاري المنعزل
  void selectNetwork(NetworkPosEntity network) {
    if (selectedNetwork.value?.networkId == network.networkId && wallet.value != null) {
      return;
    }
    selectedNetwork.value = network;
    loadWalletAndLogsForSelectedNetwork();
  }

  /// جلب بيانات المحفظة وسجل الحركات للشبكة المحددة حصراً
  Future<void> loadWalletAndLogsForSelectedNetwork() async {
    final net = selectedNetwork.value;
    if (net == null) return;

    errorMessage.value = '';
    isLoadingWallet.value = true;
    logs.clear();

    try {
      final walletResponse = await getPosWalletUseCase(
        networkId: net.networkId,
        posId: posId,
      );

      if (walletResponse.success && walletResponse.data != null) {
        wallet.value = walletResponse.data;
        await loadLogs(refresh: true);
      } else {
        errorMessage.value = walletResponse.message.isNotEmpty
            ? walletResponse.message
            : 'تعذر جلب الحساب الجاري مع هذه الشبكة.';
      }
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(e);
    } finally {
      isLoadingWallet.value = false;
    }
  }

  /// جلب سجل الحركات المالية للحساب الجاري مع الشبكة المحددة
  Future<void> loadLogs({bool refresh = false}) async {
    final currentWallet = wallet.value;
    if (currentWallet == null) return;

    if (refresh) {
      _currentPage = 1;
      hasMoreLogs.value = true;
      isLoadingLogs.value = true;
    }

    try {
      final response = await getPosWalletLogsUseCase(
        walletId: currentWallet.walletId,
        page: _currentPage,
        perPage: _perPage,
        logOperationType: selectedOperation.value == 'ALL' ? null : selectedOperation.value,
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

  /// تغيير فلتر نوع الحركة
  void setOperationFilter(String operation) {
    if (selectedOperation.value == operation) return;
    selectedOperation.value = operation;
    loadLogs(refresh: true);
  }

  /// البحث النصي اللحظي
  void onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      loadLogs(refresh: true);
    });
  }

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
