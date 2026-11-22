import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/date_picker_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// حقل منتقي التاريخ الموحد، مع دعم Form والقيم المتحكم بها وغير المتحكم بها.
///
/// يدعم الاختيار المفرد والنطاق والمتعدد. تتم إدارة قيمة النموذج والتحقق من
/// صحتها عبر FormField، بينما تبقى عملية عرض المنتقي مفوضة إلى DatePickerService.
class CustomDatePickerField extends FormField<List<DateTime?>> {
  CustomDatePickerField({
    super.key,
    List<DateTime?>? value,
    this.onChanged,
    FormFieldSetter<List<DateTime?>>? onSaved,
    required this.label,
    this.hint,
    this.pickerType = DatePickerSelectionMode.single,
    this.enableTime = false,
    this.showQuickPresets = true,
    this.firstDate,
    this.lastDate,
    this.currentDate,
    this.selectableDayPredicate,
    this.isRequired = false,
    this.requiredMessage = 'هذا الحقل مطلوب',
    this.rangeIncompleteMessage = 'يرجى تحديد تاريخ البداية والنهاية',
    this.outOfRangeMessage = 'التاريخ المحدد خارج النطاق المسموح',
    this.unselectableDateMessage = 'أحد التواريخ المحددة غير متاح',
    bool enabled = true,
    this.readOnly = false,
    this.clearable = true,
    FormFieldValidator<List<DateTime?>>? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    this.prefixIcon,
    this.suffixIcon,
    this.displayFormatter,
    this.dialogTitle,
    this.useDialog = false,
    this.maxDisplayLines = 2,
  }) : value = _normalizeDatePickerValue(value, pickerType),
       assert(
         firstDate == null ||
             lastDate == null ||
             !_dateOnly(firstDate).isAfter(_dateOnly(lastDate)),
         'firstDate must be on or before lastDate.',
       ),
       assert(maxDisplayLines >= 1 && maxDisplayLines <= 3),
       super(
         initialValue: _normalizeDatePickerValue(value, pickerType),
         enabled: enabled,
         autovalidateMode: autovalidateMode,
         validator: (candidate) => _validateDatePickerValue(
           candidate,
           pickerType: pickerType,
           isRequired: isRequired,
           requiredMessage: requiredMessage,
           rangeIncompleteMessage: rangeIncompleteMessage,
           outOfRangeMessage: outOfRangeMessage,
           unselectableDateMessage: unselectableDateMessage,
           firstDate: firstDate,
           lastDate: lastDate,
           selectableDayPredicate: selectableDayPredicate,
           validator: validator,
         ),
         onSaved: onSaved == null
             ? null
             : (candidate) => onSaved(
                   _normalizeDatePickerValue(candidate, pickerType),
                 ),
         builder: _buildCustomDatePickerField,
       );

  /// منشئ التاريخ المفرد.
  factory CustomDatePickerField.single({
    Key? key,
    DateTime? value,
    ValueChanged<DateTime?>? onChanged,
    FormFieldSetter<DateTime?>? onSaved,
    required String label,
    String? hint,
    bool enableTime = false,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    bool isRequired = false,
    String requiredMessage = 'هذا الحقل مطلوب',
    bool enabled = true,
    bool readOnly = false,
    bool clearable = true,
    String? Function(DateTime?)? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String Function(DateTime?)? displayFormatter,
    String? dialogTitle,
    bool useDialog = false,
    int maxDisplayLines = 2,
  }) {
    DateTime? extractDate(List<DateTime?>? dates) {
      if (dates == null || dates.isEmpty) return null;
      for (final date in dates) {
        if (date != null) return date;
      }
      return null;
    }

    return CustomDatePickerField(
      key: key,
      value: value == null ? null : [value],
      onChanged: onChanged == null
          ? null
          : (dates) => onChanged(extractDate(dates)),
      onSaved: onSaved == null
          ? null
          : (dates) => onSaved(extractDate(dates)),
      label: label,
      hint: hint ?? 'اختر التاريخ...',
      pickerType: DatePickerSelectionMode.single,
      enableTime: enableTime,
      showQuickPresets: false,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      isRequired: isRequired,
      requiredMessage: requiredMessage,
      enabled: enabled,
      readOnly: readOnly,
      clearable: clearable,
      validator: validator == null
          ? null
          : (dates) => validator(extractDate(dates)),
      autovalidateMode: autovalidateMode,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      displayFormatter: displayFormatter == null
          ? null
          : (dates) => displayFormatter(extractDate(dates)),
      dialogTitle: dialogTitle,
      useDialog: useDialog,
      maxDisplayLines: maxDisplayLines,
    );
  }

