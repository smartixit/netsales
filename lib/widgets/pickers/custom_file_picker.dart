import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/models/app_picked_file.dart';
import 'package:netsales/core/services/file_picker_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/pickers/widgets/file_card_item.dart';
import 'package:netsales/widgets/pickers/widgets/file_picker_dropzone.dart';

/// أنماط العرض المتاحة لمنتقي الملفات الموحد (CustomFilePicker)
enum FilePickerDisplayMode {
  /// نمط السحب والإفلات الكامل (Dropzone)
  dropzone,

  /// نمط الزر المدمج (Compact Button)
  button,

  /// نمط بطاقة الاستمارة الرسمية (Form Card)
  formCard,
}

/// منتقي المرفقات والملفات المؤسسي فائق التخصيص (CustomFilePicker)
///
/// يدعم تحديد سقف عدد الملفات، سقف الأحجام، تصفية الامتدادات، الحماية الأمنية،
/// والسحب والإفلات على الحاسوب والويب، متوافقاً 100% مع معايير كود النظام الموحد.
class CustomFilePicker extends StatefulWidget {
  final List<AppPickedFile>? initialFiles;
  final ValueChanged<List<AppPickedFile>>? onFilesChanged;
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
  final String? Function(List<AppPickedFile>?)? validator;

  const CustomFilePicker({
    super.key,
    this.initialFiles,
    this.onFilesChanged,
    this.maxFiles = 5,
    this.maxFileSizeBytes = 2 * 1024 * 1024, // 2MB
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
    AppPickedFile? initialFile,
    ValueChanged<AppPickedFile?>? onFileChanged,
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
    List<AppPickedFile>? initialFiles,
    ValueChanged<List<AppPickedFile>>? onFilesChanged,
    int maxFiles = 1,
    int maxFileSizeBytes = 10 * 1024 * 1024, // 10MB
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
  late final List<AppPickedFile> _files;

  @override
  void initState() {
    super.initState();
    _files = List<AppPickedFile>.from(widget.initialFiles ?? []);
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

  bool get _canAddMore => _files.length < widget.maxFiles;

  Future<void> _pickFiles() async {
    if (widget.readOnly || !_canAddMore) return;

    final remainingSlots = widget.maxFiles - _files.length;
    final pickedList = await FilePickerService.instance.pickMultiFiles(
      allowedExtensions: widget.allowedExtensions,
      preset: widget.preset,
      maxFiles: remainingSlots,
      maxSizeBytes: widget.maxFileSizeBytes,
      maxTotalSizeBytes: widget.maxTotalSizeBytes,
    );

    if (pickedList.isNotEmpty) {
      setState(() {
        _files.addAll(pickedList);
      });
      widget.onFilesChanged?.call(List.unmodifiable(_files));
    }
  }

  void _handleDroppedFiles(List<AppPickedFile> dropped) {
    if (widget.readOnly || !_canAddMore) return;

    final remainingSlots = widget.maxFiles - _files.length;
    final toAdd = dropped.take(remainingSlots).toList();

    if (toAdd.isNotEmpty) {
      setState(() {
        _files.addAll(toAdd);
      });
      widget.onFilesChanged?.call(List.unmodifiable(_files));
    }
  }

  void _removeFile(int index) {
    if (widget.readOnly) return;
    setState(() {
      _files.removeAt(index);
    });
    widget.onFilesChanged?.call(List.unmodifiable(_files));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FormField<List<AppPickedFile>>(
      initialValue: _files,
      validator: widget.validator,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. الترويسة والعنوان (إذا وجد)
            if (widget.label != null) ...[
              _FilePickerHeader(
                label: widget.label!,
                hint: widget.hint,
                isRequired: widget.isRequired,
                currentCount: _files.length,
                maxFiles: widget.maxFiles,
              ),
              AppSpacing.vSm,
            ],

            // 2. منطقة الإدخال والاختيار بحسب النمط
            if (!widget.readOnly && _canAddMore) ...[
              if (widget.displayMode == FilePickerDisplayMode.dropzone ||
                  widget.displayMode == FilePickerDisplayMode.formCard)
                FilePickerDropzone(
                  onBrowse: _pickFiles,
                  onDroppedFiles: _handleDroppedFiles,
                  subtitle: widget.hint ??
                      'الحد الأقصى: ${widget.maxFiles} ملفات (${widget.maxFileSizeBytes ~/ (1024 * 1024)}MB لكل ملف)',
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton.outline(
                    text: widget.maxFiles > 1 ? 'إرفاق ملفات' : 'إرفاق ملف',
                    icon: Icons.attach_file_rounded,
                    onPressed: _pickFiles,
                  ),
                ),
            ],

            // 3. رسالة خطأ التحقق إن وجدت
            if (fieldState.hasError) ...[
              AppSpacing.vXs,
              Text(
                fieldState.errorText!,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.error,
                ),
              ),
            ],

            // 4. قائمة الملفات المرفقة
            if (_files.isNotEmpty) ...[
              AppSpacing.vMd,
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _files.length,
                separatorBuilder: (_, __) => AppSpacing.vSm,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return FileCardItem(
                    file: file,
                    readOnly: widget.readOnly,
                    onRemove: () => _removeFile(index),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

/// ترويسة حقل منتقي الملفات
class _FilePickerHeader extends StatelessWidget {
  final String label;
  final String? hint;
  final bool isRequired;
  final int currentCount;
  final int maxFiles;

  const _FilePickerHeader({
    required this.label,
    this.hint,
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
