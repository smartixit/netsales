import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة اختيار شبكة واحدة داخل النافذة السفلية (WorkspaceNetworkPickerTile)
class WorkspaceNetworkPickerTile extends StatelessWidget {
  final NetworkEntity network;
  final bool isSelected;
  final VoidCallback onTap;

  const WorkspaceNetworkPickerTile({
    super.key,
    required this.network,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final locationParts = [
      if (network.governorateName != null &&
          network.governorateName!.isNotEmpty)
        network.governorateName!,
      if (network.directorateName != null &&
          network.directorateName!.isNotEmpty)
        network.directorateName!,
    ].join(' • ');

    final initials = TextFormatter.avatarInitials(
      network.networkName,
      maxChars: 2,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: CustomInteractiveBounce(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                : (isDark ? colors.surfaceContainerLow : colors.surface),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected
                  ? colors.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : colors.outlineVariant.withValues(alpha: 0.8)),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            children: [
              // لوجو أو أيقونة الشبكة
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.secondary],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                padding: const EdgeInsets.all(1.5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md - 1),
                    color: isDark ? const Color(0xFF0E1522) : colors.surface,
                  ),
                  alignment: Alignment.center,
                  child:
                      network.networkProfileLogoUrl != null &&
                              network.networkProfileLogoUrl!.isNotEmpty
                          ? CustomCachedImage.avatar(
                              url: network.networkProfileLogoUrl,
                              radius: 19.r,
                            )
                          : Text(
                              initials,
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                ),
              ),
              SizedBox(width: AppSpacing.md),

              // اسم الشبكة وموقعها
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            network.networkName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (network.isActive) ...[
                          SizedBox(width: 6.w),
                          CustomPulsingIndicator(
                            color: colors.success,
                            size: 5.r,
                            enablePing: false,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      locationParts.isNotEmpty
                          ? locationParts
                          : (network.networkPhoneNumber.isNotEmpty
                              ? network.networkPhoneNumber
                              : 'شبكة اتصالات معتمدة'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // شارة التحديد
              if (isSelected)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 13.r,
                        color: colors.onPrimary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'نشطة',
                        style: TextStyle(
                          color: colors.onPrimary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12.r,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
