import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_modal.dart';

export 'package:netsales/core/utils/date_formatter.dart';
export 'package:netsales/widgets/pickers/custom_date_picker_modal.dart'
    show CustomDatePickerModal;

/// أنماط اختيار التاريخ المعتمدة في خدمة التقويم
enum DatePickerSelectionMode {
  /// اختيار يوم محدد
  single,

  /// اختيار نطاق زمني (من تاريخ - إلى تاريخ)
  range,

  /// اختيار تواريخ متعددة متفرقة
  multi,
}

/// اسم بديل متوافق لنمط اختيار التاريخ
typedef CustomDatePickerType = DatePickerSelectionMode;

/// ============================================================================
/// خدمة منتقي التاريخ والوقت المركزية الموحدة (DatePickerService)
/// ============================================================================
/// تتبع نمط الخدمات المؤسسية (GetxService) كبقية خدمات النظام في طبقة Core
/// (مثل FilePickerService و PushNotificationService و SoundService):
/// - مسؤولة حصرياً عن منطق الأعمال، تنسيق التواريخ، ودورة حياة الخدمة
/// - تفوض رسم الواجهات البصرية إلى طبقة الودجات [CustomDatePickerModal]
/// - تتيح استدعاءات إجرائية سريعة ونظيفة من أي مكان في النظام:
///   `await DatePickerService.instance.pickDate(...)`
///   `await DatePickerService.instance.pickDateRange(...)`
///   `await DatePickerService.instance.pickDateTime(...)`
class DatePickerService extends GetxService {
  DatePickerService._();

  static final DatePickerService instance = DatePickerService._();

  static DatePickerService get to =>
      Get.isRegistered<DatePickerService>() ? Get.find<DatePickerService>() : instance;

  /// تهيئة الخدمة وضمان توفر بيانات التقويم
  Future<DatePickerService> init() async {
    DateFormatter.ensureInitialized();
    return this;
  }

