import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_details_skeleton_view.dart';
import 'package:netsales/features/operations/presentation/widgets/request_audit_status_card.dart';
import 'package:netsales/features/operations/presentation/widgets/request_details_action_dock.dart';
import 'package:netsales/features/operations/presentation/widgets/request_hero_bond_card.dart';
import 'package:netsales/features/operations/presentation/widgets/request_items_card.dart';
import 'package:netsales/features/operations/presentation/widgets/request_notes_card.dart';
import 'package:netsales/features/operations/presentation/widgets/request_parties_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/sheets/invoice_print_format_sheet.dart';

/// ============================================================================
/// شاشة تفاصيل طلب توريد الكروت السيادية (VoucherRequestDetailsScreen)
/// ============================================================================
/// مجمّع تركيبي رشيق يعرض تفاصيل طلب التوريد بنمط السند الرقمي المعتمد:
/// يتيح المراجعة الفورية، اعتماد وتوليد الفاتورة، أو الرفض والإلغاء مع رصيف قرارات عائم.
class VoucherRequestDetailsScreen extends GetView<OperationsController> {
  const VoucherRequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      showBackButton: true,
      appBarTitle: 'تفاصيل طلب التوريد',
      centerTitle: true,
      useSurfaceMesh: true,
      extendBodyBehindAppBar: true,
      actions: [
        CustomButton.icon(
          icon: Icons.share_outlined,
          tooltip: 'طباعة ومشاركة الطلب',
          onPressed: () {
            final request = controller.selectedRequest.value;
            if (request != null) {
              InvoicePrintFormatSheet.show(context, request: request);
            }
          },
          dimension: 40.r,
          iconSize: 18.r,
          backgroundColor: Colors.transparent,
        ),
        AppSpacing.hXs,
      ],
      bottomNavigationBar: Obx(() {
        final request = controller.selectedRequest.value;
        if (request == null || controller.isLoadingRequestDetails.value) {
          return const SizedBox.shrink();
        }
        return RequestDetailsActionDock(
          request: request,
          controller: controller,
        );
      }),
      body: Obx(() {
        if (controller.isLoadingRequestDetails.value) {
          return const OperationsDetailsSkeletonView();
        }

        if (controller.requestDetailsError.value.isNotEmpty) {
          return CustomErrorState(
            title: 'تعذر تحميل بيانات الطلب',
            subtitle: controller.requestDetailsError.value,
            onRetry: controller.refreshCurrentRequest,
          );
        }

        final request = controller.selectedRequest.value;
        if (request == null) {
          return const CustomEmptyState(
            title: 'الطلب غير متوفر',
            subtitle: 'لم يتم العثور على أي بيانات مطابقة لهذا الطلب',
          );
        }

        return RefreshIndicator(
          color: colors.primary,
          onRefresh: controller.refreshCurrentRequest,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: ResponsiveContentWrapper(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.appBarHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. بطاقة السند الرقمي الهيرو لطلب التوريد
                    RequestHeroBondCard(request: request),

                    AppSpacing.vMd,

                    // 2. بطاقة أطراف طلب التوريد السيادية
                    RequestPartiesCard(request: request),

                    AppSpacing.vMd,

                    // 3. بطاقة بنود الباقات والكميات المطلوبة مع المحاذاة الدقيقة
                    RequestItemsCard(request: request),

                    // 4. بطاقة ملاحظات وتعليمات الطلب إن وجدت
                    if (request.requestNote != null &&
                        request.requestNote!.trim().isNotEmpty) ...[
                      AppSpacing.vMd,
                      RequestNotesCard(note: request.requestNote!.trim()),
                    ],

                    // 5. سجل التدقيق والاعتماد للطلبات المعالجة
                    if (!request.isPending) ...[
                      AppSpacing.vMd,
                      RequestAuditStatusCard(request: request),
                    ],

                    AppSpacing.vLg,
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
