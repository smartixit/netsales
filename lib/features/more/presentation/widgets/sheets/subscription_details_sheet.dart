import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

/// ============================================================================
/// نافذة تفاصيل اشتراك النظام السحابي (SubscriptionDetailsSheet)
/// ============================================================================
/// تعرض باقة الاشتراك السحابي للمنشأة، وحدود بطاقات الكروت، وتاريخ التجديد
/// مع إمكانية التواصل الفوري لترقية الحساب أو التجديد المؤسسي.
class SubscriptionDetailsSheet extends StatelessWidget {
  const SubscriptionDetailsSheet({super.key});

  /// فتح النافذة السفلية المنبثقة
  static Future<void> show(BuildContext context) {
    return CustomBottomSheet.show<void>(
      title: 'اشتراك وخطة النظام السحابية',
      subtitle: 'تفاصيل الخطة المعتمدة، ترخيص المنشأة، وحدود العمليات',
      leadingIcon: Icons.workspace_premium_rounded,
      scrollable: true,
      child: const SubscriptionDetailsSheet(),
    );
  }

  Future<void> _contactSupport() async {
    final uri = Uri.parse('https://wa.me/967770000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = Get.find<MoreController>();
    final subscription = controller.subscription;

    final expiryDateStr = subscription?.endDate != null
        ? DateFormat('yyyy/MM/dd').format(subscription!.endDate!)
        : 'غير محدد (نشط دائماً)';

    final planName = subscription?.planName ?? 'الباقة المؤسسية المتقدمة';
    final statusLabel = subscription?.statusLabel ?? 'ساري ونشط';
    final daysRemaining = subscription?.daysRemaining ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // بطاقة ملخص الباقة
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary,
                colors.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppElevation.level3(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: colors.onPrimary,
                      size: 26.r,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      statusLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.vLg,
              Text(
                planName,
                style: AppTypography.headlineSmall.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vXs,
              Text(
                'تاريخ التجديد القادم: $expiryDateStr',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onPrimary.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),

        AppSpacing.vLg,

        // مؤشرات حدود العمليات
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              _buildLimitRow(
                context,
                title: 'الأيام المتبقية في الخطة الحالية',
                value: '$daysRemaining يوم',
                icon: Icons.hourglass_top_rounded,
              ),
              AppSpacing.vMd,
              const Divider(height: 1),
              AppSpacing.vMd,
              _buildLimitRow(
                context,
                title: 'تزامن الأجهزة والجلسات الفورية',
                value: 'مفتوح وغير محدود',
                icon: Icons.sync_rounded,
              ),
              AppSpacing.vMd,
              const Divider(height: 1),
              AppSpacing.vMd,
              _buildLimitRow(
                context,
                title: 'الدعم الفني المباشر',
                value: 'دعم مؤسسي مخصص 24/7',
                icon: Icons.support_agent_rounded,
              ),
            ],
          ),
        ),

        AppSpacing.vXl,

        // زر التواصل والترقية
        CustomButton.primary(
          text: 'طلب ترقية الخطة أو التجديد المؤسسي',
          icon: Icons.upgrade_rounded,
          onPressed: _contactSupport,
        ),
      ],
    );
  }

  Widget _buildLimitRow(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 22.r),
        AppSpacing.hMd,
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
      ],
    );
  }
}
