import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة حظر وتوجيه حسابات إدارة المنصة العامة (AUTH-06: UnsupportedPlatformClientScreen)
/// تمنع حسابات SUPER_ADMIN و SUPPORT_AGENT من العمل عبر تطبيق الهاتف،
/// وترشدهم رسمياً لاستخدام تطبيق إدارة المنصة المكتبي المستقل لنظام Windows.
class UnsupportedPlatformScreen extends StatelessWidget {
  const UnsupportedPlatformScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.desktop_windows_rounded,
                    size: 48.r,
                    color: colors.primary,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'حساب إدارة المنصة العامة',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Text(
                  'تطبيق الهاتف مخصص حصرياً للعمليات التشغيلية الميدانية بين مزودي الشبكات (NETWORK) ونقاط البيع (POS).\n\n'
                  'وفقاً للسياسة المعمارية المعتمدة للمنظومة، تُدار مهام الإدارة العامة للنظام، والاشتراكات السحابية، والرقابة الأمنية الشاملة حصرياً عبر تطبيق الإدارة المكتبي لنظام Windows.',
                  style: AppTypography.bodyMedium.copyWith(
                    height: 1.6,
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 32.h),
              CustomButton(
                text: 'تسجيل الخروج الآمن',
                icon: Icons.logout_rounded,
                onPressed: () async {
                  if (Get.isRegistered<SessionService>()) {
                    await SessionService.to.terminateSession();
                  }
                  await Get.offAllNamed<dynamic>(AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
