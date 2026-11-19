import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_card/network_pos_card_accordion.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_card/network_pos_card_actions.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_card/network_pos_card_header.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة نقطة البيع المرتبطة بنظام الأكورديون الأنيق (Network POS Card)
class NetworkPosCard extends StatelessWidget {
  const NetworkPosCard({
    super.key,
    required this.link,
    required this.onTap,
    this.isExpanded = false,
    this.onToggleExpansion,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final NetworkPosLinkEntity link;
  final VoidCallback onTap;
  final bool isExpanded;
  final VoidCallback? onToggleExpansion;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: colors.primary.withValues(alpha: .12),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.emeraldDeep.withValues(alpha: .04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: .02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. ترويسة البطاقة
            NetworkPosCardHeader(link: link),

            // 2. المحتوى التفاعلي والأكورديون
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: NetworkPosCardAccordion(
                link: link,
                isExpanded: isExpanded,
                onToggle: onToggleExpansion ?? () {},
              ),
            ),

            // 3. أزرار الإجراءات
            NetworkPosCardActions(
              link: link,
              onToggleStatus: onToggleStatus,
              onViewDetails: onTap,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
