import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/public_settings_service.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ودجت محتوى دعم ومراجعة الحساب (PendingSupportDialogContent)
///
/// يُعرض داخل [CustomDialog] عند محاولة المستخدم تسجيل الدخول وحسابه أو جهازه لا يزال
/// قيد المراجعة والاعتماد، ليوفر تجربة استخدام احترافية وشعوراً بالطمأنينة وقنوات تواصل مباشرة.
class PendingSupportDialogContent extends StatelessWidget {
  final String message;
  final String? phone;

  const PendingSupportDialogContent({
    super.key,
    required this.message,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. نص رسالة الخادم التوضيحية
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),

        AppSpacing.vMd,

        // 2. بطاقة توضيح مدة المراجعة المتوقعة (SLA Box)
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: colors.warning,
                size: 20.r,
              ),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'تستغرق المراجعة والاعتماد عادة من ساعتين إلى 24 ساعة عمل.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        AppSpacing.vLg,

        // 3. عنوان قنوات التواصل المباشر
        Text(
          'هل ترغب بمتابعة طلبك أو لديك استفسار؟',
          textAlign: TextAlign.center,
          style: AppTypography.labelLarge.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),

        AppSpacing.vSm,

        // 4. زر المراسلة الفورية عبر واتساب
        CustomButton.outline(
          text: 'مراسلة الدعم الفني عبر واتساب',
          prefix: Icons.chat_bubble_outline_rounded,
          foregroundColor: colors.primary,
          borderColor: colors.primary.withValues(alpha: 0.4),
          width: double.infinity,
          onPressed: () {
            final inquiryMsg = (phone != null && phone!.trim().isNotEmpty)
                ? 'مرحباً فريق الدعم، أود الاستفسار عن حالة حسابي رقم (${phone!.trim()}) قيد المراجعة في نظام NetSales.'
                : 'مرحباً فريق الدعم، أود الاستفسار عن حالة حسابي قيد المراجعة في نظام NetSales.';
            UrlLauncherService.openWhatsApp(
              phoneNumber: PublicSettingsService.instance.supportWhatsApp,
              message: inquiryMsg,
            );
          },
        ),

        AppSpacing.vXs,

        // 5. زر المراسلة عبر البريد الإلكتروني
        CustomButton.outline(
          text: 'مراسلة الدعم عبر البريد الإلكتروني',
          prefix: Icons.mail_outline_rounded,
          foregroundColor: colors.onSurface,
          borderColor: colors.outlineVariant,
          width: double.infinity,
          onPressed: () {
            final inquiryMsg = (phone != null && phone!.trim().isNotEmpty)
                ? 'مرحباً فريق الدعم، أود الاستفسار عن حالة حسابي رقم (${phone!.trim()}) قيد المراجعة في نظام NetSales.'
                : 'مرحباً فريق الدعم، أود الاستفسار عن حالة حسابي قيد المراجعة في نظام NetSales.';
            UrlLauncherService.sendEmail(
              to: PublicSettingsService.instance.supportEmail,
              subject: 'استفسار بخصوص حساب قيد المراجعة والاعتماد',
              body: inquiryMsg,
            );
          },
        ),
      ],
    );
  }
}
