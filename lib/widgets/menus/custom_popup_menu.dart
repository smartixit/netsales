import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ============================================================================
/// كائن عنصر القائمة المنسدلة الموحدة (CustomPopupItem)
/// ============================================================================
/// يمثل عنصراً تفاعلياً قياسياً أو فاصلاً أو عنوان قسم داخل القائمة المنبثقة،
/// ويدعم التخصيص الكامل للأيقونات، الألوان، الحالات التحذيرية/التدميرية،
/// والعناصر التابعة (Trailing) مع تصميم غير مسطح (Non-Flat Rich Layered).
sealed class CustomPopupEntry<T> {
  const CustomPopupEntry();
}

/// عنصر خيار تفاعلي قابل للاختيار
class CustomPopupItem<T> extends CustomPopupEntry<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final bool isDestructive;
  final bool enabled;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CustomPopupItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.textColor,
    this.isDestructive = false,
    this.enabled = true,
    this.trailing,
    this.onTap,
  });
}

/// فاصل خطي أنيق بين مجموعات الخيارات
class CustomPopupDivider<T> extends CustomPopupEntry<T> {
  final double? indent;
  final double? endIndent;

  const CustomPopupDivider({this.indent, this.endIndent});
}

/// عنوان نصي لتجميع الخيارات ضمن تصنيف معين
class CustomPopupSectionHeader<T> extends CustomPopupEntry<T> {
  final String title;

  const CustomPopupSectionHeader({required this.title});
}

/// ============================================================================
/// القائمة المنبثقة المؤسسية الموحدة (CustomPopupMenu)
/// ============================================================================
/// ودجت قياسي يعوض بالكامل استخدام PopupMenuButton الخام، ويوفر:
/// 1. تصميماً ثلاثي الأبعاد غير مسطح (Rich Layered Glassmorphic Depth).
/// 2. حواف ناعمة وظلال تفاعلية متكيفة مع الوضعين الفاتح والداكن عبر AppElevation.
/// 3. أيقونات مؤطرة في حاويات لونية شفافة متناسقة مع طبيعة الإجراء.
/// 4. دعم الإجراءات التدميرية (الحذف، الإلغاء) بتدرجات لونية تحذيرية مميزة.
/// 5. اهتزاز لمسي خفيف فور فتح القائمة أو التفاعل مع عناصرها.
class CustomPopupMenu<T> extends StatelessWidget {
  /// قائمة العناصر والفواصل
  final List<CustomPopupEntry<T>> items;

  /// دالة استدعاء عند تحديد أحد الخيارات
  final ValueChanged<T>? onSelected;

  /// دالة استدعاء عند إلغاء القائمة بدون اختيار
  final VoidCallback? onCanceled;

  /// الويدجت المخصص كمفتاح إطلاق للقائمة (إن لم يحدد، يستخدم الزر الأيقوني الافتراضي)
  final Widget? trigger;

  /// أيقونة زر الإطلاق الافتراضي
  final IconData triggerIcon;

  /// لون أيقونة زر الإطلاق
  final Color? triggerIconColor;

  /// حجم أيقونة زر الإطلاق
  final double? triggerIconSize;

  /// حجم زر الإطلاق الدائري
  final double? triggerDimension;

  /// لون خلفية زر الإطلاق الافتراضي
  final Color? triggerBackgroundColor;

  /// نص التلميح
  final String? tooltip;

  /// موضع القائمة بالنسبة لعنصر الإطلاق
  final PopupMenuPosition position;

  /// إزاحة القائمة يدوياً
  final Offset offset;

  /// الحد الأدنى لعرض القائمة
  final double? minWidth;

  /// تمكين القائمة
  final bool enabled;

