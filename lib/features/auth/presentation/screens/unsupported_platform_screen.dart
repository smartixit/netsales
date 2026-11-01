import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_text_styles.dart';
import 'package:netsales/widgets/buttons/custom_filled_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// ============================================================================
/// شاشة حظر وتوجيه حسابات إدارة المنصة العامة (AUTH-06: UnsupportedPlatformClientScreen)
/// ============================================================================
/// تمنع حسابات SUPER_ADMIN و SUPPORT_AGENT من العمل عبر تطبيق الهاتف،
/// وترشدهم رسمياً لاستخدام تطبيق إدارة المنصة المكتبي المستقل لنظام Windows.
class UnsupportedPlatformClientScreen extends StatelessWidget {
  const UnsupportedPlatformClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomAppScaffold(
      useSurfaceMesh: true,
      safeAreaTop: true,
      safeAreaBottom: true,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // أيقونة شاشة سطح المكتب ونظام Windows
              Container(
                width: 96.w,
                height: 96.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.desktop_windows_rounded,
                    size: 48.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // العنوان الرسمي
              Text(
                'حساب إدارة المنصة العامة',
                style: AppTextStyles.h2(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.darkSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // رسالة التوضيح المعمارية
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  'تطبيق الهاتف مخصص حصرياً للعمليات التشغيلية الميدانية بين مزودي الشبكات (NETWORK) ونقاط البيع (POS).\n\n'
                  'وفقاً للسياسة المعمارية المعتمدة للمنظومة، تُدار مهام الإدارة العامة للنظام، والاشتراكات السحابية، والرقابة الأمنية الشاملة حصرياً عبر تطبيق الإدارة المكتبي لنظام Windows.',
                  style: AppTextStyles.body(context).copyWith(
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 32.h),

              // زر تسجيل الخروج الآمن
              CustomFilledButton(
                text: 'تسجيل الخروج الآمن',
                icon: Icons.logout_rounded,
                backgroundColor: AppColors.primary,
                onPressed: () async {
                  if (Get.isRegistered<SessionService>()) {
                    await SessionService.to.terminateSession();
                  }
                  Get.offAllNamed(AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

