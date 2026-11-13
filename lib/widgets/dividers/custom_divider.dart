import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';

enum CustomDividerAxis { horizontal, vertical }

/// Theme-aware divider for separating related content in shared surfaces.
class CustomDivider extends StatelessWidget {
  const CustomDivider({
    this.axis = CustomDividerAxis.horizontal,
    this.thickness = 1,
    this.extent,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
    super.key,
  });

  final CustomDividerAxis axis;
  final double thickness;
  final double? extent;
  final double indent;
  final double endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        color ?? context.colors.outlineVariant.withValues(alpha: 0.65);

    if (axis == CustomDividerAxis.vertical) {
      return SizedBox(
        width: extent ?? AppSpacing.xs,
        child: Center(
          child: Container(
            width: thickness,
            margin: EdgeInsetsDirectional.only(
              top: indent,
              bottom: endIndent,
            ),
            decoration: BoxDecoration(color: dividerColor),
          ),
        ),
      );
    }

    return SizedBox(
      height: extent ?? AppSpacing.xs,
      child: Center(
        child: Container(
          height: thickness,
          margin: EdgeInsetsDirectional.only(
            start: indent,
            end: endIndent,
          ),
          decoration: BoxDecoration(color: dividerColor),
        ),
      ),
    );
  }
}
