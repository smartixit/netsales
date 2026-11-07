/// Concrete Syncfusion chart types supported by the reusable chart framework.
enum ChartType {
  // Trend and time-series.
  line,
  spline,
  fastLine,
  area,
  splineArea,
  stepLine,
  stepArea,
  rangeArea,
  splineRangeArea,

  // Categorical comparison and composition.
  column,
  bar,
  stackedColumn,
  stackedBar,
  stackedArea,
  stackedLine,
  stackedColumn100,
  stackedBar100,
  stackedArea100,
  stackedLine100,
  waterfall,

  // Statistical and distribution.
  scatter,
  bubble,
  histogram,
  boxAndWhisker,
  errorBar,
  rangeColumn,

  // Financial.
  candle,
  hilo,
  ohlc,

  // Circular and stage charts.
  pie,
  doughnut,
  radialBar,
  funnel,
  pyramid,

  // Compact spark charts.
  sparkLine,
  sparkArea,
  sparkBar,
  sparkWinLoss,
}
