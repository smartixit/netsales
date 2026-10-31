import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:netsales/core/services/qr_code_service.dart';

/// ============================================================================
/// Custom QR Code Widget
///
/// Widget عامة لعرض QR Code بتخصيص كامل.
///
/// المميزات:
/// - تخصيص التصميم باستخدام PrettyQrDecoration.
/// - تخصيص مستوى تصحيح الأخطاء.
/// - التحكم بالحجم.
/// - دعم الشعارات والصور.
/// - دعم الأشكال والتدرجات.
/// - إعادة إنشاء QR عند تغيير البيانات.
/// ============================================================================
class CustomQrCode extends StatefulWidget {
  /// البيانات المطلوب تحويلها إلى QR
  final String data;

  /// أبعاد QR
  final double size;

  /// إعدادات التصميم الكاملة للمكتبة
  final PrettyQrDecoration decoration;

  /// عنصر بديل عند حدوث خطأ
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// نص وصف لقارئات الشاشة
  final String? semanticsLabel;

  /// لون خلفية الحاوية الخارجية
  final Color? containerColor;

  /// الحواف الخارجية
  final BorderRadius? borderRadius;

  /// الحشو الخارجي
  final EdgeInsetsGeometry padding;

  /// محاذاة QR
  final AlignmentGeometry alignment;

  const CustomQrCode({
    super.key,
    required this.data,
    this.size = 200,
    this.decoration = const PrettyQrDecoration(),
    this.errorBuilder,
    this.semanticsLabel,
    this.containerColor,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.center,
  });

  @override
  State<CustomQrCode> createState() => _CustomQrCodeState();
}

class _CustomQrCodeState extends State<CustomQrCode> {
  QrImage? _qrImage;

  Object? _error;

  @override
  void initState() {
    super.initState();
    _generateQr();
  }

  @override
  void didUpdateWidget(covariant CustomQrCode oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      _generateQr();
    }
  }

  /// إنشاء QR Image عند الحاجة فقط
  void _generateQr() {
    try {
      _qrImage = QrCodeService.createQrImage(data: widget.data);

      _error = null;
    } catch (e) {
      _qrImage = null;
      _error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null || _qrImage == null) {
      return _buildError(context);
    }

    return Semantics(
      label: widget.semanticsLabel ?? 'QR Code',
      image: true,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.containerColor,
          borderRadius: widget.borderRadius,
        ),
        child: Align(
          alignment: widget.alignment,
          child: SizedBox.square(
            dimension: widget.size,
            child: PrettyQrView(
              qrImage: _qrImage!,
              decoration: widget.decoration,
            ),
          ),
        ),
      ),
    );
  }

  /// واجهة الخطأ
  Widget _buildError(BuildContext context) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error ?? Exception('Invalid QR'));
    }

    return SizedBox.square(
      dimension: widget.size,
      child: Center(
        child: Icon(
          Icons.qr_code_2,
          size: widget.size * 0.35,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
