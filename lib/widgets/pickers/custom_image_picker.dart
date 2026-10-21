import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/file_picker_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// أنماط عرض منتقي الصور الموحد
enum ImagePickerVariant {
  /// نمط الشعار (Logo): مربع بحواف دائرية فخمة للعلامات التجارية والشبكات
  logo,

  /// نمط الصورة الشخصية (Avatar): دائري للمستخدمين والموظفين
  avatar,
}

/// منتقي الصور والشعارات المؤسسي الموحد (CustomImagePicker).
///
/// يدعم نمطي الشعار والصورة الشخصية، ويوفر نافذة سفلية منبثقة لاختيار
/// الكاميرا أو المعرض مع فحص الحجم المسموح (2MB كحد أقصى) وأزرار الإجراءات الموحدة.
class CustomImagePicker extends StatelessWidget {
  final ImagePickerVariant variant;
  final ValueNotifier<File?>? valueListenable;
  final ValueChanged<File?>? onChanged;
  final String label;
  final String hint;
  final double? size;
  final bool isRequired;
  final String? existingImageUrl;

  const CustomImagePicker({
    super.key,
    required this.variant,
    this.valueListenable,
    this.onChanged,
    required this.label,
    this.hint = 'PNG, JPG حتى 2MB',
    this.size,
    this.isRequired = false,
    this.existingImageUrl,
  });

  /// مُنشئ سريع لنمط الشعار (Logo)
  factory CustomImagePicker.logo({
    Key? key,
    ValueNotifier<File?>? valueListenable,
    ValueChanged<File?>? onChanged,
    String label = 'شعار الشبكة',
    String hint = 'PNG, JPG حتى 2MB (اختياري)',
    double? size,
    bool isRequired = false,
    String? existingImageUrl,
  }) =>
      CustomImagePicker(
        key: key,
        variant: ImagePickerVariant.logo,
        valueListenable: valueListenable,
        onChanged: onChanged,
        label: label,
        hint: hint,
        size: size,
        isRequired: isRequired,
        existingImageUrl: existingImageUrl,
      );

  /// مُنشئ سريع لنمط الصورة الشخصية (Avatar)
  factory CustomImagePicker.avatar({
    Key? key,
    ValueNotifier<File?>? valueListenable,
    ValueChanged<File?>? onChanged,
    String label = 'صورة المسؤول',
    String hint = 'اختياري',
    double? size,
    bool isRequired = false,
    String? existingImageUrl,
  }) =>
      CustomImagePicker(
        key: key,
        variant: ImagePickerVariant.avatar,
        valueListenable: valueListenable,
        onChanged: onChanged,
        label: label,
        hint: hint,
        size: size,
        isRequired: isRequired,
        existingImageUrl: existingImageUrl,
      );

  @override
  Widget build(BuildContext context) {
    if (valueListenable != null) {
      return ValueListenableBuilder<File?>(
        valueListenable: valueListenable!,
        builder: (context, file, _) {
          return _buildPickerContent(context, file);
        },
      );
    }
    return _buildPickerContent(context, null);
  }

  Widget _buildPickerContent(BuildContext context, File? currentFile) {
    if (variant == ImagePickerVariant.avatar) {
      return _buildAvatarPicker(context, currentFile);
    }
    return _buildLogoPicker(context, currentFile);
  }

