import 'package:flutter/material.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط إجراءات بطاقة الباقة التنفيذية (Package Card Actions)
///
/// يركز على الإجراء الأهم: الدخول للتفاصيل واستعراض الباقة، مع الحفاظ على النقاء البصري
class PackageCardActions extends StatelessWidget {
  const PackageCardActions({
    super.key,
    required this.package,
    required this.onDetails,
  });

  final PackageEntity package;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return CustomButton.secondary(
      text: 'عرض تفاصيل وهوامش الباقة',
      icon: Icons.arrow_back_rounded,
      size: AppButtonSize.small,
      shape: AppButtonShape.rounded,
      onPressed: onDetails,
    );
  }
}
