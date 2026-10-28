import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/presentation/controllers/packages_controller.dart';
import 'package:netsales/features/partners/domain/entities/pos_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/pickers/custom_pos_selector_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// نافذة معالج إنشاء وتعديل خصم نقطة البيع (CreateEditDiscountSheet)
/// ============================================================================
class CreateEditDiscountSheet extends StatefulWidget {
  final PackagesController controller;
  final VoucherPackageDiscountEntity? discount;
  final int? preselectedPackageId;
  final PosEntity? preselectedPos;

  const CreateEditDiscountSheet({
    super.key,
    required this.controller,
    this.discount,
    this.preselectedPackageId,
    this.preselectedPos,
  });

  /// الدالة المصنعية المركزية لعرض النافذة
  static Future<void> show(
    BuildContext context, {
    required PackagesController controller,
    VoucherPackageDiscountEntity? discount,
    int? preselectedPackageId,
    PosEntity? preselectedPos,
  }) {
    final isEdit = discount != null;

    return CustomBottomSheet.show<void>(
      title: isEdit ? 'تعديل الخصم المخصص' : 'تخصيص خصم استثنائي لوكيل',
      subtitle: isEdit
          ? 'تعديل نسب الخصم لنقطة البيع على الباقة'
          : 'حدد نقطة البيع والباقة والنسب مع احتساب فوري للتكلفة',
      leadingIcon: Icons.percent_rounded,
      scrollable: true,
      child: CreateEditDiscountSheet(
        controller: controller,
        discount: discount,
        preselectedPackageId: preselectedPackageId,
        preselectedPos: preselectedPos,
      ),
    );
  }

  @override
  State<CreateEditDiscountSheet> createState() =>
      _CreateEditDiscountSheetState();
}