  const CustomPopupMenu({
    super.key,
    required this.items,
    this.onSelected,
    this.onCanceled,
    this.trigger,
    this.triggerIcon = Icons.more_vert_rounded,
    this.triggerIconColor,
    this.triggerIconSize,
    this.triggerDimension,
    this.triggerBackgroundColor,
    this.tooltip,
    this.position = PopupMenuPosition.under,
    this.offset = Offset.zero,
    this.minWidth,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveMinWidth = minWidth ?? 170.w;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: colors.surfaceContainerHighest,
          surfaceTintColor: Colors.transparent,
          elevation: 6,
          shadowColor: AppElevation.level4(context).first.color,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
            side: BorderSide(
              color: colors.outline.withValues(alpha: 0.16),
              width: 1.w,
            ),
          ),
        ),
      ),
      child: PopupMenuButton<T>(
        enabled: enabled && items.isNotEmpty,
        tooltip: tooltip,
        position: position,
        offset: offset,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: effectiveMinWidth),
        elevation: 6,
        color: colors.surfaceContainerHighest,
        shadowColor: AppElevation.level4(context).first.color,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdRadius,
          side: BorderSide(
            color: colors.outline.withValues(alpha: 0.16),
            width: 1.w,
          ),
        ),
        onSelected: (value) {
          HapticFeedback.lightImpact();
          onSelected?.call(value);
        },
        onCanceled: () {
          onCanceled?.call();
        },
        itemBuilder: (popupContext) => _buildMenuItems(popupContext, colors),
        child: trigger ?? _buildDefaultTrigger(context, colors),
      ),
    );
  }

  /// بناء زر الإطلاق الافتراضي المحاط بحاوية دائرية أنيقة تفاعلية
  Widget _buildDefaultTrigger(BuildContext context, AppColors colors) {
    final dimension = triggerDimension ?? 36.r;
    final iconSize = triggerIconSize ?? 18.r;
    final iconColor = triggerIconColor ?? colors.onSurfaceVariant;
    // final bgColor = triggerBackgroundColor ?? colors.surfaceContainerLow;

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        // color: bgColor,
        // shape: BoxShape.circle,
        borderRadius: AppRadius.mdRadius,
        // border: Border.all(
        //   color: colors.outline.withValues(alpha: 0.12),
        //   width: 1.w,
        // ),
        // boxShadow: AppElevation.level1(context),
      ),
      alignment: Alignment.center,
      child: Icon(triggerIcon, size: iconSize, color: iconColor),
    );
  }

  /// تحويل العناصر المجردة إلى مدخلات PopupMenuEntry قياسية
  List<PopupMenuEntry<T>> _buildMenuItems(
    BuildContext context,
    AppColors colors,
  ) {
    final entries = <PopupMenuEntry<T>>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item is CustomPopupDivider<T>) {
        entries.add(PopupMenuDivider(height: 10.h));
      } else if (item is CustomPopupSectionHeader<T>) {
        entries.add(_PopupHeaderEntry<T>(title: item.title, colors: colors));
      } else if (item is CustomPopupItem<T>) {
        entries.add(_PopupItemEntry<T>(item: item, colors: colors));
      }
    }

    return entries;
  }
}

/// ============================================================================
/// ودجت العنصر التفاعلي داخل القائمة (Rich Styled Popup Item Entry)
/// ============================================================================
class _PopupItemEntry<T> extends PopupMenuItem<T> {
  _PopupItemEntry({required CustomPopupItem<T> item, required AppColors colors})
    : super(
        value: item.value,
        enabled: item.enabled,
        height: item.subtitle != null ? 52.h : 42.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        onTap: item.onTap,
        child: _PopupItemContent(item: item, colors: colors),
      );
}

class _PopupItemContent<T> extends StatelessWidget {
  final CustomPopupItem<T> item;
  final AppColors colors;

  const _PopupItemContent({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    // تحديد لون الأيقونة والنص بحسب الحالة التدميرية أو التخصيص
    final effectiveColor = !item.enabled
        ? colors.outline
        : item.isDestructive
        ? colors.error
        : (item.iconColor ?? item.textColor ?? colors.onSurface);

    final effectiveTextColor = !item.enabled
        ? colors.outline
        : item.isDestructive
        ? colors.error
        : (item.textColor ?? colors.onSurface);

    return Row(
      children: [
        if (item.icon != null) ...[
          // حاوية الأيقونة المؤطرة بتدرج لوني لطيف ومريح بصرياً
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: item.isDestructive
                  ? colors.error.withValues(alpha: 0.10)
                  : effectiveColor.withValues(alpha: 0.09),
              borderRadius: AppRadius.smRadius,
              border: Border.all(
                color: item.isDestructive
                    ? colors.error.withValues(alpha: 0.20)
                    : effectiveColor.withValues(alpha: 0.15),
                width: 0.8.w,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 15.r, color: effectiveColor),
          ),
          AppSpacing.hSm,
        ],

        // النصوص (العنوان والوصف الفرعي إن وجد)
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: AppTypography.labelMedium.copyWith(
                  color: effectiveTextColor,
                  fontWeight: item.isDestructive
                      ? FontWeight.w700
                      : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.subtitle != null) ...[
                AppSpacing.vXxs,
                Text(
                  item.subtitle!,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                    fontSize: 9.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // العنصر التابع إن وجد
        if (item.trailing != null) ...[AppSpacing.hXs, item.trailing!],
      ],
    );
  }
}

/// ============================================================================
/// ودجت ترويسة القسم داخل القائمة (Section Header)
/// ============================================================================
class _PopupHeaderEntry<T> extends PopupMenuEntry<T> {
  final String title;
  final AppColors colors;

  const _PopupHeaderEntry({required this.title, required this.colors});

  @override
  double get height => 26.h;

  @override
  bool represents(T? value) => false;

  @override
  State<_PopupHeaderEntry<T>> createState() => _PopupHeaderEntryState<T>();
}

class _PopupHeaderEntryState<T> extends State<_PopupHeaderEntry<T>> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Text(
        widget.title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: widget.colors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 9.5.sp,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
