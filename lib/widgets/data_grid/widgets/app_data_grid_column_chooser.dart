import 'package:flutter/material.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_column.dart';
import 'package:netsales/widgets/menus/custom_popup_menu.dart';

/// Reusable column visibility menu. It prevents hiding the final visible column.
class AppDataGridColumnChooser<T> extends StatelessWidget {
  const AppDataGridColumnChooser({
    super.key,
    required this.columns,
    required this.onVisibilityChanged,
    this.tooltip = 'إدارة الأعمدة',
    this.triggerIcon = Icons.view_column_outlined,
  });

  final List<AppDataGridColumn<T>> columns;
  final ValueChanged<String> onVisibilityChanged;
  final String tooltip;
  final IconData triggerIcon;

  @override
  Widget build(BuildContext context) {
    final visibleCount = columns.where((column) => column.visible).length;
    return CustomPopupMenu<String>(
      tooltip: tooltip,
      triggerIcon: triggerIcon,
      items: columns
          .map(
            (column) => CustomPopupItem<String>(
              value: column.name,
              label: column.label,
              enabled: !column.visible || visibleCount > 1,
              icon: column.visible
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
            ),
          )
          .toList(growable: false),
      onSelected: onVisibilityChanged,
    );
  }
}
