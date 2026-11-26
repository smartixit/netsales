import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// شريط أزرار الإجراءات التفاعلية الموحد أسفل شاشات التفاصيل (CustomDocumentActionBar)
///
/// المرجع المعتمد للشريط الثابت أسفل شاشات التفاصيل:
/// - حماية كاملة عبر [SafeArea].
/// - تقييد العرض الأقصى للمحتوى [maxWidth] وتوسيطه تلقائياً على الشاشات الواسعة.
/// - إطار علوي دقيق مع خلفية سطحية وظلال علوية ناعمة.
/// - مرونة تامة في استقبال قائمة أزرار أو ويدجيت مخصص.
class CustomDocumentActionBar extends StatelessWidget {
  const CustomDocumentActionBar({
    super.key,
    this.child,
    this.actions,
    this.padding,
    this.maxWidth = 760,
  }) : assert(
         child != null || actions != null,
         'يجب تمرير child أو actions للشريط.',
       );

  final Widget? child;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content =
        child ??
        Row(
          children: [
            for (var i = 0; i < actions!.length; i++) ...[
              if (i > 0) AppSpacing.hSm,
              Expanded(child: actions![i]),
            ],
          ],
        );

    return SafeArea(
      top: false,
      child: Container(
        padding:
            padding ??
            EdgeInsets.fromLTRB(
              AppSpacing.cardPadding,
              AppSpacing.sm,
              AppSpacing.cardPadding,
              AppSpacing.sm,
            ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
          border: Border(top: BorderSide(color: colors.outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, -7),
            ),
          ],
        ),
        child: maxWidth != null
            ? Align(
                alignment: Alignment.center,
                heightFactor: 1.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth!),
                  child: content,
                ),
              )
            : content,
      ),
    );
  }
}
