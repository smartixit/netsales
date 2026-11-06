
# NetSales Reusable DataGrid

## Engine and public entry point

The system uses Syncfusion Flutter DataGrid (SfDataGrid) as the rendering/interaction engine and exposes a stable NetSales wrapper:

```dart
import 'package:netsales/widgets/data_grid/data_grid.dart';
```

## Architecture

- `AppDataGridColumn<T>`: typed column definition, value getter, optional renderer/editor/parser/validator. An edit handler returns the updated typed record; null rejects the edit.
- `NetSalesDataGridSource<T>`: adapts host records to Syncfusion. Keep it long-lived in the feature controller/binding; never create it in build().
- `AppDataGrid<T>`: Stateless UI wrapper for design tokens, toolbar, states, responsive rendering, selection and navigation.
- `AppDataGridFeatures`: feature policy for one grid.
- `AppDataGridPagination`: page-based or cursor-based navigation; cursor mode has no fabricated total-page count. Page-based desktop/tablet mode can host Syncfusion `SfDataPager` with automatic local paging or a host-provided remote delegate; mobile uses the same page state with previous/next controls.
- `AppDataGridExportController`: Excel/PDF export through the shared FileExportService.

## Remote-data safety

Set `dataMode: AppDataGridDataMode.remote` for API-backed partial datasets. Local filtering is disabled in remote mode. Sorting changes are intercepted and delegated to the feature controller. Search, advanced filters, page/cursor navigation and server-side export must flow through feature Use Cases, repositories and Laravel API. Never sort/filter only the loaded cursor page and imply the result covers all records.

Exports from the grid controller contain currently loaded rows. A full filtered result export must use an authorized backend export endpoint/job and return the complete artifact.

The generic layer has no HTTP, permissions, workspace, financial or business logic. Editing only emits a typed callback; feature code performs mutations through Use Cases and refreshes from the authoritative response.

## Responsive and visual behavior

Desktop/tablet use SfDataGrid with horizontal scrolling. Phones use key/value record cards; provide `mobileItemBuilder` for a feature-specific mobile presentation. Pull-to-refresh remains available when enabled. Grid-state Excel/PDF export buttons are hidden on mobile because no SfDataGrid is mounted there; mobile features may provide a feature-owned export action. Light/Dark uses the active NetSales AppColors palette. RTL follows Directionality.

## Syncfusion capabilities surfaced

Column widgets, sorting and multi-sort, built-in filter menus, row/checkbox selection, editing hooks, column resizing/reordering/visibility, frozen columns/rows, grouping, stacked headers, summary rows, footer, pull-to-refresh/load-more hooks, page/cursor pagination, Excel/PDF export, dark/light and RTL.

## License

Syncfusion DataGrid and DataGrid Export require a commercial license or a valid Community License. Verify formal eligibility before distribution; this implementation does not assume license eligibility.
