import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/presentation/controllers/packages_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// نافذة معالج إنشاء وتعديل باقة الكروت الذكية (CreateEditPackageSheet)
/// ============================================================================
/// تطبق المبدأ الحاكم (أقل احتكاك ممكن) عبر تزويد المستخدم بقوالب سريعة
/// وحاسبة لحظية لهوامش الربح والأسعار الصافية دون أي مجهود ذهني.
class CreateEditPackageSheet extends StatefulWidget {
  final PackagesController controller;
  final VoucherPackageEntity? package;
  final int? preselectedNetworkId;

  const CreateEditPackageSheet({
    super.key,
    required this.controller,
    this.package,
    this.preselectedNetworkId,
  });

  /// الدالة المصنعية المركزية لعرض النافذة
  static Future<void> show(
    BuildContext context, {
    required PackagesController controller,
    VoucherPackageEntity? package,
    int? preselectedNetworkId,
  }) {
    final isEdit = package != null;
    final colors = context.colors;

    return CustomBottomSheet.show<void>(
      title: isEdit ? 'تعديل باقة الكروت' : 'إنشاء باقة كروت جديدة',
      subtitle: isEdit
          ? 'تعديل أسعار ومواصفات باقة "${package.packageName}"'
          : 'حدد مواصفات الباقة أو اختر قالباً سريعاً بنقرة واحدة',
      leadingIcon: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.confirmation_number_outlined,
          color: colors.primary,
          size: 20.r,
        ),
      ),
      scrollable: true,
      child: CreateEditPackageSheet(
        controller: controller,
        package: package,
        preselectedNetworkId: preselectedNetworkId,
      ),
    );
  }

  @override
  State<CreateEditPackageSheet> createState() => _CreateEditPackageSheetState();
}

