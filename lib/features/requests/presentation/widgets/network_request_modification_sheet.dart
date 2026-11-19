import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/modification_sheet/network_request_approval_notes_section.dart';
import 'package:netsales/features/requests/presentation/widgets/modification_sheet/network_request_catalog_section.dart';
import 'package:netsales/features/requests/presentation/widgets/modification_sheet/network_request_commercial_parties_card.dart';
import 'package:netsales/features/requests/presentation/widgets/modification_sheet/network_request_proposed_items_section.dart';
import 'package:netsales/features/requests/presentation/widgets/modification_sheet/network_request_quotation_preview_section.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// شيت مراجعة وتعديل طلب التوريد لمشغلي الشبكة
///
/// مكون واجهة مستخدم نقي خالٍ تماماً من المنطق (Pure Presentation Widget).
/// تُدار دورة حياة الفتح والتعديل والتحقق والاعتماد بالكامل داخل [NetworkProcurementReviewController].
class NetworkRequestModificationSheet
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestModificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final request = controller.editingRequest.value;
      final lines = controller.modificationLines.toList(growable: false);
      final preview = controller.currentPreview.value;
      final isLoadingEditor = controller.isLoadingEditor.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (request != null) ...[
            NetworkRequestCommercialPartiesCard(request: request),
            AppSpacing.vMd,
          ],
          if (isLoadingEditor && lines.isEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: const CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.cards,
                  itemCount: 2,
                  showCardSurface: true,
                ),
              ),
            ),
          ] else ...[
            NetworkRequestProposedItemsSection(
              request: request,
              lines: lines,
            ),
            AppSpacing.vLg,
            const NetworkRequestCatalogSection(),
            AppSpacing.vLg,
            const NetworkRequestApprovalNotesSection(),
            AppSpacing.vLg,
            NetworkRequestQuotationPreviewSection(
              request: request,
              preview: preview,
              lines: lines,
            ),
          ],
          AppSpacing.vXl,
        ],
      );
    });
  }
}
