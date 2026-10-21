import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/app_cache_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/media_gallery/models/media_gallery_item.dart';
import 'package:open_filex/open_filex.dart';
import 'package:printing/printing.dart';

/// بطاقة وعارض مستندات الـ PDF التفاعلي المدمج داخل المعرض (MediaPdfViewerCard)
///
/// يدعم استعراض كافة صفحات ملف الـ PDF مباشرة داخل التطبيق وتكبيرها وتصفحها
/// بواسطة [PdfPreview] دون الحاجة لمغادرة التطبيق أو فتح روابط ويب، مع إمكانية
/// الفتح في تطبيق خارجي.
class MediaPdfViewerCard extends StatefulWidget {
  final MediaGalleryItem item;
  final ValueChanged<Uint8List>? onBytesLoaded;

  const MediaPdfViewerCard({
    super.key,
    required this.item,
    this.onBytesLoaded,
  });

  @override
  State<MediaPdfViewerCard> createState() => _MediaPdfViewerCardState();
}

class _MediaPdfViewerCardState extends State<MediaPdfViewerCard> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdfData();
  }

  Future<void> _loadPdfData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Uint8List? bytes = widget.item.bytes;

      if (bytes == null || bytes.isEmpty) {
        if (widget.item.isLocalFile) {
          final file = File(widget.item.url);
          if (await file.exists()) {
            bytes = await file.readAsBytes();
          }
        } else {
          bytes = await AppCacheService.instance.getBytes(widget.item.url);
        }
      }

      if (bytes != null && bytes.isNotEmpty) {
        if (mounted) {
          setState(() {
            _pdfBytes = bytes;
            _isLoading = false;
          });
          widget.onBytesLoaded?.call(bytes);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'تعذر العثور على محتوى ملف الـ PDF';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'تعثر تحميل ملف الـ PDF: $e';
        });
      }
    }
  }

  Future<void> _openInExternalApp() async {
    try {
      if (widget.item.isLocalFile) {
        await OpenFilex.open(widget.item.url);
      } else {
        final file = await AppCacheService.instance.getFile(widget.item.url);
        await OpenFilex.open(file.path);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 36.r,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.primary,
              ),
            ),
            AppSpacing.vMd,
            Text(
              'جاري تجهيز وعرض مستند الـ PDF...',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null || _pdfBytes == null) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(AppSpacing.xl),
          padding: EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
              width: 1.w,
            ),
            boxShadow: AppElevation.level1(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 48.r,
                  color: colors.error,
                ),
              ),
              AppSpacing.vMd,
              Text(
                widget.item.title,
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              AppSpacing.vXs,
              Text(
                _errorMessage ?? 'تعذر قراءة المستند',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.error,
                ),
              ),
              AppSpacing.vLg,
              CustomButton.outline(
                text: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                onPressed: _loadPdfData,
              ),
            ],
          ),
        ),
      );
    }

    // استعراض الـ PDF تفاعلياً وبشكل مباشر داخل فلاتر عبر PdfPreview
    return Column(
      children: [
        // شريط إجراءات مصغر أعلى المستند
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton.text(
                text: 'فتح في تطبيق خارجي',
                icon: Icons.open_in_new_rounded,
                onPressed: _openInExternalApp,
              ),
            ],
          ),
        ),
        Expanded(
          child: PdfPreview(
            build: (_) async => _pdfBytes!,
            pdfFileName: '${widget.item.title}.pdf',
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            useActions: false, // الإجراءات تُدار بالكامل عبر أزرار نظامنا الموحدة
            scrollViewDecoration: const BoxDecoration(color: Colors.transparent),
            loadingWidget: Center(
              child: SizedBox.square(
                dimension: 32.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
