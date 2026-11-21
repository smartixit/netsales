import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط أزرار إجراءات بطاقة الشريك في مساحة عمل نقطة البيع (POS Actions)
///
/// يتبع المعمارية الموحدة المعتمدة في [ProcurementOrderCardPosActions]:
/// - زر رئيسي لاستعراض ملف مزود الشبكة المعتمد.
/// - زر دائري لفك الارتباط بمزود الشبكة.
/// - زر دائري للقائمة الموسعة (المزيد من الخيارات).
class CommercialPartnerCardPosActions extends StatelessWidget {
  const CommercialPartnerCardPosActions({
    super.key,
    required this.onViewDetails,
    this.onDelete,
    required this.onMoreActions,
  });

  final VoidCallback onViewDetails;
  final VoidCallback? onDelete;
  final VoidCallback onMoreActions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        // 1. الزر الرئيسي المعتمد لاستعراض ملف مزود الشبكة
        Expanded(
          child: CustomButton.outline(
            text: 'ملف المزود',
            icon: Icons.hub_rounded,
            size: AppButtonSize.small,
            foregroundColor: colors.primary,
            borderColor: colors.primary.withValues(alpha: .6),
            onPressed: onViewDetails,
          ),
        ),

        // 2. زر فك الارتباط بمزود الشبكة
        if (onDelete != null) ...[
          AppSpacing.hXs,
          CustomButton.icon(
            icon: Icons.link_off_rounded,
            tooltip: 'فك الارتباط بمزود الشبكة',
            dimension: 38.r,
            backgroundColor: colors.error.withValues(alpha: .08),
            foregroundColor: colors.error,
            borderColor: colors.error.withValues(alpha: .25),
            onPressed: onDelete,
          ),
        ],

        // 3. زر المزيد من الإجراءات
        AppSpacing.hXs,
        CustomButton.icon(
          icon: Icons.more_horiz_rounded,
          tooltip: 'المزيد من الخيارات',
          dimension: 38.r,
          backgroundColor: colors.surfaceContainer,
          foregroundColor: colors.onSurfaceVariant,
          borderColor: colors.outlineVariant.withValues(alpha: .6),
          onPressed: onMoreActions,
        ),
      ],
    );
  }
}
