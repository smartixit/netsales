import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/cards/custom_kpi_summary_card.dart';

/// شريط ملخص المؤشرات والحالات الأفقي الموحد (CustomStatusSummaryStrip)
///
/// يدعم استعراض بطاقات الـ KPI أفقياً مع التمرير السلس وحالات التحميل والاختيار.
class CustomStatusSummaryStrip extends StatelessWidget {
  const CustomStatusSummaryStrip({
    super.key,
    required this.cards,
    this.selectedKey,
    this.isLoading = false,
    this.onSelectKey,
  });

  final List<CustomKpiCardData> cards;
  final String? selectedKey;
  final bool isLoading;
  final ValueChanged<String?>? onSelectKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) AppSpacing.hXs,
              CustomKpiSummaryCard(
                data: cards[i],
                isLoading: isLoading,
                isSelected: selectedKey == cards[i].statusKey,
                onTap: onSelectKey != null
                    ? () {
                        if (selectedKey == cards[i].statusKey) {
                          onSelectKey!(null);
                        } else {
                          onSelectKey!(cards[i].statusKey);
                        }
                      }
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
