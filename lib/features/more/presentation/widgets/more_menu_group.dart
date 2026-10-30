import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/more/presentation/widgets/more_menu_tile.dart';

/// ============================================================================
/// مجموعة قوائم قطاع المزيد التنفيذية (MoreMenuGroup)
/// ============================================================================
/// حاوية Bento مصقولة تجمع البنود ذات الصلة داخل وعاء زجاجي موحد.
class MoreMenuGroup extends StatelessWidget {
  final String title;
  final List<MoreMenuTile> items;

  const MoreMenuGroup({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
        AppSpacing.vXs,
        Container(
          decoration: BoxDecoration(
            gradient: AppGradients.surfaceMesh(context),
            borderRadius: AppRadius.lgRadius,
            boxShadow: AppElevation.level1(context),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.28),
              width: 1.w,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.lgRadius,
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i < items.length - 1)
                    Divider(
                      color: colors.outlineVariant.withValues(alpha: 0.16),
                      height: 1.h,
                      indent: 58.w,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
