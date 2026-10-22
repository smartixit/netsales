import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/core/services/date_picker_service.dart';

/// ============================================================================
/// حقل استمارة منتقي التاريخ والوقت المؤسسي (CustomDatePickerField)
/// ============================================================================
/// يماثل تماماً حقول الإدخال الموحدة [CustomTextField] في الهندسة والمظهر:
/// - يعرض التاريخ أو النطاق المختار بشكل أنيق ومنسق عربياً
/// - يدعم التحقق من الصحة (Validation) وإظهار رسائل الخطأ
/// - يفتح تلقائياً نافذة المنتقي السفلية أو الحوار عند النقر
/// - متكامل بالكامل مع الألوان والخطوط والأبعاد الموحدة دون أرقام أو ألوان سحرية
class CustomDatePickerField extends StatefulWidget {
  const CustomDatePickerField({
    super.key,
    this.value,
    this.onChanged,
    required this.label,
    this.hint,
    this.pickerType = DatePickerSelectionMode.single,
    this.enableTime = false,
    this.showQuickPresets = true,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.isRequired = false,
    this.enabled = true,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.displayFormatter,
    this.dialogTitle,
    this.useDialog = false,
  });

  /// منشئ مخصص لتاريخ مفرد (Single Date)
  factory CustomDatePickerField.single({
    Key? key,
    DateTime? value,
    ValueChanged<DateTime?>? onChanged,
    required String label,
    String? hint,
    bool enableTime = false,
    DateTime? firstDate,
    DateTime? lastDate,
    bool Function(DateTime)? selectableDayPredicate,
    bool isRequired = false,
    bool enabled = true,
    String? Function(DateTime?)? validator,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String Function(DateTime?)? displayFormatter,
    String? dialogTitle,
    bool useDialog = false,
  }) {
    return CustomDatePickerField(
      key: key,
      value: value != null ? [value] : null,
      onChanged: (dates) => onChanged?.call(dates.isNotEmpty ? dates.first : null),
      label: label,
      hint: hint ?? 'اختر التاريخ...',
      pickerType: DatePickerSelectionMode.single,
      enableTime: enableTime,
      showQuickPresets: false,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
      isRequired: isRequired,
      enabled: enabled,
      validator: validator != null
          ? (dates) => validator(dates != null && dates.isNotEmpty ? dates.first : null)
          : null,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      displayFormatter: displayFormatter != null
          ? (dates) => displayFormatter(dates.isNotEmpty ? dates.first : null)
          : null,
      dialogTitle: dialogTitle,
      useDialog: useDialog,
    );
  }

  /// منشئ مخصص لنطاق تواريخ (Date Range)
  factory CustomDatePickerField.range({
    Key? key,
    DateTimeRange? value,
    ValueChanged<DateTimeRange?>? onChanged,
    required String label,
    String? hint,
    bool enableTime = false,
    bool showQuickPresets = true,
    DateTime? firstDate,
    DateTime? lastDate,
    bool Function(DateTime)? selectableDayPredicate,
    bool isRequired = false,
    bool enabled = true,
    String? Function(DateTimeRange?)? validator,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String Function(DateTimeRange?)? displayFormatter,
    String? dialogTitle,
    bool useDialog = false,
  }) {
    DateTimeRange? toRange(List<DateTime?>? dates) {
      if (dates != null && dates.length >= 2 && dates[0] != null && dates[1] != null) {
        return DateTimeRange(start: dates[0]!, end: dates[1]!);
      }
      return null;
    }

    return CustomDatePickerField(
      key: key,
      value: value != null ? [value.start, value.end] : null,
      onChanged: (dates) => onChanged?.call(toRange(dates)),
      label: label,
      hint: hint ?? 'اختر النطاق الزمني...',
      pickerType: DatePickerSelectionMode.range,
      enableTime: enableTime,
      showQuickPresets: showQuickPresets,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
      isRequired: isRequired,
      enabled: enabled,
      validator: validator != null ? (dates) => validator(toRange(dates)) : null,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      displayFormatter: displayFormatter != null
          ? (dates) => displayFormatter(toRange(dates))
          : null,
      dialogTitle: dialogTitle,
      useDialog: useDialog,
    );
  }

  /// القيمة الحالية للتواريخ
  final List<DateTime?>? value;

  /// رد النداء عند تغيير التواريخ
  final ValueChanged<List<DateTime?>>? onChanged;

  /// عنوان الحقل المرجعي
  final String label;

  /// التلميح الإرشادي في حالة عدم وجود قيمة
  final String? hint;

  /// نمط الاختيار (مفرد، نطاق، متعدد)
  final DatePickerSelectionMode pickerType;

  /// تفعيل اختيار الوقت
  final bool enableTime;

  /// إظهار كبسولات الفلاتر السريعة في نمط النطاق
  final bool showQuickPresets;

  /// الحد الأدنى للتاريخ
  final DateTime? firstDate;

  /// الحد الأقصى للتاريخ
  final DateTime? lastDate;

  /// دالة التحقق من قابلية اليوم للاختيار
  final bool Function(DateTime)? selectableDayPredicate;

