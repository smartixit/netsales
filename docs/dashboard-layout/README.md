# Reusable Dashboard Layout

A desktop-first, responsive Flutter dashboard shell with no business-domain or state-management dependency.

## Public API

Import:

```dart
import 'package:netsales/widgets/dashboard_layout/dashboard_layout.dart';
```

Compose `DashboardShell` with a `DashboardNavigationSection`, selected navigation ID, callback, optional branding/profile/topbar slots and a page widget. The host application owns routing, authorization, session state and state management.

## Styling

The generic shell reads `DashboardLayoutTheme` from Flutter's ThemeExtensions and falls back to the active Material `ColorScheme`. NetSales can map its existing AppColors, AppRadius, AppSpacing, AppBreakpoints and AppMotion through `NetSalesDashboardThemeAdapter.of(context)`. Add that extension to the host ThemeData; generic widgets never import GetX or NetSales core services.

## Responsive behavior

The shell uses its available layout constraints. At the configured mobile breakpoint it replaces the persistent sidebar with a Scaffold drawer. On larger surfaces the sidebar remains persistent and can be collapsed by externally controlled state.

## Navigation and authorization

Navigation items are presentation models only. The host must provide the items it intends to expose and handle callbacks. This package does not authorize, filter permissions, or navigate through a router.

## Direction and accessibility

Layout uses directional padding/alignment and inherits the ambient Directionality. Use localized labels from the host application. Built-in buttons, tooltips and Material interactions provide keyboard and pointer affordances.

## Example

```dart
DashboardShell(
  navigation: const DashboardNavigationSection(
    items: [
      DashboardNavigationItem(
        id: 'overview',
        label: 'Overview',
        icon: Icons.dashboard_outlined,
      ),
    ],
  ),
  selectedNavigationId: selectedId,
  onNavigationSelected: onNavigate,
  sidebarHeader: const Text('Workspace'),
  child: const Center(child: Text('Page content')),
)
```
