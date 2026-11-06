# Reusable Dashboard Metrics

A presentation-only KPI component system for Flutter dashboards.

## Core principle

A KPI is more than a number and an icon. The public model captures:

- **Value:** host-formatted display value and optional unit/description.
- **Meaning:** explicit semantic tone and a typed trend interpretation. An increase is not inherently positive; the host supplies the interpretation.
- **Direction:** increase, decrease, or unchanged, with a caller-provided display label and comparison period.
- **Boundaries:** optional target progress and normalized threshold markers. The host supplies the normalized progress and threshold positions; widgets only render them.
- **Provenance:** source label, optional detail, update timestamp/label, and freshness state.
- **History:** optional normalized sparkline series.
- **State:** loading, data, empty, and error presentations.

The generic UI never calculates deltas, percentages, financial values, threshold breaches, or freshness. These are domain/backend responsibilities. All values and labels are display-ready and localized by the host.

## Variants

- `standard`: value and contextual description.
- `trend`: value, interpreted trend, optional sparkline.
- `status`: value and semantic status caption.
- `target`: value, supplied progress fraction, and optional boundary markers.

## NetSales theme integration

Wrap the metrics section with `NetSalesDashboardMetricsThemeAdapter.wrap(context: context, child: ...)`. The adapter maps the existing `AppColors`, `AppRadius`, `AppSpacing`, `AppBreakpoints`, `AppElevation`, and `AppMotion` design tokens into `DashboardMetricsTheme`, normalizing ScreenUtil-backed card geometry to logical dimensions. The generic card and grid import only Flutter and the generic KPI contracts; they do not import NetSales core classes. Generic metric widgets consume only the theme extension and Flutter Material theme.

## Responsive grid

Use `DashboardMetricGrid` to calculate columns from the actual available width. It uses the central `AppBreakpoints.gridGutter` token by default and never assumes that a full device screen is available to the card grid.

## Usage

```dart
DashboardMetricGrid(
  metrics: metrics,
  onMetricTap: (metricId) => openMetricDetails(metricId),
)
```

Use the card directly when the page needs custom composition:

```dart
DashboardMetricCard(
  metric: metric,
  state: DashboardMetricState.data,
  onTap: openDetails,
)
```

No GetX, API, role, permission, repository, or NetSales business model is imported by the generic framework.


## Visual showcase

A developer-only showcase screen demonstrates the four card variants separately, the six semantic tones, and loading/empty/error states. It uses local sample data only and allows switching between Light/Dark and LTR/RTL without changing the persisted application theme.

In a debug build, open the route:

`/dev/dashboard-metrics`

The route is conditionally registered with `kDebugMode`, so it is not included in release builds. The screen is under `lib/widgets/dashboard_metrics/showcase/` and uses the existing NetSales theme adapter.