class _CreateEditPackageSheetState extends State<CreateEditPackageSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _balanceController;
  late final TextEditingController _validityController;
  late final TextEditingController _uptimeController;
  late final TextEditingController _voucherCountController;
  late final TextEditingController _cashDiscountController;
  late final TextEditingController _creditDiscountController;
  late final ValueNotifier<int?> _selectedNetworkIdNotifier;

  String _selectedColor = '0xFF0D7A5F';

  @override
  void initState() {
    super.initState();
    final p = widget.package;

    final initialNetworkId = widget.package?.networkId ??
        widget.preselectedNetworkId ??
        (widget.controller.networks.length == 1
            ? widget.controller.networks.first.networkId
            : SessionService.to.activeNetworkId);
    _selectedNetworkIdNotifier = ValueNotifier<int?>(initialNetworkId);

    _nameController = TextEditingController(text: p?.packageName ?? '');
    _priceController = TextEditingController(
      text: p != null
          ? AmountFormatter.formatValue(p.packageVoucherPrice, decimalPlaces: 0)
          : '',
    );
    _balanceController = TextEditingController(
      text: p?.packageBalance != null
          ? AmountFormatter.formatValue(p!.packageBalance!, decimalPlaces: 0)
          : '',
    );
    _validityController = TextEditingController(text: p?.packageValidity ?? '');
    _uptimeController = TextEditingController(text: p?.packageUptime ?? '');
    _voucherCountController = TextEditingController(
      text: (p?.packageVoucherCount ?? 51).toString(),
    );
    _cashDiscountController = TextEditingController(
      text: p != null
          ? AmountFormatter.formatValue(
              p.packageDefaultCashDiscount,
              decimalPlaces: 0,
            )
          : '10',
    );
    _creditDiscountController = TextEditingController(
      text: p != null
          ? AmountFormatter.formatValue(
              p.packageDefaultCreditDiscount,
              decimalPlaces: 0,
            )
          : '5',
    );

    if (p?.packageColor != null && p!.packageColor!.isNotEmpty) {
      _selectedColor = p.packageColor!;
    }

    _priceController.addListener(_onFieldChanged);
    _cashDiscountController.addListener(_onFieldChanged);
    _creditDiscountController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _priceController.removeListener(_onFieldChanged);
    _cashDiscountController.removeListener(_onFieldChanged);
    _creditDiscountController.removeListener(_onFieldChanged);

    _selectedNetworkIdNotifier.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _balanceController.dispose();
    _validityController.dispose();
    _uptimeController.dispose();
    _voucherCountController.dispose();
    _cashDiscountController.dispose();
    _creditDiscountController.dispose();
    super.dispose();
  }

  /// تطبيق قالب سريع بنقرة واحدة (The Zero Friction Preset)
  void _applyPreset({
    required String name,
    required double price,
    required double balance,
    required String validity,
    required String uptime,
    required double cashDisc,
    required double creditDisc,
    required String color,
  }) {
    setState(() {
      _nameController.text = name;
      _priceController.text = AmountFormatter.formatValue(
        price,
        decimalPlaces: 0,
      );
      _balanceController.text = AmountFormatter.formatValue(
        balance,
        decimalPlaces: 0,
      );
      _validityController.text = validity;
      _uptimeController.text = uptime;
      _cashDiscountController.text = AmountFormatter.formatValue(
        cashDisc,
        decimalPlaces: 0,
      );
      _creditDiscountController.text = AmountFormatter.formatValue(
        creditDisc,
        decimalPlaces: 0,
      );
      _selectedColor = color;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final price =
        double.tryParse(AmountFormatter.clean(_priceController.text)) ?? 0.0;
    final balance = double.tryParse(
      AmountFormatter.clean(_balanceController.text),
    );
    final voucherCount =
        int.tryParse(AmountFormatter.clean(_voucherCountController.text)) ?? 51;
    final cashDisc =
        double.tryParse(AmountFormatter.clean(_cashDiscountController.text)) ??
        0.0;
    final creditDisc =
        double.tryParse(
          AmountFormatter.clean(_creditDiscountController.text),
        ) ??
        0.0;

    // تحديد معرف الشبكة من الباقة قيد التعديل أو الاختيار الصريح أو الشبكة الوحيدة أو السياق النشط
    final int? networkId = widget.package?.networkId ??
        _selectedNetworkIdNotifier.value ??
        (widget.controller.networks.length == 1
            ? widget.controller.networks.first.networkId
            : SessionService.to.activeNetworkId);

    if (networkId == null) {
      CustomSnackbar.show(
        title: 'تنبيه النطاق',
        message: 'لا يمكن حفظ الباقة: يرجى تحديد الشبكة التابعة لها الباقة أولاً.',
        type: SnackType.warning,
      );
      return;
    }

    final success = await widget.controller.savePackage(
      packageId: widget.package?.packageId,
      networkId: networkId,
      packageName: _nameController.text.trim(),
      packageColor: _selectedColor,
      packageBalance: balance,
      packageUptime: _uptimeController.text.trim().isEmpty
          ? null
          : _uptimeController.text.trim(),
      packageValidity: _validityController.text.trim().isEmpty
          ? null
          : _validityController.text.trim(),
      packageVoucherCount: voucherCount,
      packageVoucherPrice: price,
      packageDefaultCashDiscount: cashDisc,
      packageDefaultCreditDiscount: creditDisc,
      status: widget.package?.status ?? true,
    );

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEdit = widget.package != null;

    final priceVal =
        double.tryParse(AmountFormatter.clean(_priceController.text)) ?? 0.0;
    final cashDiscVal =
        double.tryParse(AmountFormatter.clean(_cashDiscountController.text)) ??
        0.0;
    final creditDiscVal =
        double.tryParse(
          AmountFormatter.clean(_creditDiscountController.text),
        ) ??
        0.0;

    final netCash = priceVal - (priceVal * cashDiscVal / 100);
    final netCredit = priceVal - (priceVal * creditDiscVal / 100);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. القوالب السريعة (تظهر فقط عند إنشاء باقة جديدة لتوفير الوقت) ──
          if (!isEdit) ...[
            Text(
              'قوالب فئات الكروت الشائعة في السوق (تعبئة فورية بنقرة واحدة):',
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vXs,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _PresetChip(
                    label: '500 ر.ي (1GB / يوم)',
                    onTap: () => _applyPreset(
                      name: 'باقة 500 ريال',
                      price: 500,
                      balance: 1024,
                      validity: '1',
                      uptime: '24',
                      cashDisc: 10,
                      creditDisc: 5,
                      color: '0xFF0D7A5F',
                    ),
                  ),
                  AppSpacing.hXs,
                  _PresetChip(
                    label: '1000 ر.ي (3GB / أسبوع)',
                    onTap: () => _applyPreset(
                      name: 'باقة 1000 ريال',
                      price: 1000,
                      balance: 3072,
                      validity: '7',
                      uptime: '72',
                      cashDisc: 10,
                      creditDisc: 5,
                      color: '0xFF1976D2',
                    ),
                  ),
                  AppSpacing.hXs,
                  _PresetChip(
                    label: '2000 ر.ي (8GB / شهر)',
                    onTap: () => _applyPreset(
                      name: 'باقة 2000 ريال',
                      price: 2000,
                      balance: 8192,
                      validity: '30',
                      uptime: '160',
                      cashDisc: 12,
                      creditDisc: 6,
                      color: '0xFF7B1FA2',
                    ),
                  ),
                  AppSpacing.hXs,
                  _PresetChip(
                    label: '5000 ر.ي (25GB / شهر)',
                    onTap: () => _applyPreset(
                      name: 'باقة 5000 ريال',
                      price: 500,
                      balance: 25600,
                      validity: '30',
                      uptime: '300',
                      cashDisc: 15,
                      creditDisc: 8,
                      color: '0xFFE65100',
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.vMd,
          ],

          // ── 2. اختيار اللون المميز للباقة عبر المنتقي الموحد ──
          CustomColorPicker(
            label: 'اللون التعريفي للباقة في شاشات النظام:',
            selectedColorHex: _selectedColor,
            onColorChanged: (hex) => setState(() => _selectedColor = hex),
          ),

          AppSpacing.vMd,

          // ── 3. اختيار الشبكة (في حال امتلاك المزود لأكثر من شبكة) ──
          if (!isEdit)
            Obx(() {
              if (widget.controller.networks.length > 1) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: CustomDropdown<int>(
                    label: 'الشبكة التابعة لها الباقة *',
                    hint: 'اختر الشبكة',
                    prefixIcon: Icons.cell_tower_rounded,
                    valueListenable: _selectedNetworkIdNotifier,
                    items: widget.controller.networks
                        .map(
                          (net) => DropdownItem<int>(
                            value: net.networkId,
                            child: Text(net.networkName),
                          ),
                        )
                        .toList(),
                    itemSearchText: (id) =>
                        widget.controller.networks
                            .firstWhereOrNull((n) => n.networkId == id)
                            ?.networkName ??
                        '',
                    onChanged: (id) {
                      _selectedNetworkIdNotifier.value = id;
                    },
                    validator: (val) {
                      if (val == null) {
                        return 'يرجى اختيار الشبكة التابعة لها الباقة أولاً';
                      }
                      return null;
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

          // ── 4. حقول إدخال البيانات الأساسية ──
          CustomTextField(
            controller: _nameController,
            label: 'اسم باقة الكروت',
            hint: 'مثال: باقة يومية 500 ريال',
            prefixIcon: const Icon(Icons.confirmation_number_outlined),
            validator: FormValidators.required(fieldName: 'اسم باقة الكروت'),
          ),

          AppSpacing.vSm,

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _priceController,
                  label: 'سعر البيع للجمهور (ر.ي)',
                  hint: '500',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.payments_outlined),
                  validator: FormValidators.amountValidator(
                    fieldName: 'سعر البيع للجمهور',
                    minValue: 1,
                  ),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomTextField(
                  controller: _balanceController,
                  label: 'رصيد البيانات (MB)',
                  hint: '1024',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.data_usage_rounded),
                ),
              ),
            ],
          ),

          AppSpacing.vSm,

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _validityController,
                  label: 'فترة الصلاحية (بالأيام)',
                  hint: 'مثال: 7',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.schedule_rounded),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomTextField(
                  controller: _uptimeController,
                  label: 'ساعات الاستخدام (ساعة)',
                  hint: 'مثال: 24',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.timer_outlined),
                ),
              ),
            ],
          ),

          AppSpacing.vSm,

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _cashDiscountController,
                  label: 'خصم الكاش الافتراضي (%)',
                  hint: '10',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.percent_rounded),
                  validator: FormValidators.percentageValidator(
                    fieldName: 'خصم الكاش الافتراضي',
                  ),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomTextField(
                  controller: _creditDiscountController,
                  label: 'خصم الآجل الافتراضي (%)',
                  hint: '5',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.percent_rounded),
                  validator: FormValidators.percentageValidator(
                    fieldName: 'خصم الآجل الافتراضي',
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          // ── 4. المعاينة اللحظية لهوامش الربح (Zero-Friction Margin Engine) ──
          if (priceVal > 0) ...[
            _MarginPreviewBox(
              price: priceVal,
              netCash: netCash,
              netCredit: netCredit,
              cashDiscountPercent: cashDiscVal,
              creditDiscountPercent: creditDiscVal,
            ),
            AppSpacing.vMd,
          ],

          // ── 5. زر التأكيد والحفظ ──
          CustomButton.primary(
            text: isEdit ? 'تحديث باقة الكروت' : 'حفظ وإضافة الباقة',
            icon: Icons.check_circle_outline_rounded,
            onPressed: _submit,
          ),

          AppSpacing.vSm,
        ],
      ),
    );
  }
}

