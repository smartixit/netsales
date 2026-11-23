import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// بطاقة البيانات الوصفية والتدقيقية للباقة (Package Metadata Surface Card)
///
/// تعتمد كلياً على المكون الموحد [CustomSurfaceCard] و [CustomInfoListTile] وتوكنز [AppColors] و [AppSpacing]
class PackageMetadataSurfaceCard extends StatelessWidget {
  const PackageMetadataSurfaceCard({super.key, required this.package});

  final PackageEntity package;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final createdDateStr = package.createdAt != null
        ? DateFormatter.fullDate(package.createdAt!)
        : 'غير محدد';
    final updatedDateStr = package.updatedAt != null
        ? DateFormatter.fullDate(package.updatedAt!)
        : createdDateStr;

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 20.r,
                color: colors.primary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'بيانات الاعتماد والشبكة التابعة',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(
            height: AppSpacing.xl,
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
          CustomInfoListTile(
            leading: Icon(
              Icons.hub_outlined,
              size: 20.r,
              color: colors.primary,
            ),
            title: Text(
              'شبكة الكروت التابعة',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            subtitle: Text(
              package.networkName != null
                  ? '${package.networkName}'
                  : 'الشبكة الافتراضية',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          CustomInfoListTile(
            leading: Icon(
              Icons.calendar_today_outlined,
              size: 20.r,
              color: colors.primary,
            ),
            title: Text(
              'تاريخ إنشاء الباقة',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            subtitle: Text(
              createdDateStr,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          CustomInfoListTile(
            leading: Icon(
              Icons.update_rounded,
              size: 20.r,
              color: colors.primary,
            ),
            title: Text(
              'آخر تحديث للبيانات',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            subtitle: Text(
              updatedDateStr,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
