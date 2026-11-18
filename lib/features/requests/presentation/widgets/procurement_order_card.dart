import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_accordion.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_actions.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_header.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_metrics_bar.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة طلب التوريد المتطورة بنظام الأكورديون الأنيق (Procurement Order Card - Executive Edition)
///
/// تجسد المعمارية الموحدة لطلبات التوريد في مساحة نقطة البيع ومساحة شبكة التوزيع:
/// حواف 24.r، ظلال مزدوجة بمسحة زمردية، شريط ترويسة بهوية الطلب وشعار واسم الطرف الآخر
/// مع معرّف الـ UUID كاملاً بدون انقطاع، شريط شارات أفقي مقاوم للتجاوز، أكورديون تفاعلي أنيق،
/// وسكة قياس ثلاثية المبالغ محمية بـ FittedBox، وأزرار إجراءات ذكية بحسب سياق العمل.
class ProcurementOrderCard extends StatelessWidget {
  const ProcurementOrderCard({
    super.key,
    required this.request,
    required this.onDetails,
    this.isNetworkView = false,
    this.isExpanded = false,
    this.onToggleExpand,
    this.onEdit,
    this.onCancel,
    this.onDelete,
    this.onApprove,
    this.onModify,
    this.onReject,
  });

  final RequestEntity request;
  final VoidCallback onDetails;
  final bool isNetworkView;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onModify;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = EnumPresentationRegistry.resolveRequestStatus(
      request.status,
      serverLabel: request.statusLabel,
    );
    final saleType = EnumPresentationRegistry.resolveSaleType(
      request.saleType,
      serverLabel: request.saleTypeLabel,
    );
    final packages = request.items
        .map((item) => item.voucherPackage)
        .whereType<PackageEntity>()
        .toList(growable: false);

    return CustomInteractiveBounce(
      onTap: onDetails,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: colors.primary.withValues(alpha: .15),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF064F43).withValues(alpha: .065),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. ترويسة هوية الطلب والطرف المقابل
            ProcurementOrderCardHeader(
              request: request,
              status: status,
              saleType: saleType,
              isNetworkView: isNetworkView,
            ),

            // 2. المحتوى الداخلي للطلب
            Padding(
              padding: EdgeInsets.fromLTRB(14.r, 12.r, 14.r, 14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // لوحة الباقات المضمنة في الطلب بنظام الأكورديون الأنيق
                  ProcurementOrderCardAccordion(
                    request: request,
                    packages: packages,
                    isExpanded: isExpanded,
                    onToggle: onToggleExpand,
                  ),
                  AppSpacing.vSm,

                  // سكة القياسات الثلاثية (باقات، كمية، إجمالي الطلب)
                  ProcurementOrderCardMetricsBar(
                    itemCount: request.items.length,
                    totalQuantity: request.totalVouchers,
                    totalAmount: request.requestTotalAmount,
                  ),
                  AppSpacing.vSm,

                  // شريط أزرار الإجراءات السياقية
                  ProcurementOrderCardActions(
                    request: request,
                    onDetails: onDetails,
                    isNetworkView: isNetworkView,
                    onEdit: onEdit,
                    onCancel: onCancel,
                    onDelete: onDelete,
                    onApprove: onApprove,
                    onModify: onModify,
                    onReject: onReject,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
