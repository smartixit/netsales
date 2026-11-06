
import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class NetSalesDataGridThemeAdapter {
  const NetSalesDataGridThemeAdapter._();

  static Widget wrap({required BuildContext context, required Widget child}) {
    final colors = context.colors;
    return SfDataGridTheme(
      data: SfDataGridThemeData(
        headerColor: colors.surfaceContainerHigh,
        headerHoverColor: colors.surfaceContainerHighest,
        gridLineColor: colors.outlineVariant.withValues(alpha: 0.55),
        selectionColor: colors.primary.withValues(alpha: 0.12),
        rowHoverColor: colors.surfaceContainerLow,
        sortIconColor: colors.primary,
        filterIconColor: colors.onSurfaceVariant,
        frozenPaneLineColor: colors.outlineVariant,
        columnResizeIndicatorColor: colors.primary,
        columnDragIndicatorColor: colors.primary,
      ),
      child: child,
    );
  }
}