  /// حقل إلزامي
  final bool isRequired;

  /// تفعيل الحقل
  final bool enabled;

  /// دالة التحقق من صحة القيمة
  final String? Function(List<DateTime?>?)? validator;

  /// أيقونة البادئة
  final Widget? prefixIcon;

  /// أيقونة اللاحقة
  final Widget? suffixIcon;

  /// دالة تنسيق النص المعروض
  final String Function(List<DateTime?>)? displayFormatter;

  /// عنوان نافذة الاختيار المنبثقة
  final String? dialogTitle;

  /// العرض في مربع حوار Dialog بدلاً من BottomSheet
  final bool useDialog;

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  String? _errorText;

  Future<void> _handleTap() async {
    if (!widget.enabled) return;
    HapticFeedback.lightImpact();

    final result = await DatePickerService.instance.showPicker(
      context: context,
      initialValue: widget.value,
      mode: widget.pickerType,
      enableTime: widget.enableTime,
      showQuickPresets: widget.showQuickPresets,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      selectableDayPredicate: widget.selectableDayPredicate,
      title: widget.dialogTitle ?? widget.label,
      useDialog: widget.useDialog,
    );

    if (!mounted) return;

    if (result != null) {
      widget.onChanged?.call(result);
      _validate(result);
    }
  }

  void _validate(List<DateTime?>? value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  void _handleClear() {
    HapticFeedback.lightImpact();
    widget.onChanged?.call([]);
    _validate([]);
  }

  String _formatDisplayText() {
    final list = widget.value;
    if (list == null || list.isEmpty || list.every((d) => d == null)) {
      return '';
    }

    if (widget.displayFormatter != null) {
      return widget.displayFormatter!(list);
    }

    if (widget.pickerType == DatePickerSelectionMode.range) {
      final start = list.isNotEmpty ? list[0] : null;
      final end = list.length > 1 ? list[1] : null;
      return DatePickerService.instance.formatArabicRange(start, end, includeTime: widget.enableTime);
    }

    if (widget.pickerType == DatePickerSelectionMode.single) {
      return DatePickerService.instance.formatArabicDate(
        list.first,
        includeDayName: true,
        includeTime: widget.enableTime,
      );
    }

    return '${list.where((d) => d != null).length} تواريخ محددة';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasValue = widget.value != null &&
        widget.value!.isNotEmpty &&
        widget.value!.any((d) => d != null);
    final displayText = _formatDisplayText();
    final hasError = _errorText != null;

    final borderColor = hasError
        ? colors.error
        : colors.outlineVariant.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. عنوان الحقل (Label)
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            children: [
              Text(
                widget.label,
                style: AppTypography.inputLabel.copyWith(
                  color: widget.enabled
                      ? colors.onSurface
                      : colors.onSurface.withValues(alpha: 0.4),
                ),
              ),
              if (widget.isRequired) ...[
                SizedBox(width: 4.w),
                Text(
                  '*',
                  style: AppTypography.inputLabel.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),

        // 2. حاوية الحقل القابلة للنقر بالارتداد الفيزيائي
        CustomInteractiveBounce(
          onTap: _handleTap,
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? colors.surfaceContainerHighest.withValues(alpha: 0.35)
                  : colors.surfaceContainerHighest.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
              border: Border.all(
                color: borderColor,
                width: hasError ? 1.5.w : 1.w,
              ),
            ),
            child: Row(
              children: [
                // أيقونة البادئة (افتراضياً أيقونة التقويم)
                widget.prefixIcon ??
                    Icon(
                      widget.enableTime
                          ? Icons.access_time_rounded
                          : Icons.calendar_today_rounded,
                      size: 18.r,
                      color: hasError
                          ? colors.error
                          : colors.onSurfaceVariant,
                    ),
                AppSpacing.hSm,

                // النص المعروض أو التلميح
                Expanded(
                  child: Text(
                    hasValue ? displayText : (widget.hint ?? 'اختر التاريخ...'),
                    style: hasValue
                        ? AppTypography.bodyMedium.copyWith(
                            color: widget.enabled
                                ? colors.onSurface
                                : colors.onSurface.withValues(alpha: 0.4),
                            fontWeight: FontWeight.w500,
                          )
                        : AppTypography.inputHint.copyWith(
                            color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // أيقونة اللاحقة أو زر المسح
                if (hasValue && widget.enabled)
                  CustomButton.icon(
                    icon: Icons.close_rounded,
                    tooltip: 'مسح التاريخ',
                    iconSize: 16.r,
                    dimension: 30.r,
                    foregroundColor: colors.onSurfaceVariant,
                    backgroundColor: Colors.transparent,
                    onPressed: _handleClear,
                  )
                else
                  widget.suffixIcon ??
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20.r,
                        color: colors.onSurfaceVariant,
                      ),
              ],
            ),
          ),
        ),

        // 3. رسالة الخطأ التحققي (Validation Error Text)
        if (hasError) ...[
          Padding(
            padding: EdgeInsets.only(top: 4.h, right: 8.w),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 14.r,
                  color: colors.error,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: AppTypography.inputError.copyWith(
                      color: colors.error,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
