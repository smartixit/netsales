import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/date_picker_service.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// ودجت نافذة منتقي التاريخ والوقت الموحدة (CustomDatePickerModal)
/// ============================================================================
/// يمثل طبقة العرض البصرية (Presentation UI Widget) داخل مجلد widgets/pickers:
/// - يوفر واجهة تفاعلية لاختيار التاريخ (مفرد، نطاق، متعدد) والوقت المدمج
/// - متوافق تماماً مع الوضعين الفاتح والداكن وميثاق Clean Architecture
/// - خالي 100% من الأرقام والألوان السحرية والأزرار الخام
class CustomDatePickerModal extends StatelessWidget {
  const CustomDatePickerModal({
    super.key,
    this.initialValue,
    this.mode = DatePickerSelectionMode.single,
    this.enableTime = false,
    this.showQuickPresets = true,
    this.firstDate,
    this.lastDate,
    this.currentDate,
    this.selectableDayPredicate,
    required this.title,
    required this.onConfirm,
    required this.onCancel,
  });

  final List<DateTime?>? initialValue;
  final DatePickerSelectionMode mode;
  final bool enableTime;
  final bool showQuickPresets;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? currentDate;
  final bool Function(DateTime)? selectableDayPredicate;
  final String title;
  final ValueChanged<List<DateTime?>> onConfirm;
  final VoidCallback onCancel;

  /// إظهار المنتقي كنافذة سفلية (Bottom Sheet)
  /// يعرض المنتقي عبر النافذة السفلية المشتركة، مع تثبيته عند الحافة السفلية.
  static Future<List<DateTime?>?> showBottomSheet({
    required BuildContext context,
    List<DateTime?>? initialValue,
    DatePickerSelectionMode mode = DatePickerSelectionMode.single,
    bool enableTime = false,
    bool showQuickPresets = true,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    required String title,
  }) {
    HapticFeedback.lightImpact();

    if (!context.mounted) return Future<List<DateTime?>?>.value(null);

    return CustomBottomSheet.show<List<DateTime?>>(
      child: CustomDatePickerBottomSheetContent(
        initialValue: initialValue,
        mode: mode,
        enableTime: enableTime,
        showQuickPresets: showQuickPresets,
        firstDate: firstDate,
        lastDate: lastDate,
        currentDate: currentDate,
        selectableDayPredicate: selectableDayPredicate,
        title: title,
      ),
      maxHeightFactor: 0.94,
      maxWidth: AppBreakpoints.maxModalWidth,
      showDragHandle: true,
      showCloseButton: false,
      scrollable: true,
      padding: EdgeInsets.zero,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  /// إظهار المنتقي في مربع حوار مركزي (Dialog)
  static Future<List<DateTime?>?> showDialog({
    required BuildContext context,
    List<DateTime?>? initialValue,
    DatePickerSelectionMode mode = DatePickerSelectionMode.single,
    bool enableTime = false,
    bool showQuickPresets = true,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    required String title,
  }) {
    HapticFeedback.lightImpact();
    return showGeneralDialog<List<DateTime?>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Date Picker',
      barrierColor: Colors.black54,
      transitionDuration: AppMotion.duration(context, AppMotion.normal),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curvedAnim = CurvedAnimation(
          parent: anim,
          curve: AppMotion.decelerate,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnim),
          child: FadeTransition(opacity: curvedAnim, child: child),
        );
      },
      pageBuilder: (ctx, anim, secondaryAnim) => CustomDatePickerDialogContent(
        initialValue: initialValue,
        mode: mode,
        enableTime: enableTime,
        showQuickPresets: showQuickPresets,
        firstDate: firstDate,
        lastDate: lastDate,
        currentDate: currentDate,
        selectableDayPredicate: selectableDayPredicate,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DatePickerContainerView(
      initialValue: initialValue,
      mode: mode,
      enableTime: enableTime,
      showQuickPresets: showQuickPresets,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      title: title,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}

/// غلاف النافذة السفلية (Bottom Sheet Container)
class CustomDatePickerBottomSheetContent extends StatelessWidget {
  const CustomDatePickerBottomSheetContent({
    super.key,
    this.initialValue,
    required this.mode,
    required this.enableTime,
    required this.showQuickPresets,
    this.firstDate,
    this.lastDate,
    this.currentDate,
    this.selectableDayPredicate,
    required this.title,
  });

  final List<DateTime?>? initialValue;
  final DatePickerSelectionMode mode;
  final bool enableTime;
  final bool showQuickPresets;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? currentDate;
  final bool Function(DateTime)? selectableDayPredicate;
  final String title;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey<String>('custom-date-picker-sheet-content'),
      child: _DatePickerContainerView(
        initialValue: initialValue,
        mode: mode,
        enableTime: enableTime,
        showQuickPresets: showQuickPresets,
        firstDate: firstDate,
        lastDate: lastDate,
        currentDate: currentDate,
        selectableDayPredicate: selectableDayPredicate,
        title: title,
        onConfirm: (dates) => Get.back<List<DateTime?>>(result: dates),
        onCancel: () => Get.back<List<DateTime?>>(),
      ),
    );
  }
}

/// غلاف مربع الحوار المركزي (Dialog Container)
class CustomDatePickerDialogContent extends StatelessWidget {
  const CustomDatePickerDialogContent({
    super.key,
    this.initialValue,
    required this.mode,
    required this.enableTime,
    required this.showQuickPresets,
    this.firstDate,
    this.lastDate,
    this.currentDate,
    this.selectableDayPredicate,
    required this.title,
  });

