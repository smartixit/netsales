import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/models/app_picked_file.dart';
import 'package:netsales/core/services/app_cache_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/media_gallery/models/media_gallery_item.dart';
import 'package:netsales/widgets/media_gallery/widgets/media_gallery_filmstrip.dart';
import 'package:netsales/widgets/media_gallery/widgets/media_gallery_header_overlay.dart';
import 'package:netsales/widgets/media_gallery/widgets/media_viewer_item.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum _ViewerActionState { none, downloading, sharing, printing }

/// عارض معرض الوسائط والمستندات التفاعلي الشامل لنظام NetSales (MediaGalleryViewer)
///
/// يدعم:
/// - استعراض تفاعلي للصور، مستندات الـ PDF، وجداول البيانات في نافذة واحدة.
/// - إيماءات التمرير الرأسي للإغلاق التفاعلي الناعم (Swipe-to-Dismiss).
/// - شريط مصغرات سفلي تفاعلي (WhatsApp Filmstrip Carousel).
/// - حفظ المستندات والوسائط محلياً، والمشاركة، والطباعة المباشرة.
class MediaGalleryViewer extends StatefulWidget {
  final List<MediaGalleryItem> items;
  final int initialIndex;
  final String? defaultTitle;

  const MediaGalleryViewer({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.defaultTitle,
  });

  /// استدعاء سريع ومريح لفتح المعرض كنافذة عائمة متجاوبة
  static Future<void> show(
    BuildContext context, {
    required List<MediaGalleryItem> items,
    int initialIndex = 0,
    String? defaultTitle,
  }) {
    if (items.isEmpty) return Future.value();

    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (ctx, anim, _) => FadeTransition(
          opacity: anim,
          child: MediaGalleryViewer(
            items: items,
            initialIndex: initialIndex.clamp(0, items.length - 1),
            defaultTitle: defaultTitle,
          ),
        ),
        transitionDuration: AppMotion.fast,
      ),
    );
  }

  /// استدعاء سريع لعرض عنصر فردي مباشر (مثل صورة شخصية أو فاتورة)
  static Future<void> showSingle(
    BuildContext context,
    MediaGalleryItem item,
  ) {
    return show(context, items: [item], initialIndex: 0);
  }

  /// استدعاء سريع لتحويل وعرض ملفات [AppPickedFile] المرفقة
  static Future<void> showPickedFiles(
    BuildContext context, {
    required List<AppPickedFile> files,
    int initialIndex = 0,
  }) {
    final items = files.map(MediaGalleryItem.fromPickedFile).toList();
    return show(context, items: items, initialIndex: initialIndex);
  }

  @override
  State<MediaGalleryViewer> createState() => _MediaGalleryViewerState();
}

