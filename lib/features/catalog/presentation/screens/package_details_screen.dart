import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_details_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/dialogs/package_action_dialogs.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_details_content.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_voucher_card_showcase.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/document_details/custom_document_action_bar.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة تفاصيل باقة كروت الإنترنت الفاخرة (VIP Telecom Package Details Screen)
///
/// تجسد أعلى معايير هندسة الواجهات وتجربة المستخدم النظيفة:
/// - شاشة تركيبية تصريحية بحتة (Pure Declarative Page Composition) بدون أي دوال مساعدة أو منطق.
/// - محاكاة ثلاثية الأبعاد لكرت شحن إنترنت فاخر [PackageVoucherCardShowcase].
/// - شبكة مكعبات المواصفات الفنية التفاعلية [PackageBentoSpecsGrid].
/// - رادار المقارنة المالية والتجارية وهوامش التوفير [PackageCommercialPricingRadar].
/// - بطاقة بيانات الاعتماد والشبكة التابعة [PackageMetadataSurfaceCard].
/// - شريط الإجراءات والتحكم التنفيذي الثابت [CustomDocumentActionBar].
class PackageDetailsScreen extends GetView<PackageDetailsController> {
  const PackageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. حالة التحميل الهيكلي الأنيق
      if (controller.isLoading.value && controller.package.value == null) {
        return CustomAppScaffold(
          showBackButton: true,
          appBarTitle: 'تفاصيل باقة الكروت',
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: CustomStateView.loading(
              presentation: CustomStatePresentation.skeletonOnly,
              skeleton: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 4,
                cardHeight: 160.h,
              ),
            ),
          ),
        );
      }

      // 2. حالة الخطأ مع إمكانية إعادة المحاولة
      if (controller.errorMessage.value != null &&
          controller.package.value == null) {
        return CustomAppScaffold(
          appBarTitle: 'تفاصيل باقة الكروت',
          body: CustomErrorState(
            title: 'تعذر تحميل تفاصيل الباقة',
            subtitle: controller.errorMessage.value!,
            onRetry: controller.refreshDetails,
          ),
        );
      }

      final package = controller.package.value;

      // 3. حالة عدم العثور على الباقة
      if (package == null) {
        return CustomAppScaffold(
          appBarTitle: 'تفاصيل باقة الكروت',
          body: Center(
            child: CustomEmptyState(
              icon: Icons.wifi_tethering_off_rounded,
              title: 'لم يتم العثور على الباقة',
              subtitle:
                  'قد تكون هذه الباقة حُذفت أو لم يعد بالإمكان الوصول إليها.',
              actionLabel: 'العودة للكتالوج',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      return CustomAppScaffold(
        appBarTitle: package.packageName,
        bottomNavigationBar: CustomDocumentActionBar(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 760.w),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton.secondary(
                      text: package.isActive ? 'تعطيل الباقة' : 'تفعيل الباقة',
                      icon: package.isActive
                          ? Icons.pause_circle_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      size: AppButtonSize.medium,
                      shape: AppButtonShape.rounded,
                      loading: controller.isTogglingStatus.value,
                      onPressed: () =>
                          PackageActionDialogs.showToggleStatusConfirmation(
                            context,
                            package: package,
                            onConfirm: controller.toggleStatus,
                          ),
                    ),
                  ),
                  if (controller.canEditPackage) ...[
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: CustomButton.primary(
                        text: 'تعديل الباقة',
                        icon: Icons.edit_outlined,
                        size: AppButtonSize.medium,
                        shape: AppButtonShape.rounded,
                        onPressed: controller.navigateToEdit,
                      ),
                    ),
                  ],
                  if (controller.canDeletePackage) ...[
                    SizedBox(width: AppSpacing.sm),
                    CustomButton.icon(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'حذف الباقة',
                      shape: AppButtonShape.rounded,
                      onPressed: () =>
                          PackageActionDialogs.showDeleteConfirmation(
                            context,
                            package: package,
                            onConfirm: controller.deletePackage,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        body: PackageDetailsContent(package: package, controller: controller),
      );
    });
  }
}
