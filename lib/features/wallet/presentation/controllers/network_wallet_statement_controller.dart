import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/wallet/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/entities/network_wallet_log_entity.dart';
import 'package:netsales/features/wallet/domain/usecases/get_network_wallet_logs_use_case.dart';
import 'package:netsales/features/wallet/domain/usecases/get_network_wallet_use_case.dart';
import 'package:netsales/features/wallet/presentation/controllers/wallet_filter_controller.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';

/// متحكم كشف حساب ودفتر أستاذ محفظة مزود الشبكة (Network Wallet Statement Controller)
///
/// متحكم تنفيذي للقراءة والتدقيق فقط خالٍ من أي دوال للتعديل أو الحذف اليدوي.
class NetworkWalletStatementController extends GetxController
    implements WalletFilterController {
  NetworkWalletStatementController({
    required this.getNetworkWalletUseCase,
    required this.getNetworkWalletLogsUseCase,
    this.initialNetworkId,
  });

  final GetNetworkWalletUseCase getNetworkWalletUseCase;
  final GetNetworkWalletLogsUseCase getNetworkWalletLogsUseCase;
  final int? initialNetworkId;

  // الحالات التفاعلية
  final Rxn<NetworkWalletEntity> wallet = Rxn<NetworkWalletEntity>();
  final RxList<NetworkWalletLogEntity> logs = <NetworkWalletLogEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString errorMessage = RxnString();

  // الفلاتر
  @override
  final Rxn<WalletOperationType> selectedOperationType =
      Rxn<WalletOperationType>();
  final RxString searchQuery = ''.obs;
  final RxnString fromDate = RxnString();
  final RxnString toDate = RxnString();
  @override
  final TextEditingController searchController = TextEditingController();

  // الترقيم التدريجي بالمؤشر
  final RxnString nextCursor = RxnString();
  final RxBool hasMore = false.obs;

  Timer? _searchDebounceTimer;
  int? _resolvedNetworkId;

  @override
  void onInit() {
    super.onInit();
    _resolveContextAndLoad();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _resolveContextAndLoad() {
    // 1. استخراج معرف الشبكة من arguments
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _resolvedNetworkId = args['network_id'] as int?;
    }

    _resolvedNetworkId ??= initialNetworkId;

    // 2. إذا لم يتوفر، استخراجه من متحكم مساحة عمل الشبكة النشط
    if (_resolvedNetworkId == null &&
        Get.isRegistered<NetworkWorkspaceController>()) {
      final networkController = Get.find<NetworkWorkspaceController>();
      _resolvedNetworkId ??= networkController.selectedNetworkId.value;
    }

    loadWalletAndLogs();
  }

  /// تحميل بيانات محفظة الشبكة والسجلات الأولية
  Future<void> loadWalletAndLogs({bool isRefresh = false}) async {
    if (!isRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = null;

    final netId = _resolvedNetworkId ?? 0;
    if (netId <= 0) {
      isLoading.value = false;
      errorMessage.value = 'يرجى اختيار الشبكة المزودة لاستعراض دفتر الأستاذ.';
      return;
    }

    try {
      // 1. جلب بيانات المحفظة
      final walletData = await getNetworkWalletUseCase(netId);
      wallet.value = walletData;

      // 2. جلب الصفحة الأولى من قيود دفتر الأستاذ
      await _fetchLogsPage(isInitial: true);
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل المزيد من السجلات عبر المؤشر (Cursor Pagination)
  Future<void> loadMoreLogs() async {
    if (isLoadingMore.value || !hasMore.value || wallet.value == null) {
      return;
    }

    isLoadingMore.value = true;
    try {
      await _fetchLogsPage(isInitial: false);
    } catch (_) {
      // إيقاف مؤشر التحميل دون إلغاء العناصر السابقة
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _fetchLogsPage({required bool isInitial}) async {
    final currentWallet = wallet.value;
    if (currentWallet == null) return;

    final PaginatedList<NetworkWalletLogEntity> pageResult =
        await getNetworkWalletLogsUseCase(
          walletId: currentWallet.walletId,
          operationType: selectedOperationType.value,
          fromDate: fromDate.value,
          toDate: toDate.value,
          search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
          cursor: isInitial ? null : nextCursor.value,
          perPage: 15,
        );

    if (isInitial) {
      logs.assignAll(pageResult.items);
    } else {
      logs.addAll(pageResult.items);
    }

    nextCursor.value = pageResult.nextCursor;
    hasMore.value = pageResult.hasMore;
  }

  /// تغيير فلتر نوع الحركة (الكل / إيداع / سحب)
  @override
  void setOperationFilter(WalletOperationType? type) {
    if (selectedOperationType.value == type) return;
    selectedOperationType.value = type;
    nextCursor.value = null;
    loadWalletAndLogs(isRefresh: true);
  }

  /// تعيين فلاتر التاريخ
  void setDateFilter(String? from, String? to) {
    fromDate.value = from;
    toDate.value = to;
    nextCursor.value = null;
    loadWalletAndLogs(isRefresh: true);
  }

  /// مسح فلاتر التاريخ
  void clearDateFilter() {
    fromDate.value = null;
    toDate.value = null;
    nextCursor.value = null;
    loadWalletAndLogs(isRefresh: true);
  }

  /// البحث المؤجل (Debounced Search)
  @override
  void onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (searchQuery.value != query.trim()) {
        searchQuery.value = query.trim();
        nextCursor.value = null;
        loadWalletAndLogs(isRefresh: true);
      }
    });
  }
}
