import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
export 'package:dropdown_button2/dropdown_button2.dart' show DropdownItem;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' show RxBool;
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// يكيّف `RxBool` من GetX مع `ValueListenable<bool>` ليستطيع
/// `ValueListenableBuilder` داخل القائمة المفتوحة التفاعل مع تغيّره.
/// يشترك في تدفق الـ Rx فقط ما دام مستمع واحد على الأقل مرتبطًا،
/// فيُحدّ عمر الاشتراك بعمر الـ ValueListenableBuilder نفسه.
class RxBoolListenable implements ValueListenable<bool> {
  RxBoolListenable(this._rx);

  final RxBool _rx;
  StreamSubscription<bool>? _subscription;
  final Set<VoidCallback> _listeners = {};

  void _syncSubscription() {
    if (_listeners.isNotEmpty && _subscription == null) {
      _subscription = _rx.stream.listen((_) {
        for (final listener in List<VoidCallback>.of(_listeners)) {
          listener();
        }
      });
    } else if (_listeners.isEmpty && _subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }
  }

  @override
  bool get value => _rx.value;

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    _syncSubscription();
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    _syncSubscription();
  }
}

/// حقل قائمة منسدلة موحد وقابل لإعادة الاستخدام (CustomDropdown)
class CustomDropdown<T> extends StatefulWidget {
  const CustomDropdown({
    super.key,
    required this.items,
    required this.valueListenable,
    required this.onChanged,
    this.hint,
    this.label,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
    this.searchEnabled = true,
    this.itemSearchText,
    this.onRemoteSearch,
    this.isSearchingListenable,
    this.isSearching = false,
    this.selectedItemFallback,
    this.showScanner = false,
    this.onScannerTap,
    this.onScanResult,
  });

  final List<DropdownItem<T>> items;

  /// قناة القيمة التفاعلية — تُدار من الـ Controller (GetX).
  final ValueListenable<T?> valueListenable;

  final ValueChanged<T?>? onChanged;

  final String? hint;

  final String? label;

  final IconData? prefixIcon;

  final String? Function(T?)? validator;

  final bool enabled;

  final bool searchEnabled;

  /// نص يظهر في خانة البحث لكل قيمة، عادةً الـ label الظاهر.
  /// يُستخدم للفلترة النصية داخل القائمة. عند غيابه يُبحث عبر `toString()`.
  final String Function(T value)? itemSearchText;

  /// دالة استدعاء البحث السيرفري عن بُعد (مع مؤقت تأخير Debounce 350ms تلقائي).
  final Future<void> Function(String query)? onRemoteSearch;

  /// مؤشر تفاعلي لحالة طلب البحث السيرفري الجاري.
  final ValueListenable<bool>? isSearchingListenable;

  /// مؤشر ثابت لحالة طلب البحث السيرفري الجاري لإظهار دوار التحميل.
  final bool isSearching;

  /// عنصر احتياطي يضمن بقاء العنصر المحدد مسبقاً مرئياً حتى لو استبعدته نتائج البحث.
  final DropdownItem<T>? selectedItemFallback;

  /// يُظهر زر مسح رمز QR بجانب حقل البحث في القائمة المنسدلة (لأجهزة الموبايل).
  final bool showScanner;

  /// معالج الضغط على زر الماسح الضوئي (QR Scanner Callback).
  final VoidCallback? onScannerTap;

  /// استدعاء اختياري عند التقاط نص من الماسح.
  final ValueChanged<String>? onScanResult;

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<Offset> _shakeAnimation;
  late final String? Function(T?)? _wrappedValidator;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _hadError = false;

  /// قائمة ثابتة الهوية تُمرَّر للحزمة حتى يظل الرابط المرجعي الذي تلتقطه
  /// القائمة المفتوحة كما هو؛ تُحدَّث محتوياتها في مكانها فقط.
  late final List<DropdownItem<T>> _currentItems;

  /// يشير إلى أن آخر نتيجة بحث سيرفري كانت فارغة، فيُعرض «لا توجد نتائج».
  bool _remoteEmpty = false;

  /// يحمي «الاستحثاث» الاصطناعي لمحرف البحث من إطلاق ديبونس خدمي إضافي.
  bool _poking = false;

