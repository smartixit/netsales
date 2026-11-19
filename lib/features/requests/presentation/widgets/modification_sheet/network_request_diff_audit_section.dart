import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_item_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_removed_item_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/modification_sheet/network_request_preview_item_diff_card.dart';
import 'package:netsales/features/requests/presentation/widgets/modification_sheet/network_request_removed_item_diff_card.dart';

/// قسم سجل الفروقات المباشر وتدقيق التعديلات على بنود الطلب
class NetworkRequestDiffAuditSection extends StatelessWidget {
  const NetworkRequestDiffAuditSection({
    super.key,
    required this.items,
    required this.removedItems,
  });

  final List<RequestModificationPreviewItemEntity> items;
  final List<RequestModificationRemovedItemEntity> removedItems;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 16.r,
              color: colors.onSurfaceVariant,
            ),
            AppSpacing.hXxs,
            Expanded(
              child: Text(
                'سجل الفروقات المباشر على البنود',
                style: AppTypography.labelLarge.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vXs,
        ...items.map((item) => NetworkRequestPreviewItemDiffCard(item: item)),
        if (removedItems.isNotEmpty) ...[
          AppSpacing.vXs,
          ...removedItems.map(
            (item) => NetworkRequestRemovedItemDiffCard(item: item),
          ),
        ],
      ],
    );
  }
}
