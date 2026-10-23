import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netsales/core/cache/netsales_cache_manager.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/services/app_cache_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// مكون موحد لعرض الصور الشبكية المحمية والمؤقتة مع حماية الذاكرة من الانهيار (CustomCachedImage)
///
/// يوفر:
/// - حماية من انهيار الذاكرة العشوائية (Zero-OOM Protection) عبر تقييد أبعاد فك التشفير.
/// - تعافٍ ذاتي فوري (Self-Healing Cache) لحذف أي ملف فاسد من الكاش عند تعثر عرضه.
/// - مؤشر تحميل هيكلي (Shimmer Placeholder) متكيف مع المظهرين الفاتح والداكن عبر `context.colors`.
/// - بديل أيقوني نظيف عند تعذر التحميل بدون أي ألوان سحرية.
class CustomCachedImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BoxFit? errorFit;
  final Widget? fallback;
  final String? fallbackText;
  final TextStyle? fallbackTextStyle;
  final Widget? placeholder;
  final ValueChanged<Uint8List>? onLoaded;
  final bool enableMemCacheDownsampling;
  final double? borderRadius;

  const CustomCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorFit = BoxFit.cover,
    this.fallback,
    this.fallbackText,
    this.fallbackTextStyle,
    this.placeholder,
    this.onLoaded,
    this.enableMemCacheDownsampling = true,
    this.borderRadius,
  });

  /// فئة مصنعية لعرض الصورة الشخصية (Avatar) بشكل دائري أنيق
  factory CustomCachedImage.avatar({
    Key? key,
    required String? url,
    required double radius,
    String? fallbackText,
    TextStyle? fallbackTextStyle,
    Widget? fallback,
    ValueChanged<Uint8List>? onLoaded,
  }) {
    final size = radius * 2;
    return CustomCachedImage(
      key: key,
      url: url,
      width: size,
      height: size,
      borderRadius: radius,
      fit: BoxFit.cover,
      fallbackText: fallbackText,
      fallbackTextStyle: fallbackTextStyle,
      fallback: fallback,
      onLoaded: onLoaded,
    );
  }

  /// فئة مصنعية لعرض شعار الشبكة أو نقطة البيع بحواف ناعمة
  factory CustomCachedImage.logo({
    Key? key,
    required String? url,
    required double size,
    double? borderRadius,
    String? fallbackText,
    TextStyle? fallbackTextStyle,
    Widget? fallback,
    ValueChanged<Uint8List>? onLoaded,
  }) {
    return CustomCachedImage(
      key: key,
      url: url,
      width: size,
      height: size,
      borderRadius: borderRadius ?? AppRadius.md,
      fit: BoxFit.contain,
      fallbackText: fallbackText,
      fallbackTextStyle: fallbackTextStyle,
      fallback: fallback,
      onLoaded: onLoaded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawUrl = url?.trim() ?? '';
    if (rawUrl.isEmpty) {
      return _buildFallback(context);
    }

    final normalizedUrl = NetSalesDioFileService.normalizeMediaUrl(rawUrl);
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // حساب أبعاد التسييل في الذاكرة لمنع تحميل صور 4K بدقتها الأصلية في الـ RAM
    int? memWidth;
    int? memHeight;

    if (enableMemCacheDownsampling) {
      if (width != null && width! > 0) {
        memWidth = (width! * pixelRatio).round().clamp(50, 1600);
      }
      if (height != null && height! > 0) {
        memHeight = (height! * pixelRatio).round().clamp(50, 1600);
      }
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: normalizedUrl,
      cacheManager: NetSalesCacheManager.instance,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memWidth,
      memCacheHeight: memHeight,
      fadeInDuration: AppMotion.normal,
      fadeOutDuration: AppMotion.fast,
      placeholder: (ctx, _) => placeholder ?? _buildPlaceholder(ctx),
      errorWidget: (ctx, errorUrl, error) {
        // تعافٍ ذاتي: حذف أي ملف فاسد من الكاش حتى لا يستمر الخطأ
        AppCacheService.instance.evictMedia(rawUrl);
        return _buildFallback(ctx);
      },
      imageBuilder: onLoaded != null
          ? (ctx, imageProvider) {
              _triggerOnLoaded(rawUrl);
              return Image(
                image: imageProvider,
                width: width,
                height: height,
                fit: fit,
              );
            }
          : null,
    );

    if (borderRadius != null && borderRadius! > 0) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  void _triggerOnLoaded(String targetUrl) {
    if (onLoaded == null) return;
    AppCacheService.instance.getBytes(targetUrl).then((bytes) {
      if (bytes != null && bytes.isNotEmpty) {
        onLoaded?.call(bytes);
      }
    });
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (fallbackText != null && fallbackText!.trim().isNotEmpty) {
      return _buildFallback(context);
    }

    final colors = context.colors;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius!)
            : null,
      ),
      alignment: Alignment.center,
      child: SizedBox.square(
        dimension: _spinnerSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    if (fallback != null) {
      return SizedBox(
        width: width,
        height: height,
        child: fallback,
      );
    }

    final colors = context.colors;

    if (fallbackText != null && fallbackText!.trim().isNotEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.12),
          borderRadius: borderRadius != null
              ? BorderRadius.circular(borderRadius!)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          fallbackText!.trim(),
          style: fallbackTextStyle ??
              AppTypography.labelMedium.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius!)
            : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: _iconSize,
        color: colors.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }

  double get _size => (width ?? height ?? 56).toDouble();
  double get _spinnerSize => (_size * 0.35).clamp(16.0, 32.0);
  double get _iconSize => (_size * 0.5).clamp(20.0, 48.0);
}

/// موفر صور يعتمد على كاش NetSales الموحد مع [ImageProvider]
class CustomCachedImageProvider extends CachedNetworkImageProvider {
  CustomCachedImageProvider(
    String url, {
    super.maxHeight,
    super.maxWidth,
    super.scale,
    super.headers,
  }) : super(
          NetSalesDioFileService.normalizeMediaUrl(url),
          cacheManager: NetSalesCacheManager.instance,
        );
}
