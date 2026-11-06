
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/data_grid/adapters/app_data_grid_export_controller.dart';
import 'package:netsales/widgets/data_grid/adapters/net_sales_data_grid_source.dart';
import 'package:netsales/widgets/data_grid/adapters/netsales_data_grid_theme_adapter.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_column.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_features.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_pagination.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_state.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_grid.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

typedef AppDataGridMobileItemBuilder<T> = Widget Function(BuildContext context, T item);
typedef AppDataGridSelectionChanged<T> = void Function(List<T> selected, List<T> deselected);
typedef AppDataGridSortRequested = void Function(SortColumnDetails? next, SortColumnDetails? previous);

class AppDataGrid<T> extends StatelessWidget {
  const AppDataGrid({
    super.key,
    required this.source,
    this.features = const AppDataGridFeatures(),
    this.viewState = AppDataGridViewState.success,
    this.title,
    this.subtitle,
    this.searchController,
    this.searchHint = 'بحث في السجلات...',
    this.onSearchChanged,
    this.onClearSearch,
    this.headerActions = const <Widget>[],
    this.pagination = const AppDataGridPagination.none(),
    this.exportController,
    this.exportFileName = 'NetSales_Report',
    this.selectedCount = 0,
    this.selectedItems = const <T>[],
    this.onSelectionChanged,
    this.onColumnsReordered,
    this.onSelectionChanging,
    this.onCheckboxValueChanged,
    this.onCurrentCellActivating,
    this.onCurrentCellActivated,
    this.onCellTap,
    this.onCellDoubleTap,
    this.onCellSecondaryTap,
    this.onCellLongPress,
    this.onSortRequested,
    this.onSortChanged,
    this.onFilterChanging,
    this.onFilterChanged,
    this.onFilterRequested,
    this.onRetry,
    this.errorTitle = 'تعذر تحميل البيانات',
    this.errorMessage = 'حدث خطأ أثناء تحميل السجلات. يرجى المحاولة مجدداً.',
    this.emptyTitle = 'لا توجد سجلات حتى الآن',
    this.emptyMessage = 'ستظهر السجلات هنا عند توفرها.',
    this.emptyActionLabel,
    this.onEmptyAction,
    this.mobileItemBuilder,
    this.noResultsQuery,
    this.noResultsAction,
  });