class _MediaGalleryViewerState extends State<MediaGalleryViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _showOverlays = true;
  double _dragOffset = 0.0;
  _ViewerActionState _actionState = _ViewerActionState.none;
  final Map<String, Uint8List> _bytesCache = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleOverlays() {
    setState(() => _showOverlays = !_showOverlays);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.primaryDelta ?? 0.0;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 140 ||
        (details.primaryVelocity?.abs() ?? 0) > 800) {
      Navigator.of(context).pop();
    } else {
      setState(() => _dragOffset = 0.0);
    }
  }

  Future<Uint8List?> _resolveItemBytes(MediaGalleryItem item) async {
    if (_bytesCache.containsKey(item.url)) {
      return _bytesCache[item.url];
    }

    if (item.bytes != null && item.bytes!.isNotEmpty) {
      _bytesCache[item.url] = item.bytes!;
      return item.bytes!;
    }

    if (item.isLocalFile) {
      final file = File(item.url);
      if (await file.exists()) {
        final b = await file.readAsBytes();
        _bytesCache[item.url] = b;
        return b;
      }
    } else {
      final b = await AppCacheService.instance.getBytes(item.url);
      if (b != null && b.isNotEmpty) {
        _bytesCache[item.url] = b;
        return b;
      }
    }

    return null;
  }

  Future<void> _downloadCurrentItem() async {
    final item = widget.items[_currentIndex];
    setState(() => _actionState = _ViewerActionState.downloading);

    try {
      final bytes = await _resolveItemBytes(item);
      if (bytes == null || bytes.isEmpty) {
        CustomSnackbar.show(
          title: 'تنبيه',
          message: 'تعذر تنزيل الملف، المحتوى غير متوفر حالياً',
          type: SnackType.warning,
        );
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final ext = item.url.split('.').last.split('?').first;
      final safeExt = ext.isNotEmpty && ext.length <= 5 ? ext : 'bin';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${item.title}.$safeExt';
      final saveFile = File('${dir.path}/$fileName');
      await saveFile.writeAsBytes(bytes);

      CustomSnackbar.show(
        title: 'تم الحفظ بنجاح',
        message: 'تم حفظ الملف في مستندات التطبيق:\n${saveFile.path}',
        type: SnackType.success,
      );

      await OpenFilex.open(saveFile.path);
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ أثناء الحفظ',
        message: 'تعذر إتمام عملية الحفظ: $e',
        type: SnackType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _actionState = _ViewerActionState.none);
      }
    }
  }

  Future<void> _shareCurrentItem() async {
    final item = widget.items[_currentIndex];
    setState(() => _actionState = _ViewerActionState.sharing);

    try {
      final bytes = await _resolveItemBytes(item);
      if (bytes == null || bytes.isEmpty) {
        CustomSnackbar.show(
          title: 'تنبيه',
          message: 'تعذر مشاركة الملف، المحتوى غير جاهز',
          type: SnackType.warning,
        );
        return;
      }

      await Printing.sharePdf(
        bytes: bytes,
        filename: '${item.title}.pdf',
      );
    } catch (_) {
      // مشاركة بديلة عبر فتح الملف في التطبيقات الخارجية
      if (item.isLocalFile) {
        await OpenFilex.open(item.url);
      }
    } finally {
      if (mounted) {
        setState(() => _actionState = _ViewerActionState.none);
      }
    }
  }

  Future<void> _printCurrentItem() async {
    final item = widget.items[_currentIndex];
    setState(() => _actionState = _ViewerActionState.printing);

    try {
      final bytes = await _resolveItemBytes(item);
      if (bytes == null || bytes.isEmpty) {
        CustomSnackbar.show(
          title: 'تنبيه',
          message: 'تعذر بدء الطباعة، لم يتم تحميل المستند بعد',
          type: SnackType.warning,
        );
        return;
      }

      Uint8List printBytes = bytes;

      if (!item.isPdf) {
        // إذا كان العنصر صورة، يتم تضمينها في مستند PDF أحادي الصفحة للطباعة القياسية
        final pdf = pw.Document();
        final image = pw.MemoryImage(bytes);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(16),
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
        printBytes = await pdf.save();
      }

      await Printing.layoutPdf(
        onLayout: (_) => printBytes,
        name: item.title,
      );
    } catch (_) {
      CustomSnackbar.show(
        title: 'خطأ',
        message: 'تعذر معالجة أمر الطباعة',
        type: SnackType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _actionState = _ViewerActionState.none);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentItem = widget.items[_currentIndex];
    final opacity = (1.0 - (_dragOffset.abs() / 320)).clamp(0.2, 1.0);

    return Scaffold(
      backgroundColor: colors.scrim.withValues(alpha: opacity * 0.95),
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. محتوى المعرض التفاعلي مع إمكانية التمرير والسحب
            Transform.translate(
              offset: Offset(0, _dragOffset),
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.items.length,
                onPageChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return MediaViewerItem(
                    item: widget.items[index],
                    onTap: _toggleOverlays,
                    onBytesLoaded: (bytes) {
                      _bytesCache[widget.items[index].url] = bytes;
                    },
                  );
                },
              ),
            ),

            // 2. ترويسة المعرض وأزرار الإجراءات العلوية
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              top: _showOverlays ? 0 : -100.h,
              left: 0,
              right: 0,
              child: MediaGalleryHeaderOverlay(
                currentItem: currentItem,
                currentIndex: _currentIndex,
                totalCount: widget.items.length,
                defaultTitle: widget.defaultTitle,
                isDownloading: _actionState == _ViewerActionState.downloading,
                isSharing: _actionState == _ViewerActionState.sharing,
                isPrinting: _actionState == _ViewerActionState.printing,
                onClose: () => Navigator.of(context).pop(),
                onDownload: _downloadCurrentItem,
                onShare: _shareCurrentItem,
                onPrint: _printCurrentItem,
              ),
            ),

            // 3. شريط المصغرات السفلي التفاعلي
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              bottom: _showOverlays ? 0 : -90.h,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: MediaGalleryFilmstrip(
                  items: widget.items,
                  currentIndex: _currentIndex,
                  onItemTap: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
