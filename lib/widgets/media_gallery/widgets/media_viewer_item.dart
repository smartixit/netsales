import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/media_gallery/models/media_gallery_item.dart';
import 'package:netsales/widgets/media_gallery/widgets/media_document_viewer_card.dart';
import 'package:netsales/widgets/media_gallery/widgets/media_pdf_viewer_card.dart';

/// عارض العنصر الفردي داخل معرض الوسائط (MediaViewerItem)
///
/// يدعم التبديل الذكي حسب نوع العنصر:
/// - استعراض PDF التفاعلي عبر [MediaPdfViewerCard].
/// - استعراض جداول البيانات والمستندات عبر [MediaDocumentViewerCard].
/// - استعراض الصور مع دعم السحب والتكبير والتصغير التفاعلي واللمس المزدوج.
class MediaViewerItem extends StatefulWidget {
  final MediaGalleryItem item;
  final VoidCallback? onTap;
  final ValueChanged<Uint8List>? onBytesLoaded;

  const MediaViewerItem({
    super.key,
    required this.item,
    this.onTap,
    this.onBytesLoaded,
  });

  @override
  State<MediaViewerItem> createState() => _MediaViewerItemState();
}

class _MediaViewerItemState extends State<MediaViewerItem>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformationController;
  late final AnimationController _zoomAnimationController;
  Animation<Matrix4>? _zoomAnimation;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _zoomAnimationController = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
    )..addListener(() {
        if (_zoomAnimation != null) {
          _transformationController.value = _zoomAnimation!.value;
        }
      });

    if (widget.item.isLocalFile) {
      File(widget.item.url).readAsBytes().then((bytes) {
        if (mounted && bytes.isNotEmpty) {
          widget.onBytesLoaded?.call(bytes);
        }
      }).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _zoomAnimationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final endMatrix = Matrix4.identity();

    if (currentScale < 1.8) {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      const zoomScale = 2.5;
      final x = -position.dx * (zoomScale - 1);
      final y = -position.dy * (zoomScale - 1);

      endMatrix.setEntry(0, 0, zoomScale);
      endMatrix.setEntry(1, 1, zoomScale);
      endMatrix.setEntry(0, 3, x);
      endMatrix.setEntry(1, 3, y);
    }

    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _zoomAnimationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.isPdf) {
      return MediaPdfViewerCard(
        item: widget.item,
        onBytesLoaded: widget.onBytesLoaded,
      );
    }

    if (!widget.item.isImage) {
      return MediaDocumentViewerCard(item: widget.item);
    }

    // عرض الصورة مع التكبير المزدوج والسحب التفاعلي
    Widget imageWidget;
    if (widget.item.isLocalFile) {
      imageWidget = Image.file(
        File(widget.item.url),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildErrorPlaceholder(context),
      );
    } else {
      imageWidget = CustomCachedImage(
        url: widget.item.url,
        fit: BoxFit.contain,
        fallback: _buildErrorPlaceholder(context),
        onLoaded: widget.onBytesLoaded,
      );
    }

    if (widget.item.heroTag != null) {
      imageWidget = Hero(tag: widget.item.heroTag!, child: imageWidget);
    }

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: Center(
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.9,
          maxScale: 4.5,
          clipBehavior: Clip.none,
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_rounded,
            size: 48.r,
            color: colors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          AppSpacing.vSm,
          Text(
            'تعذر تحميل الصورة أو خلل في الملف',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
