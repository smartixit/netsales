import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_text_styles.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// ترويسة بطاقة شبكة التزويد المرتبطة بنقطة البيع
class PosLinkedNetworkCardHeader extends StatelessWidget {
  const PosLinkedNetworkCardHeader({
    super.key,
    required this.link,
  });

  final NetworkPosLinkEntity link;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: colors.primary.withValues(alpha: .08),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // أيقونة الشبكة المزودة
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.hub_rounded,
              color: colors.primary,
              size: 24.r,
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          // الاسم والمعرف الأصلي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  link.displayNetworkName,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                InkWell(
                  onTap: () => UrlLauncherService.copyToClipboard(
                      link.displayNetworkReference),
                  borderRadius: BorderRadius.circular(4.r),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          link.displayNetworkReference,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: colors.textSecondary,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.copy_rounded,
                        size: 13.r,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xs),

          // شارة حالة الارتباط
          CustomStatusBadge(
            label: link.isActive ? 'مزود معتمد' : 'مجمد',
            type: link.isActive
                ? StatusBadgeType.success
                : StatusBadgeType.warning,
            size: StatusBadgeSize.small,
          ),
        ],
      ),
    );
  }
}
