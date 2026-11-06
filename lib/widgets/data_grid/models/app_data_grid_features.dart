
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum AppDataGridDataMode { local, remote }

@immutable
class AppDataGridFeatures {
  const AppDataGridFeatures({
    this.dataMode = AppDataGridDataMode.local,
    this.allowSorting = true,
    this.allowMultiColumnSorting = true,
    this.allowTriStateSorting = false,
    this.allowFiltering = true,
    this.allowSelection = true,
    this.allowMultiSelection = true,
    this.showCheckboxColumn = false,
    this.allowColumnResizing = true,
    this.allowColumnDragging = true,
    this.allowEditing = false,
    this.allowGrouping = false,
    this.allowPullToRefresh = false,
    this.allowSwiping = false,
    this.loadMoreViewBuilder,
    this.startSwipeActionsBuilder,
    this.endSwipeActionsBuilder,
    this.onSwipeStart,
    this.onSwipeUpdate,
    this.onSwipeEnd,
    this.frozenColumnsCount = 0,
    this.frozenRowsCount = 0,
    this.rowHeight = 58,
    this.headerRowHeight = 54,
    this.defaultColumnWidth = 150,
    this.rowsPerPage,
    this.columnWidthMode = ColumnWidthMode.none,
    this.columnWidthCalculationRange = ColumnWidthCalculationRange.visibleRows,
    this.navigationMode = GridNavigationMode.row,
    this.highlightRowOnHover = true,
    this.showHorizontalScrollbar = true,
    this.showVerticalScrollbar = true,
    this.isScrollbarAlwaysShown = false,
    this.showSortNumbers = true,
    this.showColumnHeaderIconOnHover = true,
    this.stackedHeaderRows = const <StackedHeaderRow>[],
    this.tableSummaryRows = const <GridTableSummaryRow>[],
    this.footer,
    this.footerHeight = 48,
  });

  final AppDataGridDataMode dataMode;
  final bool allowSorting;
  final bool allowMultiColumnSorting;
  final bool allowTriStateSorting;
  final bool allowFiltering;
  final bool allowSelection;
  final bool allowMultiSelection;
  final bool showCheckboxColumn;
  final bool allowColumnResizing;
  final bool allowColumnDragging;
  final bool allowEditing;
  final bool allowGrouping;
  final bool allowPullToRefresh;
  final bool allowSwiping;
  final LoadMoreViewBuilder? loadMoreViewBuilder;
  final DataGridSwipeActionsBuilder? startSwipeActionsBuilder;
  final DataGridSwipeActionsBuilder? endSwipeActionsBuilder;
  final DataGridSwipeStartCallback? onSwipeStart;
  final DataGridSwipeUpdateCallback? onSwipeUpdate;
  final DataGridSwipeEndCallback? onSwipeEnd;
  final int frozenColumnsCount;
  final int frozenRowsCount;
  final double rowHeight;
  final double headerRowHeight;
  final double defaultColumnWidth;
  final int? rowsPerPage;
  final ColumnWidthMode columnWidthMode;
  final ColumnWidthCalculationRange columnWidthCalculationRange;
  final GridNavigationMode navigationMode;
  final bool highlightRowOnHover;
  final bool showHorizontalScrollbar;
  final bool showVerticalScrollbar;
  final bool isScrollbarAlwaysShown;
  final bool showSortNumbers;
  final bool showColumnHeaderIconOnHover;
  final List<StackedHeaderRow> stackedHeaderRows;
  final List<GridTableSummaryRow> tableSummaryRows;
  final Widget? footer;
  final double footerHeight;

  GridNavigationMode get effectiveNavigationMode => allowEditing ? GridNavigationMode.cell : navigationMode;

  SelectionMode get effectiveSelectionMode {
    if (!allowSelection) return SelectionMode.none;
    return allowMultiSelection ? SelectionMode.multiple : SelectionMode.single;
  }

  bool get canFilterLocally => dataMode == AppDataGridDataMode.local && allowFiltering;
}