  @override
  void onInit() {
    super.onInit();
    init();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. الواجهات الإجرائية العامة (Public API Methods)
  // ───────────────────────────────────────────────────────────────────────────

  /// اختيار يوم محدد (Single Date)
  Future<DateTime?> pickDate({
    BuildContext? context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    String? title,
    bool useDialog = false,
  }) async {
    final dates = await showPicker(
      context: context ?? Get.context!,
      initialValue: initialDate != null ? [initialDate] : null,
      mode: DatePickerSelectionMode.single,
      enableTime: false,
      showQuickPresets: false,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      title: title ?? 'اختيار التاريخ',
      useDialog: useDialog,
    );
    return dates != null && dates.isNotEmpty ? dates.first : null;
  }

  /// اختيار نطاق زمني (Date Range)
  Future<DateTimeRange?> pickDateRange({
    BuildContext? context,
    DateTimeRange? initialRange,
    bool showQuickPresets = true,
    bool enableTime = false,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    String? title,
    bool useDialog = false,
  }) async {
    final initialList = initialRange != null
        ? [initialRange.start, initialRange.end]
        : <DateTime?>[];

    final dates = await showPicker(
      context: context ?? Get.context!,
      initialValue: initialList,
      mode: DatePickerSelectionMode.range,
      enableTime: enableTime,
      showQuickPresets: showQuickPresets,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      title: title ?? 'اختيار النطاق الزمني',
      useDialog: useDialog,
    );

    if (dates != null && dates.length >= 2 && dates[0] != null && dates[1] != null) {
      return DateTimeRange(start: dates[0]!, end: dates[1]!);
    }
    return null;
  }

  /// اختيار تاريخ ووقت معاً في واجهة تفاعلية موحدة (DateTime combined)
  Future<DateTime?> pickDateTime({
    BuildContext? context,
    DateTime? initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    String? title,
    bool useDialog = false,
  }) async {
    final dates = await showPicker(
      context: context ?? Get.context!,
      initialValue: initialDateTime != null ? [initialDateTime] : null,
      mode: DatePickerSelectionMode.single,
      enableTime: true,
      showQuickPresets: false,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      title: title ?? 'اختيار التاريخ والوقت',
      useDialog: useDialog,
    );
    return dates != null && dates.isNotEmpty ? dates.first : null;
  }

  /// اختيار تواريخ متعددة متفرقة (Multi Dates)
  Future<List<DateTime>?> pickMultiDates({
    BuildContext? context,
    List<DateTime>? initialDates,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    String? title,
    bool useDialog = false,
  }) async {
    final dates = await showPicker(
      context: context ?? Get.context!,
      initialValue: initialDates,
      mode: DatePickerSelectionMode.multi,
      enableTime: false,
      showQuickPresets: false,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      title: title ?? 'اختيار تواريخ متعددة',
      useDialog: useDialog,
    );
    return dates?.whereType<DateTime>().toList();
  }

  /// إظهار منتقي التاريخ والوقت التفاعلي العام وإرجاع قائمة التواريخ المحددة
  Future<List<DateTime?>?> showPicker({
    BuildContext? context,
    List<DateTime?>? initialValue,
    DatePickerSelectionMode mode = DatePickerSelectionMode.single,
    bool enableTime = false,
    bool showQuickPresets = true,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    String? title,
    bool useDialog = false,
  }) async {
    final ctx = context ?? Get.context!;
    if (useDialog) {
      return CustomDatePickerModal.showDialog(
        context: ctx,
        initialValue: initialValue,
        mode: mode,
        enableTime: enableTime,
        showQuickPresets: showQuickPresets,
        firstDate: firstDate,
        lastDate: lastDate,
        currentDate: currentDate,
        selectableDayPredicate: selectableDayPredicate,
        title: title ?? 'اختيار التاريخ',
      );
    }

    return CustomDatePickerModal.showBottomSheet(
      context: ctx,
      initialValue: initialValue,
      mode: mode,
      enableTime: enableTime,
      showQuickPresets: showQuickPresets,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      title: title ?? 'اختيار التاريخ',
    );
  }

  /// إظهار منتقي التاريخ كنافذة سفلية منبثقة (Bottom Sheet)
  Future<List<DateTime?>?> showBottomSheet({
    BuildContext? context,
    List<DateTime?>? initialValue,
    DatePickerSelectionMode mode = DatePickerSelectionMode.single,
    bool enableTime = false,
    bool showQuickPresets = true,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    String? title,
  }) => showPicker(
    context: context,
    initialValue: initialValue,
    mode: mode,
    enableTime: enableTime,
    showQuickPresets: showQuickPresets,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    selectableDayPredicate: selectableDayPredicate,
    title: title,
    useDialog: false,
  );

  /// إظهار منتقي التاريخ في مربع حوار مركزي (Dialog)
  Future<List<DateTime?>?> showDialog({
    BuildContext? context,
    List<DateTime?>? initialValue,
    DatePickerSelectionMode mode = DatePickerSelectionMode.single,
    bool enableTime = false,
    bool showQuickPresets = true,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    bool Function(DateTime)? selectableDayPredicate,
    String? title,
  }) => showPicker(
    context: context,
    initialValue: initialValue,
    mode: mode,
    enableTime: enableTime,
    showQuickPresets: showQuickPresets,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    selectableDayPredicate: selectableDayPredicate,
    title: title,
    useDialog: true,
  );

  // ───────────────────────────────────────────────────────────────────────────
  // 2. دوال التنسيق العربية المعتمدة على [DateFormatter] الموحد
  // ───────────────────────────────────────────────────────────────────────────

  /// تسميات أيام الأسبوع المختصرة المطلوبة لترويسة تقويم calendar_date_picker2
  static const List<String> weekdayShortLabels = [
    'أحد',
    'إثن',
    'ثلا',
    'أرب',
    'خمي',
    'جمع',
    'سبت'
  ];

  /// اسم بديل متوافق لتسميات أيام الأسبوع المختصرة
  static const List<String> arabicWeekdayShort = weekdayShortLabels;

  /// تنسيق تاريخ مفرد باللغة العربية عبر [DateTimeX] الموحد
  String formatArabicDate(
    DateTime? date, {
    bool includeDayName = true,
    bool includeTime = false,
  }) {
    if (date == null) return '';
    if (includeTime) {
      return includeDayName
          ? '${date.toFullDate()} (${date.toTime()})'
          : '${date.toLongDate()} (${date.toTime()})';
    }
    return includeDayName ? date.toFullDate() : date.toLongDate();
  }

  /// تنسيق نطاق زمني باللغة العربية عبر [DateFormatter] الموحد
  String formatArabicRange(
    DateTime? start,
    DateTime? end, {
    bool includeTime = false,
  }) {
    if (start == null && end == null) return 'اختر النطاق الزمني';
    if (start != null && end == null) {
      return 'من ${formatArabicDate(start, includeDayName: false, includeTime: includeTime)}';
    }
    return '${formatArabicDate(start, includeDayName: false, includeTime: includeTime)}  ←  ${formatArabicDate(end, includeDayName: false, includeTime: includeTime)}';
  }
}