  final List<DateTime?>? initialValue;
  final DatePickerSelectionMode mode;
  final bool enableTime;
  final bool showQuickPresets;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? currentDate;
  final bool Function(DateTime)? selectableDayPredicate;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        (mediaQuery.size.height -
                mediaQuery.viewInsets.vertical -
                AppSpacing.xxl)
            .clamp(0.0, mediaQuery.size.height)
            .toDouble();

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppBreakpoints.maxModalWidth,
            maxHeight: availableHeight,
          ),
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.all(AppSpacing.md),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl.r),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.4),
                width: 1.w,
              ),
              boxShadow: AppElevation.level3(context),
            ),
            child: SingleChildScrollView(
              primary: false,
              physics: const ClampingScrollPhysics(),
              child: _DatePickerContainerView(
                initialValue: initialValue,
                mode: mode,
                enableTime: enableTime,
                showQuickPresets: showQuickPresets,
                firstDate: firstDate,
                lastDate: lastDate,
                currentDate: currentDate,
                selectableDayPredicate: selectableDayPredicate,
                title: title,
                onConfirm: (dates) => Navigator.of(context).pop(dates),
                onCancel: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// المحتوى الداخلي للمنتقي (_DatePickerContainerView)
// ─────────────────────────────────────────────────────────────────────────────
/// واجهة Stateless للحاوية؛ حالة كل نافذة مملوكة لمتحكم GetX محلي.
class _DatePickerContainerView extends StatelessWidget {
  const _DatePickerContainerView({
    this.initialValue,
    required this.mode,
    required this.enableTime,
    required this.showQuickPresets,
    this.firstDate,
    this.lastDate,
    this.currentDate,
    this.selectableDayPredicate,
    required this.title,
    required this.onConfirm,
    required this.onCancel,
  });

  final List<DateTime?>? initialValue;
  final DatePickerSelectionMode mode;
  final bool enableTime;
  final bool showQuickPresets;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? currentDate;
  final bool Function(DateTime)? selectableDayPredicate;
  final String title;
  final ValueChanged<List<DateTime?>> onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_DatePickerModalController>(
      global: false,
      init: _DatePickerModalController(
        initialValue: initialValue,
        mode: mode,
        enableTime: enableTime,
        firstDate: firstDate,
        lastDate: lastDate,
        currentDate: currentDate,
        selectableDayPredicate: selectableDayPredicate,
      ),
      builder: (controller) => _buildContent(context, controller),
    );
  }

  Widget _buildContent(
    BuildContext context,
    _DatePickerModalController controller,
  ) {
    final colors = context.colors;
    final calendarConfig = CalendarDatePicker2Config(
      calendarType: controller.calendarType,
      firstDate: controller.effectiveFirstDate,
      lastDate: controller.effectiveLastDate,
      currentDate: controller.effectiveCurrentDate,
      selectableDayPredicate: controller.selectableDayPredicate,
      rangeBidirectional: true,
      selectedDayHighlightColor: colors.primary,
      selectedDayTextStyle: AppTypography.bodyMedium.copyWith(
        color: colors.onPrimary,
        fontWeight: FontWeight.bold,
      ),
      dayTextStyle: AppTypography.bodyMedium.copyWith(color: colors.onSurface),
      todayTextStyle: AppTypography.bodyMedium.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.bold,
      ),
      disabledDayTextStyle: AppTypography.bodyMedium.copyWith(
        color: colors.onSurface.withValues(alpha: 0.28),
      ),
      selectedRangeHighlightColor: colors.primaryContainer.withValues(
        alpha: 0.40,
      ),
      selectedRangeDayTextStyle: AppTypography.bodyMedium.copyWith(
        color: colors.onPrimaryContainer,
        fontWeight: FontWeight.bold,
      ),
      weekdayLabelTextStyle: AppTypography.labelMedium.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      controlsTextStyle: AppTypography.titleMedium.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.bold,
      ),
      weekdayLabels: const [
        'الأحد',
        'الاثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
      ],
      firstDayOfWeek: 6,
      lastMonthIcon: Icon(
        Icons.chevron_right_rounded,
        color: colors.onSurface,
        size: 24.sp,
      ),
      nextMonthIcon: Icon(
        Icons.chevron_left_rounded,
        color: colors.onSurface,
        size: 24.sp,
      ),
      centerAlignModePicker: true,
      disableModePicker: false,
      disableMonthPicker: true,
      useAbbrLabelForMonthModePicker: true,
      modePickersGap: 0,
      controlsHeight: 46.h,
      dayBorderRadius: BorderRadius.circular(AppRadius.md.r),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DatePickerHeader(
          mode: controller.mode,
          selectedDates: controller.selectedDates,
          selectedTime: controller.selectedTime,
          enableTime: controller.enableTime,
          title: title,
          onClear: controller.selectedDates.isNotEmpty
              ? controller.clearSelection
              : null,
        ),
        if (controller.mode == DatePickerSelectionMode.range &&
            showQuickPresets) ...[
          AppSpacing.vSm,
          _QuickPresetsBar(
            referenceDate: controller.effectiveCurrentDate,
            isPresetSelectable: controller.isPresetSelectable,
            onPresetSelected: controller.selectPreset,
          ),
        ],
        AppSpacing.vSm,
        Divider(
          height: 1,
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: CalendarDatePicker2(
            config: calendarConfig,
            value: controller.selectedDates,
            onValueChanged: controller.updateDates,
          ),
        ),
        Divider(
          height: 1,
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
        if (controller.enableTime) ...[
          AppSpacing.vSm,
          _TimePickerSection(
            selectedTime: controller.selectedTime,
            onTimeChanged: controller.updateTime,
          ),
        ],
        AppSpacing.vMd,
        _DatePickerActions(
          onConfirm: () => controller.confirm(onConfirm),
          onCancel: onCancel,
          canConfirm: controller.canConfirm,
        ),
        AppSpacing.vSm,
      ],
    );
  }
}

