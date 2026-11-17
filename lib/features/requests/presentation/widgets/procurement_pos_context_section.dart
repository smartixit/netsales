import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';

/// بطاقة اختيار نقطة البيع التابعة للشبكة المحددة.
class ProcurementPosContextSection extends GetView<PosProcurementController> {
  const ProcurementPosContextSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      final positions = controller.myPosList;
      final selected = controller.activePos;
      final isExpanded = controller.expandedProcurementContext.value == 'pos';
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: .48)),
          boxShadow: [BoxShadow(color: colors.shadow.withValues(alpha: .045), blurRadius: 18, offset: const Offset(0, 7))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 34.r, height: 34.r, decoration: BoxDecoration(color: colors.secondary.withValues(alpha: .12), borderRadius: BorderRadius.circular(11.r)), child: Icon(Icons.storefront_rounded, color: colors.secondary, size: 18.r)),
            AppSpacing.hSm,
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('نقطة البيع', style: AppTypography.titleSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800)),
              Text('الموقع الذي سيستلم الكروت المورّدة', style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
            ])),
            if (positions.length > 1)
              CustomButton.text(
                text: isExpanded ? 'إغلاق' : 'تغيير',
                icon: isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.swap_horiz_rounded,
                size: AppButtonSize.small,
                onPressed: () => controller.expandedProcurementContext.value = isExpanded ? '' : 'pos',
              ),
          ]),
          AppSpacing.vSm,
          if (positions.isEmpty)
            Text('لا توجد نقاط بيع معتمدة ومصرح بها لحسابك حالياً.', style: AppTypography.bodySmall.copyWith(color: colors.error))
          else
            _PosIdentityTile(
              name: selected?.posName ?? 'اختر نقطة البيع',
              detail: selected?.posAddress ?? 'نقطة البيع المحددة لتنفيذ الطلب',
              logoUrl: selected?.posProfileLogoUrl,
              initial: TextFormatter.avatarInitial(selected?.posName, fallback: 'ن'),
              selected: true,
            ),
          if (isExpanded && positions.length > 1) ...[
            AppSpacing.vSm,
            ...positions.map((pos) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () {
                  controller.onPosSelected(pos.posId);
                  controller.expandedProcurementContext.value = '';
                },
                child: _PosIdentityTile(
                  name: pos.posName,
                  detail: pos.posAddress ?? 'نقطة بيع معتمدة',
                  logoUrl: pos.posProfileLogoUrl,
                  initial: TextFormatter.avatarInitial(pos.posName, fallback: 'ن'),
                  selected: pos.posId == controller.selectedPosId.value,
                ),
              ),
            )),
          ],
        ]),
      );
    });
  }
}

class _PosIdentityTile extends StatelessWidget {
  const _PosIdentityTile({required this.name, required this.detail, required this.logoUrl, required this.initial, required this.selected});
  final String name, detail, initial;
  final String? logoUrl;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [colors.secondary.withValues(alpha: .11), colors.primary.withValues(alpha: .045)]),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: selected ? colors.secondary.withValues(alpha: .35) : colors.outlineVariant.withValues(alpha: .3)),
      ),
      child: Row(children: [
        CustomCachedImage.logo(url: logoUrl, size: 48.r, borderRadius: 14.r, fallbackText: initial, fallbackTextStyle: AppTypography.titleMedium.copyWith(color: colors.secondary, fontWeight: FontWeight.w900)),
        AppSpacing.hSm,
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.titleSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800)),
          AppSpacing.vXxs,
          Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
        ])),
        if (selected) Icon(Icons.verified_rounded, color: colors.secondary, size: 21.r),
      ]),
    );
  }
}
