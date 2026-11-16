import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_request_item_row.dart';

/// البنود الأصلية التي أرسلها صاحب الطلب، دون استبدالها ببنود الفاتورة.
class ProcurementOriginalItemsSection extends StatelessWidget {
  const ProcurementOriginalItemsSection({
    super.key,
    required this.items,
  });

  final List<RequestItemEntity> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البنود الأصلية في الطلب (${items.length})',
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vSm,
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              'لا توجد بنود مرفقة مع هذا الطلب.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => AppSpacing.vXs,
            itemBuilder: (context, index) => ProcurementRequestItemRow(
              item: items[index],
              index: index,
            ),
          ),
      ],
    );
  }
}