  /// منشئ نطاق التواريخ.
  factory CustomDatePickerField.range({
    Key? key,
    DateTimeRange? value,
    ValueChanged<DateTimeRange?>? onChanged,
    FormFieldSetter<DateTimeRange?>? onSaved,
    required String label,
    String? hint,
    bool enableTime = false,
    bool showQuickPresets = true,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    bool isRequired = false,
    String requiredMessage = 'هذا الحقل مطلوب',
    String rangeIncompleteMessage = 'يرجى تحديد تاريخ البداية والنهاية',
    bool enabled = true,
    bool readOnly = false,
    bool clearable = true,
    String? Function(DateTimeRange?)? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String Function(DateTimeRange?)? displayFormatter,
    String? dialogTitle,
    bool useDialog = false,
    int maxDisplayLines = 2,
  }) {
    DateTimeRange? extractRange(List<DateTime?>? dates) {
      final normalized = _normalizeDatePickerValue(
        dates,
        DatePickerSelectionMode.range,
      );
      if (normalized.length < 2 ||
          normalized[0] == null ||
          normalized[1] == null) {
        return null;
      }

      return DateTimeRange(
        start: normalized[0]!,
        end: normalized[1]!,
      );
    }

    return CustomDatePickerField(
      key: key,
      value: value == null ? null : [value.start, value.end],
      onChanged: onChanged == null
          ? null
          : (dates) => onChanged(extractRange(dates)),
      onSaved: onSaved == null
          ? null
          : (dates) => onSaved(extractRange(dates)),
      label: label,
      hint: hint ?? 'اختر النطاق الزمني...',
      pickerType: DatePickerSelectionMode.range,
      enableTime: enableTime,
      showQuickPresets: showQuickPresets,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      isRequired: isRequired,
      requiredMessage: requiredMessage,
      rangeIncompleteMessage: rangeIncompleteMessage,
      enabled: enabled,
      readOnly: readOnly,
      clearable: clearable,
      validator: validator == null
          ? null
          : (dates) => validator(extractRange(dates)),
      autovalidateMode: autovalidateMode,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      displayFormatter: displayFormatter == null
          ? null
          : (dates) => displayFormatter(extractRange(dates)),
      dialogTitle: dialogTitle,
      useDialog: useDialog,
      maxDisplayLines: maxDisplayLines,
    );
  }

  /// منشئ اختيار مجموعة من التواريخ المتفرقة.
  factory CustomDatePickerField.multi({
    Key? key,
    List<DateTime>? value,
    ValueChanged<List<DateTime>>? onChanged,
    FormFieldSetter<List<DateTime>>? onSaved,
    required String label,
    String? hint,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    bool isRequired = false,
    String requiredMessage = 'هذا الحقل مطلوب',
    bool enabled = true,
    bool readOnly = false,
    bool clearable = true,
    String? Function(List<DateTime>?)? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String Function(List<DateTime>)? displayFormatter,
    String? dialogTitle,
    bool useDialog = false,
    int maxDisplayLines = 2,
  }) {
    List<DateTime> extractDates(List<DateTime?>? dates) =>
        _normalizeDatePickerValue(
          dates,
          DatePickerSelectionMode.multi,
        ).whereType<DateTime>().toList();

    return CustomDatePickerField(
      key: key,
      value: value,
      onChanged: onChanged == null
          ? null
          : (dates) => onChanged(extractDates(dates)),
      onSaved: onSaved == null
          ? null
          : (dates) => onSaved(extractDates(dates)),
      label: label,
      hint: hint ?? 'اختر التواريخ...',
      pickerType: DatePickerSelectionMode.multi,
      enableTime: false,
      showQuickPresets: false,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      isRequired: isRequired,
      requiredMessage: requiredMessage,
      enabled: enabled,
      readOnly: readOnly,
      clearable: clearable,
      validator: validator == null
          ? null
          : (dates) => validator(extractDates(dates)),
      autovalidateMode: autovalidateMode,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      displayFormatter: displayFormatter == null
          ? null
          : (dates) => displayFormatter(extractDates(dates)),
      dialogTitle: dialogTitle,
      useDialog: useDialog,
      maxDisplayLines: maxDisplayLines,
    );
  }

