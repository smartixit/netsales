import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_specification_card.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_specification_divider.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_specification_item.dart';

/// شريط مواصفات الباقة (الرصيد، الصلاحية، مدة الاستخدام)
class ProcurementPackageSpecificationStrip extends StatelessWidget {
  const ProcurementPackageSpecificationStrip({
    super.key,
    required this.specifications,
  });

  final List<ProcurementPackageSpecificationItem> specifications;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .065),
        borderRadius: BorderRadius.circular(17.r),
      ),
      child: Row(
        children: [
          for (var i = 0; i < specifications.length; i++) ...[
            Expanded(
              child: ProcurementPackageSpecificationCard(
                icon: specifications[i].icon,
                label: specifications[i].label,
                value: specifications[i].value,
              ),
            ),
            if (i < specifications.length - 1)
              ProcurementPackageSpecificationDivider(
                color: colors.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}
