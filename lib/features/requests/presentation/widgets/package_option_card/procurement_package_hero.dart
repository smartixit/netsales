import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_artwork.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ترويسة بطاقة باقة التوريد (العنوان، شارة الخصم، سعة الورقة، والعمل الفني)
class ProcurementPackageHero extends StatelessWidget {
  const ProcurementPackageHero({
    super.key,
    required this.title,
    required this.sheetCapacity,
    required this.unitLabel,
    required this.packageAccentColor,
    required this.isCustomDiscount,
    required this.discount,
    this.tagLabel,
    this.tagColor,
    this.onDelete,
    this.trailingHeaderAction,
  });

  final String title;
  final int sheetCapacity;
  final String unitLabel;
  final Color packageAccentColor;
  final bool isCustomDiscount;
  final double discount;
  final String? tagLabel;
  final Color? tagColor;
  final VoidCallback? onDelete;
  final Widget? trailingHeaderAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final resolvedTag = tagLabel ??
        (isCustomDiscount
            ? 'خصم خاص'
            : discount > 0
                ? 'خصم افتراضي'
                : 'باقة الشبكة');

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340.w;
        final artworkSize = compact ? 104.r : 124.r;
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: artworkSize),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    compact ? 8.r : 12.r,
                    9.r,
                    8.r,
                    9.r,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 7.r : 10.r,
                                vertical: 5.r,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: tagColor != null
                                      ? [
                                          tagColor!,
                                          tagColor!.withValues(alpha: .75),
                                        ]
                                      : [
                                          colors.emeraldDark,
                                          colors.emeraldDeep,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.emeraldDark.withValues(
                                      alpha: .18,
                                    ),
                                    blurRadius: 9,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    isCustomDiscount
                                        ? Icons.storefront_rounded
                                        : Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                    size: 14.r,
                                  ),
                                  AppSpacing.hXxs,
                                  Flexible(
                                    child: Text(
                                      resolvedTag,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (trailingHeaderAction != null) ...[
                            AppSpacing.hXs,
                            trailingHeaderAction!,
                          ] else if (onDelete != null) ...[
                            AppSpacing.hXs,
                            CustomButton.icon(
                              icon: Icons.delete_outline_rounded,
                              tooltip: 'حذف الباقة',
                              dimension: 28.r,
                              size: AppButtonSize.small,
                              backgroundColor: colors.error.withValues(
                                alpha: .12,
                              ),
                              foregroundColor: colors.error,
                              onPressed: onDelete,
                            ),
                          ],
                        ],
                      ),
                      AppSpacing.vMd,
                      Row(
                        children: [
                          Container(
                            key: const ValueKey(
                              'procurement-package-color-accent',
                            ),
                            width: 4.r,
                            height: 18.r,
                            decoration: BoxDecoration(
                              color: packageAccentColor,
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                          ),
                          AppSpacing.hXs,
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: AppTypography.titleMedium.copyWith(
                                color: packageAccentColor,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vSm,
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth - artworkSize - 28.r,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.r,
                          vertical: 4.r,
                        ),
                        decoration: BoxDecoration(
                          color: packageAccentColor.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                          border: Border.all(
                            color: packageAccentColor.withValues(alpha: .14),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.layers_rounded,
                              size: 13.r,
                              color: packageAccentColor,
                            ),
                            AppSpacing.hXxs,
                            Flexible(
                              child: Text(
                                'سعة الورقة: $sheetCapacity $unitLabel',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: packageAccentColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: artworkSize,
                height: artworkSize,
                child: const ProcurementPackageArtwork(),
              ),
            ],
          ),
        );
      },
    );
  }
}
