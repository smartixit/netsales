import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// حاوية أكورديون قابلة للطي والتوسيع موحدة وعامة للبطاقات (Enterprise Card Accordion)
///
/// تُستخدم في كافة بطاقات النظام (الطلبات، الفواتير، المصروفات، والشركاء التجاريين)
/// لتوحيد شكل الحاوية، الرسوم المتحركة، وأزرار التبديل دون أي تكرار للكود.
class CustomCardAccordion extends StatelessWidget {
  const CustomCardAccordion({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
    this.icon = Icons.layers_outlined,
    this.count,
    this.expandLabel = 'عرض التفاصيل',
    this.collapseLabel = 'إخفاء التفاصيل',
  });

  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;
  final IconData icon;
  final int? count;
  final String expandLabel;
  final String collapseLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final countSuffix = count != null ? ' ($count)' : '';
    final fullTitle = '$title$countSuffix';

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
                      icon,
                      size: 16.r,
                      color: colors.primary,
                    ),
                    AppSpacing.hXs,
                    Flexible(
                      child: Text(
                        fullTitle,
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      isExpanded ? collapseLabel : expandLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.hXxs,
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 260),
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

          // ── محتوى الأكورديون مع حركة انزلاق ناعمة ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            reverseDuration: const Duration(milliseconds: 220),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeInCubic,
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 10.h),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