  final NetSalesDataGridSource<T> source;
  final AppDataGridFeatures features;
  final AppDataGridViewState viewState;
  final String? title;
  final String? subtitle;
  final TextEditingController? searchController;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onClearSearch;
  final List<Widget> headerActions;
  final AppDataGridPagination pagination;
  final AppDataGridExportController? exportController;
  final String exportFileName;
  final int selectedCount;
  final List<T> selectedItems;
  final AppDataGridSelectionChanged<T>? onSelectionChanged;
  final VoidCallback? onColumnsReordered;
  final SelectionChangingCallback? onSelectionChanging;
  final DataGridCheckboxValueChangedCallback? onCheckboxValueChanged;
  final CurrentCellActivatingCallback? onCurrentCellActivating;
  final CurrentCellActivatedCallback? onCurrentCellActivated;
  final DataGridCellTapCallback? onCellTap;
  final DataGridCellDoubleTapCallback? onCellDoubleTap;
  final DataGridCellTapCallback? onCellSecondaryTap;
  final DataGridCellLongPressCallback? onCellLongPress;
  final AppDataGridSortRequested? onSortRequested;
  final DataGridColumnSortChangedCallback? onSortChanged;
  final DataGridFilterChangingCallback? onFilterChanging;
  final DataGridFilterChangedCallback? onFilterChanged;
  final ValueChanged<DataGridFilterChangeDetails>? onFilterRequested;
  final VoidCallback? onRetry;
  final String errorTitle;
  final String errorMessage;
  final String emptyTitle;
  final String emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final AppDataGridMobileItemBuilder<T>? mobileItemBuilder;
  final String? noResultsQuery;
  final VoidCallback? noResultsAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null || subtitle != null || searchController != null || headerActions.isNotEmpty || source.items.isNotEmpty || (!AppBreakpoints.isMobile(context) && exportController != null && viewState == AppDataGridViewState.success))
          _GridToolbar(
            title: title,
            subtitle: subtitle,
            searchController: searchController,
            searchHint: searchHint,
            onSearchChanged: onSearchChanged,
            onClearSearch: onClearSearch,
            actions: headerActions,
            exportController: !AppBreakpoints.isMobile(context) && viewState == AppDataGridViewState.success && source.items.isNotEmpty ? exportController : null,
            exportFileName: exportFileName,
            itemCount: source.items.length,
            selectedCount: selectedCount,
            isRemote: features.dataMode == AppDataGridDataMode.remote,
          ),
        Expanded(child: _buildBody(context)),
        if (viewState == AppDataGridViewState.success && pagination.isEnabled)
          if (pagination.mode == AppDataGridPaginationMode.pageBased &&
              pagination.delegate != null &&
              !AppBreakpoints.isMobile(context))
            SfDataPagerTheme(
              data: SfDataPagerThemeData(
                backgroundColor: context.colors.surfaceContainerHigh,
                itemColor: context.colors.surfaceContainerLowest,
                itemTextStyle: AppTypography.labelMedium.copyWith(color: context.colors.onSurface),
                selectedItemColor: context.colors.primary,
                selectedItemTextStyle: AppTypography.labelMedium.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
                disabledItemColor: context.colors.surfaceContainerLow,
                disabledItemTextStyle: AppTypography.labelMedium.copyWith(color: context.colors.onSurfaceVariant),
                itemBorderColor: context.colors.outlineVariant,
                itemBorderWidth: 0.6,
                itemBorderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: SfDataPager(
                key: ValueKey('data-grid-pager-${pagination.currentPage}'),
                delegate: pagination.delegate!,
                pageCount: pagination.totalPages.toDouble(),
                initialPageIndex: pagination.currentPage - 1,
                direction: Axis.horizontal,
                pageItemBuilder: (itemName) {
                  final label = switch (itemName) {
                    'First' => 'الأولى',
                    'Previous' => 'السابق',
                    'Next' => 'التالي',
                    'Last' => 'الأخيرة',
                    _ => itemName,
                  };
                  return Center(
                    child: Text(
                      label,
                      style: AppTypography.labelMedium.copyWith(color: context.colors.onSurface),
                    ),
                  );
                },
                onPageNavigationStart: pagination.onPageNavigationStart,
                onPageNavigationEnd: pagination.onPageNavigationEnd,
              ),
            )
          else
            _GridPaginationBar(
              pagination: pagination,
              onPageChanged: features.dataMode == AppDataGridDataMode.remote
                  ? (page) {
                      unawaited(source.handlePageChange(pagination.currentPage - 1, page - 1).then<void>((changed) {
                        if (changed) pagination.onPageChanged?.call(page);
                      }));
                    }
                  : pagination.onPageChanged,
            ),
        if (viewState == AppDataGridViewState.success && features.dataMode == AppDataGridDataMode.remote)
          Padding(
            padding: EdgeInsetsDirectional.only(start: AppSpacing.md, end: AppSpacing.md, bottom: AppSpacing.xs),
            child: Text(
              'يتم تطبيق الفرز والتصفية على الخادم لضمان صحة نتائج الصفحات.',
              style: AppTypography.caption.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (viewState) {
      case AppDataGridViewState.loading:
        return const Padding(
          key: ValueKey('data-grid-loading'),
          padding: EdgeInsets.all(16),
          child: CustomSkeletonGrid(count: 6, crossAxisCount: 2),
        );
      case AppDataGridViewState.error:
        return CustomErrorState.boxed(
          key: const ValueKey('data-grid-error'),
          title: errorTitle,
          subtitle: errorMessage,
          icon: Icons.cloud_off_rounded,
          onRetry: onRetry,
        );
      case AppDataGridViewState.empty:
        return CustomEmptyState.boxed(
          key: const ValueKey('data-grid-empty'),
          title: emptyTitle,
          subtitle: emptyMessage,
          icon: Icons.table_rows_outlined,
          actionLabel: emptyActionLabel,
          onAction: onEmptyAction,
        );
      case AppDataGridViewState.noResults:
        return CustomEmptyState.search(
          key: const ValueKey('data-grid-no-results'),
          query: noResultsQuery ?? searchController?.text ?? '',
          onClearSearch: noResultsAction ?? onClearSearch,
        );
      case AppDataGridViewState.success:
        if (source.items.isEmpty) {
          return CustomEmptyState.boxed(
            key: const ValueKey('data-grid-empty-success'),
            title: emptyTitle,
            subtitle: emptyMessage,
            icon: Icons.table_rows_outlined,
            actionLabel: emptyActionLabel,
            onAction: onEmptyAction,
          );
        }
        if (AppBreakpoints.isMobile(context)) {
          return _MobileGridList<T>(
            key: const ValueKey('data-grid-mobile'),
            source: source,
            pagination: pagination,
            rowsPerPage: features.rowsPerPage,
            allowPullToRefresh: features.allowPullToRefresh,
            allowSelection: features.allowSelection,
            allowMultiSelection: features.allowMultiSelection,
            selectedItems: selectedItems,
            onSelectionChanged: onSelectionChanged,
            itemBuilder: mobileItemBuilder,
            isRemote: features.dataMode == AppDataGridDataMode.remote,
          );
        }
        final gridColumns = source.columns.where((column) => column.visible).map((column) => column.toGridColumn(context)).toList();
        return ClipRRect(
          key: const ValueKey('data-grid-desktop'),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: NetSalesDataGridThemeAdapter.wrap(
            context: context,
            child: SfDataGrid(
              key: exportController?.gridKey,
              source: source,
              columns: gridColumns,
              rowHeight: features.rowHeight,
              headerRowHeight: features.headerRowHeight,
              defaultColumnWidth: features.defaultColumnWidth,
              rowsPerPage: features.rowsPerPage,
              columnWidthMode: features.columnWidthMode,
              columnSizer: features.columnSizer,
              columnResizeMode: features.columnResizeMode,
              columnDragFeedbackBuilder: features.columnDragFeedbackBuilder,
              onColumnResizeStart: features.onColumnResizeStart,
              onColumnResizeEnd: features.onColumnResizeEnd,
              controller: features.controller,
              selectionManager: features.selectionManager,
              sortingGestureType: features.sortingGestureType,
              checkboxColumnSettings: features.checkboxColumnSettings,
              horizontalScrollPhysics: features.horizontalScrollPhysics,
              verticalScrollPhysics: features.verticalScrollPhysics,
              horizontalScrollController: features.horizontalScrollController,
              verticalScrollController: features.verticalScrollController,
              shrinkWrapColumns: features.shrinkWrapColumns,
              shrinkWrapRows: features.shrinkWrapRows,
              rowsCacheExtent: features.rowsCacheExtent,
              columnWidthCalculationRange: features.columnWidthCalculationRange,
              gridLinesVisibility: features.gridLinesVisibility,
              headerGridLinesVisibility: features.headerGridLinesVisibility,
              selectionMode: features.effectiveSelectionMode,
              navigationMode: features.effectiveNavigationMode,
              frozenColumnsCount: _safeFrozenCount(features.frozenColumnsCount, source.columns.where((column) => column.visible).length),
              frozenRowsCount: _safeFrozenRowCount(features.frozenRowsCount, source.rows.length),
              footerFrozenColumnsCount: _safeFrozenCount(features.footerFrozenColumnsCount, source.columns.where((column) => column.visible).length),
              footerFrozenRowsCount: _safeFrozenRowCount(features.footerFrozenRowsCount, source.rows.length),
              allowSorting: features.allowSorting,
              allowMultiColumnSorting: features.allowSorting && features.allowMultiColumnSorting,
              allowTriStateSorting: features.allowSorting && features.allowTriStateSorting,
              showSortNumbers: features.showSortNumbers,
              showColumnHeaderIconOnHover: features.showColumnHeaderIconOnHover,
              allowFiltering: features.allowFiltering,
              allowEditing: features.allowEditing,
              editingGestureType: features.editingGestureType,
              placeholder: features.placeholder,
              checkboxShape: features.checkboxShape,
              allowColumnsResizing: features.allowColumnResizing,
              onColumnResizeStart: features.allowColumnResizing ? features.onColumnResizeStart : null,
              onColumnResizeUpdate: features.allowColumnResizing
                  ? (details) {
                      final accepted = features.onColumnResizeUpdate?.call(details) ?? true;
                      if (accepted) source.updateColumnWidth(details.column.columnName, details.width);
                      return accepted;
                    }
                  : null,
              onColumnResizeEnd: features.allowColumnResizing ? features.onColumnResizeEnd : null,
              allowColumnsDragging: features.allowColumnDragging,
              onColumnDragging: features.allowColumnDragging
                  ? (details) {
                      if (details.action == DataGridColumnDragAction.dropped) {
                        final from = details.from;
                        final to = details.to;
                        if (to == null ||
                            from < 0 ||
                            from >= gridColumns.length ||
                            to < 0 ||
                            to >= gridColumns.length) {
                          return false;
                        }
                        source.reorderVisibleColumns(from, to);
                        final moved = gridColumns.removeAt(from);
                        gridColumns.insert(to, moved);
                        onColumnsReordered?.call();
                      }
                      return true;
                    }
                  : null,
              allowExpandCollapseGroup: features.allowGrouping && features.allowExpandCollapseGroup,
              autoExpandGroups: features.autoExpandGroups,
              groupCaptionTitleFormat: features.groupCaptionTitleFormat,
              groupExpanding: features.groupExpanding,
              groupExpanded: features.groupExpanded,
              groupCollapsing: features.groupCollapsing,
              groupCollapsed: features.groupCollapsed,
              allowPullToRefresh: features.allowPullToRefresh,
              refreshIndicatorDisplacement: features.refreshIndicatorDisplacement,
              refreshIndicatorStrokeWidth: features.refreshIndicatorStrokeWidth,
              loadMoreViewBuilder: features.loadMoreViewBuilder,
              allowSwiping: features.allowSwiping,
              swipeMaxOffset: features.swipeMaxOffset,
              startSwipeActionsBuilder: features.startSwipeActionsBuilder,
              endSwipeActionsBuilder: features.endSwipeActionsBuilder,
              onSwipeStart: features.onSwipeStart,
              onSwipeUpdate: features.onSwipeUpdate,
              onSwipeEnd: features.onSwipeEnd,
              showCheckboxColumn: features.showCheckboxColumn,
              highlightRowOnHover: features.highlightRowOnHover,
              isScrollbarAlwaysShown: features.isScrollbarAlwaysShown,
              showHorizontalScrollbar: features.showHorizontalScrollbar,
              showVerticalScrollbar: features.showVerticalScrollbar,
              stackedHeaderRows: features.stackedHeaderRows,
              tableSummaryRows: features.tableSummaryRows,
              footer: features.footer,
              footerHeight: features.footerHeight,
              onQueryRowHeight: features.onQueryRowHeight,
              onSelectionChanging: onSelectionChanging,
              onCheckboxValueChanged: onCheckboxValueChanged,
              onCurrentCellActivating: onCurrentCellActivating,
              onCurrentCellActivated: onCurrentCellActivated,
              onCellTap: onCellTap,
              onCellDoubleTap: onCellDoubleTap,
              onCellSecondaryTap: onCellSecondaryTap,
              onCellLongPress: onCellLongPress,
              onSelectionChanged: onSelectionChanged == null ? null : (added, removed) {
                onSelectionChanged!(source.itemsForRows(added), source.itemsForRows(removed));
              },
              onColumnSortChanged: onSortChanged,
              onFilterChanging: features.dataMode == AppDataGridDataMode.local
                  ? onFilterChanging
                  : (details) {
                      onFilterRequested?.call(details);
                      return false;
                    },
              onFilterChanged: features.dataMode == AppDataGridDataMode.local ? onFilterChanged : null,
              onColumnSortChanging: features.dataMode == AppDataGridDataMode.remote
                  ? (next, previous) {
                      onSortRequested?.call(next, previous);
                      return false;
                    }
                  : null,
            ),
          ),
        );
    }
  }

  static int _safeFrozenCount(int count, int visibleColumns) =>
      visibleColumns <= 1 ? 0 : count.clamp(0, visibleColumns - 1).toInt();

  static int _safeFrozenRowCount(int count, int rowCount) =>
      rowCount <= 1 ? 0 : count.clamp(0, rowCount - 1).toInt();
}

class _GridToolbar extends StatelessWidget {
  const _GridToolbar({
    this.title,
    this.subtitle,
    this.searchController,
    required this.searchHint,
    this.onSearchChanged,
    this.onClearSearch,
    required this.actions,
    this.exportController,
    required this.exportFileName,
    required this.itemCount,
    required this.selectedCount,
    required this.isRemote,
  });

  final String? title;
  final String? subtitle;
  final TextEditingController? searchController;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onClearSearch;
  final List<Widget> actions;
  final AppDataGridExportController? exportController;
  final String exportFileName;
  final int itemCount;
  final int selectedCount;
  final bool isRemote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || actions.isNotEmpty || exportController != null) ...[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (title != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!, style: AppTypography.titleMedium.copyWith(color: colors.onSurface)),
                      if (subtitle != null)
                        Text(subtitle!, style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant)),
                    ],
                  ),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    ...actions,
                    if (exportController != null) ...[
                      CustomButton.icon(
                        icon: Icons.table_view_rounded,
                        tooltip: 'تصدير Excel',
                        size: AppButtonSize.small,
                        onPressed: () => exportController!.exportExcel(fileName: exportFileName),
                      ),
                      CustomButton.icon(
                        icon: Icons.picture_as_pdf_outlined,
                        tooltip: 'تصدير PDF',
                        size: AppButtonSize.small,
                        onPressed: () => exportController!.exportPdf(fileName: exportFileName),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            AppSpacing.vSm,
          ],
          if (searchController != null)
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: searchController!,
                    label: 'بحث',
                    hint: searchHint,
                    prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
                    onChanged: onSearchChanged,
                    isRequired: false,
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  ),
                ),
                if (onClearSearch != null) ...[
                  AppSpacing.hXs,
                  CustomButton.icon(icon: Icons.close_rounded, tooltip: 'مسح البحث', size: AppButtonSize.small, onPressed: onClearSearch),
                ],
              ],
            ),
          AppSpacing.vXs,
          Row(
            children: [
              CustomChip(label: isRemote ? '${itemCount} سجل محمّل' : '${itemCount} سجل', icon: Icons.table_rows_outlined, isCompact: true),
              if (selectedCount > 0) ...[
                AppSpacing.hXs,
                CustomChip(label: selectedCount.toString() + ' محدد', icon: Icons.check_circle_outline_rounded, isCompact: true),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileGridList<T> extends StatelessWidget {
  const _MobileGridList({super.key, required this.source, required this.pagination, this.rowsPerPage, this.allowPullToRefresh = false, this.allowSelection = false, this.allowMultiSelection = true, this.selectedItems = const <T>[], this.onSelectionChanged, this.itemBuilder, this.isRemote = false});
  final NetSalesDataGridSource<T> source;
  final AppDataGridPagination pagination;
  final int? rowsPerPage;
  final bool allowPullToRefresh;
  final bool allowSelection;
  final bool allowMultiSelection;
  final List<T> selectedItems;
  final AppDataGridSelectionChanged<T>? onSelectionChanged;
  final AppDataGridMobileItemBuilder<T>? itemBuilder;
  final bool isRemote;

  @override
  Widget build(BuildContext context) {
    final allRows = source.items;
    final rows = !isRemote && pagination.mode == AppDataGridPaginationMode.pageBased && rowsPerPage != null
        ? allRows.skip((pagination.currentPage - 1) * rowsPerPage!).take(rowsPerPage!).toList(growable: false)
        : allRows;
    if (rows.isEmpty) {
      return const CustomEmptyState.compact(title: 'لا توجد سجلات', subtitle: 'لا توجد بيانات لعرضها في هذه الصفحة.', icon: Icons.table_rows_outlined);
    }
    final list = ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
      itemCount: rows.length,
      separatorBuilder: (_, __) => AppSpacing.vSm,
      itemBuilder: (context, index) {
        final item = rows[index];
        final isSelected = selectedItems.contains(item);
        final recordCard = itemBuilder?.call(context, item) ??
            _DefaultMobileRecordCard<T>(
              item: item,
              columns: source.columns.where((column) => column.visible).toList(growable: false),
            );
        if (!allowSelection || onSelectionChanged == null) return recordCard;
        return Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (selected) {
                if (selected == true) {
                  onSelectionChanged!(
                    [item],
                    allowMultiSelection
                        ? const <T>[]
                        : selectedItems.where((value) => value != item).toList(growable: false),
                  );
                } else {
                  onSelectionChanged!(const <T>[], [item]);
                }
              },
            ),
            Expanded(child: recordCard),
          ],
        );
      },
    );
    Widget content = list;
    if (source.onLoadMore != null) {
      content = NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 180 && source.hasMore) {
            unawaited(source.requestLoadMore());
          }
          return false;
        },
        child: content,
      );
    }
    if (!allowPullToRefresh) return content;
    return RefreshIndicator(
      onRefresh: source.handleRefresh,
      child: content,
    );
  }
}