/// ودجت مستقل لاختيار القوالب السريعة
class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 14.r, color: colors.primary),
            AppSpacing.hXxs,
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ودجت مستقل للمعاينة اللحظية لهوامش الربح (Real-time Margin Preview Box)
class _MarginPreviewBox extends StatelessWidget {
  final double price;
  final double netCash;
  final double netCredit;
  final double cashDiscountPercent;
  final double creditDiscountPercent;

  const _MarginPreviewBox({
    required this.price,
    required this.netCash,
    required this.netCredit,
    required this.cashDiscountPercent,
    required this.creditDiscountPercent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cashSavings = price - netCash;
    final creditSavings = price - netCredit;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14.r,
                color: colors.primary,
              ),
              AppSpacing.hXxs,
              Text(
                'احتساب فوري لهامش ربح نقطة البيع (تكلفة الشراء الصافية):',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.vXs,
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colors.successContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عند الشراء نقداً (ربح ${AmountFormatter.formatValue(cashSavings, decimalPlaces: 0)} ر.ي)',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.success,
                        ),
                      ),
                      Text(
                        'يدفع الوكيل: ${AmountFormatter.formatValue(netCash, decimalPlaces: 0)} ر.ي',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عند الشراء آجلاً (ربح ${AmountFormatter.formatValue(creditSavings, decimalPlaces: 0)} ر.ي)',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                      Text(
                        'يدفع الوكيل: ${AmountFormatter.formatValue(netCredit, decimalPlaces: 0)} ر.ي',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
