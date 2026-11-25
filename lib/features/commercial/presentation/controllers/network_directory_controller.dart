import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_networks_page_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_trashed_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/restore_network_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkDirectoryController extends GetxController {
  NetworkDirectoryController(
    this._getPageUseCase,
    this._getTrashedUseCase,
    this._restoreUseCase,
  );

  final GetNetworksPageUseCase _getPageUseCase;
  final GetTrashedNetworksUseCase _getTrashedUseCase;
  final RestoreNetworkUseCase _restoreUseCase;
  final searchController = TextEditingController();
  final networks = <NetworkEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final loadMoreError = RxnString();
  final searchQuery = ''.obs;
  final statusFilter = RxnString();
  final showArchived = false.obs;
  final isRestoring = false.obs;

  String? _nextCursor;
  Timer? _debounce;
  int _revision = 0;
  bool _requestInFlight = false;
  bool _suppressSearchListener = false;

  bool get canCreate => PermissionService.to.can(AppPermissions.networksCreate);
  bool get canRestore => PermissionService.to.can(AppPermissions.networksRestore);

  bool get hasMore => _nextCursor != null && _nextCursor!.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    refreshDirectory();
  }

  void _onSearchChanged() {
    if (_suppressSearchListener) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchQuery.value = searchController.text.trim();
      refreshDirectory();
    });
  }

  void toggleArchiveView() {
    showArchived.toggle();
    networks.clear();
    _nextCursor = null;
    refreshDirectory();
  }

  Future<void> restoreNetwork(NetworkEntity network) async {
    if (!canRestore || isRestoring.value) return;
    isRestoring.value = true;
    try {
      await _restoreUseCase(network.networkId);
      if (showArchived.value) {
        networks.removeWhere((item) => item.networkId == network.networkId);
      }
      CustomSnackbar.show(
        title: 'تمت الاستعادة',
        message: 'أعيدت الشبكة إلى دليل الكيانات النشطة.',
        type: SnackType.success,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'تعذرت الاستعادة',
        message: AppException.sanitizeMessage(error),
        type: SnackType.error,
      );
    } finally {
      isRestoring.value = false;
    }
  }

  void setStatusFilter(String? value) {
    if (statusFilter.value == value) return;
    statusFilter.value = value;
    refreshDirectory();
  }

  void clearSearch() {
    _debounce?.cancel();
    _suppressSearchListener = true;
    searchController.clear();
    _suppressSearchListener = false;
    searchQuery.value = '';
    refreshDirectory();
  }

  Future<void> refreshDirectory() async {
    final revision = ++_revision;
    _nextCursor = null;
    loadMoreError.value = null;
    isLoadingMore.value = false;
    errorMessage.value = null;
    isLoading.value = true;
    _requestInFlight = true;
    try {
      final page = showArchived.value
          ? await _getTrashedUseCase(search: searchQuery.value)
          : await _getPageUseCase(
              search: searchQuery.value,
              status: statusFilter.value,
            );
      if (isClosed || revision != _revision) return;
      networks.assignAll(page.items);
      _nextCursor = page.nextCursor;
    } catch (error) {
      if (isClosed || revision != _revision) return;
      errorMessage.value = AppException.sanitizeMessage(error);
    } finally {
      if (!isClosed && revision == _revision) {
        isLoading.value = false;
        _requestInFlight = false;
      }
    }
  }

  Future<void> loadMore() async {
    final cursor = _nextCursor;
    if (cursor == null || cursor.isEmpty || isLoadingMore.value || _requestInFlight) return;
    final revision = _revision;
    isLoadingMore.value = true;
    loadMoreError.value = null;
    try {
      final PaginatedList<NetworkEntity> page = showArchived.value
          ? await _getTrashedUseCase(
              search: searchQuery.value,
              cursor: cursor,
            )
          : await _getPageUseCase(
              search: searchQuery.value,
              status: statusFilter.value,
              cursor: cursor,
            );
      if (isClosed || revision != _revision) return;
      final knownIds = networks.map((item) => item.networkId).toSet();
      for (final item in page.items) {
        if (knownIds.add(item.networkId)) networks.add(item);
      }
      _nextCursor = page.nextCursor;
    } catch (error) {
      if (!isClosed && revision == _revision) {
        loadMoreError.value = AppException.sanitizeMessage(error);
      }
    } finally {
      if (!isClosed && revision == _revision) isLoadingMore.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}
