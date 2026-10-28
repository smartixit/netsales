import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';
import 'package:netsales/features/more/presentation/widgets/more_logout_section.dart';
import 'package:netsales/features/more/presentation/widgets/more_menu_group.dart';
import 'package:netsales/features/more/presentation/widgets/more_menu_tile.dart';
import 'package:netsales/features/more/presentation/widgets/more_profile_hero_card.dart';
import 'package:netsales/features/more/presentation/widgets/more_quick_metrics_row.dart';
import 'package:netsales/features/more/presentation/widgets/more_wallet_card.dart';
import 'package:netsales/features/more/presentation/widgets/sheets/authorized_sessions_sheet.dart';
import 'package:netsales/features/more/presentation/widgets/sheets/bank_accounts_sheet.dart';
import 'package:netsales/features/more/presentation/widgets/sheets/operational_expenses_sheet.dart';
import 'package:netsales/features/more/presentation/widgets/sheets/subscription_details_sheet.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/home_tab_shell.dart';

/// ============================================================================
/// شاشة قطاع المزيد والمركز المالي التنفيذية (MoreScreen)
/// ============================================================================
/// مجمّع تركيبي رشيق (Lean Composite Assembler) لقطاع المزيد، يجمع الهوية المالية،
/// ملخصات الحساب، مجموعات القوائم، وتأكيد تسجيل الخروج، خالٍ تماماً من دوال البناء المساعدة.
class MoreScreen extends GetView<MoreController> {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return HomeTabShell.scrollable(
      onRefresh: () => controller.loadOverview(isRefresh: true),
      child: Obx(() {
        if (controller.isLoading.value && controller.overview.value == null) {
          return const CustomSkeletonFeed(itemCount: 4, cardHeight: 110);
        }

        return Column(
          children: [
            // 1. بطاقة الهوية الشخصية ومظهر التطبيق
            MoreProfileHeroCard(user: controller.currentUser),

            AppSpacing.vMd,

            // 2. بطاقة المحفظة المالية التشغيلية المتقدمة
            MoreWalletCard(
              wallet: controller.wallet,
              controller: controller,
            ),

            AppSpacing.vMd,

            // 3. شريط المؤشرات الحيوية السريعة
            MoreQuickMetricsRow(
              totalExpenses: controller.totalExpenses,
              subscription: controller.subscription,
              support: controller.support,
            ),

            AppSpacing.vLg,

            // 4. مجموعة القوائم الأولى: الإدارة والعمليات المالية
            MoreMenuGroup(
              title: 'الإدارة والعمليات المالية',
              items: [
                MoreMenuTile(
                  icon: Icons.account_balance_rounded,
                  iconColor: colors.primary,
                  iconBgColor: colors.primaryContainer.withValues(
                    alpha: 0.35,
                  ),
                  title: 'الحسابات المصرفية',
                  subtitle: 'إدارة وتغذية الحسابات البنكية المعتمدة',
                  onTap: () => BankAccountsSheet.show(context),
                ),
                MoreMenuTile(
                  icon: Icons.payments_rounded,
                  iconColor: colors.secondary,
                  iconBgColor: colors.secondaryContainer.withValues(
                    alpha: 0.35,
                  ),
                  title: 'المصروفات التشغيلية',
                  subtitle: 'تسجيل وتتبع نفقات وإيصالات المنشأة',
                  onTap: () => OperationalExpensesSheet.show(context),
                ),
                MoreMenuTile(
                  icon: Icons.confirmation_number_rounded,
                  iconColor: colors.tertiary,
                  iconBgColor: colors.tertiaryContainer.withValues(
                    alpha: 0.35,
                  ),
                  title: 'باقات الكروت والخصومات',
                  subtitle: 'إعداد فئات الباقات وخصومات نقاط التوزيع',
                  onTap: () => Get.toNamed(AppRoutes.voucherPackages),
                ),
              ],
            ),

            AppSpacing.vMd,

            // 5. مجموعة القوائم الثانية: الخدمات والدعم المؤسسي
            MoreMenuGroup(
              title: 'الخدمات والدعم والاشتراكات',
              items: [
                MoreMenuTile(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: colors.success,
                  iconBgColor: colors.successContainer.withValues(
                    alpha: 0.35,
                  ),
                  title: 'اشتراك وخطة النظام',
                  subtitle: 'تفاصيل الخطة السحابية وتجديد الترخيص',
                  onTap: () => SubscriptionDetailsSheet.show(context),
                ),
                MoreMenuTile(
                  icon: Icons.support_agent_rounded,
                  iconColor: colors.warning,
                  iconBgColor: colors.warningContainer.withValues(
                    alpha: 0.35,
                  ),
                  title: 'مركز الدعم والمساعدة',
                  subtitle: 'فتح تذاكر فنية ومتابعة الردود المباشرة',
                  onTap: () {},
                ),
              ],
            ),

            AppSpacing.vMd,

            // 6. مجموعة القوائم الثالثة: الأجهزة والجلسات والتفضيلات
            MoreMenuGroup(
              title: 'الأجهزة والجلسات والتفضيلات',
              items: [
                MoreMenuTile(
                  icon: Icons.devices_rounded,
                  iconColor: colors.primary,
                  iconBgColor: colors.primaryContainer.withValues(
                    alpha: 0.35,
                  ),
                  title: 'الأجهزة والجلسات المصرح بها',
                  subtitle: 'إدارة الأجهزة الموثوقة ومتابعة النشاط',
                  trailing: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${controller.activeSessionsCount} نشط',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => AuthorizedSessionsSheet.show(context),
                ),
                MoreMenuTile(
                  icon: Icons.notifications_active_outlined,
                  iconColor: colors.secondary,
                  iconBgColor: colors.secondaryContainer.withValues(
                    alpha: 0.35,
                  ),
                  title: 'إعدادات الإشعارات والتنبيهات',
                  subtitle: 'تخصيص الرسائل النصية القصيرة وتنبيهات الرصيد',
                  onTap: () {},
                ),
              ],
            ),

            AppSpacing.vLg,

            // 7. قسم تسجيل الخروج الآمن
            MoreLogoutSection(controller: controller),
          ],
        );
      }),
    );
  }
}
