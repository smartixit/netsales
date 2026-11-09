import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/charts/charting.dart';

import 'charts_showcase_controller.dart';

/// Seven-family visual laboratory. Uses local data only and is debug-only.
class ChartsShowcaseScreen extends GetView<ChartsShowcaseController> {
  const ChartsShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = controller.isDarkMode.value;
      final rtl = controller.isRtl.value;
      return Theme(
        data: dark ? AppThemes.dark : AppThemes.light,
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Builder(
            builder: (previewContext) => NetSalesChartsThemeAdapter.wrap(
              context: previewContext,
              child: _ChartsShowcaseContent(controller: controller),
            ),
          ),
        ),
      );
    });
  }
}

class _ChartsShowcaseContent extends StatelessWidget {
  const _ChartsShowcaseContent({required this.controller});
  final ChartsShowcaseController controller;

  static const _trend = <ChartDataPoint>[
    ChartDataPoint(x: 'يناير', y: 18),
    ChartDataPoint(x: 'فبراير', y: 25),
    ChartDataPoint(x: 'مارس', y: 21),
    ChartDataPoint(x: 'أبريل', y: 34),
    ChartDataPoint(x: 'مايو', y: 31),
    ChartDataPoint(x: 'يونيو', y: 46),
  ];
  static const _categories = <ChartDataPoint>[
    ChartDataPoint(x: 'الشبكات', y: 42),
    ChartDataPoint(x: 'نقاط البيع', y: 28),
    ChartDataPoint(x: 'المبيعات', y: 64),
    ChartDataPoint(x: 'الاشتراكات', y: 35),
  ];
  static const _financial = <ChartDataPoint>[
    ChartDataPoint(x: 'الأحد', low: 19, high: 32, open: 23, close: 29),
    ChartDataPoint(x: 'الاثنين', low: 20, high: 35, open: 29, close: 24),
    ChartDataPoint(x: 'الثلاثاء', low: 22, high: 38, open: 24, close: 34),
    ChartDataPoint(x: 'الأربعاء', low: 25, high: 39, open: 34, close: 31),
    ChartDataPoint(x: 'الخميس', low: 27, high: 43, open: 31, close: 40),
  ];
  static const _distribution = <ChartDataPoint>[
    ChartDataPoint(x: 'أ', y: 12),
    ChartDataPoint(x: 'ب', y: 18),
    ChartDataPoint(x: 'ج', y: 24),
    ChartDataPoint(x: 'د', y: 16),
    ChartDataPoint(x: 'هـ', y: 30),
  ];