  /// بناء واجهة اختيار الشعار (Logo)
  Widget _buildLogoPicker(BuildContext context, File? file) {
    final colors = context.colors;
    final boxSize = size ?? 96.r;
    final hasImage = file != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                label,
                style: AppTypography.inputLabel.copyWith(
                  color: colors.onSurface,
                ),
              ),
              if (isRequired) ...[
                AppSpacing.hXxs,
                Text(
                  '*',
                  style: AppTypography.inputLabel.copyWith(
                    color: colors.error,
                  ),
                ),
              ],
            ],
          ),
          AppSpacing.vXs,
        ],
        CustomInteractiveBounce(
          onTap: () => _showSourceBottomSheet(context, hasImage),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: hasImage
                    ? colors.primary.withValues(alpha: 0.5)
                    : colors.outlineVariant.withValues(alpha: 0.4),
                width: hasImage ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // معاينة الشعار أو العنصر الافتراضي
                Container(
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                    ),
                    boxShadow: AppElevation.level1(context),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: hasImage
                        ? Image.file(
                            file,
                            width: boxSize,
                            height: boxSize,
                            fit: BoxFit.cover,
                            cacheWidth: (boxSize * 2.5).toInt(),
                            cacheHeight: (boxSize * 2.5).toInt(),
                          )
                        : (existingImageUrl != null && existingImageUrl!.isNotEmpty)
                            ? Image.network(
                                existingImageUrl!,
                                width: boxSize,
                                height: boxSize,
                                fit: BoxFit.cover,
                                cacheWidth: (boxSize * 2.5).toInt(),
                                cacheHeight: (boxSize * 2.5).toInt(),
                                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(colors),
                              )
                            : _buildPlaceholderIcon(colors),
                  ),
                ),
                AppSpacing.hMd,

                // النصوص وزر الإجراء الموحد
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasImage ? 'تم اختيار الشعار' : 'انقر لرفع الشعار',
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        hint,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.vSm,
                      Row(
                        children: [
                          CustomButton.outline(
                            text: hasImage ? 'تغيير' : 'اختيار صورة',
                            icon: hasImage
                                ? Icons.edit_outlined
                                : Icons.cloud_upload_outlined,
                            iconSize: 16.r,
                            size: AppButtonSize.small,
                            onPressed: () =>
                                _showSourceBottomSheet(context, hasImage),
                          ),
                          if (hasImage) ...[
                            AppSpacing.hSm,
                            CustomButton.icon(
                              icon: Icons.delete_outline_rounded,
                              tooltip: 'حذف الشعار',
                              iconSize: 18.r,
                              dimension: 34.r,
                              foregroundColor: colors.error,
                              backgroundColor:
                                  colors.error.withValues(alpha: 0.08),
                              onPressed: () => _updateFile(null),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// بناء واجهة اختيار الصورة الشخصية (Avatar)
  Widget _buildAvatarPicker(BuildContext context, File? file) {
    final colors = context.colors;
    final avatarRadius = (size ?? 90.r) / 2;
    final hasImage = file != null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInteractiveBounce(
            onTap: () => _showSourceBottomSheet(context, hasImage),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: avatarRadius * 2,
                  height: avatarRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surfaceContainerLowest,
                    border: Border.all(
                      color: hasImage
                          ? colors.primary
                          : colors.outlineVariant.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: AppElevation.level2(context),
                  ),
                  child: ClipOval(
                    child: hasImage
                        ? Image.file(
                            file,
                            width: avatarRadius * 2,
                            height: avatarRadius * 2,
                            fit: BoxFit.cover,
                            cacheWidth: (avatarRadius * 4).toInt(),
                            cacheHeight: (avatarRadius * 4).toInt(),
                          )
                        : (existingImageUrl != null && existingImageUrl!.isNotEmpty)
                            ? Image.network(
                                existingImageUrl!,
                                width: avatarRadius * 2,
                                height: avatarRadius * 2,
                                fit: BoxFit.cover,
                                cacheWidth: (avatarRadius * 4).toInt(),
                                cacheHeight: (avatarRadius * 4).toInt(),
                                errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(colors),
                              )
                            : _buildAvatarPlaceholder(colors),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary,
                      border: Border.all(
                        color: colors.surface,
                        width: 2,
                      ),
                      boxShadow: AppElevation.level1(context),
                    ),
                    child: Icon(
                      hasImage ? Icons.edit_rounded : Icons.camera_alt_rounded,
                      size: 16.r,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (label.isNotEmpty) ...[
            AppSpacing.vXs,
            Text(
              label,
              style: AppTypography.inputLabel.copyWith(
                color: colors.onSurface,
              ),
            ),
          ],
          if (hint.isNotEmpty) ...[
            AppSpacing.vXxs,
            Text(
              hint,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon(AppColors colors) {
    return Center(
      child: Icon(
        Icons.add_photo_alternate_outlined,
        color: colors.primary.withValues(alpha: 0.7),
        size: 32.r,
      ),
    );
  }

  Widget _buildAvatarPlaceholder(AppColors colors) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        color: colors.onSurfaceVariant.withValues(alpha: 0.5),
        size: 40.r,
      ),
    );
  }

  /// عرض النافذة السفلية لاختيار المصدر (Source BottomSheet)
  void _showSourceBottomSheet(BuildContext context, bool hasImage) {
    final colors = context.colors;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
          boxShadow: AppElevation.level4(context),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مؤشر السحب
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              AppSpacing.vMd,

              // عنوان النافذة
              Text(
                label,
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vLg,

              // خيار الكاميرا
              _buildSourceOption(
                context,
                title: 'التقاط صورة بالكاميرا',
                icon: Icons.camera_alt_outlined,
                onTap: () => _pickImage(ImagePickerSource.camera),
              ),

              AppSpacing.vSm,

              // خيار المعرض
              _buildSourceOption(
                context,
                title: 'اختيار من معرض الصور',
                icon: Icons.photo_library_outlined,
                onTap: () => _pickImage(ImagePickerSource.gallery),
              ),

              // خيار حذف الصورة إذا كانت موجودة
              if (hasImage) ...[
                AppSpacing.vSm,
                _buildSourceOption(
                  context,
                  title: 'حذف الصورة الحالية',
                  icon: Icons.delete_outline_rounded,
                  isDestructive: true,
                  onTap: () {
                    Get.back();
                    _updateFile(null);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colors = context.colors;
    final itemColor = isDestructive ? colors.error : colors.onSurface;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isDestructive
              ? colors.error.withValues(alpha: 0.08)
              : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isDestructive
                ? colors.error.withValues(alpha: 0.2)
                : colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: itemColor,
              size: 22.r,
            ),
            AppSpacing.hMd,
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: itemColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: itemColor.withValues(alpha: 0.5),
              size: 14.r,
            ),
          ],
        ),
      ),
    );
  }

  /// معالجة التقاط الصورة عبر الخدمة المركزية الموحدة
  Future<void> _pickImage(ImagePickerSource source) async {
    Get.back(); // إغلاق الـ BottomSheet

    final picked = await FilePickerService.instance.pickImage(
      source: source,
      maxSizeBytes: 2 * 1024 * 1024, // 2MB
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );

    if (picked != null) {
      _updateFile(picked.toFile());
    }
  }

  void _updateFile(File? file) {
    if (valueListenable is ValueNotifier<File?>) {
      (valueListenable as ValueNotifier<File?>).value = file;
    }
    onChanged?.call(file);
  }
}
