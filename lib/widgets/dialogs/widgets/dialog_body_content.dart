import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ودجت نصوص ومحتوى الحوار (DialogBodyContent)
///
/// يعرض العنوان والرسالة أو الودجت المخصص مع دعم التمرير الرأسي الآمن
/// في حال كانت النصوص طويلة لضمان عدم حدوث أي overflow.
class DialogBodyContent extends StatelessWidget {
  final String title;
  final String message;
  final Widget? content;

  const DialogBodyContent({
    super.key,
    required this.title,
    this.message = '',
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. عنوان الحوار
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            0,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 2. المحتوى المخصص أو الرسالة النصية
        if (content != null)
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: content,
            ),
          )
        else if (message.isNotEmpty)
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
