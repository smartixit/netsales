import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/date_picker_service.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

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
    return showModalBottomSheet<List<DateTime?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomDatePickerBottomSheetContent(
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
    final colors = context.colors;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppBreakpoints.maxModalWidth),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl.r)),
            boxShadow: AppElevation.level4(context),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.w,
                    height: 4.h,
                    margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: colors.outlineVariant.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.full.r),
                    ),
                  ),
                  _DatePickerContainerView(
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
                ],
              ),
            ),
          ),
        ),
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

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(AppSpacing.md),
          constraints: BoxConstraints(maxWidth: AppBreakpoints.maxModalWidth),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl.r),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.4),
              width: 1.w,
            ),
            boxShadow: AppElevation.level3(context),
          ),
          clipBehavior: Clip.antiAlias,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// المحتوى الداخلي للمنتقي (_DatePickerContainerView)
// ─────────────────────────────────────────────────────────────────────────────
class _DatePickerContainerView extends StatefulWidget {
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
  State<_DatePickerContainerView> createState() => _DatePickerContainerViewState();
}

class _DatePickerContainerViewState extends State<_DatePickerContainerView> {
  late List<DateTime?> _selectedDates;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDates = widget.initialValue != null
        ? List<DateTime?>.from(widget.initialValue!)
        : [DateTime.now()];