class _DatePickerModalController extends GetxController {
  _DatePickerModalController({
    required List<DateTime?>? initialValue,
    required this.mode,
    required this.enableTime,
    required this.firstDate,
    required this.lastDate,
    required this.currentDate,
    required this.selectableDayPredicate,
  }) {
    _validateDatePickerBounds(firstDate, lastDate);
    selectedDates = _filterSelectableDates(_normalizeDates(initialValue, mode));
    DateTime? initialDate;
    for (final date in selectedDates) {
      if (date != null) {
        initialDate = date;
        break;
      }
    }
    selectedTime = TimeOfDay.fromDateTime(initialDate ?? effectiveCurrentDate);
  }

  final DatePickerSelectionMode mode;
  final bool enableTime;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? currentDate;
  final bool Function(DateTime)? selectableDayPredicate;

  late List<DateTime?> selectedDates;
  late TimeOfDay selectedTime;
  bool wasExplicitlyCleared = false;

  CalendarDatePicker2Type get calendarType => switch (mode) {
    DatePickerSelectionMode.single => CalendarDatePicker2Type.single,
    DatePickerSelectionMode.range => CalendarDatePicker2Type.range,
    DatePickerSelectionMode.multi => CalendarDatePicker2Type.multi,
  };

  DateTime get effectiveFirstDate {
    if (firstDate != null) return _dateOnly(firstDate!);

    final defaultFirstDate = DateTime(2000);
    if (lastDate != null && _dateOnly(lastDate!).isBefore(defaultFirstDate)) {
      return _dateOnly(lastDate!);
    }
    return defaultFirstDate;
  }

