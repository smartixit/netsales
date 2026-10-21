import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/models/app_picked_file.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// منطقة السحب والإفلات التفاعلية لاختيار الملفات (FilePickerDropzone)
///
/// تدعم السحب والإفلات المباشر على منصات سطح المكتب والويب، مع استعراض
/// الملفات عند النقر، وتنبيهات بصرية متناسقة مع ألوان النظام.
class FilePickerDropzone extends StatefulWidget {
  final VoidCallback onBrowse;
  final ValueChanged<List<AppPickedFile>>? onDroppedFiles;
  final String title;
  final String? subtitle;
  final bool enabled;

  const FilePickerDropzone({
    super.key,
    required this.onBrowse,
    this.onDroppedFiles,
    this.title = 'اسحب الملفات هنا أو انقر للتصفح',
    this.subtitle,
    this.enabled = true,
  });

  @override
  State<FilePickerDropzone> createState() => _FilePickerDropzoneState();
}

class _FilePickerDropzoneState extends State<FilePickerDropzone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final borderColor = _isDragging
        ? colors.primary
        : colors.outlineVariant.withValues(alpha: 0.5);

    final backgroundColor = _isDragging
        ? colors.primary.withValues(alpha: 0.08)
        : colors.surfaceContainerLow.withValues(alpha: 0.6);

    return DropTarget(
      enable: widget.enabled,
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (detail) {
        setState(() => _isDragging = false);
        if (detail.files.isEmpty) return;

        final converted = <AppPickedFile>[];
        for (final xFile in detail.files) {
          final file = File(xFile.path);
          if (file.existsSync()) {
            converted.add(AppPickedFile.fromFile(file));
          }
        }
        if (converted.isNotEmpty) {
          widget.onDroppedFiles?.call(converted);
        }
      },
      child: GestureDetector(
        onTap: widget.enabled ? widget.onBrowse : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: borderColor,
              width: _isDragging ? 2.w : 1.2.w,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. أيقونة السحب والرفع
              Container(
                width: 54.r,
                height: 54.r,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  color: colors.primary,
                  size: 28.r,
                ),
              ),

              AppSpacing.vMd,

              // 2. العنوان الرئيسي
              Text(
                widget.title,
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              // 3. النص التوضيحي والشروط
              if (widget.subtitle != null) ...[
                AppSpacing.vXs,
                Text(
                  widget.subtitle!,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              AppSpacing.vMd,

              // 4. زر التصفح الصريح
              CustomButton.outline(
                text: 'استعراض الملفات',
                icon: Icons.folder_open_rounded,
                size: AppButtonSize.small,
                onPressed: widget.enabled ? widget.onBrowse : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
