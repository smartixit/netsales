import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({super.key, required this.profile});

  final ProfileEntity profile;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '؟';
    return parts.take(2).map((part) => part.substring(0, 1)).join();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = profile.fullName.trim().isEmpty
        ? '؟'
        : profile.fullName
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0])
              .join();

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: colors.executiveHeroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.executiveGoldAccent.withValues(alpha: 0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.emeraldDark.withValues(alpha: 0.12),
            blurRadius: 20.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Row(
        children: [
          CustomAvatarBadge(
            imageUrl: profile.avatarUrl,
            initials: initials.isEmpty ? '؟' : initials,
            size: AvatarBadgeSize.lg,
            customDimension: 72,
            hasPulse: false,
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName.isEmpty ? 'المستخدم' : profile.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  'حساب NetSales',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
