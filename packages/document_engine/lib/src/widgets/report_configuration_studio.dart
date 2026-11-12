import 'package:flutter/material.dart';

import '../reports/report_criteria.dart';
import '../reports/report_definition.dart';
import '../reports/report_filter_value.dart';
import '../reports/report_presentation_options.dart';

typedef ReportLabelResolver = String Function(
  BuildContext context,
  String localizationKey,
);

/// Lets the host replace package-default actions with its design-system buttons.
typedef ReportStudioActionBuilder = Widget Function(
  BuildContext context, {
  required String label,
  required IconData icon,
  required VoidCallback? onPressed,
  required bool secondary,
});

/// Lets the host replace all schema filter controls with its own design system.
typedef ReportStudioFilterSectionBuilder = Widget Function(
  BuildContext context, {
  required ReportDefinition definition,
  required ReportCriteria criteria,
  required ReportLabelResolver resolveLabel,
  required ValueChanged<ReportCriteria> onChanged,
});

/// Lets the host replace all output controls with its own design system.
typedef ReportStudioPresentationSectionBuilder = Widget Function(
  BuildContext context, {
  required ReportDefinition definition,
  required ReportPresentationOptions presentation,
  required ReportLabelResolver resolveLabel,
  required ValueChanged<ReportPresentationOptions> onChanged,
});

/// Responsive, schema-driven report configuration UI.
///
/// The widget is controlled: the host owns criteria/presentation state and
/// supplies callbacks. This keeps it independent of GetX, routing, API access,
/// preset persistence, tenant policy, and report execution.
class ReportConfigurationStudio extends StatelessWidget {
  const ReportConfigurationStudio({
    required this.definition,
    required this.criteria,
    required this.presentation,
    required this.resolveLabel,
    required this.onCriteriaChanged,
    required this.onPresentationChanged,
    this.onPreview,
    this.onSavePreset,
    this.actionBuilder,
    this.filterSectionBuilder,
    this.presentationSectionBuilder,
    this.isBusy = false,
    super.key,
  });

