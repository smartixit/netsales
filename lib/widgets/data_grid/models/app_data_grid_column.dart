
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

typedef AppDataGridCellBuilder<T> = Widget Function(BuildContext context, T row, Object? value);
typedef AppDataGridEditorBuilder<T> = Widget Function({required T row, required Object? initialValue, required ValueChanged<Object?> onChanged, required VoidCallback onSubmit});
typedef AppDataGridValueParser = Object? Function(Object? value);
typedef AppDataGridValueValidator<T> = bool Function(T row, Object? value);

@immutable
class AppDataGridColumn<T> {
  const AppDataGridColumn({
    required this.name,
    required this.label,
    required this.valueGetter,
    this.cellBuilder,
    this.editorBuilder,
    this.parseEditedValue,
    this.validateEditedValue,
    this.width,
    this.minimumWidth,
    this.maximumWidth,
    this.columnWidthMode = ColumnWidthMode.none,
    this.visible = true,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.allowEditing = false,
    this.headerAlignment = AlignmentDirectional.centerStart,
    this.cellAlignment = AlignmentDirectional.centerStart,
  }) : assert(name != '');

  final String name;
  final String label;
  final Object? Function(T row) valueGetter;
  final AppDataGridCellBuilder<T>? cellBuilder;
  final AppDataGridEditorBuilder<T>? editorBuilder;
  final AppDataGridValueParser? parseEditedValue;
  final AppDataGridValueValidator<T>? validateEditedValue;
  final double? width;
  final double? minimumWidth;
  final double? maximumWidth;
  final ColumnWidthMode columnWidthMode;
  final bool visible;
  final bool allowSorting;
  final bool allowFiltering;
  final bool allowEditing;
  final AlignmentGeometry headerAlignment;
  final AlignmentGeometry cellAlignment;

  AppDataGridColumn<T> copyWith({String? label, bool? visible, bool? allowSorting, bool? allowFiltering, bool? allowEditing, double? width}) =>
      AppDataGridColumn<T>(
        name: name,
        label: label ?? this.label,
        valueGetter: valueGetter,
        cellBuilder: cellBuilder,
        editorBuilder: editorBuilder,
        parseEditedValue: parseEditedValue,
        validateEditedValue: validateEditedValue,
        width: width ?? this.width,
        minimumWidth: minimumWidth,
        maximumWidth: maximumWidth,
        columnWidthMode: columnWidthMode,
        visible: visible ?? this.visible,
        allowSorting: allowSorting ?? this.allowSorting,
        allowFiltering: allowFiltering ?? this.allowFiltering,
        allowEditing: allowEditing ?? this.allowEditing,
        headerAlignment: headerAlignment,
        cellAlignment: cellAlignment,
      );

  GridColumn toGridColumn(BuildContext context) {
    final theme = Theme.of(context);
    return GridColumn(
      columnName: name,
      label: Container(
        alignment: headerAlignment,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w700)),
      ),
      width: width ?? double.nan,
      minimumWidth: minimumWidth ?? double.nan,
      maximumWidth: maximumWidth ?? double.nan,
      columnWidthMode: columnWidthMode,
      visible: visible,
      allowSorting: allowSorting,
      allowFiltering: allowFiltering,
      allowEditing: allowEditing,
      filterPopupMenuOptions: const FilterPopupMenuOptions(),
    );
  }
}
