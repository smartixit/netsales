import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

/// بطاقة الطرف التجاري الفردية في شاشة تفاصيل الفاتورة
class InvoiceDetailsPartyTile extends StatelessWidget {
  const InvoiceDetailsPartyTile({
    super.key,
    required this.roleLabel,
    required this.name,
    this.logoUrl,
    this.phoneNumber,
    this.address,
    required this.accentColor,
  });

  final String roleLabel;
  final String name;
  final String? logoUrl;
  final String? phoneNumber;
  final String? address;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = TextFormatter.avatarInitial(name);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .28),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomAvatarBadge(
            imageUrl: logoUrl,
            initials: initials,
            size: AvatarBadgeSize.sm,
            hasPulse: false,
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  roleLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.5.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    phoneNumber!,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (phoneNumber != null && phoneNumber!.trim().isNotEmpty)
            CustomButton.icon(
              icon: Icons.phone_outlined,
              iconSize: 18.r,
              tooltip: 'اتصال هاتفي',
              backgroundColor: colors.surfaceContainerHighest,
              foregroundColor: colors.primary,
              onPressed: () => UrlLauncherService.callPhone(phoneNumber!.trim()),
            ),
        ],
      ),
    );
  }
}
