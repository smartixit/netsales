import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';

// ─────────────────────────────────────────────────────────────────────────────
// نموذج بيانات عنصر القطاع (SegmentItem)
// ─────────────────────────────────────────────────────────────────────────────
/// يمثل تعريف قطاع واحد داخل [CustomSegmentedBar].
///
/// - [label]         : نص عنوان التبويب.
/// - [count]         : عدد العناصر الحية (يظهر كشارة). اتركه صفراً لإخفاء الشارة.
/// - [highlightBadge]: إن true، تُلوَّن الشارة بلون التحذير (warning) للفت الانتباه.
/// - [icon]          : أيقونة اختيارية تُعرض قبل النص.
class CustomSegmentItem {
  final String label;
  final int count;
  final bool highlightBadge;
  final IconData? icon;

  const CustomSegmentItem({
    required this.label,
    this.count = 0,
    this.highlightBadge = false,
    this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// الودجت الرئيسي (CustomSegmentedBar)
// ─────────────────────────────────────────────────────────────────────────────
/// شريط تبويب قطاعي قابل لإعادة الاستخدام بالكامل (Generic Segmented Tab Bar).
///
/// ## مميزاته:
/// - لا يحمل أي مرجع لـ Feature أو Controller محدد.
/// - يقبل قائمة [CustomSegmentItem] ليُنشئ الأزرار تلقائياً.
/// - يدعم شارات العداد الحية بألوان متكيفة (primary / warning / neutral).
/// - يدعم أيقونة اختيارية لكل قطاع.
/// - كافة الأبعاد تعتمد على [AppSpacing] و [AppRadius] و [flutter_screenutil].
/// - الحركة الانتقالية عبر [AnimatedContainer] بدون أي [Duration] سحري.
///
/// ## مثال الاستخدام:
/// ```dart
/// CustomSegmentedBar(
///   selectedIndex: controller.activeSegmentIndex.value,
///   onSegmentChanged: controller.changeSegment,
///   items: const [
///     CustomSegmentItem(label: 'فواتير المبيعات', count: 12),
///     CustomSegmentItem(label: 'طلبات الكروت', count: 3, highlightBadge: true),
///   ],
/// )
/// ```
class CustomSegmentedBar extends StatelessWidget {
  /// الفهرس النشط حالياً.
  final int selectedIndex;

  /// استدعاء عند النقر على قطاع جديد — يمرر فهرسه.
  final ValueChanged<int> onSegmentChanged;

  /// قائمة القطاعات المطلوب عرضها.
  final List<CustomSegmentItem> items;

  /// Padding خارجي إجباري للحاوية — القيمة الافتراضية تتبع [AppSpacing].
  final EdgeInsetsGeometry? padding;

  const CustomSegmentedBar({
    super.key,
    required this.selectedIndex,
    required this.onSegmentChanged,
    required this.items,
    this.padding,
  }) : assert(items.length >= 2, 'CustomSegmentedBar requires at least 2 items');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) AppSpacing.hXs,
            Expanded(
              child: _SegmentTab(
                item: items[i],
                isSelected: selectedIndex == i,
                onTap: () => onSegmentChanged(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// زر القطاع الداخلي (_SegmentTab) — private لهذا الملف فقط
// ─────────────────────────────────────────────────────────────────────────────
class _SegmentTab extends StatelessWidget {
  final CustomSegmentItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.surface : Colors.transparent,
          borderRadius: AppRadius.mdRadius,
          boxShadow: isSelected ? AppElevation.level1(context) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة اختيارية
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 15.r,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
              AppSpacing.hXxs,
            ],

            // النص الرئيسي
            Flexible(
              child: Text(
                item.label,
                style: AppTypography.titleSmall.copyWith(
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // شارة العداد (تظهر فقط إن count > 0)
            if (item.count > 0) ...[
              AppSpacing.hXxs,
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: item.highlightBadge
                      ? colors.warning.withValues(alpha: 0.15)
                      : (isSelected
                          ? colors.primary.withValues(alpha: 0.12)
                          : colors.onSurfaceVariant.withValues(alpha: 0.10)),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  item.count > 99 ? '99+' : item.count.toString(),
                  style: AppTypography.labelSmall.copyWith(
                    color: item.highlightBadge
                        ? colors.warning
                        : (isSelected
                            ? colors.primary
                            : colors.onSurfaceVariant),
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
