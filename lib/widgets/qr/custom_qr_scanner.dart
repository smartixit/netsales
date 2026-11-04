import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/qr/custom_qr_scanner_controller.dart';
import 'package:netsales/widgets/qr/custom_qr_scanner_overlay.dart';
import 'package:netsales/widgets/qr/qr_scan_result.dart';

/// شاشة/ويدجت ماسح رمز الاستجابة السريعة المؤسسي (Enterprise Custom QR Scanner)
///
/// مكون مستقل وعام تماماً (Domain-Agnostic)، مبني كـ StatelessWidget مع GetX
/// بدون أي StatefulWidget أو setState()، ويوفر تجربة مسح سريعة وفخمة.
class CustomQrScanner extends StatelessWidget {
  /// رد الاتصال عند التقاط رمز صالح
  final ValueChanged<QrScanResult> onScan;

  /// عنوان الشاشة
  final String title;

  /// إرشادات الاستخدام الموجهة للمستخدم
  final String instruction;

  /// تفعيل زر استيراد صورة من المعرض
  final bool enableGalleryImport;

  /// تفعيل زر تشغيل/إطفاء الفلاش
  final bool enableTorch;

  /// تفعيل زر تبديل الكاميرا (أمامية/خلفية)
  final bool enableCameraSwitch;

  /// تفعيل التنبيه الصوتي
  final bool enableAudioFeedback;

  /// طبقة تأطير مخصصة (إن وجدت)
  final Widget? customOverlay;

  /// زر الإغلاق / الرجوع
  final VoidCallback? onClose;

  /// معرّف فريد للمتحكم لتجنب تضارب الحالات المتعددة
  final String? controllerTag;

  const CustomQrScanner({
    super.key,
    required this.onScan,
    this.title = 'مسح رمز الاستجابة السريعة',
    this.instruction = 'قم بتوجيه الكاميرا نحو رمز QR داخل الإطار',
    this.enableGalleryImport = true,
    this.enableTorch = true,
    this.enableCameraSwitch = true,
    this.enableAudioFeedback = true,
    this.customOverlay,
    this.onClose,
    this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomQrScannerController>(
      init: CustomQrScannerController(
        onScan: onScan,
        enableAudioFeedback: enableAudioFeedback,
      ),
      tag: controllerTag,
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. معاينة الكاميرا المباشرة
              MobileScanner(
                controller: controller.mobileScannerController,
                onDetect: controller.handleBarcodeCapture,
                errorBuilder: (context, error) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam_off_rounded,
                            size: 48.r,
                            color: Colors.white70,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'تعذر الوصول إلى الكاميرا. يرجى التأكد من منح الإذن من إعدادات الجهاز.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 2. طبقة التأطير والتعتيم
              customOverlay ?? const CustomQrScannerOverlay(),

              // 3. شريط التحكم العلوي
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر الإغلاق
                        if (onClose != null)
                          CustomButton.icon(
                            icon: Icons.close_rounded,
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black45,
                            onPressed: onClose,
                          )
                        else
                          const SizedBox(width: 44),

                        // العنوان
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // أدوات التحكم: المصباح وتبديل الكاميرا
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (enableTorch)
                              Obx(
                                () => CustomButton.icon(
                                  icon: controller.isTorchOn.value
                                      ? Icons.flash_on_rounded
                                      : Icons.flash_off_rounded,
                                  foregroundColor: controller.isTorchOn.value
                                      ? Colors.amber
                                      : Colors.white,
                                  backgroundColor: Colors.black45,
                                  onPressed: controller.toggleTorch,
                                ),
                              ),
                            if (enableCameraSwitch) ...[
                              SizedBox(width: AppSpacing.sm),
                              CustomButton.icon(
                                icon: Icons.flip_camera_ios_rounded,
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black45,
                                onPressed: controller.switchCamera,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. القسم السفلي: التعليمات وزر استيراد الصور ورسائل الخطأ
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // رسالة الخطأ إن وُجدت
                        Obx(() {
                          final error = controller.errorMessage.value;
                          if (error == null || error.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            margin: EdgeInsets.only(bottom: AppSpacing.md),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.error.withValues(
                                alpha: 0.9,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.white,
                                  size: 18.r,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Flexible(
                                  child: Text(
                                    error,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // بطاقة التعليمات الإرشادية
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            instruction,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // زر استيراد من المعرض
                        if (enableGalleryImport) ...[
                          SizedBox(height: AppSpacing.md),
                          CustomButton.outline(
                            text: 'اختيار من معرض الصور',
                            icon: Icons.photo_library_outlined,
                            onPressed: controller.pickAndScanFromGallery,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
