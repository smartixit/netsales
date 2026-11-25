import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_networks_page_use_case.dart';

class NetworkDirectoryController extends GetxController {
  NetworkDirectoryController(this._getPageUseCase);

  final GetNetworksPageUseCase _getPageUseCase;
  final searchController = TextEditingController();
  final networks = <NetworkEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final loadMoreError = RxnString();
  final searchQuery = ''.obs;
  final statusFilter = RxnString();

  String? _nextCursor;
  Timer? _debounce;
  int _revision = 0;
  bool _requestInFlight = false;
  bool _suppressSearchListener = false;

  bool get canCreate => PermissionService.to.can(AppPermissions.networksCreate);

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
      final page = await _getPageUseCase(
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
      final PaginatedList<NetworkEntity> page = await _getPageUseCase(
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
