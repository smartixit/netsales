import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_form_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_voucher_card_showcase.dart';

/// هيرو المحاكاة الحية المباشرة لكرت الباقة أثناء الإنشاء أو التعديل (Live Voucher Simulator Hero)
///
/// يعكس تفاعل صاحب الشبكة المباشر مع المنتج، ويحدث بطاقة الكرت ثلاثية الأبعاد فورياً مع كل لمسة
class PackageFormPreviewHero extends GetView<PackageFormController> {
  const PackageFormPreviewHero({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final preview = controller.livePreviewPackage;
          return PackageVoucherCardShowcase(
            package: preview,
            showPricingSummary: true,
          );
        }),
      ],
    );
  }
}