  ChartDefinition _definition(
    ChartFamily family,
    ChartType type,
    List<ChartDataPoint> points, {
    ChartOptions options = const ChartOptions(),
  }) => ChartDefinition(
    family: family,
    type: type,
    options: options,
    series: [
      ChartSeries(
        id: '${family.name}-${type.name}',
        name: 'الإجمالي',
        data: points,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final liveDefinition = ChartDefinition(
      family: ChartFamily.cartesian,
      type: ChartType.spline,
      options: const ChartOptions(
        enableTrackball: true,
        enableZoom: true,
        enablePinching: true,
        enablePanning: true,
        autoScrollingDelta: 12,
      ),
      series: [
        ChartSeries(
          id: 'live-sales',
          name: 'القراءات المباشرة',
          liveDataSource: controller.liveSales,
        ),
      ],
    );

    final cards = <Widget>[
      ChartCard(
        title: '1. الاتجاهات والسلاسل الزمنية',
        description: 'Line / Spline / Area / Step وRange Area',
        height: 280,
        chart: ChartRenderer(
          definition: _definition(
            ChartFamily.cartesian,
            ChartType.spline,
            _trend,
            options: const ChartOptions(
              showMarkers: true,
              enableTrackball: true,
              enableCrosshair: true,
            ),
          ),
        ),
      ),
      ChartCard(
        title: '2. المقارنة والتوزيع',
        description: 'Column / Bar / Stacked / 100% / Waterfall',
        height: 280,
        chart: ChartRenderer(
          definition: _definition(
            ChartFamily.comparison,
            ChartType.column,
            _categories,
            options: const ChartOptions(showDataLabels: true),
          ),
        ),
      ),
      ChartCard(
        title: '3. المخططات الدائرية',
        description: 'Pie / Doughnut / Radial Bar',
        height: 280,
        chart: ChartRenderer(
          definition: _definition(
            ChartFamily.circular,
            ChartType.doughnut,
            _distribution,
            options: const ChartOptions(showDataLabels: true),
          ),
        ),
      ),
      ChartCard(
        title: '4. القمع والهرم',
        description: 'Funnel / Pyramid لمراحل التحويل',
        height: 280,
        chart: ChartRenderer(
          definition: _definition(ChartFamily.funnel, ChartType.funnel, const [
            ChartDataPoint(x: 'الزيارات', y: 100),
            ChartDataPoint(x: 'التسجيلات', y: 72),
            ChartDataPoint(x: 'الاشتراكات', y: 48),
            ChartDataPoint(x: 'العملاء النشطون', y: 31),
          ]),
        ),
      ),
      ChartCard(
        title: '5. الإحصاءات والتوزيعات',
        description: 'Scatter / Bubble / Histogram / Box & Whisker',
        height: 280,
        chart: ChartRenderer(
          definition: _definition(
            ChartFamily.statistical,
            ChartType.scatter,
            const [
              ChartDataPoint(x: 1, y: 18),
              ChartDataPoint(x: 2, y: 26),
              ChartDataPoint(x: 3, y: 21),
              ChartDataPoint(x: 4, y: 38),
              ChartDataPoint(x: 5, y: 33),
              ChartDataPoint(x: 6, y: 45),
            ],
            options: const ChartOptions(
              xAxis: ChartAxisConfig(
                kind: ChartAxisKind.numeric,
                title: 'العينة',
              ),
              enableTrackball: true,
            ),
          ),
        ),
      ),
      ChartCard(
        title: '6. المخططات المالية',
        description: 'Candlestick / OHLC / HiLo',
        height: 280,
        chart: ChartRenderer(
          definition: _definition(
            ChartFamily.financial,
            ChartType.candle,
            _financial,
          ),
        ),
      ),
      ChartCard(
        title: '7. المخططات المصغرة',
        description: 'SparkLine / SparkArea / SparkBar / Win-Loss',
        height: 150,
        chart: ChartRenderer(
          definition: _definition(
            ChartFamily.spark,
            ChartType.sparkLine,
            _trend,
            options: const ChartOptions(animate: true),
          ),
        ),
      ),
      ChartCard(
        title: 'التحديث اللحظي عبر Syncfusion',
        description: 'نقطة جديدة كل ثانيتين دون إعادة بناء الشاشة بالكامل.',
        height: 280,
        badge: const _LiveBadge(),
        chart: ChartRenderer(definition: liveDefinition),
        footer: Obx(
          () => Text(
            'عدد التحديثات: ${controller.liveTick.value} • '
            'النقاط الحالية: ${controller.liveSales.length}',
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('مختبر المخططات البيانية'),
        actions: [
          Obx(
            () => CustomButton.icon(
              tooltip: 'الوضع الداكن',
              icon: Icon(
                controller.isDarkMode.value
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () =>
                  controller.setDarkMode(!controller.isDarkMode.value),
              size: AppButtonSize.small,
              dimension: 40,
            ),
          ),
          Obx(
            () => CustomButton.icon(
              tooltip: 'اتجاه العرض',
              icon: Icon(
                controller.isRtl.value
                    ? Icons.format_textdirection_l_to_r
                    : Icons.format_textdirection_r_to_l,
              ),
              onPressed: () => controller.setRtl(!controller.isRtl.value),
              size: AppButtonSize.small,
              dimension: 40,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveContentWrapper(
          padding: EdgeInsets.symmetric(
            horizontal: AppBreakpoints.screenMargin(context),
            vertical: AppSpacing.lg,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = AppBreakpoints.columnsFor(context).clamp(1, 3);
              final gutter = AppBreakpoints.gridGutter(context);
              final itemWidth =
                  (constraints.maxWidth - (gutter * (columns - 1))) / columns;

              return Wrap(
                spacing: gutter,
                runSpacing: gutter,
                children: [
                  for (final card in cards)
                    SizedBox(width: itemWidth, child: card),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        'LIVE',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    ),
  );
}
