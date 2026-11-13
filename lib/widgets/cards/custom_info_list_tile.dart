import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';

/// Shared title/subtitle/leading/trailing row used by record and settings
/// surfaces. It keeps feature-specific data out of the global widget layer.
class CustomInfoListTile extends StatelessWidget {
  const CustomInfoListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.minHeight = 56,
    this.subtitleSpacing = 4,
    this.titleMaxLines = 2,
    this.subtitleMaxLines,
    this.semanticLabel,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double minHeight;
  final double subtitleSpacing;
  final int titleMaxLines;
  final int? subtitleMaxLines;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          AppSpacing.hSm,
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle.merge(
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
                child: title,
              ),
              if (subtitle != null) ...[
                SizedBox(height: subtitleSpacing),
                DefaultTextStyle.merge(
                  maxLines: subtitleMaxLines,
                  overflow: subtitleMaxLines == null
                      ? TextOverflow.clip
                      : TextOverflow.ellipsis,
                  child: subtitle!,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          AppSpacing.hSm,
          trailing!,
        ],
      ],
    );

    final effectivePadding = padding ??
        EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );

    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: onTap == null
            ? Padding(padding: effectivePadding, child: content)
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Padding(
                    padding: effectivePadding,
                    child: content,
                  ),
                ),
              ),
      ),
    );
  }
}
