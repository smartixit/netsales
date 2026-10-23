import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

/// ============================================================================
/// رأس التبويب القطاعي للعمليات (OperationsSegmentedHeader)
/// ============================================================================
/// غلاف رشيق (Lean Wrapper) يربط [CustomSegmentedBar] بـ [OperationsController].
/// كل منطق العرض يعيش في [CustomSegmentedBar] المشترك — هذا الملف مسؤول فقط
/// عن تحويل بيانات المتحكم إلى [CustomSegmentItem] وتمرير الإجراء.
class OperationsSegmentedHeader extends StatelessWidget {
  final OperationsController controller;

  const OperationsSegmentedHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomSegmentedBar(
          selectedIndex: controller.activeSegmentIndex.value,
          onSegmentChanged: controller.changeSegment,
          items: [
            CustomSegmentItem(
              label: 'فواتير المبيعات',
              count: controller.invoices.length,
            ),
            CustomSegmentItem(
              label: 'طلبات الكروت',
              count: controller.pendingRequestsCount,
              // يُلوَّن badge بالأصفر التحذيري عند وجود طلبات معلقة
              highlightBadge: controller.pendingRequestsCount > 0,
            ),
          ],
        ));
  }
}
