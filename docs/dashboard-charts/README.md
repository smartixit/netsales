# Reusable Syncfusion Chart Framework

The reusable chart layer lives under `lib/widgets/charts`. It provides a
framework-neutral chart contract, Syncfusion renderers, a NetSales theme
adapter, a NetSales export adapter, and a local showcase at
`/dev/dashboard-charts`.

## Seven chart families

| Family | Supported types |
| --- | --- |
| Cartesian / trends | Line, Spline, FastLine, Area, SplineArea, StepLine, StepArea, RangeArea, SplineRangeArea |
| Comparison | Column, Bar, StackedColumn, StackedBar, StackedArea, StackedLine, 100% stacked variants, Waterfall |
| Circular | Pie, Doughnut, RadialBar |
| Funnel | Funnel, Pyramid |
| Statistical | Scatter, Bubble, Histogram, BoxAndWhisker, ErrorBar, RangeColumn |
| Financial | Candle, HiLo, OHLC |
| Spark | SparkLine, SparkArea, SparkBar, SparkWinLoss |

## Basic usage

Import the public barrel:

```dart
import 'package:netsales/widgets/charts/charting.dart';
```

Create a definition in the feature that owns the data, then render it:

```dart
final definition = ChartDefinition(
  family: ChartFamily.cartesian,
  type: ChartType.spline,
  options: const ChartOptions(
    showMarkers: true,
    enableTrackball: true,
    enableZoom: true,
    enablePinching: true,
    enablePanning: true,
  ),
  series: [
    ChartSeries(
      id: 'monthly-sales',
      name: 'Sales',
      data: const [
        ChartDataPoint(x: 'Jan', y: 120),
        ChartDataPoint(x: 'Feb', y: 145),
        ChartDataPoint(x: 'Mar', y: 132),
      ],
    ),
  ],
);

ChartRenderer(definition: definition);
```

Wrap the feature surface with `NetSalesChartsThemeAdapter.wrap` to adapt
the application Design System tokens. The reusable renderers themselves do
not depend on GetX, API clients, repositories, or NetSales domain models.

## Advanced analysis and axis context

Cartesian series support configurable trendline overlays: linear, exponential,
logarithmic, polynomial, power, and moving average. Configure moving-average
period, polynomial order, styling, tooltip/legend visibility, and forward or
backward visual projection.

Each configured primary or additional axis can display shaded plot bands or
labeled reference levels. Use `ChartPlotBandConfig.referenceLine` for a single
threshold or the regular constructor for a range.

Trendline projections are visual statistical overlays, not authoritative
NetSales financial forecasts. Horizontal Bar, StackedBar and StackedBar100
series do not accept Syncfusion trendlines; the renderer rejects that
unsupported combination explicitly.

## Live data

The host feature owns the source and its lifecycle. The renderer registers a
per-series Syncfusion controller callback and detaches only its own binding.

```dart
final liveSales = ChartLiveDataSource<ChartDataPoint>(
  initialData: const [
    ChartDataPoint(x: 1, y: 10),
    ChartDataPoint(x: 2, y: 12),
  ],
  maxDataPoints: 120,
);

// Use from a WebSocket, SSE, polling, or another stream adapter.
await liveSales.bindStream(salesStream);

// Or update manually.
liveSales.append(const ChartDataPoint(x: 3, y: 15));
liveSales.updateAt(0, const ChartDataPoint(x: 1, y: 11));
liveSales.removeAt(0);
liveSales.replaceAll(nextSnapshot);
```

The Cartesian, circular, funnel, and pyramid renderers use Syncfusion's
`onRendererCreated` callback and the matching series controller's
`updateDataSource` method. Changes are sent as added, removed, or updated
indexes rather than replacing the complete chart widget. Sources support
multiple independent chart bindings and an optional bounded data window.
Spark charts listen to every visible live source and rebuild their compact data lists. A live source may initially be empty; it transitions from the empty state to the chart when its first point arrives.

Do not mutate `liveSales.data` directly. Use the source mutation methods so
the corresponding Syncfusion controllers receive the correct change indexes.
Dispose the source from the feature/controller that created it.

## Zoom and pan controls

Pass one `ChartController` to the renderer and its card:

```dart
final chartController = ChartController();

ChartCard(
  title: 'Sales',
  chartController: chartController,
  chart: ChartRenderer(
    definition: definition,
    controller: chartController,
  ),
);
```

The card exposes reset, zoom-in, and zoom-out actions. The controller also
provides directional pan methods. Configure `ChartOptions.zoomMode` to limit
zooming to the horizontal, vertical, or both axes. Double-tap, directional,
pinch, selection, wheel, and pan gestures are separately configurable.

## Legend interaction

Set `ChartOptions.toggleSeriesVisibility` to allow users to select a legend item to show or hide its series. The default is enabled and is applied consistently to Cartesian, circular, funnel, and pyramid charts.

## Chart card, states, and data view

`ChartCard` supports:
- Header, description, badge, footer, and host-provided actions.
- Host-defined period chips and period-change callbacks.
- Loading, empty, error, offline, and stale states with retry.
- Zoom reset and controller-backed zoom actions.
- Expand and accessible data-table toggles.
- Export/share menu actions for PNG, PDF, and CSV.

The host supplies export/share callbacks so the widget layer remains decoupled
from storage, permission, and platform-specific behavior.

`ChartDataTable` adapts its columns to the point shape, including range,
financial, bubble, distribution, and waterfall subtotal/total semantics. CSV also exports the subtotal and final-total flags.

## Export and sharing

Use `NetSalesChartsExportAdapter` for PNG capture, PDF creation, CSV encoding,
saving through the existing `FileExportService`, and platform sharing.
Supply a `GlobalKey` to `ChartCard.chartBoundaryKey` for image/PDF capture.
CSV export uses UTF-8 with BOM and escapes commas, quotes, and line breaks.

## Verification

Run:

```bash
flutter analyze
flutter test test/widgets/charts
flutter test
```

CI additionally performs Android Debug source compilation and Windows Debug
compilation. The Windows check compiles the application but does not package an
APK.

## Syncfusion licensing

This project consumes the Syncfusion Flutter packages from pub.dev. Syncfusion
documents that Flutter packages from version 18.3.0.x onward do not require
runtime license-key registration. This differs from several other Syncfusion
platforms and products; do not add a .NET/JavaScript license-registration
pattern to the Flutter startup path.
