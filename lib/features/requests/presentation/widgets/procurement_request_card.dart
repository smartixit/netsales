import 'package:flutter/material.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/pos_procurement_order_card.dart';

/// بطاقة عرض وتفاصيل طلب التوريد الموحدة للمنصة (Procurement Request Card)
///
/// توجه مباشرة وبشكل متوافق مع كافة الأنظمة إلى [ProcurementOrderCard] المتطورة
/// ذات المعمارية الموحدة لشبكة التوزيع ونقاط البيع، مع الحماية الكاملة من الـ Overflow
/// والأكورديون الانسيابي بنظام الألوان والأوراق والكروت وسكة القياسات ثلاثية الأعمدة.
class ProcurementRequestCard extends StatelessWidget {
  final RequestEntity request;
  final bool isNetworkView;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback? onToggleAccordion;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onModify;
  final VoidCallback? onReject;

  const ProcurementRequestCard({
    super.key,
    required this.request,
    this.isNetworkView = false,
    this.isExpanded = false,
    required this.onTap,
    this.onToggleAccordion,
    this.onEdit,
    this.onCancel,
    this.onDelete,
    this.onApprove,
    this.onModify,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return ProcurementOrderCard(
      request: request,
      isNetworkView: isNetworkView,
      isExpanded: isExpanded,
      onDetails: onTap,
      onToggleExpand: onToggleAccordion,
      onEdit: onEdit,
      onCancel: onCancel,
      onDelete: onDelete,
      onApprove: onApprove,
      onModify: onModify,
      onReject: onReject,
    );
  }
}
