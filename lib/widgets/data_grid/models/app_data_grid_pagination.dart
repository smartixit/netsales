
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum AppDataGridPaginationMode { none, pageBased, cursorBased }

@immutable
class AppDataGridPagination {
  const AppDataGridPagination.none()
      : mode = AppDataGridPaginationMode.none, currentPage = 0, totalPages = 0,
        pageLabel = null, hasPrevious = false, hasNext = false,
        onPageChanged = null, onPrevious = null, onNext = null, isLoading = false, delegate = null;

  const AppDataGridPagination.pageBased({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.isLoading = false,
    this.delegate,
  }) : assert(currentPage >= 1),
       assert(totalPages >= 1),
       assert(currentPage <= totalPages),
       mode = AppDataGridPaginationMode.pageBased,
       pageLabel = null, hasPrevious = false, hasNext = false,
       onPrevious = null, onNext = null;

  const AppDataGridPagination.cursorBased({
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
    this.pageLabel,
    this.isLoading = false,
  }) : mode = AppDataGridPaginationMode.cursorBased,
       currentPage = 0, totalPages = 0, onPageChanged = null, delegate = null;

  final AppDataGridPaginationMode mode;
  final int currentPage;
  final int totalPages;
  final String? pageLabel;
  final bool hasPrevious;
  final bool hasNext;
  final ValueChanged<int>? onPageChanged;
  final Future<void> Function()? onPrevious;
  final Future<void> Function()? onNext;
  final bool isLoading;
  final DataPagerDelegate? delegate;

  bool get isEnabled => mode != AppDataGridPaginationMode.none;
}