class _CreateEditDiscountSheetState extends State<CreateEditDiscountSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _cashDiscountController;
  late final TextEditingController _creditDiscountController;

  int? _selectedPackageId;
  PosEntity? _selectedPos;
  String? _posError;

  @override
  void initState() {
    super.initState();
    final d = widget.discount;

    if (d != null) {
      _selectedPos =
          widget.controller.posList.firstWhereOrNull(
            (p) => p.posId == d.posId,
          ) ??
          PosEntity(
            posId: d.posId,
            posUuid: '',
            posName: d.posName ?? 'وكيل نقطة البيع #${d.posId}',
            governorateId: 0,
            directorateId: 0,
            ownerId: 0,
            status: 'ACTIVE',
          );
    } else if (widget.preselectedPos != null) {
      _selectedPos = widget.preselectedPos;
    }

    _cashDiscountController = TextEditingController(
      text: d != null
          ? AmountFormatter.formatValue(d.discountCash, decimalPlaces: 0)
          : '15',
    );
    _creditDiscountController = TextEditingController(
      text: d != null
          ? AmountFormatter.formatValue(d.discountCredit, decimalPlaces: 0)
          : '8',
    );

    _selectedPackageId = d?.packageId ?? widget.preselectedPackageId;

    if (_selectedPackageId == null && widget.controller.packages.isNotEmpty) {
      _selectedPackageId = widget.controller.packages.first.packageId;
    }

    _cashDiscountController.addListener(_onFieldChanged);
    _creditDiscountController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _cashDiscountController.removeListener(_onFieldChanged);
    _creditDiscountController.removeListener(_onFieldChanged);
    _cashDiscountController.dispose();
    _creditDiscountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedPos == null) {
      setState(() => _posError = 'يرجى اختيار نقطة البيع أو الوكيل');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final posId = _selectedPos!.posId;
    final cashDisc =
        double.tryParse(AmountFormatter.clean(_cashDiscountController.text)) ??
        0.0;
    final creditDisc =
        double.tryParse(
          AmountFormatter.clean(_creditDiscountController.text),
        ) ??
        0.0;

    if (_selectedPackageId == null || _selectedPackageId! <= 0) {
      return;
    }

    // استنتاج معرف الشبكة من الباقة المختارة أو الخصم قيد التعديل
    final selectedPkg = widget.controller.packages.firstWhereOrNull(
      (p) => p.packageId == _selectedPackageId,
    );
    final int? networkId = widget.discount?.networkId ?? selectedPkg?.networkId;

    if (networkId == null) {
      CustomSnackbar.show(
        title: 'تنبيه النطاق',
        message:
            'لا يمكن حفظ الخصم: لم يتم العثور على شبكة مرتبطة بالباقة المختارة.',
        type: SnackType.warning,
      );
      return;
    }

    final success = await widget.controller.saveDiscount(
      discountId: widget.discount?.discountId,
      networkId: networkId,
      posId: posId,
      packageId: _selectedPackageId!,
      discountCash: cashDisc,
      discountCredit: creditDisc,
      status: widget.discount?.status ?? true,
    );

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEdit = widget.discount != null;

    final selectedPkg = widget.controller.packages.firstWhereOrNull(
      (p) => p.packageId == _selectedPackageId,
    );
    final basePrice = selectedPkg?.packageVoucherPrice ?? 0.0;

    final cashDiscVal =
        double.tryParse(AmountFormatter.clean(_cashDiscountController.text)) ??
        0.0;
    final creditDiscVal =
        double.tryParse(
          AmountFormatter.clean(_creditDiscountController.text),
        ) ??
        0.0;

    final netCash = basePrice - (basePrice * cashDiscVal / 100);
    final netCredit = basePrice - (basePrice * creditDiscVal / 100);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. اختيار الباقة المستهدفة ──
          Text(
            'باقة الكروت المستهدفة بالخصم الاستثنائي',
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vXs,
          if (widget.controller.packages.isEmpty)
            Text(
              'لا توجد باقات كروت مسجلة في النظام لتطبيق الخصم عليها.',
              style: AppTypography.bodySmall.copyWith(color: colors.error),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: widget.controller.packages.map((pkg) {
                  final isSelected = pkg.packageId == _selectedPackageId;
                  return Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: _PackageSelectChip(
                      label:
                          '${pkg.packageName} (${AmountFormatter.formatValue(pkg.packageVoucherPrice, decimalPlaces: 0)} ر.ي)',
                      isSelected: isSelected,
                      isDisabled: isEdit,
                      onTap: () {
                        if (!isEdit) {
                          setState(() {
                            _selectedPackageId = pkg.packageId;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

          AppSpacing.vMd,

          // ── 2. اختيار وتحديد نقطة البيع / الوكيل الذكي ──
          Obx(
            () => CustomPosSelectorField(
              label: 'نقطة البيع / الوكيل المخصص له الخصم',
              selectedPos: _selectedPos,
              posList: widget.controller.posList,
              isLoading: widget.controller.isLoadingPosList.value,
              readOnly: isEdit,
              onPosChanged: (pos) {
                setState(() {
                  _selectedPos = pos;
                  _posError = null;
                });
              },
              errorText: _posError,
            ),
          ),

          AppSpacing.vSm,

          // ── 3. نسب الخصم المخصصة ──
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _cashDiscountController,
                  label: 'نسبة خصم الكاش (%)',
                  hint: '15',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.percent_rounded),
                  validator: FormValidators.percentageValidator(
                    fieldName: 'نسبة خصم الكاش',
                  ),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomTextField(
                  controller: _creditDiscountController,
                  label: 'نسبة خصم الآجل (%)',
                  hint: '8',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.percent_rounded),
                  validator: FormValidators.percentageValidator(
                    fieldName: 'نسبة خصم الآجل',
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          // ── 4. المعاينة اللحظية لهوامش وتكاليف نقطة البيع ──
          if (basePrice > 0) ...[
            _DiscountMarginPreviewBox(
              basePrice: basePrice,
              netCash: netCash,
              netCredit: netCredit,
              cashDiscount: cashDiscVal,
              creditDiscount: creditDiscVal,
            ),
            AppSpacing.vMd,
          ],

          // ── 5. زر الحفظ والتأكيد ──
          CustomButton.primary(
            text: isEdit ? 'تحديث الخصم المخصص' : 'تطبيق وحفظ الخصم الاستثنائي',
            icon: Icons.check_circle_outline_rounded,
            onPressed: _submit,
          ),

          AppSpacing.vSm,
        ],
      ),
    );
  }
}

/// ودجت مستقل للمعاينة اللحظية لتكلفة نقطة البيع وهامش ربحها
class _DiscountMarginPreviewBox extends StatelessWidget {
  final double basePrice;
  final double netCash;
  final double netCredit;
  final double cashDiscount;
  final double creditDiscount;

  const _DiscountMarginPreviewBox({
    required this.basePrice,
    required this.netCash,
    required this.netCredit,
    required this.cashDiscount,
    required this.creditDiscount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cashProfit = basePrice - netCash;
    final creditProfit = basePrice - netCredit;

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
                Icons.calculate_outlined,
                size: 14.r,
                color: colors.secondary,
              ),
              AppSpacing.hXxs,
              Text(
                'الاحتساب اللحظي لمعاملة الوكيل (سعر الجمهور: ${AmountFormatter.formatValue(basePrice, decimalPlaces: 0)} ر.ي):',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.secondary,
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
                        'عند الدفع نقداً (${AmountFormatter.formatValue(cashDiscount, decimalPlaces: 0)}%)',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'يدفع الوكيل: ${AmountFormatter.formatValue(netCash, decimalPlaces: 0)} ر.ي',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ربح الوكيل: ${AmountFormatter.formatValue(cashProfit, decimalPlaces: 0)} ر.ي',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.success,
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
                        'عند الدفع آجلاً (${AmountFormatter.formatValue(creditDiscount, decimalPlaces: 0)}%)',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'يدفع الوكيل: ${AmountFormatter.formatValue(netCredit, decimalPlaces: 0)} ر.ي',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ربح الوكيل: ${AmountFormatter.formatValue(creditProfit, decimalPlaces: 0)} ر.ي',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.secondary,
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

/// ودجت مستقل لاختيار الباقة بتفاعل لمسي وألوان متناسقة
class _PackageSelectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _PackageSelectChip({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: isDisabled ? () {} : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary
              : colors.surfaceContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outlineVariant,
            width: 1.w,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? colors.onPrimary : colors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