  DateTime get effectiveLastDate {
    if (lastDate != null) return _dateOnly(lastDate!);

    final defaultLastDate = DateTime(2100);
    if (firstDate != null && _dateOnly(firstDate!).isAfter(defaultLastDate)) {
      return _dateOnly(firstDate!);
    }
    return defaultLastDate;
  }

  DateTime get effectiveCurrentDate {
    final preferred = _dateOnly(currentDate ?? DateTime.now());
    if (preferred.isBefore(effectiveFirstDate)) return effectiveFirstDate;
    if (preferred.isAfter(effectiveLastDate)) return effectiveLastDate;
    return preferred;
  }

  bool get canConfirm {
    if (wasExplicitlyCleared) return true;

    switch (mode) {
      case DatePickerSelectionMode.single:
        return selectedDates.length == 1 && selectedDates.first != null;
      case DatePickerSelectionMode.range:
        return selectedDates.length >= 2 &&
            selectedDates[0] != null &&
            selectedDates[1] != null;
      case DatePickerSelectionMode.multi:
        return selectedDates.any((date) => date != null);
    }
  }

  bool isSelectable(DateTime date) {
    final normalized = _dateOnly(date);
    if (normalized.isBefore(effectiveFirstDate) ||
        normalized.isAfter(effectiveLastDate)) {
      return false;
    }
    return selectableDayPredicate?.call(normalized) ?? true;
  }

  List<DateTime?> _filterSelectableDates(List<DateTime?> dates) {
    switch (mode) {
      case DatePickerSelectionMode.single:
        if (dates.isEmpty || dates.first == null) return <DateTime?>[];
        return isSelectable(dates.first!)
            ? <DateTime?>[dates.first]
            : <DateTime?>[];
      case DatePickerSelectionMode.range:
        if (dates.isEmpty) return <DateTime?>[];
        final start = dates.first;
        final end = dates.length > 1 ? dates[1] : null;
        return _normalizeDates(<DateTime?>[
          start != null && !isSelectable(start) ? null : start,
          end != null && !isSelectable(end) ? null : end,
        ], mode);
      case DatePickerSelectionMode.multi:
        return dates.whereType<DateTime>().where(isSelectable).toList();
    }
  }

  bool isPresetSelectable(DateTime start, DateTime end) {
    if (end.isBefore(start)) return false;
    var day = _dateOnly(start);
    final finalDay = _dateOnly(end);
    while (!day.isAfter(finalDay)) {
      if (!isSelectable(day)) return false;
      day = DateTime(day.year, day.month, day.day + 1);
    }
    return true;
  }

