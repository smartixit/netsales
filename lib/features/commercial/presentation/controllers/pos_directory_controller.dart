import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_page_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_trashed_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/restore_pos_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class PosDirectoryController extends GetxController {
  PosDirectoryController(
    this._getPageUseCase,
    this._getTrashedUseCase,
    this._restoreUseCase,
  );

  final GetPosPageUseCase _getPageUseCase;
  final GetTrashedPosUseCase _getTrashedUseCase;
  final RestorePosUseCase _restoreUseCase;
  final searchController = TextEditingController();
  final points = <PosEntity>[].obs;
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

  bool get canCreate => PermissionService.to.can(AppPermissions.posCreate);
  bool get canRestore => PermissionService.to.can(AppPermissions.posRestore);

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
    points.clear();
    _nextCursor = null;
    refreshDirectory();
  }

  Future<void> restorePos(PosEntity pos) async {
    if (!canRestore || isRestoring.value) return;
    isRestoring.value = true;
    try {
      await _restoreUseCase(pos.posId);
      if (showArchived.value) {
        points.removeWhere((item) => item.posId == pos.posId);
      }
      CustomSnackbar.show(
        title: 'تمت الاستعادة',
        message: 'أعيدت نقطة البيع إلى دليل الكيانات النشطة.',
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
      points.assignAll(page.items);
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
      final PaginatedList<PosEntity> page = showArchived.value
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
      final knownIds = points.map((item) => item.posId).toSet();
      for (final item in page.items) {
        if (knownIds.add(item.posId)) points.add(item);
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