    final firstDate = _selectedDates.isNotEmpty ? _selectedDates.first : null;
    if (firstDate != null) {
      _selectedTime = TimeOfDay(hour: firstDate.hour, minute: firstDate.minute);
    } else {
      _selectedTime = TimeOfDay.now();
    }
  }

  void _onDatesChanged(List<DateTime?> dates) {
    setState(() {
      _selectedDates = dates;
      _applyTimeToDates();
    });
  }

  void _onTimeChanged(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
      _applyTimeToDates();
    });
  }

  void _applyTimeToDates() {
    if (!widget.enableTime || _selectedDates.isEmpty) return;
    _selectedDates = _selectedDates.map((date) {
      if (date == null) return null;
      return DateTime(
        date.year,
        date.month,
        date.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
    }).toList();
  }

  void _onQuickPresetSelected(List<DateTime?> presetDates) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedDates = presetDates;
      _applyTimeToDates();
    });
  }

  void _onClear() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedDates = [];
    });
  }

  void _handleConfirm() {
    HapticFeedback.mediumImpact();
    widget.onConfirm(_selectedDates);
  }

  CalendarDatePicker2Type get _mappedCalendarType {
    switch (widget.mode) {
      case DatePickerSelectionMode.single:
        return CalendarDatePicker2Type.single;
      case DatePickerSelectionMode.range:
        return CalendarDatePicker2Type.range;
      case DatePickerSelectionMode.multi:
        return CalendarDatePicker2Type.multi;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final calendarConfig = CalendarDatePicker2Config(
      calendarType: _mappedCalendarType,
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2100),
      currentDate: widget.currentDate ?? DateTime.now(),
      selectableDayPredicate: widget.selectableDayPredicate,
      rangeBidirectional: true,
      selectedDayHighlightColor: colors.primary,
      selectedDayTextStyle: AppTypography.bodyMedium.copyWith(
        color: colors.onPrimary,
        fontWeight: FontWeight.bold,
      ),
      dayTextStyle: AppTypography.bodyMedium.copyWith(
        color: colors.onSurface,
      ),
      todayTextStyle: AppTypography.bodyMedium.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.bold,
      ),
      disabledDayTextStyle: AppTypography.bodyMedium.copyWith(
        color: colors.onSurface.withValues(alpha: 0.28),
      ),
      selectedRangeHighlightColor: colors.primaryContainer.withValues(alpha: 0.40),
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
      weekdayLabels: DatePickerService.weekdayShortLabels,
      dayBorderRadius: BorderRadius.circular(AppRadius.md.r),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. ترويسة التاريخ المحدد
        _DatePickerHeader(
          mode: widget.mode,
          selectedDates: _selectedDates,
          selectedTime: _selectedTime,
          enableTime: widget.enableTime,
          title: widget.title,
          onClear: _selectedDates.isNotEmpty ? _onClear : null,
        ),

        // 2. شريط الفلاتر السريعة لنطاق التواريخ
        if (widget.mode == DatePickerSelectionMode.range &&
            widget.showQuickPresets) ...[
          _QuickPresetsBar(onPresetSelected: _onQuickPresetSelected),
          AppSpacing.vXs,
        ],

        // 3. التقويم الأساسي
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: CalendarDatePicker2(
            config: calendarConfig,
            value: _selectedDates,
            onValueChanged: _onDatesChanged,
          ),
        ),

        // 4. ودجت اختيار الوقت
        if (widget.enableTime) ...[
          _TimePickerSection(
            selectedTime: _selectedTime,
            onTimeChanged: _onTimeChanged,
          ),
        ],

        // 5. أزرار الإجراءات (تأكيد / إلغاء)
        AppSpacing.vSm,
        _DatePickerActions(
          onConfirm: _handleConfirm,
          onCancel: widget.onCancel,
          canConfirm: _selectedDates.isNotEmpty,
        ),
        AppSpacing.vXs,
      ],
    );
  }
}

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
    if (selectedDates.isEmpty) {
      return mode == DatePickerSelectionMode.range
          ? 'اختر النطاق الزمني'
          : 'اختر التاريخ';
    }

    if (mode == DatePickerSelectionMode.range) {
      final start = selectedDates.isNotEmpty ? selectedDates[0] : null;
      final end = selectedDates.length > 1 ? selectedDates[1] : null;
      return DatePickerService.instance.formatArabicRange(start, end, includeTime: enableTime);
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

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg.r)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: colors.primary,
              size: 20.r,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  _formatDisplayText(),
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onClear != null)
            CustomButton.icon(
              icon: Icons.clear_rounded,
              tooltip: 'مسح',
              iconSize: 18.r,
              dimension: 36.r,
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
  const _QuickPresetsBar({required this.onPresetSelected});

  final ValueChanged<List<DateTime?>> onPresetSelected;

  void _selectToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    onPresetSelected([today, today]);
  }

  void _selectYesterday() {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    onPresetSelected([yesterday, yesterday]);
  }

  void _selectLast7Days() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = DateTime(now.year, now.month, now.day - 6);
    onPresetSelected([start, end]);
  }

  void _selectLast30Days() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = DateTime(now.year, now.month, now.day - 29);
    onPresetSelected([start, end]);
  }

  void _selectThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    onPresetSelected([start, end]);
  }

  void _selectLastMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month, 0);
    onPresetSelected([start, end]);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          _PresetChip(label: 'اليوم', onTap: _selectToday),
          AppSpacing.hXs,
          _PresetChip(label: 'أمس', onTap: _selectYesterday),
          AppSpacing.hXs,
          _PresetChip(label: 'آخر 7 أيام', onTap: _selectLast7Days),
          AppSpacing.hXs,
          _PresetChip(label: 'آخر 30 يوماً', onTap: _selectLast30Days),
          AppSpacing.hXs,
          _PresetChip(label: 'هذا الشهر', onTap: _selectThisMonth),
          AppSpacing.hXs,
          _PresetChip(label: 'الشهر الماضي', onTap: _selectLastMonth),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
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
    HapticFeedback.lightImpact();
    final newHour = (selectedTime.hour + 1) % 24;
    onTimeChanged(TimeOfDay(hour: newHour, minute: selectedTime.minute));
  }

  void _decrementHour() {
    HapticFeedback.lightImpact();
    final newHour = (selectedTime.hour - 1 + 24) % 24;
    onTimeChanged(TimeOfDay(hour: newHour, minute: selectedTime.minute));
  }

  void _incrementMinute() {
    HapticFeedback.lightImpact();
    final newMinute = (selectedTime.minute + 5) % 60;
    onTimeChanged(TimeOfDay(hour: selectedTime.hour, minute: newMinute));
  }

  void _decrementMinute() {
    HapticFeedback.lightImpact();
    final newMinute = (selectedTime.minute - 5 + 60) % 60;
    onTimeChanged(TimeOfDay(hour: selectedTime.hour, minute: newMinute));
  }

  void _togglePeriod() {
    HapticFeedback.lightImpact();
    final isPm = selectedTime.hour >= 12;
    final newHour = isPm ? selectedTime.hour - 12 : selectedTime.hour + 12;
    onTimeChanged(TimeOfDay(hour: newHour, minute: selectedTime.minute));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPm = selectedTime.hour >= 12;
    final displayHour = selectedTime.hour % 12 == 0 ? 12 : selectedTime.hour % 12;
    final displayMinute = selectedTime.minute.toString().padLeft(2, '0');

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
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
          const Spacer(),

          // عداد الساعات
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

          // عداد الدقائق
          _TimeUnitCounter(
            value: displayMinute,
            onIncrement: _incrementMinute,
            onDecrement: _decrementMinute,
          ),

          AppSpacing.hSm,

          // زر التبديل بين صباحاً ومساءً
          CustomInteractiveBounce(
            onTap: _togglePeriod,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm.r),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.35),
                  width: 1.w,
                ),
              ),
              child: Text(
                isPm ? 'مساءً (م)' : 'صباحاً (ص)',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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
            dimension: 28.r,
            foregroundColor: colors.onSurfaceVariant,
            backgroundColor: Colors.transparent,
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
            dimension: 28.r,
            foregroundColor: colors.onSurfaceVariant,
            backgroundColor: Colors.transparent,
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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: CustomButton.outline(
              text: 'إلغاء',
              icon: Icons.close_rounded,
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: CustomButton.primary(
              text: 'تأكيد',
              icon: Icons.check_rounded,
              onPressed: canConfirm ? onConfirm : null,
            ),
          ),
        ],
      ),
    );
  }
}
