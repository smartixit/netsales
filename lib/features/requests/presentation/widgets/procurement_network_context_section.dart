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

/// بطاقة اختيار الشبكة الموردة؛ الاختيار يتم من بطاقات داخلية وليس قائمة منسدلة.
class ProcurementNetworkContextSection extends GetView<PosProcurementController> {
  const ProcurementNetworkContextSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final links = controller.linkedNetworks;
      final selected = links.firstWhereOrNull(
        (link) => link.networkId == controller.selectedNetworkId.value,
      );
      final isExpanded = controller.expandedProcurementContext.value == 'network';
      return _ContextSelectorCard(
        title: 'الشبكة المورّدة',
        subtitle: 'الجهة التي ستوفر الباقات والأسعار لهذا الطلب',
        icon: Icons.cell_tower_rounded,
        name: selected?.network?.networkName ?? 'اختر الشبكة المورّدة',
        detail: selected?.network?.networkAddress ?? 'حدد الشبكة المرتبطة بنقطة البيع',
        logoUrl: selected?.network?.networkProfileLogoUrl,
        initial: TextFormatter.avatarInitial(selected?.network?.networkName, fallback: 'ش'),
        isExpanded: isExpanded,
        isLoading: controller.isLoadingNetworks.value,
        options: links.map((link) => _ContextOption(
          id: link.networkId,
          name: link.network?.networkName ?? 'شبكة #${link.networkId}',
          detail: link.network?.networkAddress ?? 'شبكة مورّدة مرتبطة',
          logoUrl: link.network?.networkProfileLogoUrl,
          initial: TextFormatter.avatarInitial(link.network?.networkName, fallback: 'ش'),
          selected: link.networkId == controller.selectedNetworkId.value,
          onTap: () {
            controller.onNetworkSelected(link.networkId);
            controller.expandedProcurementContext.value = '';
          },
        )).toList(growable: false),
        onToggle: links.length > 1
            ? () => controller.expandedProcurementContext.value = isExpanded ? '' : 'network'
            : null,
        emptyMessage: links.isEmpty ? 'لا توجد شبكات مورّدة نشطة مرتبطة بنقطة البيع حالياً.' : null,
      );
    });
  }
}

class _ContextSelectorCard extends StatelessWidget {
  const _ContextSelectorCard({
    required this.title, required this.subtitle, required this.icon,
    required this.name, required this.detail, required this.logoUrl,
    required this.initial, required this.isExpanded, required this.isLoading,
    required this.options, required this.onToggle, this.emptyMessage,
  });
  final String title, subtitle, name, detail, initial;
  final IconData icon;
  final String? logoUrl, emptyMessage;
  final bool isExpanded, isLoading;
  final List<_ContextOption> options;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
          Container(width: 34.r, height: 34.r, decoration: BoxDecoration(color: colors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(11.r)), child: Icon(icon, color: colors.primary, size: 18.r)),
          AppSpacing.hSm,
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.titleSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800)),
            Text(subtitle, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
          ])),
          if (onToggle != null)
            CustomButton.text(
              text: isExpanded ? 'إغلاق' : 'تغيير',
              icon: isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.swap_horiz_rounded,
              size: AppButtonSize.small,
              onPressed: onToggle,
            ),
        ]),
        AppSpacing.vSm,
        if (isLoading)
          const LinearProgressIndicator()
        else if (emptyMessage != null)
          Text(emptyMessage!, style: AppTypography.bodySmall.copyWith(color: colors.error))
        else
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [colors.primary.withValues(alpha: .105), colors.secondary.withValues(alpha: .045)]),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.primary.withValues(alpha: .18)),
            ),
            child: Row(children: [
              CustomCachedImage.logo(
                url: logoUrl, size: 48.r, borderRadius: 14.r, fallbackText: initial,
                fallbackTextStyle: AppTypography.titleMedium.copyWith(color: colors.primary, fontWeight: FontWeight.w900),
              ),
              AppSpacing.hSm,
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.titleSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800)),
                AppSpacing.vXxs,
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
              ])),
              Icon(Icons.check_circle_rounded, color: colors.primary, size: 21.r),
            ]),
          ),
        if (isExpanded && options.length > 1) ...[
          AppSpacing.vSm,
          ...options.map((option) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs),
            child: _ContextOptionTile(option: option),
          )),
        ],
      ]),
    );
  }
}

class _ContextOption {
  const _ContextOption({required this.id, required this.name, required this.detail, required this.logoUrl, required this.initial, required this.selected, required this.onTap});
  final int id;
  final String name, detail, initial;
  final String? logoUrl;
  final bool selected;
  final VoidCallback onTap;
}

class _ContextOptionTile extends StatelessWidget {
  const _ContextOptionTile({required this.option});
  final _ContextOption option;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: option.selected ? colors.primary.withValues(alpha: .07) : colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: option.onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: option.selected ? colors.primary.withValues(alpha: .55) : colors.outlineVariant.withValues(alpha: .3))),
          child: Row(children: [
            CustomCachedImage.logo(url: option.logoUrl, size: 38.r, borderRadius: 11.r, fallbackText: option.initial),
            AppSpacing.hSm,
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(option.name, style: AppTypography.labelLarge.copyWith(color: colors.onSurface, fontWeight: FontWeight.w700)),
              Text(option.detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
            ])),
            if (option.selected) Icon(Icons.check_circle_rounded, color: colors.primary),
          ]),
        ),
      ),
    );
  }
}