  void updateDates(List<DateTime?> dates) {
    selectedDates = _filterSelectableDates(_normalizeDates(dates, mode));
    wasExplicitlyCleared = false;
    _applyTimeToDates();
    update();
  }

  void updateTime(TimeOfDay time) {
    if (!enableTime) return;
    selectedTime = time;
    _applyTimeToDates();
    update();
  }

  void selectPreset(List<DateTime?> dates) {
    if (dates.length != 2 || dates[0] == null || dates[1] == null) return;
    if (!isPresetSelectable(dates[0]!, dates[1]!)) return;
    HapticFeedback.selectionClick();
    selectedDates = _filterSelectableDates(_normalizeDates(dates, mode));
    wasExplicitlyCleared = false;
    _applyTimeToDates();
    update();
  }

  void clearSelection() {
    HapticFeedback.selectionClick();
    selectedDates = <DateTime?>[];
    wasExplicitlyCleared = true;
    update();
  }

  void confirm(ValueChanged<List<DateTime?>> onConfirm) {
    if (!canConfirm) return;
    HapticFeedback.mediumImpact();
    onConfirm(List<DateTime?>.unmodifiable(selectedDates));
  }

  void _applyTimeToDates() {
    if (!enableTime || selectedDates.isEmpty) return;
    selectedDates = selectedDates.map((date) {
      if (date == null) return null;
      return DateTime(
        date.year,
        date.month,
        date.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    }).toList();
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

// ─────────────────────────────────────────────────────────────────────────────
// الترويسة الموحدة (_DatePickerHeader)
// ─────────────────────────────────────────────────────────────────────────────
class _DatePickerHeader extends StatelessWidget {
  const _DatePickerHeader({
    required this.mode,
    required this.selectedDates,
    required this.selectedTime,
    required this.enableTime,
    required this.title,
    this.onClear,
  });

  final DatePickerSelectionMode mode;
  final List<DateTime?> selectedDates;
  final TimeOfDay selectedTime;
  final bool enableTime;
  final String title;
  final VoidCallback? onClear;

  String _formatDisplayText() {
    if (mode == DatePickerSelectionMode.multi) {
      final count = selectedDates.whereType<DateTime>().length;
      return count == 0 ? 'لم يتم تحديد تواريخ' : '$count تواريخ محددة';
    }

    if (selectedDates.isEmpty) {
      return mode == DatePickerSelectionMode.range
          ? 'اختر النطاق الزمني'
          : 'اختر التاريخ';
    }

    if (mode == DatePickerSelectionMode.range) {
      final start = selectedDates.isNotEmpty ? selectedDates[0] : null;
      final end = selectedDates.length > 1 ? selectedDates[1] : null;

      if (start != null && end == null) {
        return 'من ${DatePickerService.instance.formatArabicDate(start, includeDayName: false, includeTime: enableTime)}';
      }

      if (start == null && end != null) {
        return 'إلى ${DatePickerService.instance.formatArabicDate(end, includeDayName: false, includeTime: enableTime)}';
      }

      return DatePickerService.instance.formatArabicRange(
        start,
        end,
        includeTime: enableTime,
      );
    }

    return DatePickerService.instance.formatArabicDate(
      selectedDates.first,
      includeDayName: true,
      includeTime: enableTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              mode == DatePickerSelectionMode.range
                  ? Icons.date_range_rounded
                  : Icons.calendar_today_rounded,
              color: colors.primary,
              size: 22.sp,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  _formatDisplayText(),
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onClear != null)
            CustomButton.icon(
              icon: Icons.refresh_rounded,
              tooltip: 'مسح التحديد',
              iconSize: 20.sp,
              dimension: 40.r,
              enableFeedback: false,
              foregroundColor: colors.onSurfaceVariant,
              backgroundColor: Colors.transparent,
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// شريط الفلاتر السريعة لنطاق التواريخ (_QuickPresetsBar)
// ─────────────────────────────────────────────────────────────────────────────
class _QuickPresetsBar extends StatelessWidget {
  const _QuickPresetsBar({
    required this.referenceDate,
    required this.isPresetSelectable,
    required this.onPresetSelected,
  });

  final DateTime referenceDate;
  final bool Function(DateTime, DateTime) isPresetSelectable;
  final ValueChanged<List<DateTime?>> onPresetSelected;

  List<_DateRangePreset> _presets() {
    final now = _dateOnly(referenceDate);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    return [
      _DateRangePreset('اليوم', now, now),
      _DateRangePreset('أمس', yesterday, yesterday),
      _DateRangePreset(
        'آخر 7 أيام',
        now.subtract(const Duration(days: 6)),
        now,
      ),
      _DateRangePreset(
        'آخر 30 يوماً',
        now.subtract(const Duration(days: 29)),
        now,
      ),
      _DateRangePreset('هذا الشهر', monthStart, monthEnd),
      _DateRangePreset('الشهر الماضي', lastMonthStart, lastMonthEnd),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final presets = _presets();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          for (var index = 0; index < presets.length; index++) ...[
            _PresetChip(
              label: presets[index].label,
              enabled: isPresetSelectable(
                presets[index].start,
                presets[index].end,
              ),
              onTap: () =>
                  onPresetSelected([presets[index].start, presets[index].end]),
            ),
            if (index != presets.length - 1) AppSpacing.hXs,
          ],
        ],
      ),
    );
  }
}

class _DateRangePreset {
  const _DateRangePreset(this.label, this.start, this.end);

  final String label;
  final DateTime start;
  final DateTime end;
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: CustomInteractiveBounce(
        onTap: enabled ? onTap : null,
        enableHaptic: false,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.38,
          duration: AppMotion.duration(context, AppMotion.fast),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadius.full.r),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.3),
                width: 1.w,
              ),
            ),
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// منتقي الوقت المدمج (_TimePickerSection)
// ─────────────────────────────────────────────────────────────────────────────
class _TimePickerSection extends StatelessWidget {
  const _TimePickerSection({
    required this.selectedTime,
    required this.onTimeChanged,
  });

  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  void _incrementHour() {
    HapticFeedback.selectionClick();
    onTimeChanged(
      TimeOfDay(
        hour: (selectedTime.hour + 1) % 24,
        minute: selectedTime.minute,
      ),
    );
  }

  void _decrementHour() {
    HapticFeedback.selectionClick();
    onTimeChanged(
      TimeOfDay(
        hour: (selectedTime.hour - 1 + 24) % 24,
        minute: selectedTime.minute,
      ),
    );
  }

  void _adjustMinutes(int delta) {
    const minutesPerDay = 24 * 60;
    final totalMinutes = selectedTime.hour * 60 + selectedTime.minute + delta;
    final normalizedMinutes =
        (totalMinutes % minutesPerDay + minutesPerDay) % minutesPerDay;

    onTimeChanged(
      TimeOfDay(hour: normalizedMinutes ~/ 60, minute: normalizedMinutes % 60),
    );
  }

  void _incrementMinute() {
    HapticFeedback.selectionClick();
    _adjustMinutes(5);
  }

  void _decrementMinute() {
    HapticFeedback.selectionClick();
    _adjustMinutes(-5);
  }

  void _togglePeriod() {
    HapticFeedback.selectionClick();
    final nextHour = selectedTime.hour >= 12
        ? selectedTime.hour - 12
        : selectedTime.hour + 12;
    onTimeChanged(TimeOfDay(hour: nextHour, minute: selectedTime.minute));
  }

  Widget _buildTimeControls(AppColors colors) {
    final displayHour = selectedTime.hour % 12 == 0
        ? 12
        : selectedTime.hour % 12;
    final displayMinute = selectedTime.minute.toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TimeUnitCounter(
          value: displayHour.toString().padLeft(2, '0'),
          onIncrement: _incrementHour,
          onDecrement: _decrementHour,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            ':',
            style: AppTypography.titleLarge.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _TimeUnitCounter(
          value: displayMinute,
          onIncrement: _incrementMinute,
          onDecrement: _decrementMinute,
        ),
      ],
    );
  }

  Widget _buildPeriodButton(AppColors colors) {
    return CustomButton.secondary(
      text: selectedTime.hour >= 12 ? 'مساءً (م)' : 'صباحاً (ص)',
      size: AppButtonSize.small,
      height: 44.r,
      enableFeedback: false,
      enableScaleAnimation: false,
      onPressed: _togglePeriod,
      backgroundColor: colors.primaryContainer.withValues(alpha: 0.5),
      foregroundColor: colors.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            !constraints.hasBoundedWidth ||
            constraints.maxWidth < AppBreakpoints.maxFormWidth;
        final decoration = BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
        );

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: decoration,
          child: compact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: colors.primary,
                          size: 20.r,
                        ),
                        AppSpacing.hSm,
                        Text(
                          'الوقت:',
                          style: AppTypography.labelMedium.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.hSm,
                        _buildPeriodButton(colors),
                      ],
                    ),
                    AppSpacing.vSm,
                    Center(child: _buildTimeControls(colors)),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: colors.primary,
                      size: 20.r,
                    ),
                    AppSpacing.hSm,
                    Text(
                      'الوقت:',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    _buildTimeControls(colors),
                    AppSpacing.hSm,
                    _buildPeriodButton(colors),
                  ],
                ),
        );
      },
    );
  }
}

