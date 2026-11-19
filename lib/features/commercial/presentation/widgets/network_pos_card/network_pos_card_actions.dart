import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// أزرار إجراءات بطاقة نقطة البيع لمشغل الشبكة
class NetworkPosCardActions extends StatelessWidget {
  const NetworkPosCardActions({
    super.key,
    required this.link,
    required this.onToggleStatus,
    required this.onViewDetails,
    required this.onDelete,
  });

  final NetworkPosLinkEntity link;
  final VoidCallback onToggleStatus;
  final VoidCallback onViewDetails;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          // زر استعراض التفاصيل الكاملة
          Expanded(
            child: CustomButton.secondary(
              text: 'التفاصيل',
              icon: Icons.info_outline_rounded,
              size: AppButtonSize.small,
              onPressed: onViewDetails,
            ),
          ),
          SizedBox(width: AppSpacing.xs),

          // زر تجميد / تفعيل الارتباط التجاري
          CustomButton.secondary(
            text: link.isActive ? 'تجميد' : 'تفعيل',
            icon: link.isActive
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            size: AppButtonSize.small,
            onPressed: onToggleStatus,
          ),
          SizedBox(width: AppSpacing.xs),

          // زر فك الارتباط
          IconButton.filledTonal(
            tooltip: 'فك الارتباط التجاري',
            style: IconButton.styleFrom(
              backgroundColor: colors.error.withValues(alpha: .1),
              foregroundColor: colors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              minimumSize: Size(36.r, 36.r),
              padding: EdgeInsets.zero,
            ),
            icon: Icon(Icons.link_off_rounded, size: 18.r),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