  @override
  void initState() {
    super.initState();
    _currentItems = List<DropdownItem<T>>.of(widget.items);

    _shakeController = AnimationController(
      vsync: this,
      duration: AppMotion.normal,
    );
    _shakeAnimation = _shakeController.drive(
      TweenSequence<Offset>([
        TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(-10, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(-10, 0), end: const Offset(10, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(10, 0), end: const Offset(-7, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(-7, 0), end: const Offset(7, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(7, 0), end: const Offset(-4, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(-4, 0), end: const Offset(4, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(4, 0), end: Offset.zero),
          weight: 1,
        ),
      ]),
    );

    _wrappedValidator = widget.validator == null
        ? null
        : (value) {
            final error = widget.validator?.call(value);
            if (error != null && !_hadError) {
              _shake();
            }
            _hadError = error != null;
            return error;
          };

    if (widget.onRemoteSearch != null) {
      _searchController.addListener(_onSearchInputChanged);
    }
  }

  @override
  void didUpdateWidget(CustomDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onRemoteSearch != widget.onRemoteSearch) {
      if (oldWidget.onRemoteSearch != null) {
        _searchController.removeListener(_onSearchInputChanged);
      }
      if (widget.onRemoteSearch != null) {
        _searchController.addListener(_onSearchInputChanged);
      }
    }
  }

  void _onSearchInputChanged() {
    if (widget.onRemoteSearch == null || _poking) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        _runRemoteSearch(_searchController.text.trim());
      }
    });
  }

