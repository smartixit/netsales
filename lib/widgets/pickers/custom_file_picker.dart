import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/models/media_gallery_item_model.dart';
import 'package:netsales/core/services/file_picker_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/media_gallery/media_gallery_viewer.dart';
import 'package:netsales/widgets/pickers/models/custom_existing_file_item.dart';
import 'package:netsales/widgets/pickers/widgets/file_card_item.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

export 'package:netsales/widgets/pickers/models/custom_existing_file_item.dart';

/// أنماط العرض المتاحة لمنتقي الملفات الموحد (CustomFilePicker)
enum FilePickerDisplayMode {
  /// نمط السحب والإفلات الكامل (Dropzone)
  dropzone,

  /// نمط الزر المدمج (Compact Button)
  button,

  /// نمط بطاقة الاستمارة الرسمية (Form Card)
  formCard,
}

/// منتقي المرفقات والملفات المؤسسي الموحد (CustomFilePicker)
///
/// مصمم بأسلوب وتجربة مستخدم نظيفة تتيح:
/// - اختيار مصدر المرفق عبر ورقة خيارات موحدة (معرض الصور / كاميرا / مستند PDF).
/// - عرض المرفقات المسجلة مسبقاً (في وضع التعديل) مع المرفقات الجديدة في قائمة موحدة.
/// - دعم السحب والإفلات على الحاسوب، المعاينة المباشرة، والحد الأقصى المتبقي بدقة.
class CustomFilePicker extends StatefulWidget {
  final List<AppPickedFileModel>? initialFiles;
  final List<CustomExistingFileItem> existingFiles;
  final ValueChanged<List<AppPickedFileModel>>? onFilesChanged;
  final ValueChanged<CustomExistingFileItem>? onExistingFileRemoved;
  final ValueChanged<CustomExistingFileItem>? onExistingFileTap;
  final int maxFiles;
  final int maxFileSizeBytes;
  final int? maxTotalSizeBytes;
  final List<String>? allowedExtensions;
  final FileTypePreset preset;
  final FilePickerDisplayMode displayMode;
  final String? label;
  final String? hint;
  final bool isRequired;
  final bool readOnly;
  final String? Function(List<AppPickedFileModel>?)? validator;

  const CustomFilePicker({
    super.key,
    this.initialFiles,
    this.existingFiles = const [],
    this.onFilesChanged,
    this.onExistingFileRemoved,
    this.onExistingFileTap,
    this.maxFiles = 5,
    this.maxFileSizeBytes = 2 * 1024 * 1024,
    this.maxTotalSizeBytes,
    this.allowedExtensions,
    this.preset = FileTypePreset.anySafe,
    this.displayMode = FilePickerDisplayMode.dropzone,
    this.label,
    this.hint,
    this.isRequired = false,
    this.readOnly = false,
    this.validator,
  });

  /// منشئ مخصص لملف مفرد (Single File / Document)
  factory CustomFilePicker.single({
    Key? key,
    AppPickedFileModel? initialFile,
    ValueChanged<AppPickedFileModel?>? onFileChanged,
    int maxFileSizeBytes = 2 * 1024 * 1024,
    List<String>? allowedExtensions,
    FileTypePreset preset = FileTypePreset.anySafe,
    FilePickerDisplayMode displayMode = FilePickerDisplayMode.button,
    String? label,
    String? hint,
    bool isRequired = false,
    bool readOnly = false,
  }) {
    return CustomFilePicker(
      key: key,
      initialFiles: initialFile != null ? [initialFile] : null,
      maxFiles: 1,
      maxFileSizeBytes: maxFileSizeBytes,
      allowedExtensions: allowedExtensions,
      preset: preset,
      displayMode: displayMode,
      label: label,
      hint: hint,
      isRequired: isRequired,
      readOnly: readOnly,
      onFilesChanged: (files) {
        onFileChanged?.call(files.isNotEmpty ? files.first : null);
      },
    );
  }

  /// منشئ مخصص لجداول البيانات (Excel / CSV)
  factory CustomFilePicker.spreadsheet({
    Key? key,
    List<AppPickedFileModel>? initialFiles,
    ValueChanged<List<AppPickedFileModel>>? onFilesChanged,
    int maxFiles = 1,
    int maxFileSizeBytes = 10 * 1024 * 1024,
    String label = 'ملف كروت الشبكة (Excel / CSV)',
    String hint = 'xlsx, xls, csv بحد أقصى 10MB',
    bool isRequired = false,
    bool readOnly = false,
  }) {
    return CustomFilePicker(
      key: key,
      initialFiles: initialFiles,
      onFilesChanged: onFilesChanged,
      maxFiles: maxFiles,
      maxFileSizeBytes: maxFileSizeBytes,
      preset: FileTypePreset.spreadsheetsOnly,
      displayMode: FilePickerDisplayMode.dropzone,
      label: label,
      hint: hint,
      isRequired: isRequired,
      readOnly: readOnly,
    );
  }