  /// القيمة الخارجية الحالية. عند تمرير onChanged تكون القيمة متحكماً بها.
  final List<DateTime?>? value;
  final ValueChanged<List<DateTime?>>? onChanged;

  final String label;
  final String? hint;
  final DatePickerSelectionMode pickerType;
  final bool enableTime;
  final bool showQuickPresets;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? currentDate;
  final bool Function(DateTime)? selectableDayPredicate;
  final bool isRequired;
  final String requiredMessage;
  final String rangeIncompleteMessage;
  final String outOfRangeMessage;
  final String unselectableDateMessage;
  final bool readOnly;
  final bool clearable;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String Function(List<DateTime?>)? displayFormatter;
  final String? dialogTitle;
  final bool useDialog;
  final int maxDisplayLines;

  bool get canInteract => enabled && !readOnly;

  @override
  FormFieldState<List<DateTime?>> createState() =>
      _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState
    extends FormFieldState<List<DateTime?>> {
  CustomDatePickerField get _fieldWidget =>
      widget as CustomDatePickerField;

  @override
  void didUpdateWidget(covariant FormField<List<DateTime?>> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previous = oldWidget as CustomDatePickerField;
    final current = _fieldWidget;
    final valueChanged = !listEquals(previous.value, current.value);
    final selectionModeChanged = previous.pickerType != current.pickerType;
    final validationRulesChanged =
        previous.isRequired != current.isRequired ||
        previous.requiredMessage != current.requiredMessage ||
        previous.rangeIncompleteMessage != current.rangeIncompleteMessage ||
        previous.outOfRangeMessage != current.outOfRangeMessage ||
        previous.unselectableDateMessage != current.unselectableDateMessage ||
        previous.firstDate != current.firstDate ||
        previous.lastDate != current.lastDate ||
        previous.selectableDayPredicate != current.selectableDayPredicate ||
        previous.validator != current.validator ||
        previous.autovalidateMode != current.autovalidateMode;

    if (valueChanged || selectionModeChanged) {
      setValue(
        _normalizeDatePickerValue(current.value, current.pickerType),
      );
    }

    // Re-evaluate an existing or previously interacted field after an
    // external value or rule update so stale validation messages cannot linger.
    if ((valueChanged || selectionModeChanged || validationRulesChanged) &&
        (hasError || hasInteractedByUser)) {
      validate();
    }
  }
}

Widget _buildCustomDatePickerField(FormFieldState<List<DateTime?>> fieldState) {
  final field = fieldState.widget as CustomDatePickerField;
  final colors = fieldState.context.colors;
  final currentValue = fieldState.value ?? const <DateTime?>[];
  final normalizedValue = _normalizeDatePickerValue(
    currentValue,
    field.pickerType,
  );
  final hasValue = normalizedValue.any((date) => date != null);
  final displayText = _formatDatePickerValue(field, normalizedValue);
  final canInteract = field.canInteract;
  final hasError = fieldState.hasError;

  Future<void> openPicker(BuildContext context) async {
    if (!canInteract) return;

    final result = await DatePickerService.instance.showPicker(
      context: context,
      initialValue: normalizedValue,
      mode: field.pickerType,
      enableTime: field.enableTime,
      showQuickPresets: field.showQuickPresets,
      firstDate: field.firstDate,
      lastDate: field.lastDate,
      currentDate: field.currentDate,
      selectableDayPredicate: field.selectableDayPredicate,
      title: field.dialogTitle ?? field.label,
      useDialog: field.useDialog,
    );

    if (!context.mounted || !fieldState.mounted || result == null) return;

    final nextValue = _normalizeDatePickerValue(result, field.pickerType);
    fieldState.didChange(nextValue);
    field.onChanged?.call(nextValue);
  }

  void clearValue() {
    if (!canInteract) return;

    HapticFeedback.selectionClick();
    const emptyValue = <DateTime?>[];
    fieldState.didChange(emptyValue);
    field.onChanged?.call(emptyValue);
  }

  Widget buildSuffix() {
    final actions = <Widget>[];
    if (field.suffixIcon != null) {
      actions.add(field.suffixIcon!);
    }

    if (hasValue && field.clearable && canInteract) {
      if (actions.isNotEmpty) {
        actions.add(SizedBox(width: AppSpacing.xxs));
      }
      actions.add(
        CustomButton.icon(
          icon: Icons.close_rounded,
          tooltip: 'مسح التاريخ المحدد',
          iconSize: 18.r,
          dimension: 44.r,
          foregroundColor: colors.onSurfaceVariant,
          backgroundColor: Colors.transparent,
          enableFeedback: false,
          onPressed: clearValue,
        ),
      );
    }

    if (actions.isEmpty && canInteract) {
      actions.add(
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 22.r,
          color: colors.onSurfaceVariant,
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions,
    );
  }

  final decoration = InputDecoration(
    label: Text.rich(
      TextSpan(
        text: field.label,
        children: [
          if (field.isRequired)
            TextSpan(
              text: ' *',
              style: AppTypography.inputLabel.copyWith(
                color: colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      style: AppTypography.inputLabel.copyWith(
        color: field.enabled ? colors.onSurfaceVariant : colors.onDisabled,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
    hintText: field.hint ?? _defaultDatePickerHint(field.pickerType),
    hintMaxLines: 2,
    prefixIcon: field.prefixIcon ??
        Icon(
          field.enableTime
              ? Icons.event_available_rounded
              : Icons.calendar_month_rounded,
          size: 20.r,
          color: hasError ? colors.error : colors.onSurfaceVariant,
        ),
    suffixIcon: buildSuffix(),
    prefixIconConstraints: BoxConstraints(
      minWidth: 48.r,
      minHeight: 48.r,
    ),
    suffixIconConstraints: BoxConstraints(
      minWidth: 48.r,
      minHeight: 48.r,
    ),
    errorText: fieldState.errorText,
    errorMaxLines: 3,
    enabled: field.enabled,
  );

  return FocusableActionDetector(
    enabled: canInteract,
    mouseCursor: canInteract
        ? SystemMouseCursors.click
        : SystemMouseCursors.basic,
    shortcuts: const <ShortcutActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
    },
    actions: <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (_) {
          unawaited(openPicker(fieldState.context));
          return null;
        },
      ),
    },
    child: Builder(
      builder: (focusContext) {
        final isFocused = Focus.of(focusContext).hasFocus;
        final semanticsValue = hasValue
            ? displayText
            : (field.hint ?? _defaultDatePickerHint(field.pickerType));

        void handleTap() {
          if (!canInteract) return;
          Focus.of(focusContext).requestFocus();
          unawaited(openPicker(focusContext));
        }

        return Semantics(
          container: true,
          explicitChildNodes: true,
          button: canInteract,
          enabled: field.enabled,
          focusable: canInteract,
          focused: isFocused,
          label: field.label,
          value: semanticsValue,
          hint: canInteract
              ? 'اضغط لاختيار ${_selectionName(field.pickerType)}'
              : (field.readOnly ? 'حقل للعرض فقط' : null),
          onTap: canInteract ? handleTap : null,
          child: CustomInteractiveBounce(
            onTap: canInteract ? handleTap : null,
            enableHaptic: false,
            child: InputDecorator(
              isFocused: isFocused,
              isEmpty: !hasValue,
              decoration: decoration,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  hasValue ? displayText : '',
                  textAlign: TextAlign.start,
                  maxLines: field.maxDisplayLines,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inputText.copyWith(
                    color: field.enabled
                        ? colors.onSurface
                        : colors.onDisabled,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

List<DateTime?> _normalizeDatePickerValue(
  List<DateTime?>? source,
  DatePickerSelectionMode mode,
) {
  final values = source ?? const <DateTime?>[];

  switch (mode) {
    case DatePickerSelectionMode.single:
      for (final date in values) {
        if (date != null) return <DateTime?>[date];
      }
      return <DateTime?>[];

    case DatePickerSelectionMode.range:
      if (values.isEmpty) return <DateTime?>[];

      // Preserve which side of a partially selected range is populated.
      // Filtering nulls first would incorrectly convert [null, end] into [end].
      final start = values.first;
      final end = values.length > 1 ? values[1] : null;

      if (start == null && end == null) return <DateTime?>[];
      if (start == null) return <DateTime?>[null, end];
      if (end == null) return <DateTime?>[start];

      return end.isBefore(start)
          ? <DateTime?>[end, start]
          : <DateTime?>[start, end];

    case DatePickerSelectionMode.multi:
      final dates = values.whereType<DateTime>().toList()..sort();
      final uniqueDates = <DateTime>[];
      for (final date in dates) {
        final alreadyExists = uniqueDates.any(
          (selected) =>
              selected.year == date.year &&
              selected.month == date.month &&
              selected.day == date.day,
        );
        if (!alreadyExists) uniqueDates.add(date);
      }
      return uniqueDates;
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String? _validateDatePickerValue(
  List<DateTime?>? source, {
  required DatePickerSelectionMode pickerType,
  required bool isRequired,
  required String requiredMessage,
  required String rangeIncompleteMessage,
  required String outOfRangeMessage,
  required String unselectableDateMessage,
  DateTime? firstDate,
  DateTime? lastDate,
  bool Function(DateTime)? selectableDayPredicate,
  FormFieldValidator<List<DateTime?>>? validator,
}) {
  final dates = _normalizeDatePickerValue(source, pickerType);
  final selectedDates = dates.whereType<DateTime>().toList();

  if (selectedDates.isEmpty) {
    return isRequired ? requiredMessage : validator?.call(dates);
  }

  if (pickerType == DatePickerSelectionMode.range &&
      selectedDates.length != 2) {
    return rangeIncompleteMessage;
  }

  for (final date in selectedDates) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (firstDate != null) {
      final normalizedFirst = DateTime(
        firstDate.year,
        firstDate.month,
        firstDate.day,
      );
      if (normalizedDate.isBefore(normalizedFirst)) {
        return outOfRangeMessage;
      }
    }

    if (lastDate != null) {
      final normalizedLast = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );
      if (normalizedDate.isAfter(normalizedLast)) {
        return outOfRangeMessage;
      }
    }

    if (selectableDayPredicate != null &&
        !selectableDayPredicate(normalizedDate)) {
      return unselectableDateMessage;
    }
  }

  return validator?.call(dates);
}

String _formatDatePickerValue(
  CustomDatePickerField field,
  List<DateTime?> dates,
) {
  if (field.displayFormatter != null) {
    return field.displayFormatter!(dates);
  }

  switch (field.pickerType) {
    case DatePickerSelectionMode.single:
      return DatePickerService.instance.formatArabicDate(
        dates.isEmpty ? null : dates.first,
        includeDayName: true,
        includeTime: field.enableTime,
      );

    case DatePickerSelectionMode.range:
      final start = dates.isNotEmpty ? dates.first : null;
      final end = dates.length > 1 ? dates[1] : null;

      if (start != null && end == null) {
        return 'من ${DatePickerService.instance.formatArabicDate(
          start,
          includeDayName: false,
          includeTime: field.enableTime,
        )}';
      }

      if (start == null && end != null) {
        return 'إلى ${DatePickerService.instance.formatArabicDate(
          end,
          includeDayName: false,
          includeTime: field.enableTime,
        )}';
      }

      return DatePickerService.instance.formatArabicRange(
        start,
        end,
        includeTime: field.enableTime,
      );

    case DatePickerSelectionMode.multi:
      final count = dates.whereType<DateTime>().length;
      return '$count تواريخ محددة';
  }
}

String _defaultDatePickerHint(DatePickerSelectionMode mode) {
  return switch (mode) {
    DatePickerSelectionMode.single => 'اختر التاريخ...',
    DatePickerSelectionMode.range => 'اختر النطاق الزمني...',
    DatePickerSelectionMode.multi => 'اختر التواريخ...',
  };
}

String _selectionName(DatePickerSelectionMode mode) {
  return switch (mode) {
    DatePickerSelectionMode.single => 'التاريخ',
    DatePickerSelectionMode.range => 'الفترة الزمنية',
    DatePickerSelectionMode.multi => 'التواريخ',
  };
}
