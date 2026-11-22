import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/pickers/custom_image_picker.dart';

/// بطاقة الهوية التنفيذية الرئيسية في مركز الحساب مطابقة للمخطط البصري المعتمد
class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({
    super.key,
    required this.profile,
    required this.onCopyPhone,
    required this.onCopyEmail,
    required this.onAvatarChanged,
    required this.onCompleteProfile,
  });

  final ProfileEntity profile;
  final VoidCallback onCopyPhone;
  final VoidCallback onCopyEmail;
  final ValueChanged<File?> onAvatarChanged;
  final VoidCallback onCompleteProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusText = profile.statusLabel ?? 'حساب موثق';

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      backgroundColor: colors.surfaceContainerLow,
      borderColor: colors.outlineVariant.withValues(alpha: 0.45),
      child: Column(
        children: [
          // 1. الصورة الشخصية للمستخدم عبر منتقي الصور الموحد
          Center(
            child: CustomImagePicker.avatar(
              existingImageUrl: profile.avatarUrl,
              size: 88.r,
              label: '',
              hint: '',
              onChanged: onAvatarChanged,
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // 2. الاسم الكامل للمستخدم
          Text(
            profile.fullName.isEmpty ? 'المستخدم' : profile.fullName,
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: 6.h),

          // 3. شارة التوثيق والحالة المعتمدة من السيرفر
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: colors.success.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 13.r,
                  color: colors.success,
                ),
                SizedBox(width: 4.w),
                Text(
                  statusText,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // 4. الحاوية التفاعلية لخلايا الاتصال وزر إكمال الملف
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // زر إكمال الملف / تفاصيل الحساب على اليسار
                CustomButton.primary(
                  text: 'إكمال الملف',
                  isCompact: true,
                  onPressed: onCompleteProfile,
                ),
                SizedBox(width: AppSpacing.sm),

                // خلايا النسخ السريعة للهاتف والبريد على اليمين
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // رقم الهاتف
                      InkWell(
                        onTap: onCopyPhone,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  profile.phoneNumber,
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.ltr,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.content_copy_rounded,
                                size: 14.r,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 6.h,
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),

                      // البريد الإلكتروني
                      InkWell(
                        onTap: onCopyEmail,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  profile.hasEmail
                                      ? profile.email!
                                      : 'إضافة بريد إلكتروني',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: profile.hasEmail
                                        ? colors.onSurfaceVariant
                                        : colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.ltr,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.content_copy_rounded,
                                size: 14.r,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