class _DefaultMobileRecordCard<T> extends StatelessWidget {
  const _DefaultMobileRecordCard({required this.item, required this.columns});
  final T item;
  final List<AppDataGridColumn<T>> columns;

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    final primary = columns.first;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(primary.valueGetter(item)?.toString() ?? '—', style: AppTypography.titleSmall.copyWith(color: colors.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (columns.length > 1) ...[
            AppSpacing.vSm,
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: columns.skip(1).map((column) {
                final value = column.valueGetter(item);
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(column.label, style: AppTypography.caption.copyWith(color: colors.onSurfaceVariant)),
                      Text(value?.toString() ?? '—', style: AppTypography.bodyMedium.copyWith(color: colors.onSurface, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              }).toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _GridPaginationBar extends StatelessWidget {
  const _GridPaginationBar({required this.pagination, this.onPageChanged});
  final AppDataGridPagination pagination;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    final label = pagination.mode == AppDataGridPaginationMode.pageBased
        ? 'صفحة ' + pagination.currentPage.toString() + ' من ' + pagination.totalPages.toString()
        : pagination.pageLabel ?? 'تصفح النتائج';
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.sm),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.colors.outlineVariant))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: context.colors.onSurfaceVariant)),
          Row(
            children: [
              CustomButton.icon(
                icon: Directionality.of(context) == TextDirection.rtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                tooltip: 'السابق',
                size: AppButtonSize.small,
                enabled: !pagination.isLoading && (pagination.mode == AppDataGridPaginationMode.pageBased ? pagination.currentPage > 1 : pagination.hasPrevious),
                onPressed: pagination.isLoading ? null : () {
                  if (pagination.mode == AppDataGridPaginationMode.pageBased) {
                    onPageChanged?.call(pagination.currentPage - 1);
                  } else {
                    pagination.onPrevious?.call();
                  }
                },
              ),
              AppSpacing.hXs,
              CustomButton.icon(
                icon: Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                tooltip: 'التالي',
                size: AppButtonSize.small,
                enabled: !pagination.isLoading && (pagination.mode == AppDataGridPaginationMode.pageBased ? pagination.currentPage < pagination.totalPages : pagination.hasNext),
                onPressed: pagination.isLoading ? null : () {
                  if (pagination.mode == AppDataGridPaginationMode.pageBased) {
                    onPageChanged?.call(pagination.currentPage + 1);
                  } else {
                    pagination.onNext?.call();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
