import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card/invoice_card_accordion_item_row.dart';

/// لوحة استعراض بنود الفاتورة بنظام الأكورديون الحصري الانسيابي
class InvoiceCardAccordion extends StatelessWidget {
  const InvoiceCardAccordion({
    super.key,
    required this.invoice,
    required this.isExpanded,
    this.onToggle,
  });

  final InvoiceEntity invoice;
  final bool isExpanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .28),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .30),
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── شريط رأس الأكورديون القابل للنقر ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: 16.r,
                      color: colors.primary,
                    ),
                    AppSpacing.hXs,
                    Flexible(
                      child: Text(
                        'الباقات والكميات (${invoice.items.length})',
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (invoice.totalVouchersCount > 0) ...[
                      AppSpacing.hXs,
                      Text(
                        '• ${invoice.totalVouchersCount} كرت',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      isExpanded ? 'إخفاء البنود' : 'عرض التفاصيل',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.hXxs,
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18.r,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── درج البنود المتحرك ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
              child: invoice.items.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(
                        'لا توجد بنود تفصيلية مسجلة.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(
                          color: colors.outlineVariant.withValues(alpha: .25),
                          height: 1,
                        ),
                        AppSpacing.vSm,
                        ...invoice.items.map(
                          (item) => InvoiceCardAccordionItemRow(item: item),
                        ),
                      ],
                    ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }
}
