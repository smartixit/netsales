import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شارة تعريفية لفلتر نشط مع إمكانية إزالته بنقرة واحدة
class ActiveFilterItem {
  final String label;
  final VoidCallback onRemove;

  const ActiveFilterItem({
    required this.label,
    required this.onRemove,
  });
}

/// ============================================================================
/// شريط موحد وأنيق لعرض عدد السجلات ونتائج البحث والفلترة (CustomResultsCounterBar)
/// ============================================================================
/// يعرض إجمالي السجلات والعدد المصفى، مع شارات الفلاتر النشطة وزر مسح التصفية
/// بتصميم هادئ ومريح للعين، متوافق مع نظام التصميم والوضع الداكن والفاتح.
class CustomResultsCounterBar extends StatelessWidget {
  /// عدد النتائج المعروضة حالياً بعد البحث والفلترة
  final int count;

  /// إجمالي عدد السجلات الكلي قبل التصفية (اختياري)
  final int? totalCount;

  /// نوع السجل باللغة العربية (مثل: "فاتورة"، "طلب"، "باقة"، "نقطة بيع")
  final String recordLabel;

  /// هل يوجد بحث أو فلترة نشطة حالياً؟
  final bool isFiltered;

  /// هل البيانات قيد التحميل والتحديث؟
  final bool isLoading;

  /// دالة تفريغ كافة الفلاتر والبحث بنقرة واحدة
  final VoidCallback? onClear;

  /// قائمة الفلاتر النشطة لعرضها كشارات تفاعلية قابلة للإزالة فرادى (اختياري)
  final List<ActiveFilterItem> activeFilters;

  const CustomResultsCounterBar({
    super.key,
    required this.count,
    this.totalCount,
    this.recordLabel = 'سجل',
    this.isFiltered = false,
    this.isLoading = false,
    this.onClear,
    this.activeFilters = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final showClearButton = isFiltered && onClear != null && !isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: isFiltered
            ? colors.primary.withValues(alpha: 0.05)
            : colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isFiltered
              ? colors.primary.withValues(alpha: 0.2)
              : colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // 1. أيقونة الدلالة الإحصائية
              Icon(
                isFiltered ? Icons.filter_alt_outlined : Icons.list_alt_rounded,
                size: 16.sp,
                color: isFiltered ? colors.primary : colors.onSurfaceVariant,
              ),
              SizedBox(width: 6.w),

              // 2. نص العداد وحالة النتائج
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            'جاري تحديث النتائج...',
                            key: const ValueKey('loading_text'),
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : Row(
                          key: ValueKey('count_${count}_$totalCount'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isFiltered ? 'نتائج البحث: ' : 'الإجمالي: ',
                              style: AppTypography.labelMedium.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '$count $recordLabel',
                              style: AppTypography.labelMedium.copyWith(
                                color: isFiltered ? colors.primary : colors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (totalCount != null && isFiltered && totalCount != count) ...[
                              SizedBox(width: 4.w),
                              Text(
                                '(من أصل $totalCount)',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),

              // 3. زر مسح التصفية
              if (showClearButton)
                CustomButton.icon(
                  icon: Icons.refresh_rounded,
                  iconSize: 14.sp,
                  dimension: 28.h,
                  backgroundColor: colors.error.withValues(alpha: 0.08),
                  foregroundColor: colors.error,
                  tooltip: 'إلغاء البحث وكافة الفلاتر المطبقة',
                  onPressed: onClear,
                ),
            ],
          ),

          // 4. شارات الفلاتر النشطة إن وجدت
          if (activeFilters.isNotEmpty && !isLoading) ...[
            SizedBox(height: 6.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: activeFilters.map((filter) {
                  return Padding(
                    padding: EdgeInsetsDirectional.only(end: 6.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            filter.label,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          InkWell(
                            onTap: filter.onRemove,
                            borderRadius: BorderRadius.circular(10.r),
                            child: Icon(
                              Icons.close_rounded,
                              size: 13.sp,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

