import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// بطاقة باقة التوريد؛ جميع تعديلات الكمية تتم مباشرة داخل البطاقة.
class ProcurementPackageOptionCard extends StatelessWidget {
  const ProcurementPackageOptionCard({
    super.key,
    required this.package,
    required this.quantity,
    required this.onSetQuantity,
    required this.isCashSale,
  });

  final PackageEntity package;
  final int quantity;
  final ValueChanged<int> onSetQuantity;
  final bool isCashSale;

  String _paperDescription(int count, int sheetSize) {
    if (count <= 0) return 'لم تحدد كمية بعد';
    if (sheetSize <= 0) return '$count كرت';
    final full = count ~/ sheetSize;
    final remainder = count % sheetSize;
    final half = (sheetSize / 2).ceil();
    if (remainder == 0) return full == 1 ? 'ورقة واحدة' : '$full أوراق';
    if (full == 0 && remainder == half) return 'نصف ورقة ($remainder كرت)';
    if (full == 0) return ' $remainder كرت';
    if (remainder == half) return full == 1 ? 'ورقة ونصف' : '$full أوراق ونصف';
    return '${full == 1 ? 'ورقة' : '$full أوراق'} و $remainder كرت';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = CustomColorPicker.parseHex(package.packageColor);
    final active = quantity > 0;
    final sheet = package.packageVoucherCount;
    final half = sheet > 0 ? (sheet / 2).ceil() : 1;
    final unitPrice = isCashSale
        ? package.procurementCashUnitPriceMinor
        : package.procurementCreditUnitPriceMinor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: active ? accent.withValues(alpha: .055) : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: active ? accent.withValues(alpha: .7) : colors.outlineVariant.withValues(alpha: .42), width: active ? 1.5 : 1),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: active ? .10 : .035), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 46.r, height: 46.r, decoration: BoxDecoration(color: accent.withValues(alpha: .14), borderRadius: BorderRadius.circular(14.r)), child: Icon(Icons.wifi_tethering_rounded, color: accent, size: 23.r)),
          AppSpacing.hSm,
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(package.packageName, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.titleSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.w900)),
            AppSpacing.vXxs,
            Text('باقة من شبكة ${package.networkName ?? 'الشبكة المورّدة'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
          ])),
          if (active) const CustomChip(label: 'مضافة للطلب', icon: Icons.check_circle_rounded, isCompact: true),
        ]),
        AppSpacing.vSm,
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(color: accent.withValues(alpha: .075), borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Row(children: [
            Icon(Icons.layers_rounded, color: accent, size: 17.r),
            AppSpacing.hXs,
            Expanded(child: Text('الورقة الواحدة تحتوي $sheet كرت', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w800))),
            Text(_paperDescription(quantity, sheet), style: AppTypography.labelSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.w700)),
          ]),
        ),
        AppSpacing.vSm,
        Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.xs, children: [
          _Spec(icon: Icons.data_usage_rounded, text: package.balanceDisplay),
          _Spec(icon: Icons.timer_outlined, text: package.uptimeDisplay),
          _Spec(icon: Icons.event_available_outlined, text: package.validityDisplay),
        ]),
        AppSpacing.vSm,
        Row(children: [
          Expanded(child: _PricePill(label: 'نقدي', value: package.procurementCashUnitPriceMinor == null ? '—' : AmountFormatter.formatMinor(package.procurementCashUnitPriceMinor!), active: isCashSale, accent: accent)),
          AppSpacing.hXs,
          Expanded(child: _PricePill(label: 'آجل', value: package.procurementCreditUnitPriceMinor == null ? '—' : AmountFormatter.formatMinor(package.procurementCreditUnitPriceMinor!), active: !isCashSale, accent: accent)),
        ]),
        AppSpacing.vSm,
        Divider(height: 1, color: colors.outlineVariant.withValues(alpha: .4)),
        AppSpacing.vSm,
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('الكمية المطلوبة', style: AppTypography.labelLarge.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800)),
            Text('${_paperDescription(quantity, sheet)} • $quantity كرت', style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
          ])),
          CustomButton.icon(icon: Icons.remove_rounded, tooltip: 'إنقاص كرت واحد', size: AppButtonSize.small, dimension: 38, onPressed: quantity > 0 ? () => onSetQuantity(quantity - 1) : null),
          AppSpacing.hXs,
          Container(
            constraints: BoxConstraints(minWidth: 56.r, minHeight: 40.r),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(color: accent.withValues(alpha: .10), borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: accent.withValues(alpha: .3))),
            child: Text('$quantity', style: AppTypography.titleMedium.copyWith(color: accent, fontWeight: FontWeight.w900)),
          ),
          AppSpacing.hXs,
          CustomButton.icon(icon: Icons.add_rounded, tooltip: 'إضافة كرت واحد', size: AppButtonSize.small, dimension: 38, backgroundColor: accent.withValues(alpha: .13), foregroundColor: accent, onPressed: () => onSetQuantity(quantity + 1)),
        ]),
        AppSpacing.vSm,
        Row(children: [
          Expanded(child: CustomButton.outline(text: '− ورقة', icon: Icons.remove_circle_outline_rounded, size: AppButtonSize.small, foregroundColor: colors.onSurfaceVariant, onPressed: quantity > 0 ? () => onSetQuantity((quantity - (sheet > 0 ? sheet : 1)).clamp(0, 1 << 30)) : null)),
          AppSpacing.hXs,
          Expanded(child: CustomButton.outline(text: '½ ورقة', icon: Icons.exposure_minus_1_rounded, size: AppButtonSize.small, foregroundColor: colors.onSurfaceVariant, onPressed: quantity > 0 ? () => onSetQuantity((quantity - half).clamp(0, 1 << 30)) : null)),
          AppSpacing.hXs,
          Expanded(child: CustomButton.outline(text: '+ ورقة', icon: Icons.add_circle_outline_rounded, size: AppButtonSize.small, foregroundColor: accent, onPressed: () => onSetQuantity(quantity + (sheet > 0 ? sheet : 1))),
        ]),
        AppSpacing.vXs,
        Align(alignment: AlignmentDirectional.centerEnd, child: CustomButton.text(text: 'تصفير الكمية', icon: Icons.restart_alt_rounded, size: AppButtonSize.small, foregroundColor: colors.error, onPressed: quantity > 0 ? () => onSetQuantity(0) : null)),
      ]),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 14.r, color: context.colors.onSurfaceVariant),
    AppSpacing.hXxs,
    Text(text, style: AppTypography.labelSmall.copyWith(color: context.colors.onSurfaceVariant)),
  ]);
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.label, required this.value, required this.active, required this.accent});
  final String label, value;
  final bool active;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: active ? accent.withValues(alpha: .10) : colors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: active ? accent.withValues(alpha: .35) : colors.outlineVariant.withValues(alpha: .3))),
      child: Row(children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: active ? accent : colors.onSurfaceVariant, fontWeight: FontWeight.w700)),
        const Spacer(),
        Flexible(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelMedium.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800))),
      ]),
    );
  }
}
