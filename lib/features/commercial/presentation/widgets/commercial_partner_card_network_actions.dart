import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط أزرار إجراءات بطاقة الشريك في مساحة عمل شبكة التوزيع (Network Actions)
///
/// يتبع المعمارية الموحدة المعتمدة في [ProcurementOrderCardNetworkActions]:
/// - زر رئيسي لاستعراض ملف نقطة البيع المعتمد.
/// - زر دائري لتجميد أو تنشيط الارتباط التجاري.
/// - زر دائري لفك الارتباط التجاري.
/// - زر دائري للقائمة الموسعة (المزيد من الخيارات).
class CommercialPartnerCardNetworkActions extends StatelessWidget {
  const CommercialPartnerCardNetworkActions({
    super.key,
    required this.isActive,
    required this.onViewDetails,
    this.onToggleStatus,
    this.onDelete,
    required this.onMoreActions,
  });

  final bool isActive;
  final VoidCallback onViewDetails;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final VoidCallback onMoreActions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        // 1. الزر الرئيسي المعتمد لاستعراض ملف نقطة البيع
        Expanded(
          child: CustomButton.outline(
            text: 'ملف نقطة البيع',
            icon: Icons.storefront_rounded,
            size: AppButtonSize.small,
            foregroundColor: colors.primary,
            borderColor: colors.primary.withValues(alpha: .6),
            onPressed: onViewDetails,
          ),
        ),

        // 2. زر تبديل حالة النشاط التجاري (تجميد / تنشيط)
        if (onToggleStatus != null) ...[
          AppSpacing.hXs,
          CustomButton.icon(
            icon: isActive
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            tooltip: isActive ? 'تجميد الارتباط' : 'تنشيط الارتباط',
            dimension: 38.r,
            backgroundColor: isActive
                ? colors.warning.withValues(alpha: .1)
                : colors.success.withValues(alpha: .1),
            foregroundColor: isActive ? colors.warning : colors.success,
            borderColor: (isActive ? colors.warning : colors.success)
                .withValues(alpha: .3),
            onPressed: onToggleStatus,
          ),
        ],

        // 3. زر فك الارتباط التجاري
        if (onDelete != null) ...[
          AppSpacing.hXs,
          CustomButton.icon(
            icon: Icons.link_off_rounded,
            tooltip: 'فك الارتباط التجاري',
            dimension: 38.r,
            backgroundColor: colors.error.withValues(alpha: .08),
            foregroundColor: colors.error,
            borderColor: colors.error.withValues(alpha: .25),
            onPressed: onDelete,
          ),
        ],

        // 4. زر المزيد من الإجراءات
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
