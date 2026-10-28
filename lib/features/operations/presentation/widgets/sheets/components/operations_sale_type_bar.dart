import 'package:flutter/material.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

/// ============================================================================
/// شريط تحديد نمط العملية التجاري (OperationsSaleTypeBar)
/// ============================================================================
/// غلاف رشيق (Lean Adapter) يربط نمط البيع النقدي والآجل بودجت [CustomSegmentedBar]
/// الموحد، متوافق كلياً مع معيار الودجات المشتركة والقواعد المعمارية في AGENTS.md.
class OperationsSaleTypeBar extends StatelessWidget {
  final String selectedSaleType;
  final ValueChanged<String> onChanged;

  const OperationsSaleTypeBar({
    super.key,
    required this.selectedSaleType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = selectedSaleType == 'CREDIT' ? 1 : 0;

    return CustomSegmentedBar(
      selectedIndex: selectedIndex,
      onSegmentChanged: (idx) => onChanged(idx == 1 ? 'CREDIT' : 'CASH'),
      items: const [
        CustomSegmentItem(
          label: 'بيع نقدي',
          icon: Icons.payments_rounded,
        ),
        CustomSegmentItem(
          label: 'بيع آجل',
          icon: Icons.credit_score_rounded,
        ),
      ],
    );
  }
}

