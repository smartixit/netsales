import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_metric_card_data.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/document_details/custom_document_action_bar.dart';
import 'package:netsales/widgets/document_details/custom_document_details_hero.dart';
import 'package:netsales/widgets/document_details/custom_document_metrics_strip.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة تفاصيل باقة كروت الإنترنت بالمعايير القيادية الموحدة (PackageDetailsScreen)
///
/// تجسد المعمارية المؤسسية النظيفة لشاشات التفاصيل المستندية:
/// - استهلاك مباشر للمكونات العامة الموحدة [CustomDocumentDetailsHero], [CustomDocumentMetricsStrip],
///   [CustomSurfaceCard], [CustomInfoListTile], و [CustomDocumentActionBar].
/// - تفويض حالة الباقة للسجل المركزي [EnumPresentationRegistry].
/// - تفويض تنسيق المبالغ حصرياً للأداة المعتمدة [AmountFormatter.formatValue].
class PackageDetailsScreen extends GetView<PackageCatalogController> {
  const PackageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الهيكلي
      if (controller.isLoading.value && controller.selectedPackage.value == null) {
        return CustomAppScaffold(
          appBarTitle: 'تفاصيل باقة الكروت',
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: const CustomStateView.loading(
              presentation: CustomStatePresentation.skeletonOnly,
              skeleton: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 4,
                cardHeight: 140,
              ),
            ),
          ),
        );
      }

      final package = controller.selectedPackage.value;

      // 2. حالة عدم العثور على الباقة
      if (package == null) {
        return CustomAppScaffold(
          appBarTitle: 'تفاصيل باقة الكروت',
          body: Center(
            child: CustomEmptyState(
              icon: Icons.wifi_tethering_off_rounded,
              title: 'لم يتم العثور على الباقة',
              subtitle: 'قد تكون هذه الباقة حُذفت أو لم يعد بالإمكان الوصول إليها.',
              actionLabel: 'العودة للكتالوج',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      final statusPres = EnumPresentationRegistry.resolvePackageStatus(
        package.packageStatus,
      );

      return CustomAppScaffold(
        appBarTitle: package.packageName,
        bottomNavigationBar: CustomDocumentActionBar(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton.secondary(
                      text: package.isActive ? 'تعطيل الباقة' : 'تفعيل الباقة',
                      icon: package.isActive
                          ? Icons.pause_circle_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      size: AppButtonSize.medium,
                      shape: AppButtonShape.pill,
                      loading: controller.isTogglingStatus.value,
                      onPressed: () => controller.promptToggleStatus(package),
                    ),
                  ),
                  if (controller.canEditPackage) ...[
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: CustomButton.primary(
                        text: 'تعديل الباقة',
                        icon: Icons.edit_rounded,
                        size: AppButtonSize.medium,
                        shape: AppButtonShape.pill,
                        onPressed: () => controller.initEditForm(package),
                      ),
                    ),
                  ],
                  if (controller.canDeletePackage) ...[
                    SizedBox(width: AppSpacing.sm),
                    CustomButton.danger(
                      text: 'حذف',
                      icon: Icons.delete_outline_rounded,
                      size: AppButtonSize.medium,
                      shape: AppButtonShape.pill,
                      loading: controller.isDeleting.value,
                      onPressed: () => controller.promptDeletePackage(package),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.cardPadding,
            AppSpacing.cardPadding,
            AppSpacing.cardPadding,
            AppSpacing.xl,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. ترويسة تفاصيل الباقة (Hero)
                  CustomDocumentDetailsHero(
                    reference: 'باقة #${package.packageId}',
                    dateLabel: package.createdAt != null
                        ? 'تاريخ الإنشاء: ${package.createdAt!.year}/${package.createdAt!.month}/${package.createdAt!.day}'
                        : 'معتمدة في النظام',
                    heroTitle: package.packageName,
                    statusPresentation: statusPres,
                    actorLabel: package.networkName != null
                        ? 'شبكة ${package.networkName}'
                        : null,
                  ),

                  AppSpacing.vMd,

                  // 2. شريط المؤشرات المالية الثلاثية
                  CustomDocumentMetricsStrip(
                    metrics: [
                      CustomMetricCardData(
                        label: 'السعر الأساسي',
                        value: '${AmountFormatter.formatValue(package.packageVoucherPrice)} ر.ي',
                        icon: Icons.payments_outlined,
                        accentColor: colors.primary,
                        isPrimary: true,
                      ),
                      CustomMetricCardData(
                        label: 'السعر الفعلي نقداً',
                        value: '${AmountFormatter.formatValue(package.effectiveCashPrice)} ر.ي',
                        icon: Icons.price_change_outlined,
                        accentColor: colors.success,
                      ),
                      CustomMetricCardData(
                        label: 'السعر الفعلي آجلاً',
                        value: '${AmountFormatter.formatValue(package.effectiveCreditPrice)} ر.ي',
                        icon: Icons.credit_card_outlined,
                        accentColor: colors.secondary,
                      ),
                    ],
                  ),

                  AppSpacing.vMd,

                  // 3. المواصفات الفنية المعتمدة
                  CustomSurfaceCard(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 20,
                                color: colors.primary,
                              ),
                              AppSpacing.hXs,
                              Text(
                                'المواصفات الفنية للباقة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vMd,
                          CustomInfoListTile(
                            leading: Icon(Icons.wifi_tethering_rounded, color: colors.primary),
                            title: const Text('عدد الكروت في الباقة'),
                            trailing: Text('${package.packageVoucherCount} كرت'),
                          ),
                          if (package.packageBalance > 0)
                            CustomInfoListTile(
                              leading: Icon(Icons.data_usage_rounded, color: colors.primary),
                              title: const Text('حجم الرصيد'),
                              trailing: Text(PackageSpecFormatter.formatData(package.packageBalance)),
                            ),
                          if (package.packageUptime != null && package.packageUptime! > 0)
                            CustomInfoListTile(
                              leading: Icon(Icons.timer_outlined, color: colors.primary),
                              title: const Text('وقت الاتصال المسموح'),
                              trailing: Text(PackageSpecFormatter.formatDuration(package.packageUptime!)),
                            ),
                          if (package.packageValidity != null && package.packageValidity! > 0)
                            CustomInfoListTile(
                              leading: Icon(Icons.calendar_month_outlined, color: colors.primary),
                              title: const Text('فترة الصلاحية'),
                              trailing: Text(PackageSpecFormatter.formatDuration(package.packageValidity!)),
                            ),
                          CustomInfoListTile(
                            leading: Icon(Icons.money_off_rounded, color: colors.success),
                            title: const Text('نسبة الخصم النقدي'),
                            trailing: Text('${package.packageDefaultCashDiscount.toStringAsFixed(0)}%'),
                          ),
                          CustomInfoListTile(
                            leading: Icon(Icons.credit_card_rounded, color: colors.secondary),
                            title: const Text('نسبة الخصم الآجل'),
                            trailing: Text('${package.packageDefaultCreditDiscount.toStringAsFixed(0)}%'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  AppSpacing.vXl,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