  /// يُنفِّذ البحث السيرفري ثم ينتظر إطارًا بعد انعكاس النتيجة على
  /// الـ widgets من الـ Controller (Obx) كي يقرأ القائمة المحدَّثة.
  Future<void> _runRemoteSearch(String query) async {
    final remote = widget.onRemoteSearch;
    if (remote == null) return;
    await remote(query);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyRemoteResult();
    });
  }

  /// يطابق محتويات القائمة الثابتة مع آخر نتيجة سيرفرية ويستحث القائمة
  /// المفتوحة على إعادة الرسم (الآلية الوحيدة المتاحة في الحزمة).
  void _applyRemoteResult() {
    final effective = _resolveItems(widget.valueListenable.value);
    if (effective.isEmpty) {
      // إبقاء المحتوى السابق (غير فارغ) لتفادي انهيار items[0] داخل الحزمة.
      _remoteEmpty = true;
    } else {
      _remoteEmpty = false;
      _currentItems
        ..clear()
        ..addAll(effective);
    }
    _pokeMenu();
    setState(() {});
  }

  void _pokeMenu() {
    if (!mounted || widget.onRemoteSearch == null) return;
    _poking = true;
    try {
      final value = _searchController.value;
      _searchController.value = value.copyWith(
        text: '${value.text} ',
        selection: TextSelection.collapsed(offset: value.text.length + 1),
      );
      _searchController.value = value;
    } finally {
      _poking = false;
    }
  }

  /// دوار البحث أو زر المسح وفق حالة البحث السيرفري.
  Widget _buildSearchSuffix() {
    final searching = widget.isSearchingListenable;
    if (searching == null) {
      return widget.isSearching ? _buildSpinner() : _buildClearButton();
    }
    return ValueListenableBuilder<bool>(
      valueListenable: searching,
      builder: (context, isSearching, _) =>
          isSearching ? _buildSpinner() : _buildClearButton(),
    );
  }

  Widget _buildSpinner() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: SizedBox(
        width: 16.r,
        height: 16.r,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildClearButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _searchController,
      builder: (context, value, _) {
        if (value.text.isEmpty) {
          return const SizedBox.shrink();
        }
        return IconButton(
          icon: Icon(Icons.clear_rounded, size: 20.r),
          tooltip: 'مسح البحث',
          onPressed: () {
            _searchController.clear();
            if (widget.onRemoteSearch != null) {
              _debounceTimer?.cancel();
              _runRemoteSearch('');
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchInputChanged);
    _shakeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// يضمن التزام الزر بالقيمة حتى لو نسي المستدعي تحديث القناة: يكتب القيمة
  /// مباشرة في ValueNotifier إن وُجد، ثم يمرر الحدث للمسمى دائماً.
  void _handleChange(T? value) {
    final listenable = widget.valueListenable;
    if (listenable is ValueNotifier<T?>) {
      listenable.value = value;
    }
    widget.onChanged?.call(value);
  }

  void _shake() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _shakeController.forward(from: 0);
      }
    });
  }

  List<DropdownItem<T>> _resolveItems(T? currentValue) {
    if (currentValue == null) return widget.items;
    final exists = widget.items.any((item) => item.value == currentValue);
    if (exists) return widget.items;

    if (widget.selectedItemFallback != null) {
      return [widget.selectedItemFallback!, ...widget.items];
    }

    final text =
        widget.itemSearchText?.call(currentValue) ?? currentValue.toString();
    return [
      DropdownItem<T>(
        value: currentValue,
        child: Text(
          text,
          style: AppTypography.bodyMedium,
        ),
      ),
      ...widget.items,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentValue = widget.valueListenable.value;
    final effectiveItems = _resolveItems(currentValue);

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) =>
          Transform.translate(offset: _shakeAnimation.value, child: child),
      child: DropdownButtonFormField2<T>(
        valueListenable: widget.valueListenable,
        isExpanded: true,
        validator: _wrappedValidator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: widget.enabled ? _handleChange : null,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: widget.prefixIcon == null
              ? null
              : Icon(
                  widget.prefixIcon,
                  color: colors.primary,
                  size: 20.r,
                ),
          contentPadding: EdgeInsetsDirectional.only(
            start: AppSpacing.inputPadding,
            top: AppSpacing.inputPadding,
            bottom: AppSpacing.inputPadding,
            end: AppSpacing.sm,
          ),
        ),
        hint: widget.hint == null
            ? null
            : Text(
                widget.hint!,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
        iconStyleData: IconStyleData(
          icon: Icon(
            widget.enabled
                ? Icons.keyboard_arrow_down_rounded
                : Icons.lock_outline_rounded,
            size: widget.enabled ? 24.r : 20.r,
            color: colors.onSurfaceVariant,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 350.h,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        onMenuStateChange: (isOpen) {
          if (!mounted) return;
          if (!isOpen && _searchController.text.isNotEmpty) {
            _searchController.clear();
            if (widget.onRemoteSearch != null) {
              _debounceTimer?.cancel();
              _runRemoteSearch('');
            }
          }
        },
        dropdownSearchData: widget.searchEnabled
            ? DropdownSearchData(
                searchController: _searchController,
                searchBarWidgetHeight: 56.h,
                searchBarWidget: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          style: AppTypography.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'ابحث...',
                            prefixIcon: Icon(Icons.search_rounded, size: 20.r),
                            suffixIcon: _buildSearchSuffix(),
                          ),
                        ),
                      ),
                      if (widget.showScanner && widget.onScannerTap != null) ...[
                        SizedBox(width: AppSpacing.sm),
                        IconButton.filledTonal(
                          tooltip: 'مسح رمز QR',
                          icon: Icon(Icons.qr_code_scanner_rounded, size: 20.r),
                          onPressed: widget.onScannerTap,
                        ),
                      ],
                    ],
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  if (widget.onRemoteSearch != null) {
                    return !_remoteEmpty;
                  }
                  final query = searchValue.trim().toLowerCase();
                  if (query.isEmpty) return true;
                  final itemValue = item.value;
                  final text = itemValue is T
                      ? widget.itemSearchText?.call(itemValue) ??
                            itemValue.toString()
                      : '';
                  return text.toLowerCase().contains(query);
                },
                noResultsWidget: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'لا توجد نتائج مطابقة',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            : null,
        menuItemStyleData: MenuItemStyleData(
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.sm,
            end: AppSpacing.sm,
          ),
        ),
        items: _syncItems(effectiveItems),
      ),
    );
  }

  /// يحدّث القائمة الثابتة الهوية في مكانها ويعيدها لتمريرها للحزمة،
  /// فلا تُعاد إنشاء الكائن وتظل القائمة المفتوحة تشير إليه دائمًا.
  List<DropdownItem<T>> _syncItems(List<DropdownItem<T>> effective) {
    if (effective.isNotEmpty || _currentItems.isEmpty) {
      _currentItems
        ..clear()
        ..addAll(effective);
    }
    return _currentItems;
  }
}
