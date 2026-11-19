import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// قسم إضافة ملاحظات المشرف على الاعتماد في شيت التعديل
class NetworkRequestApprovalNotesSection
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestApprovalNotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller.modificationNoteController,
          label: 'ملاحظة الاعتماد لنقطة البيع (اختياري)',
          hint: 'أضف توضيحاً يظهر لنقطة البيع في تفاصيل الطلب والفاتورة الصادرة...',
          maxLines: 2,
          isRequired: false,
        ),
      ],
    );
  }
}
