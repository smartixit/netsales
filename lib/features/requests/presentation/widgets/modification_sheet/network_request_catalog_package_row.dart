import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// سطر إضافة باقة فردية من كتالوج الشبكة لمسودة الطلب
class NetworkRequestCatalogPackageRow
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestCatalogPackageRow({super.key, required this.package});

  final PackageEntity package;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final packageColor = CustomColorPicker.parseHex(
      package.packageColor,
      fallback: colors.primary,
    );
    final sheetSize = package.packageVoucherCount;
    final defaultPrice = package.effectiveCashPrice > 0
        ? package.effectiveCashPrice
        : package.packageVoucherPrice;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: packageColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  package.packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                AppSpacing.vXxs,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$sheetSize كرت/ورقة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${AmountFormatter.formatValue(defaultPrice)} ر.ي',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hSm,
          CustomButton.outline(
            text: 'إضافة',
            icon: Icons.add_rounded,
            size: AppButtonSize.small,
            foregroundColor: colors.primary,
            borderColor: colors.primary.withValues(alpha: 0.5),
            onPressed: () => controller.addModificationPackage(package.packageId),
          ),
        ],
      ),
    );
  }
}