  final ReportDefinition definition;
  final ReportCriteria criteria;
  final ReportPresentationOptions presentation;
  final ReportLabelResolver resolveLabel;
  final ValueChanged<ReportCriteria> onCriteriaChanged;
  final ValueChanged<ReportPresentationOptions> onPresentationChanged;
  final VoidCallback? onPreview;
  final VoidCallback? onSavePreset;
  final ReportStudioActionBuilder? actionBuilder;
  final ReportStudioFilterSectionBuilder? filterSectionBuilder;
  final ReportStudioPresentationSectionBuilder? presentationSectionBuilder;
  final bool isBusy;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final colors = Theme.of(context).colorScheme;
      final wide = constraints.maxWidth >= 1080;
      final filters =
          filterSectionBuilder?.call(
            context,
            definition: definition,
            criteria: criteria,
            resolveLabel: resolveLabel,
            onChanged: onCriteriaChanged,
          ) ??
          _buildFilterSection(context);
      final output =
          presentationSectionBuilder?.call(
            context,
            definition: definition,
            presentation: presentation,
            resolveLabel: resolveLabel,
            onChanged: onPresentationChanged,
          ) ??
          _buildPresentationSection(context);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: filters),
                      const SizedBox(width: 20),
                      Expanded(flex: 5, child: output),
                    ],
                  )
                else ...[
                  filters,
                  const SizedBox(height: 16),
                  output,
                ],
                const SizedBox(height: 20),
                _buildActions(context),
                const SizedBox(height: 12),
                Text(
                  resolveLabel(
                    context,
                    'report_configuration.authorization_notice',
                  ),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resolveLabel(context, definition.titleKey),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (definition.descriptionKey != null) ...[
          const SizedBox(height: 6),
          Text(
            resolveLabel(context, definition.descriptionKey!),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoPill(
              label:
                  '${resolveLabel(context, 'report_configuration.schema_version')} ${definition.schemaVersion}',
            ),
            _InfoPill(
              label: resolveLabel(
                context,
                'report_configuration.${definition.executionPolicy.name}_execution',
              ),
            ),
            if (definition.clientRowLimit != null)
              _InfoPill(
                label:
                    '${resolveLabel(context, 'report_configuration.client_limit')} ${definition.clientRowLimit}',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return _SectionCard(
      title: resolveLabel(context, 'report_configuration.data_criteria'),
      subtitle: resolveLabel(
        context,
        'report_configuration.data_criteria_hint',
      ),
      icon: Icons.filter_alt_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final filter in definition.filters) ...[
            _buildFilterControl(context, filter),
            const SizedBox(height: 14),
          ],
          if (definition.filters.isEmpty)
            _EmptyHint(
              text: resolveLabel(context, 'report_configuration.no_filters'),
            ),
          _ValidationSummary(
            issues: criteria
                .validateAgainst(definition)
                .map((issue) => '${issue.code}: ${issue.fieldId}')
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControl(
    BuildContext context,
    ReportFilterDefinition filter,
  ) {
    final current = criteria.filters[filter.id];
    final label = resolveLabel(context, filter.labelKey);
    final requiredLabel = filter.required
        ? ' · ${resolveLabel(context, 'common.required')}'
        : '';

    switch (filter.kind) {
      case ReportFilterKind.text:
        return _textField(
          key: ValueKey('report-filter-${filter.id}'),
          label: '$label$requiredLabel',
          initialValue: current is ReportTextFilterValue ? current.value : '',
          onChanged: (value) => _setFilter(
            filter.id,
            value.isEmpty ? null : ReportTextFilterValue(value),
          ),
        );
      case ReportFilterKind.integer:
        return _textField(
          key: ValueKey('report-filter-${filter.id}'),
          label: '$label$requiredLabel',
          initialValue: current is ReportIntegerFilterValue
              ? current.value.toString()
              : '',
          keyboardType: TextInputType.number,
          onChanged: (value) => _setFilter(
            filter.id,
            value.isEmpty
                ? null
                : (int.tryParse(value) == null
                      ? null
                      : ReportIntegerFilterValue(int.parse(value))),
          ),
        );
      case ReportFilterKind.decimal:
        return _textField(
          key: ValueKey('report-filter-${filter.id}'),
          label: '$label$requiredLabel',
          initialValue: current is ReportDecimalFilterValue
              ? current.value
              : '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            ReportFilterValue? next;
            if (value.isNotEmpty) {
              try {
                next = ReportDecimalFilterValue(value);
              } on ArgumentError {
                next = null;
              }
            }
            _setFilter(filter.id, next);
          },
        );
      case ReportFilterKind.date:
        return _textField(
          key: ValueKey('report-filter-${filter.id}'),
          label: '$label · YYYY-MM-DD',
          initialValue: current is ReportDateFilterValue
              ? _dateText(current.value)
              : '',
          onChanged: (value) => _setFilter(
            filter.id,
            value.isEmpty
                ? null
                : (DateTime.tryParse(value) == null
                      ? null
                      : ReportDateFilterValue(DateTime.parse(value))),
          ),
        );
      case ReportFilterKind.dateRange:
        final range = current is ReportDateRangeFilterValue ? current : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    key: ValueKey('report-filter-${filter.id}-start'),
                    label: resolveLabel(
                      context,
                      'report_configuration.from_date',
                    ),
                    initialValue: range?.start == null
                        ? ''
                        : _dateText(range!.start!),
                    onChanged: (value) => _updateDateRange(
                      filter.id,
                      value,
                      range?.end == null ? null : _dateText(range!.end!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _textField(
                    key: ValueKey('report-filter-${filter.id}-end'),
                    label: resolveLabel(
                      context,
                      'report_configuration.to_date',
                    ),
                    initialValue: range?.end == null
                        ? ''
                        : _dateText(range!.end!),
                    onChanged: (value) => _updateDateRange(
                      filter.id,
                      range?.start == null ? null : _dateText(range!.start!),
                      value,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case ReportFilterKind.boolean:
        return Material(
          type: MaterialType.transparency,
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text('$label$requiredLabel'),
            value: current is ReportBooleanFilterValue && current.value,
            onChanged: (value) =>
                _setFilter(filter.id, ReportBooleanFilterValue(value)),
          ),
        );
      case ReportFilterKind.singleChoice:
        return DropdownButtonFormField<String>(
          key: ValueKey('report-filter-${filter.id}'),
          initialValue: current is ReportChoiceFilterValue
              ? current.value
              : null,
          decoration: InputDecoration(
            labelText: '$label$requiredLabel',
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final option in filter.choices)
              DropdownMenuItem(
                value: option.value,
                child: Text(resolveLabel(context, option.labelKey)),
              ),
          ],
          onChanged: (value) => _setFilter(
            filter.id,
            value == null ? null : ReportChoiceFilterValue(value),
          ),
        );
      case ReportFilterKind.multiChoice:
        final selected = current is ReportChoicesFilterValue
            ? current.values.toSet()
            : <String>{};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label$requiredLabel',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final option in filter.choices)
                  FilterChip(
                    label: Text(resolveLabel(context, option.labelKey)),
                    selected: selected.contains(option.value),
                    onSelected: (checked) {
                      final next = {...selected};
                      if (checked) {
                        next.add(option.value);
                      } else {
                        next.remove(option.value);
                      }
                      _setFilter(
                        filter.id,
                        next.isEmpty
                            ? null
                            : ReportChoicesFilterValue(next.toList()..sort()),
                      );
                    },
                  ),
              ],
            ),
          ],
        );
    }
  }

  Widget _textField({
    required Key key,
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
  }) => TextFormField(
    key: key,
    initialValue: initialValue,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    onChanged: onChanged,
  );

  void _updateDateRange(String id, String? startText, String? endText) {
    final normalizedStart = startText?.trim() ?? '';
    final normalizedEnd = endText?.trim() ?? '';
    final start = normalizedStart.isEmpty
        ? null
        : DateTime.tryParse(normalizedStart);
    final end = normalizedEnd.isEmpty ? null : DateTime.tryParse(normalizedEnd);

    // Keep the last valid selection while the user is midway through typing.
    if ((normalizedStart.isNotEmpty && start == null) ||
        (normalizedEnd.isNotEmpty && end == null)) {
      return;
    }
    if (start == null && end == null) {
      _setFilter(id, null);
      return;
    }
    if (start != null && end != null && end.isBefore(start)) {
      return;
    }

    _setFilter(id, ReportDateRangeFilterValue(start: start, end: end));
  }

  Widget _buildPresentationSection(BuildContext context) {
    final visible = presentation.visibleColumnIds.isEmpty
        ? definition.columns
              .where((column) => column.visibleByDefault)
              .map((column) => column.id)
              .toList(growable: false)
        : presentation.visibleColumnIds;

    return _SectionCard(
      title: resolveLabel(context, 'report_configuration.output_design'),
      subtitle: resolveLabel(
        context,
        'report_configuration.output_design_hint',
      ),
      icon: Icons.tune_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            resolveLabel(context, 'report_configuration.output_columns'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          for (final column in definition.columns)
            Material(
              type: MaterialType.transparency,
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(resolveLabel(context, column.labelKey)),
                value: visible.contains(column.id),
                onChanged: column.hideable
                    ? (checked) {
                        final next = visible.toSet();
                        if (checked == true) {
                          next.add(column.id);
                        } else if (next.length > 1) {
                          next.remove(column.id);
                        }
                        _updatePresentation(
                          visibleColumnIds: next.toList(growable: false),
                        );
                      }
                    : null,
              ),
            ),
          const SizedBox(height: 12),
          _buildSortControls(context),
          const SizedBox(height: 12),
          _buildGroupControl(context),
          const SizedBox(height: 12),
          _buildTemplateControl(context),
          const SizedBox(height: 12),
          _buildLocaleControl(context),
          const SizedBox(height: 12),
          _buildPageProfileControl(context),
          if (definition.metricSlots.isNotEmpty)
            Material(
              type: MaterialType.transparency,
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  resolveLabel(context, 'report_configuration.include_metrics'),
                ),
                value: presentation.includeMetrics,
                onChanged: (value) =>
                    _updatePresentation(includeMetrics: value),
              ),
            ),
          if (definition.chartsAvailable)
            Material(
              type: MaterialType.transparency,
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  resolveLabel(context, 'report_configuration.include_charts'),
                ),
                value: presentation.includeCharts,
                onChanged: (value) => _updatePresentation(includeCharts: value),
              ),
            ),
          _ValidationSummary(
            issues: presentation
                .validateAgainst(definition)
                .map((issue) => '${issue.code}: ${issue.fieldId}')
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildSortControls(BuildContext context) {
    final sortable = definition.columns
        .where((column) => column.sortable)
        .toList();
    if (sortable.isEmpty) return const SizedBox.shrink();
    final selected = presentation.sorts.isEmpty
        ? null
        : presentation.sorts.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: const ValueKey('report-sort-field'),
          initialValue: sortable.any((item) => item.id == selected?.fieldId)
              ? selected?.fieldId
              : null,
          decoration: InputDecoration(
            labelText: resolveLabel(context, 'report_configuration.sort_by'),
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final column in sortable)
              DropdownMenuItem(
                value: column.id,
                child: Text(resolveLabel(context, column.labelKey)),
              ),
          ],
          onChanged: (id) => _updatePresentation(
            sorts: id == null
                ? const []
                : [
                    ReportSortOption(
                      fieldId: id,
                      direction:
                          selected?.direction ?? ReportSortDirection.ascending,
                    ),
                  ],
          ),
        ),
        if (selected != null) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<ReportSortDirection>(
            key: const ValueKey('report-sort-direction'),
            initialValue: selected.direction,
            decoration: InputDecoration(
              labelText: resolveLabel(
                context,
                'report_configuration.sort_direction',
              ),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: ReportSortDirection.ascending,
                child: Text(
                  resolveLabel(context, 'report_configuration.ascending'),
                ),
              ),
              DropdownMenuItem(
                value: ReportSortDirection.descending,
                child: Text(
                  resolveLabel(context, 'report_configuration.descending'),
                ),
              ),
            ],
            onChanged: (direction) {
              if (direction == null) return;
              _updatePresentation(
                sorts: [
                  ReportSortOption(
                    fieldId: selected.fieldId,
                    direction: direction,
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildGroupControl(BuildContext context) {
    final groupable = definition.columns.where((column) => column.groupable);
    if (groupable.isEmpty) return const SizedBox.shrink();
    return DropdownButtonFormField<String>(
      key: const ValueKey('report-group-field'),
      initialValue:
          groupable.any((item) => item.id == presentation.groupByFieldId)
          ? presentation.groupByFieldId
          : '',
      decoration: InputDecoration(
        labelText: resolveLabel(context, 'report_configuration.group_by'),
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text(
            resolveLabel(context, 'report_configuration.no_grouping'),
          ),
        ),
        for (final column in groupable)
          DropdownMenuItem(
            value: column.id,
            child: Text(resolveLabel(context, column.labelKey)),
          ),
      ],
      onChanged: (id) => _updatePresentation(
        groupByFieldId: id,
        clearGroup: id == null || id.isEmpty,
      ),
    );
  }

  Widget _buildTemplateControl(BuildContext context) {
    if (definition.templates.isEmpty) return const SizedBox.shrink();
    final currentKey = presentation.template?.reference.key;
    final hasCurrent = definition.templates.any(
      (item) => item.key == currentKey,
    );
    return DropdownButtonFormField<String>(
      key: const ValueKey('report-template'),
      initialValue: hasCurrent ? currentKey : null,
      decoration: InputDecoration(
        labelText: resolveLabel(context, 'report_configuration.template'),
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final item in definition.templates)
          DropdownMenuItem(value: item.key, child: Text(item.key)),
      ],
      onChanged: (key) {
        if (key == null) return;
        final item = definition.templates.singleWhere(
          (value) => value.key == key,
        );
        _updatePresentation(
          template: ReportTemplateSelection(id: item.id, version: item.version),
          clearTemplate: false,
        );
      },
    );
  }

  Widget _buildLocaleControl(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: const ValueKey('report-language'),
      initialValue:
          presentation.languageTag != null &&
              definition.supportsLocale(presentation.languageTag!)
          ? presentation.languageTag
          : definition.supportedLocaleTags.first,
      decoration: InputDecoration(
        labelText: resolveLabel(context, 'report_configuration.language'),
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final tag in definition.supportedLocaleTags)
          DropdownMenuItem(value: tag, child: Text(tag)),
      ],
      onChanged: (tag) => _updatePresentation(languageTag: tag),
    );
  }

  Widget _buildPageProfileControl(BuildContext context) {
    if (definition.pageProfileIds.isEmpty) return const SizedBox.shrink();
    return DropdownButtonFormField<String>(
      key: const ValueKey('report-page-profile'),
      initialValue:
          definition.pageProfileIds.contains(presentation.pageProfileId)
          ? presentation.pageProfileId
          : definition.pageProfileIds.first,
      decoration: InputDecoration(
        labelText: resolveLabel(context, 'report_configuration.page_profile'),
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final id in definition.pageProfileIds)
          DropdownMenuItem(value: id, child: Text(id)),
      ],
      onChanged: (id) => _updatePresentation(pageProfileId: id),
    );
  }

  void _setFilter(String id, ReportFilterValue? value) {
    final next = Map<String, ReportFilterValue>.of(criteria.filters);
    if (value == null) {
      next.remove(id);
    } else {
      next[id] = value;
    }
    onCriteriaChanged(ReportCriteria(filters: next));
  }

  void _updatePresentation({
    List<String>? visibleColumnIds,
    List<ReportSortOption>? sorts,
    String? groupByFieldId,
    bool clearGroup = false,
    ReportTemplateSelection? template,
    bool clearTemplate = false,
    String? languageTag,
    String? pageProfileId,
    bool? includeMetrics,
    bool? includeCharts,
  }) {
    onPresentationChanged(
      ReportPresentationOptions(
        visibleColumnIds: visibleColumnIds ?? presentation.visibleColumnIds,
        sorts: sorts ?? presentation.sorts,
        groupByFieldId: clearGroup
            ? null
            : groupByFieldId ?? presentation.groupByFieldId,
        template: clearTemplate ? null : template ?? presentation.template,
        languageTag: languageTag ?? presentation.languageTag,
        pageProfileId: pageProfileId ?? presentation.pageProfileId,
        includeMetrics: includeMetrics ?? presentation.includeMetrics,
        includeCharts: includeCharts ?? presentation.includeCharts,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    Widget buildAction({
      required String label,
      required IconData icon,
      required VoidCallback? onPressed,
      bool secondary = false,
    }) {
      final hostBuilder = actionBuilder;
      if (hostBuilder != null) {
        return hostBuilder(
          context,
          label: label,
          icon: icon,
          onPressed: onPressed,
          secondary: secondary,
        );
      }
      return _StudioAction(
        label: label,
        icon: icon,
        onPressed: onPressed,
        secondary: secondary,
      );
    }

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      runSpacing: 8,
      children: [
        if (onSavePreset != null)
          buildAction(
            label: resolveLabel(context, 'report_configuration.save_preset'),
            icon: Icons.bookmark_add_outlined,
            onPressed: isBusy ? null : onSavePreset,
            secondary: true,
          ),
        if (onPreview != null)
          buildAction(
            label: resolveLabel(context, 'report_configuration.preview'),
            icon: Icons.picture_as_pdf_outlined,
            onPressed: isBusy ? null : onPreview,
          ),
      ],
    );
  }

  static String _dateText(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _ValidationSummary extends StatelessWidget {
  const _ValidationSummary({required this.issues});
  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer
            .withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final issue in issues)
              Text(issue, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class _StudioAction extends StatelessWidget {
  const _StudioAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.secondary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    return Material(
      color: secondary ? colors.surfaceContainerHighest : colors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: secondary ? colors.onSurface : colors.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: secondary ? colors.onSurface : colors.onPrimary,
                ),
              ),
              if (!enabled) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: secondary ? colors.onSurface : colors.onPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
