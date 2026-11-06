import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/widgets/dashboard_metrics/adapters/netsales_dashboard_metrics_theme_adapter.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

import 'dashboard_metrics_showcase_controller.dart';

/// Developer-only visual laboratory for the reusable KPI component system.
///
/// The screen uses local sample data only. It does not call repositories,
/// services, APIs, or mutate the application's persisted theme preference.
class DashboardMetricsShowcaseScreen
    extends GetView<DashboardMetricsShowcaseController> {
  const DashboardMetricsShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = controller.isDarkMode.value;
      final isRtl = controller.isRtl.value;

      return Theme(
        data: isDarkMode ? AppThemes.dark : AppThemes.light,
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Builder(
            builder: (previewContext) {
              return NetSalesDashboardMetricsThemeAdapter.wrap(
                context: previewContext,
                child: _DashboardMetricsShowcaseContent(
                  controller: controller,
                  isDarkMode: isDarkMode,
                  isRtl: isRtl,
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class _DashboardMetricsShowcaseContent extends StatelessWidget {
  const _DashboardMetricsShowcaseContent({
    required this.controller,
    required this.isDarkMode,
    required this.isRtl,
  });

  final DashboardMetricsShowcaseController controller;
  final bool isDarkMode;
  final bool isRtl;

  static final List<DashboardMetricData> _metricExamples = [
    DashboardMetricData(
      id: 'active-networks',
      title: 'إجمالي الشبكات',
      value: '1,284',
      description: 'الشبكات المسجلة والنشطة على المنصة',
      variant: DashboardMetricVariant.standard,
      tone: DashboardMetricTone.primary,
      icon: Icons.hub_outlined,
      source: DashboardMetricSource(
        label: 'خدمة المنصة',
        updatedAtLabel: 'قبل دقيقتين',
        freshnessLabel: 'محدّث',
        freshness: DashboardMetricFreshness.fresh,
      ),
    ),
    DashboardMetricData(
      id: 'pending-operations',
      title: 'عمليات قيد المعالجة',
      value: '18',
      description: 'عمليات تنتظر استكمال الإجراء',
      variant: DashboardMetricVariant.standard,
      tone: DashboardMetricTone.warning,
      icon: Icons.pending_actions_rounded,
      source: DashboardMetricSource(
        label: 'مركز العمليات',
        updatedAtLabel: 'قبل 5 دقائق',
        freshnessLabel: 'محدّث',
        freshness: DashboardMetricFreshness.fresh,
      ),
    ),
    DashboardMetricData(
      id: 'response-time',
      title: 'متوسط زمن الاستجابة',
      value: '248',
      unit: 'مللي ثانية',
      description: 'زمن أقل يعني استجابة أسرع',
      variant: DashboardMetricVariant.trend,
      tone: DashboardMetricTone.success,
      icon: Icons.speed_rounded,
      trend: DashboardMetricTrend(
        direction: DashboardMetricDirection.decrease,
        tone: DashboardMetricTone.success,
        valueLabel: '−18.6%',
        comparisonLabel: 'مقارنة بالفترة السابقة',
        description: 'تحسّن',
      ),
      sparkline: [0.82, 0.78, 0.70, 0.74, 0.58, 0.48, 0.38],
      source: DashboardMetricSource(
        label: 'مراقبة الأداء',
        updatedAtLabel: 'قبل دقيقة',
        freshnessLabel: 'مباشر',
        freshness: DashboardMetricFreshness.fresh,
      ),
    ),
    DashboardMetricData(
      id: 'late-payments',
      title: 'نسبة المتأخرات',
      value: '8.4%',
      description: 'من إجمالي المستحقات المفتوحة',
      variant: DashboardMetricVariant.trend,
      tone: DashboardMetricTone.danger,
      icon: Icons.warning_amber_rounded,
      trend: DashboardMetricTrend(
        direction: DashboardMetricDirection.increase,
        tone: DashboardMetricTone.danger,
        valueLabel: '+2.1%',
        comparisonLabel: 'مقارنة بالفترة السابقة',
        description: 'ارتفاع يحتاج متابعة',
      ),
      sparkline: [0.24, 0.31, 0.28, 0.42, 0.55, 0.62, 0.78],
      source: DashboardMetricSource(
        label: 'ملخص التحصيل',
        updatedAtLabel: 'اليوم 10:30',
        freshnessLabel: 'محدّث',
        freshness: DashboardMetricFreshness.fresh,
      ),
    ),
    DashboardMetricData(
      id: 'service-availability',
      title: 'استقرار الخدمة',
      value: '99.92%',
      description: 'معدل إتاحة الخدمات خلال 30 يومًا',
      variant: DashboardMetricVariant.status,
      tone: DashboardMetricTone.success,
      icon: Icons.verified_user_outlined,
      statusLabel: 'مستقرة وتعمل بصورة طبيعية',
      source: DashboardMetricSource(
        label: 'مراقب الخدمة',
        updatedAtLabel: 'قبل 30 ثانية',
        freshnessLabel: 'مباشر',
        freshness: DashboardMetricFreshness.fresh,
      ),
    ),
    DashboardMetricData(
      id: 'data-sync',
      title: 'آخر مزامنة للبيانات',
      value: '12',
      unit: 'دقيقة',
      description: 'الفاصل منذ آخر تحديث مؤكد',
      variant: DashboardMetricVariant.status,
      tone: DashboardMetricTone.warning,
      icon: Icons.sync_problem_rounded,
      statusLabel: 'تأخر التحديث — يحتاج مراجعة',
      source: DashboardMetricSource(
        label: 'خدمة المزامنة',
        updatedAtLabel: 'قبل 12 دقيقة',
        freshnessLabel: 'متأخر',
        freshness: DashboardMetricFreshness.stale,
      ),
    ),
    DashboardMetricData(
      id: 'daily-sales-target',
      title: 'المبيعات اليومية',
      value: '72%',
      description: 'نسبة الإنجاز من المستهدف اليومي',
      variant: DashboardMetricVariant.target,
      tone: DashboardMetricTone.info,
      icon: Icons.track_changes_rounded,
      target: DashboardMetricTarget(
        progress: 0.72,
        currentLabel: '72%',
        targetLabel: '100%',
        label: 'تحقيق المستهدف',
        thresholds: [
          DashboardMetricThreshold(
            position: 0.5,
            label: 'نقطة التنبيه',
            tone: DashboardMetricTone.warning,
          ),
          DashboardMetricThreshold(
            position: 0.85,
            label: 'نطاق الإنجاز المرتفع',
            tone: DashboardMetricTone.success,
          ),
        ],
      ),
      source: DashboardMetricSource(
        label: 'ملخص المبيعات',
        updatedAtLabel: 'اليوم 11:00',
        freshnessLabel: 'محدّث',
        freshness: DashboardMetricFreshness.fresh,
      ),
    ),
    DashboardMetricData(
      id: 'collection-target',
      title: 'تحصيل المستحقات',
      value: '48%',
      description: 'نسبة التحصيل من إجمالي المستهدف',
      variant: DashboardMetricVariant.target,
      tone: DashboardMetricTone.danger,
      icon: Icons.account_balance_wallet_outlined,
      target: DashboardMetricTarget(
        progress: 0.48,
        currentLabel: '48%',
        targetLabel: '100%',
        label: 'نسبة التحصيل',
        thresholds: [
          DashboardMetricThreshold(
            position: 0.6,
            label: 'الحد الأدنى المقبول',
            tone: DashboardMetricTone.warning,
          ),
          DashboardMetricThreshold(
            position: 0.9,
            label: 'المستهدف',
            tone: DashboardMetricTone.success,
          ),
        ],
      ),
      source: DashboardMetricSource(
        label: 'ملخص الحسابات',
        updatedAtLabel: 'اليوم 09:45',
        freshnessLabel: 'محدّث',
        freshness: DashboardMetricFreshness.fresh,
      ),
    ),
  ];

  static final DashboardMetricData _stateMetric = DashboardMetricData(
    id: 'state-preview',
    title: 'طلبات التوريد',
    value: '248',
    description: 'هذا المؤشر مخصص لمعاينة حالات العرض',
    variant: DashboardMetricVariant.standard,
    tone: DashboardMetricTone.primary,
    icon: Icons.inventory_2_outlined,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final directionLabel = isRtl ? 'RTL' : 'LTR';
    final themeLabel = isDarkMode ? 'Dark' : 'Light';

    return Scaffold(
      appBar: AppBar(
        title: const Text('معرض مؤشرات الأداء'),
        actions: [
          Tooltip(
            message: 'إعادة ضبط المعاينة',
            child: IconButton(
              onPressed: controller.reset,
              icon: const Icon(Icons.restart_alt_rounded),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, _) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.maxContentWidth,
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                        vertical: AppSpacing.xl,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _ShowcaseHeroCard(
                            themeLabel: themeLabel,
                            directionLabel: directionLabel,
                          ),
                          SizedBox(height: AppSpacing.xl),
                          _PreviewControlsPanel(
                            controller: controller,
                            isDarkMode: isDarkMode,
                            isRtl: isRtl,
                          ),
                          SizedBox(height: AppSpacing.xxl),
                          _VariantShowcaseSection(
                            eyebrow: 'VARIANT 01 / STANDARD',
                            title: 'القيمة الأساسية',
                            description:
                                'قيمة واضحة مع وصف وسياق ومصدر تحديث، دون افتراض معنى إيجابي أو سلبي للرقم.',
                            icon: Icons.numbers_rounded,
                            metrics: _metricExamples
                                .where((metric) =>
                                    metric.variant == DashboardMetricVariant.standard)
                                .toList(growable: false),
                          ),
                          SizedBox(height: AppSpacing.xl),
                          _VariantShowcaseSection(
                            eyebrow: 'VARIANT 02 / TREND',
                            title: 'الاتجاه والتغير',
                            description:
                                'عرض اتجاه التغير وتفسيره الدلالي مع سجل مصغر؛ الانخفاض قد يكون جيدًا والارتفاع قد يكون خطرًا.',
                            icon: Icons.trending_up_rounded,
                            metrics: _metricExamples
                                .where((metric) =>
                                    metric.variant == DashboardMetricVariant.trend)
                                .toList(growable: false),
                          ),
                          SizedBox(height: AppSpacing.xl),
                          _VariantShowcaseSection(
                            eyebrow: 'VARIANT 03 / STATUS',
                            title: 'الحالة التشغيلية',
                            description:
                                'إبراز الحالة الحالية بلون دلالي ورسالة واضحة وحالة حداثة مصدر البيانات.',
                            icon: Icons.monitor_heart_outlined,
                            metrics: _metricExamples
                                .where((metric) =>
                                    metric.variant == DashboardMetricVariant.status)
                                .toList(growable: false),
                          ),
                          SizedBox(height: AppSpacing.xl),
                          _VariantShowcaseSection(
                            eyebrow: 'VARIANT 04 / TARGET',
                            title: 'الهدف والحدود',
                            description:
                                'تقدم وحدود مرئية؛ جميع النسب والمواضع والتفسيرات تأتي جاهزة من المضيف.',
                            icon: Icons.track_changes_rounded,
                            metrics: _metricExamples
                                .where((metric) =>
                                    metric.variant == DashboardMetricVariant.target)
                                .toList(growable: false),
                          ),
                          SizedBox(height: AppSpacing.xxl),
                          const _SectionHeading(
                            eyebrow: 'SEMANTIC LANGUAGE',
                            title: 'الألوان والدلالات',
                            description:
                                'اللون يعبّر عن تفسير المؤشر الذي يحدده مصدر البيانات، وليس عن اتجاه الزيادة أو النقصان وحده.',
                            icon: Icons.palette_outlined,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          const _SemanticToneLegend(),
                          SizedBox(height: AppSpacing.xxl),
                          const _SectionHeading(
                            eyebrow: 'COMPONENT STATES',
                            title: 'حالات المكوّن',
                            description:
                                'معاينة التحميل والفراغ والخطأ، بما في ذلك رسالة إعادة المحاولة.',
                            icon: Icons.layers_outlined,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          _StatePreviewGrid(metric: _stateMetric),
                          SizedBox(height: AppSpacing.xxl),
                          _PreviewNotes(
                            themeLabel: themeLabel,
                            directionLabel: directionLabel,
                          ),
                          SizedBox(height: AppSpacing.xxl),
                          Center(
                            child: Text(
                              'NetSales • Dashboard Metrics',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShowcaseHeroCard extends StatelessWidget {
  const _ShowcaseHeroCard({
    required this.themeLabel,
    required this.directionLabel,
  });

  final String themeLabel;
  final String directionLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // The dark palette's primary gradient is light; use the corresponding dark on-color.
    final foreground = isDark ? colors.onPrimaryFixed : colors.onPrimary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.primaryGradient,
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppElevation.level2(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, color: foreground, size: 22),
              const SizedBox(width: 8),
              Text(
                'COMPONENT LAB  /  KPI SYSTEM',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              _HeroPill(
                label: 'معاينة تطوير',
                foreground: foreground,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'مؤشرات الأداء،\nبمعناها الكامل.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              'مساحة مخصصة لتقييم مظهر بطاقات KPI وسلوكها قبل اعتمادها في شاشات NetSales التشغيلية والمالية.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foreground.withValues(alpha: 0.92),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroPill(label: '4 أنواع', foreground: foreground),
              _HeroPill(label: '6 دلالات لونية', foreground: foreground),
              _HeroPill(label: themeLabel, foreground: foreground),
              _HeroPill(label: directionLabel, foreground: foreground),
              _HeroPill(
                label: 'بيانات محلية تجريبية',
                foreground: foreground,
                icon: Icons.science_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.13),
        borderRadius: AppRadius.fullRadius,
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewControlsPanel extends StatelessWidget {
  const _PreviewControlsPanel({
    required this.controller,
    required this.isDarkMode,
    required this.isRtl,
  });

  final DashboardMetricsShowcaseController controller;
  final bool isDarkMode;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: colors.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'إعدادات المعاينة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: controller.reset,
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: const Text('إعادة الضبط'),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xxl,
            runSpacing: AppSpacing.lg,
            children: [
              _PreviewChoiceGroup(
                title: 'المظهر',
                options: [
                  _PreviewChoice(
                    label: 'فاتح',
                    icon: Icons.light_mode_outlined,
                    selected: !isDarkMode,
                    onSelected: () => controller.setDarkMode(false),
                  ),
                  _PreviewChoice(
                    label: 'داكن',
                    icon: Icons.dark_mode_outlined,
                    selected: isDarkMode,
                    onSelected: () => controller.setDarkMode(true),
                  ),
                ],
              ),
              _PreviewChoiceGroup(
                title: 'اتجاه الواجهة',
                options: [
                  _PreviewChoice(
                    label: 'من اليسار لليمين · LTR',
                    icon: Icons.format_textdirection_l_to_r,
                    selected: !isRtl,
                    onSelected: () => controller.setRtl(false),
                  ),
                  _PreviewChoice(
                    label: 'من اليمين لليسار · RTL',
                    icon: Icons.format_textdirection_r_to_l,
                    selected: isRtl,
                    onSelected: () => controller.setRtl(true),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'التغيير محلي داخل شاشة المعرض فقط، ولا يغيّر إعداد المظهر المحفوظ للتطبيق.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewChoiceGroup extends StatelessWidget {
  const _PreviewChoiceGroup({
    required this.title,
    required this.options,
  });

  final String title;
  final List<_PreviewChoice> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                avatar: Icon(option.icon, size: 17),
                label: Text(option.label),
                selected: option.selected,
                onSelected: (_) => option.onSelected(),
              ),
          ],
        ),
      ],
    );
  }
}

class _PreviewChoice {
  const _PreviewChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;
}

class _VariantShowcaseSection extends StatelessWidget {
  const _VariantShowcaseSection({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.metrics,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final List<DashboardMetricData> metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          eyebrow: eyebrow,
          title: title,
          description: description,
          icon: icon,
        ),
        SizedBox(height: AppSpacing.lg),
        DashboardMetricGrid(
          metrics: metrics,
          minimumCardWidth: 248,
          maximumColumns: 4,
          spacing: AppSpacing.gridSpacing,
          runSpacing: AppSpacing.gridSpacing,
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: AppRadius.mdRadius,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: colors.primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 3),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 3),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SemanticToneLegend extends StatelessWidget {
  const _SemanticToneLegend();

  static const Map<DashboardMetricTone, String> _labels = {
    DashboardMetricTone.primary: 'أساسي',
    DashboardMetricTone.success: 'نجاح',
    DashboardMetricTone.warning: 'تحذير',
    DashboardMetricTone.danger: 'خطر',
    DashboardMetricTone.info: 'معلومات',
    DashboardMetricTone.neutral: 'محايد',
  };

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardMetricsTheme.of(context);
    final colors = context.colors;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final tone in DashboardMetricTone.values)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: AppRadius.fullRadius,
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: tokens.colorFor(tone),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _labels[tone]!,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatePreviewGrid extends StatelessWidget {
  const _StatePreviewGrid({required this.metric});

  final DashboardMetricData metric;

  @override
  Widget build(BuildContext context) {
    final gap = AppSpacing.gridSpacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 960 ? 3 : width >= 620 ? 2 : 1;
        final itemWidth = (width - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: itemWidth,
              child: DashboardMetricCard(
                metric: metric,
                state: DashboardMetricState.loading,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: DashboardMetricCard(
                metric: metric,
                state: DashboardMetricState.empty,
                emptyMessage: 'لا توجد بيانات للفترة المحددة',
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: DashboardMetricCard(
                metric: metric,
                state: DashboardMetricState.error,
                errorMessage: 'تعذر تحميل المؤشر — مثال توضيحي',
                retryLabel: 'إعادة المحاولة',
                onRetry: _showRetryPreview,
              ),
            ),
          ],
        );
      },
    );
  }

  static void _showRetryPreview() {
    // Deliberately local: the showcase has no data source to retry.
  }
}

class _PreviewNotes extends StatelessWidget {
  const _PreviewNotes({
    required this.themeLabel,
    required this.directionLabel,
  });

  final String themeLabel;
  final String directionLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حدود المعاينة',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'المعروض بيانات تجريبية ثابتة، وليس أرقامًا فعلية من NetSales. '
                  'المعاينة الحالية: $themeLabel / $directionLabel. '
                  'لا تُنفذ الشاشة حسابات مالية أو تجارية ولا تتصل بالـ API.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
