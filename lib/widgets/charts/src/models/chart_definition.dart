import 'package:flutter/foundation.dart';

import '../enums/chart_family.dart';
import '../enums/chart_state.dart';
import '../enums/chart_type.dart';
import 'chart_options.dart';
import 'chart_series.dart';

@immutable
class ChartDefinition {
  const ChartDefinition({
    required this.family,
    required this.type,
    required this.series,
    this.options = const ChartOptions(),
    this.state = ChartState.data,
    this.stateMessage,
    this.stateDetails,
  });

  final ChartFamily family;
  final ChartType type;
  final List<ChartSeries> series;
  final ChartOptions options;
  final ChartState state;
  final String? stateMessage;
  final String? stateDetails;

  bool get hasData =>
      series.any((item) => item.isVisible && item.dataSource.isNotEmpty);

  bool get hasLiveSources =>
      series.any((item) => item.isVisible && item.liveDataSource != null);

  /// Keep an empty live source mounted so Syncfusion can register its series
  /// controller before the first point is appended.
  bool get canRender => hasData || hasLiveSources;

  ChartDefinition copyWith({
    ChartFamily? family,
    ChartType? type,
    List<ChartSeries>? series,
    ChartOptions? options,
    ChartState? state,
    String? stateMessage,
    String? stateDetails,
  }) => ChartDefinition(
    family: family ?? this.family,
    type: type ?? this.type,
    series: series ?? this.series,
    options: options ?? this.options,
    state: state ?? this.state,
    stateMessage: stateMessage ?? this.stateMessage,
    stateDetails: stateDetails ?? this.stateDetails,
  );
}