class _TimeUnitCounter extends StatelessWidget {
  const _TimeUnitCounter({
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton.icon(
            icon: Icons.remove_rounded,
            tooltip: 'إنقاص',
            iconSize: 14.r,
            dimension: 44.r,
            foregroundColor: colors.onSurfaceVariant,
            backgroundColor: Colors.transparent,
            enableFeedback: false,
            enableScaleAnimation: false,
            onPressed: onDecrement,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomButton.icon(
            icon: Icons.add_rounded,
            tooltip: 'زيادة',
            iconSize: 14.r,
            dimension: 44.r,
            foregroundColor: colors.onSurfaceVariant,
            backgroundColor: Colors.transparent,
            enableFeedback: false,
            enableScaleAnimation: false,
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// أزرار الإجراءات (_DatePickerActions)
// ─────────────────────────────────────────────────────────────────────────────
class _DatePickerActions extends StatelessWidget {
  const _DatePickerActions({
    required this.onConfirm,
    this.onCancel,
    required this.canConfirm,
  });

  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool canConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: CustomButton.outline(
              text: 'إلغاء',
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            flex: 2,
            child: CustomButton.primary(
              text: 'تأكيد',
              icon: Icons.check_rounded,
              enabled: canConfirm,
              onPressed: canConfirm ? onConfirm : null,
            ),
          ),
        ],
      ),
    );
  }
}

List<DateTime?> _normalizeDates(
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
        final duplicate = uniqueDates.any(
          (selected) =>
              selected.year == date.year &&
              selected.month == date.month &&
              selected.day == date.day,
        );
        if (!duplicate) uniqueDates.add(date);
      }
      return uniqueDates;
  }
}

void _validateDatePickerBounds(DateTime? firstDate, DateTime? lastDate) {
  if (firstDate != null &&
      lastDate != null &&
      _dateOnly(firstDate).isAfter(_dateOnly(lastDate))) {
    throw ArgumentError.value(
      <DateTime?>[firstDate, lastDate],
      'firstDate/lastDate',
      'firstDate must be on or before lastDate.',
    );
  }
}
