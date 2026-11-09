import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// رأس شاشة تفاصيل الباقة مع الشعار اللوني والحالة وتاريخ الإنشاء
class PackageDetailsHeader extends StatelessWidget {
  final PackageEntity package;

  const PackageDetailsHeader({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final packageColor = CustomColorPicker.parseHex(package.packageColor);

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة الباقة المميزة بلونها
          Container(
            width: AppSpacing.giant,
            height: AppSpacing.giant,
            decoration: BoxDecoration(
              color: packageColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: packageColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.wifi_tethering_rounded,
              color: packageColor,
              size: AppSpacing.xxl,
            ),
          ),
          AppSpacing.hMd,

          // الاسم والبيانات الأساسية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        package.packageName,
                        style: AppTypography.titleLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CustomStatusBadge(
                      label: package.status ? 'نشطة' : 'معطلة',
                      tone: package.status
                          ? SemanticTone.success
                          : SemanticTone.danger,
                      showDot: true,
                    ),
                  ],
                ),
                AppSpacing.vXs,
                if (package.networkName != null &&
                    package.networkName!.isNotEmpty) ...[
                  Text(
                    'الشبكة: ${package.networkName}',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.vXxs,
                ],
                if (package.createdAt != null) ...[
                  Text(
                    'تاريخ الإضافة: ${DateFormatter.date(package.createdAt!)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