  @override
  State<CustomFilePicker> createState() => _CustomFilePickerState();
}

class _CustomFilePickerState extends State<CustomFilePicker> {
  late final List<AppPickedFileModel> _files;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _files = List<AppPickedFileModel>.from(widget.initialFiles ?? []);
  }

  @override
  void didUpdateWidget(covariant CustomFilePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFiles != null &&
        widget.initialFiles != oldWidget.initialFiles) {
      _files
        ..clear()
        ..addAll(widget.initialFiles!);
    }
  }

  int get _totalCount => widget.existingFiles.length + _files.length;
  int get _remainingSlots =>
      (widget.maxFiles - _totalCount).clamp(0, widget.maxFiles);
  bool get _canAddMore => _remainingSlots > 0;

  bool get _allowsImages =>
      widget.preset == FileTypePreset.anySafe ||
      widget.preset == FileTypePreset.imagesOnly ||
      (widget.allowedExtensions?.any(
            (e) => const [
              'jpg',
              'jpeg',
              'png',
              'webp',
              'gif',
            ].contains(e.toLowerCase()),
          ) ??
          false);

  bool get _allowsDocuments =>
      widget.preset == FileTypePreset.anySafe ||
      widget.preset == FileTypePreset.documentsOnly ||
      widget.preset == FileTypePreset.pdfOnly ||
      widget.preset == FileTypePreset.spreadsheetsOnly ||
      (widget.allowedExtensions?.any(
            (e) => const ['pdf', 'doc', 'docx', 'xlsx', 'xls', 'csv']
                .contains(e.toLowerCase()),
          ) ??
          false);

  Future<void> _onPickPressed() async {
    if (widget.readOnly || !_canAddMore || _isPicking) return;

    if (!_allowsImages || widget.preset == FileTypePreset.spreadsheetsOnly) {
      await _pickFromDocuments(widget.preset);
      return;
    }

    await HapticFeedback.lightImpact();
    final action = await CustomBottomSheet.show<String>(
      title: widget.maxFiles > 1 ? 'إضافة مرفق' : 'اختيار المرفق',
      child: _FileSourceSheetContent(
        isMulti: _remainingSlots > 1,
        allowsImages: _allowsImages,
        allowsDocuments: _allowsDocuments,
      ),
    );

    if (!mounted || action == null) return;

    if (action == 'gallery') {
      await _pickFromGallery();
    } else if (action == 'camera') {
      await _pickFromCamera();
    } else if (action == 'pdf') {
      final docPreset = widget.preset == FileTypePreset.anySafe
          ? FileTypePreset.pdfOnly
          : widget.preset;
      await _pickFromDocuments(docPreset);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isPicking = true);
    try {
      if (_remainingSlots > 1) {
        final picked = await FilePickerService.instance.pickMultiImages(
          maxFiles: _remainingSlots,
          maxSizeBytes: widget.maxFileSizeBytes,
          maxTotalSizeBytes: widget.maxTotalSizeBytes,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 85,
        );
        _appendFiles(picked);
      } else {
        final picked = await FilePickerService.instance.pickImage(
          source: ImagePickerSource.gallery,
          maxSizeBytes: widget.maxFileSizeBytes,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 85,
        );
        if (picked != null) _appendFiles([picked]);
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickFromCamera() async {
    setState(() => _isPicking = true);
    try {
      final picked = await FilePickerService.instance.pickImage(
        source: ImagePickerSource.camera,
        maxSizeBytes: widget.maxFileSizeBytes,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) _appendFiles([picked]);
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickFromDocuments(FileTypePreset docPreset) async {
    setState(() => _isPicking = true);
    try {
      final picked = await FilePickerService.instance.pickMultiFiles(
        allowedExtensions: widget.allowedExtensions,
        preset: docPreset,
        maxFiles: _remainingSlots,
        maxSizeBytes: widget.maxFileSizeBytes,
        maxTotalSizeBytes: widget.maxTotalSizeBytes,
      );
      _appendFiles(picked);
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _handleDroppedFiles(List<AppPickedFileModel> dropped) {
    if (widget.readOnly || !_canAddMore || _isPicking) return;
    _appendFiles(dropped.take(_remainingSlots).toList());
  }

  void _appendFiles(List<AppPickedFileModel> added) {
    if (added.isEmpty) return;
    setState(() {
      _files.addAll(added.take(_remainingSlots));
    });
    widget.onFilesChanged?.call(List.unmodifiable(_files));
  }

  void _removeFile(int index) {
    if (widget.readOnly || _isPicking) return;
    setState(() {
      _files.removeAt(index);
    });
    widget.onFilesChanged?.call(List.unmodifiable(_files));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasAnyFiles = _totalCount > 0;

    return FormField<List<AppPickedFileModel>>(
      initialValue: _files,
      validator: widget.validator,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.label != null) ...[
              _FilePickerHeader(
                label: widget.label!,
                isRequired: widget.isRequired,
                currentCount: _totalCount,
                maxFiles: widget.maxFiles,
              ),
              AppSpacing.vSm,
            ],

            // 1. المرفقات الموجودة مسبقاً (في وضع التعديل)
            if (widget.existingFiles.isNotEmpty) ...[
              for (int i = 0; i < widget.existingFiles.length; i++) ...[
                if (i > 0) AppSpacing.vSm,
                _ExistingFileTile(
                  item: widget.existingFiles[i],
                  readOnly: widget.readOnly,
                  onTap: widget.onExistingFileTap != null
                      ? () => widget.onExistingFileTap!(widget.existingFiles[i])
                      : null,
                  onRemove: widget.onExistingFileRemoved != null
                      ? () => widget.onExistingFileRemoved!(
                            widget.existingFiles[i],
                          )
                      : null,
                ),
              ],
              if (_files.isNotEmpty || _isPicking) AppSpacing.vSm,
            ],

            // 2. المرفقات الجديدة المختارة + مؤشر التحميل
            if (_files.isNotEmpty || _isPicking) ...[
              for (int i = 0; i < _files.length; i++) ...[
                if (i > 0) AppSpacing.vSm,
                FileCardItem(
                  file: _files[i],
                  readOnly: widget.readOnly,
                  onRemove: () => _removeFile(i),
                ),
              ],
              if (_isPicking) ...[
                if (_files.isNotEmpty) AppSpacing.vSm,
                const _FileSkeletonCard(),
              ],
            ],

            // 3. رسالة الحد الأقصى أو زر/منطقة الإضافة بأسلوب Qayd
            if (!widget.readOnly) ...[
              if (!_canAddMore && hasAnyFiles) ...[
                AppSpacing.vSm,
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16.r,
                      color: colors.onSurfaceVariant,
                    ),
                    AppSpacing.hXs,
                    Expanded(
                      child: Text(
                        'وصلت للحد الأقصى (${widget.maxFiles} مرفقات)',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (hasAnyFiles) ...[
                AppSpacing.vMd,
                CustomButton.outline(
                  text: 'إضافة مرفق',
                  icon: Icons.add_rounded,
                  loading: _isPicking,
                  enabled: _canAddMore && !_isPicking,
                  onPressed: _canAddMore && !_isPicking ? _onPickPressed : null,
                ),
              ] else ...[
                _FilePickerEmptyBox(
                  onTap: _onPickPressed,
                  onDroppedFiles: _handleDroppedFiles,
                  enabled: !_isPicking && _canAddMore,
                  maxFiles: widget.maxFiles,
                  hint: widget.hint,
                  enableDrop:
                      widget.displayMode == FilePickerDisplayMode.dropzone ||
                      widget.displayMode == FilePickerDisplayMode.formCard,
                ),
              ],
            ],

            if (fieldState.hasError) ...[
              AppSpacing.vXs,
              Text(
                fieldState.errorText!,
                style: AppTypography.labelSmall.copyWith(color: colors.error),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// محتوى ورقة اختيار مصدر المرفق (معرض / كاميرا / PDF)
class _FileSourceSheetContent extends StatelessWidget {
  const _FileSourceSheetContent({
    required this.isMulti,
    required this.allowsImages,
    required this.allowsDocuments,
  });

  final bool isMulti;
  final bool allowsImages;
  final bool allowsDocuments;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (allowsImages) ...[
          ListTile(
            leading: Icon(
              Icons.photo_library_outlined,
              color: colors.primary,
            ),
            title: Text(isMulti ? 'من المعرض (عدة صور)' : 'من المعرض'),
            subtitle: isMulti
                ? const Text('يمكنك اختيار أكثر من صورة')
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            onTap: () => Navigator.of(context).pop('gallery'),
          ),
          ListTile(
            leading: Icon(
              Icons.camera_alt_outlined,
              color: colors.primary,
            ),
            title: const Text('التقاط صورة'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            onTap: () => Navigator.of(context).pop('camera'),
          ),
        ],
        if (allowsDocuments)
          ListTile(
            leading: Icon(
              Icons.picture_as_pdf_outlined,
              color: colors.primary,
            ),
            title: const Text('مستند (PDF)'),
            subtitle: isMulti
                ? const Text('يمكنك اختيار أكثر من مستند')
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            onTap: () => Navigator.of(context).pop('pdf'),
          ),
        AppSpacing.vSm,
      ],
    );
  }
}

/// صندوق حالة الفراغ التفاعلي لإضافة المرفقات (بنفس أسلوب Qayd مع دعم السحب والإفلات)
class _FilePickerEmptyBox extends StatefulWidget {
  const _FilePickerEmptyBox({
    required this.onTap,
    required this.onDroppedFiles,
    required this.enabled,
    required this.maxFiles,
    this.hint,
    this.enableDrop = true,
  });

  final VoidCallback onTap;
  final ValueChanged<List<AppPickedFileModel>> onDroppedFiles;
  final bool enabled;
  final int maxFiles;
  final String? hint;
  final bool enableDrop;

  @override
  State<_FilePickerEmptyBox> createState() => _FilePickerEmptyBoxState();
}

class _FilePickerEmptyBoxState extends State<_FilePickerEmptyBox> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final box = InkWell(
      onTap: widget.enabled ? widget.onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.fast),
        curve: AppMotion.standard,
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _isDragging
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(
            color: _isDragging ? colors.primary : colors.outlineVariant,
            width: _isDragging ? 1.8.w : 1.0.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_file_rounded,
              size: 38.sp,
              color: colors.primary,
            ),
            AppSpacing.vSm,
            Text(
              'اضغط لإضافة مرفق',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.vXs,
            Text(
              widget.hint ??
                  'يمكنك إضافة حتى ${widget.maxFiles} ملفات (صور أو PDF)',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.enableDrop) return box;

    return DropTarget(
      enable: widget.enabled,
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (detail) {
        setState(() => _isDragging = false);
        if (detail.files.isEmpty) return;

        final converted = <AppPickedFileModel>[];
        for (final xFile in detail.files) {
          final file = File(xFile.path);
          if (file.existsSync()) {
            converted.add(AppPickedFileModel.fromFile(file));
          }
        }
        if (converted.isNotEmpty) {
          widget.onDroppedFiles(converted);
        }
      },
      child: box,
    );
  }
}

/// بطاقة عرض مرفق موجود مسبقاً على الخادم مع معاينة سريعة وزر حذف
class _ExistingFileTile extends StatelessWidget {
  const _ExistingFileTile({
    required this.item,
    required this.readOnly,
    this.onTap,
    this.onRemove,
  });

  final CustomExistingFileItem item;
  final bool readOnly;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final effectiveOnTap =
        onTap ??
        (item.isImage && item.url.isNotEmpty
            ? () => MediaGalleryViewer.show(
                  context,
                  items: [
                    MediaGalleryItemModel(
                      url: item.url,
                      title: item.name,
                      type: MediaGalleryType.image,
                    ),
                  ],
                )
            : null);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: effectiveOnTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                width: 48.r,
                height: 48.r,
                color: (item.isPdf ? colors.error : colors.primary).withValues(
                  alpha: 0.1,
                ),
                child: item.isImage && item.url.isNotEmpty
                    ? CustomCachedImage(
                        url: item.url,
                        width: 48.r,
                        height: 48.r,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        item.isPdf
                            ? Icons.picture_as_pdf_rounded
                            : Icons.insert_drive_file_rounded,
                        color: item.isPdf ? colors.error : colors.primary,
                        size: 24.r,
                      ),
              ),
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: InkWell(
              onTap: effectiveOnTap,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Text(
                        item.sizeLabel != null && item.sizeLabel!.isNotEmpty
                            ? item.sizeLabel!
                            : (item.isPdf ? 'مستند PDF' : 'صورة مرفقة'),
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      if (effectiveOnTap != null) ...[
                        Text(
                          ' • ',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.outline,
                          ),
                        ),
                        Text(
                          'اضغط للمعاينة',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!readOnly && onRemove != null) ...[
            AppSpacing.hSm,
            CustomButton.icon(
              icon: Icons.delete_outline_rounded,
              tooltip: 'حذف المرفق',
              iconSize: 18.r,
              dimension: 36.r,
              foregroundColor: colors.error,
              backgroundColor: colors.error.withValues(alpha: 0.08),
              onPressed: onRemove,
            ),
          ],
        ],
      ),
    );
  }
}

/// هيكل وميضي يحاكي بطاقة الملف الفردي أثناء المعالجة
class _FileSkeletonCard extends StatelessWidget {
  const _FileSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSkeletonShimmer(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.35),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 140.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  AppSpacing.vXs,
                  Container(
                    width: 80.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ترويسة حقل منتقي الملفات
class _FilePickerHeader extends StatelessWidget {
  final String label;
  final bool isRequired;
  final int currentCount;
  final int maxFiles;

  const _FilePickerHeader({
    required this.label,
    required this.isRequired,
    required this.currentCount,
    required this.maxFiles,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Text(
          label,
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isRequired) ...[
          AppSpacing.hXxs,
          Text(
            '*',
            style: AppTypography.titleSmall.copyWith(
              color: colors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const Spacer(),
        if (maxFiles > 1)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '$currentCount / $maxFiles',
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
