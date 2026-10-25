import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/file_picker_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

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
/// الكاميرا أو المعرض مع هيكل وميضي احترافي (Skeleton Shimmer) أثناء التقاط وتحميل الصورة.
class CustomImagePicker extends StatefulWidget {
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
  }) => CustomImagePicker(
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
  }) => CustomImagePicker(
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
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  bool _isPicking = false;

  @override
  Widget build(BuildContext context) {
    if (widget.valueListenable != null) {
      return ValueListenableBuilder<File?>(
        valueListenable: widget.valueListenable!,
        builder: (context, file, _) {
          return _buildPickerContent(context, file);
        },
      );
    }
    return _buildPickerContent(context, null);
  }

  Widget _buildPickerContent(BuildContext context, File? currentFile) {
    if (widget.variant == ImagePickerVariant.avatar) {
      return _buildAvatarPicker(context, currentFile);
    }
    return _buildLogoPicker(context, currentFile);
  }

  /// بناء واجهة اختيار الشعار (Logo)
  Widget _buildLogoPicker(BuildContext context, File? file) {
    final colors = context.colors;
    final boxSize = widget.size ?? 96.r;
    final hasImage = file != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text.rich(
            TextSpan(
              text: widget.label,
              style: AppTypography.inputLabel.copyWith(color: colors.onSurface),
              children: [
                if (widget.isRequired) ...[
                  const WidgetSpan(child: SizedBox(width: 4)),
                  TextSpan(
                    text: '*',
                    style: AppTypography.inputLabel.copyWith(
                      color: colors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.vXs,
        ],
        CustomInteractiveBounce(
          onTap: () {
            if (!_isPicking) {
              _showSourceBottomSheet(context, hasImage);
            }
          },
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
                // معاينة الشعار أو الهيكل الوميضي (Skeleton)
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
                    child: _isPicking
                        ? _buildLogoSkeleton(colors, boxSize)
                        : hasImage
                        ? Image.file(
                            file,
                            width: boxSize,
                            height: boxSize,
                            fit: BoxFit.cover,
                            cacheWidth: (boxSize * 2.5).toInt(),
                            cacheHeight: (boxSize * 2.5).toInt(),
                            frameBuilder:
                                (
                                  context,
                                  child,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) {
                                  if (wasSynchronouslyLoaded || frame != null) {
                                    return child;
                                  }
                                  return _buildLogoSkeleton(colors, boxSize);
                                },
                          )
                        : (widget.existingImageUrl != null &&
                              widget.existingImageUrl!.isNotEmpty)
                        ? CustomCachedImage.logo(
                            url: widget.existingImageUrl,
                            size: boxSize,
                            fallback: _buildPlaceholderIcon(colors),
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
                        _isPicking
                            ? 'جاري التقاط ومعالجة الصورة...'
                            : hasImage
                            ? 'تم اختيار الشعار'
                            : 'انقر لرفع الشعار',
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        widget.hint,
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
                            loading: _isPicking,
                            onPressed: _isPicking
                                ? null
                                : () =>
                                      _showSourceBottomSheet(context, hasImage),
                          ),
                          if (hasImage && !_isPicking) ...[
                            AppSpacing.hSm,
                            CustomButton.icon(
                              icon: Icons.delete_outline_rounded,
                              tooltip: 'حذف الشعار',
                              iconSize: 18.r,
                              dimension: 34.r,
                              foregroundColor: colors.error,
                              backgroundColor: colors.error.withValues(
                                alpha: 0.08,
                              ),
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
    final avatarRadius = (widget.size ?? 90.r) / 2;
    final hasImage = file != null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInteractiveBounce(
            onTap: () {
              if (!_isPicking) {
                _showSourceBottomSheet(context, hasImage);
              }
            },
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
                    child: _isPicking
                        ? _buildAvatarSkeleton(colors, avatarRadius)
                        : hasImage
                        ? Image.file(
                            file,
                            width: avatarRadius * 2,
                            height: avatarRadius * 2,
                            fit: BoxFit.cover,
                            cacheWidth: (avatarRadius * 4).toInt(),
                            cacheHeight: (avatarRadius * 4).toInt(),
                            frameBuilder:
                                (
                                  context,
                                  child,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) {
                                  if (wasSynchronouslyLoaded || frame != null) {
                                    return child;
                                  }
                                  return _buildAvatarSkeleton(
                                    colors,
                                    avatarRadius,
                                  );
                                },
                          )
                        : (widget.existingImageUrl != null &&
                              widget.existingImageUrl!.isNotEmpty)
                        ? CustomCachedImage.avatar(
                            url: widget.existingImageUrl,
                            radius: avatarRadius,
                            fallback: _buildAvatarPlaceholder(colors),
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
                      border: Border.all(color: colors.surface, width: 2),
                      boxShadow: AppElevation.level1(context),
                    ),
                    child: _isPicking
                        ? SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: CustomSkeletonShimmer(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.surfaceContainerHigh,
                                ),
                              ),
                            ),
                          )
                        : Icon(
                            hasImage
                                ? Icons.edit_rounded
                                : Icons.camera_alt_rounded,
                            size: 16.r,
                            color: colors.onPrimary,
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.label.isNotEmpty) ...[
            AppSpacing.vXs,
            Text(
              widget.label,
              style: AppTypography.inputLabel.copyWith(color: colors.onSurface),
            ),
          ],
          if (widget.hint.isNotEmpty) ...[
            AppSpacing.vXxs,
            Text(
              widget.hint,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// هيكل وميضي مربع للشعار (Logo Skeleton)
  Widget _buildLogoSkeleton(AppColors colors, double boxSize) {
    return CustomSkeletonShimmer(
      child: Container(
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  /// هيكل وميضي دائري للصورة الشخصية (Avatar Skeleton)
  Widget _buildAvatarSkeleton(AppColors colors, double avatarRadius) {
    return CustomSkeletonShimmer(
      child: Container(
        width: avatarRadius * 2,
        height: avatarRadius * 2,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
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
    CustomBottomSheet.showActions(
      title: widget.label,
      items: [
        CustomBottomSheetActionItem(
          title: 'التقاط صورة بالكاميرا',
          icon: Icons.camera_alt_outlined,
          onTap: () => _pickImage(ImagePickerSource.camera),
        ),
        CustomBottomSheetActionItem(
          title: 'اختيار من معرض الصور',
          icon: Icons.photo_library_outlined,
          onTap: () => _pickImage(ImagePickerSource.gallery),
        ),
        if (hasImage)
          CustomBottomSheetActionItem(
            title: 'حذف الصورة الحالية',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onTap: () => _updateFile(null),
          ),
      ],
    );
  }

  /// معالجة التقاط الصورة عبر الخدمة المركزية الموحدة مع حالة التحميل الوميضية الفورية
  Future<void> _pickImage(ImagePickerSource source) async {
    setState(() => _isPicking = true);
    try {
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
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  void _updateFile(File? file) {
    if (widget.valueListenable is ValueNotifier<File?>) {
      (widget.valueListenable as ValueNotifier<File?>).value = file;
    }
    widget.onChanged?.call(file);
  }
}
