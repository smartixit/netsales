import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// A shared, theme-aware surface for structured content across NetSales.
///
/// Use this instead of composing feature-local Material [Card] surfaces.
/// [onTap] is optional; when supplied the surface exposes an accessible
/// interactive hit target with the same rounded clipping as the surface.
class CustomSurfaceCard extends StatelessWidget {
  const CustomSurfaceCard({
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.radius,
    this.elevation = 0,
    this.onTap,
    this.semanticLabel,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double? radius;
  final double elevation;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveRadius = radius ?? AppRadius.card;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(effectiveRadius),
      side: borderWidth <= 0
          ? BorderSide.none
          : BorderSide(
              color: borderColor ??
                  colors.outlineVariant.withValues(alpha: 0.58),
              width: borderWidth,
            ),
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Semantics(
        container: true,
        button: onTap != null,
        label: semanticLabel,
        child: Material(
          color: backgroundColor ?? colors.surfaceContainerLow,
          elevation: elevation,
          shadowColor: Theme.of(context).colorScheme.shadow,
          shape: shape,
          clipBehavior: clipBehavior,
          child: InkWell(
            onTap: onTap,
            customBorder: shape,
            child: Padding(
              padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
