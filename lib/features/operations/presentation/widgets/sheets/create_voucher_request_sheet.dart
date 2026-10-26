import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// نافذة إنشاء وإرسال طلب توريد كروت سياقية (CreateVoucherRequestSheet)
/// ============================================================================
/// نافذة منبثقة عصرية تعتمد على [CustomBottomSheet.show] تتيح لنقاط البيع
/// اختيار الباقات وتحديد الكميات مع احتساب الأسعار والخصومات والنتائج فورياً.
class CreateVoucherRequestSheet extends StatefulWidget {
  final int? networkId;
  final int? posId;
  final String? networkName;

  const CreateVoucherRequestSheet({
    super.key,
    this.networkId,
    this.posId,
    this.networkName,
  });

  /// إظهار النافذة السفلية المنبثقة
  static Future<VoucherRequestEntity?> show(
    BuildContext context, {
    int? networkId,
    int? posId,
    String? networkName,
  }) {
    final titleSubtitle = networkName != null
        ? 'شبكة: $networkName'
        : 'طلب توريد من الشبكة المعتمدة';
    return CustomBottomSheet.show<VoucherRequestEntity>(
      title: 'طلب توريد باقات كروت',
      subtitle: titleSubtitle,
      leadingIcon: Container(
        padding: EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add_shopping_cart_rounded,
          color: context.colors.primary,
          size: 20.r,
        ),
      ),
      scrollable: true,
      child: CreateVoucherRequestSheet(
        networkId: networkId,
        posId: posId,
        networkName: networkName,
      ),
    );
  }

  @override
  State<CreateVoucherRequestSheet> createState() =>
      _CreateVoucherRequestSheetState();
}

class _CreateVoucherRequestSheetState extends State<CreateVoucherRequestSheet> {
  final TextEditingController _notesController = TextEditingController();
  final Map<int, int> _packageQuantities = {};

  int? _selectedNetworkId;
  int? _selectedPosId;
  List<NetworkPosEntity> _linkedNetworks = [];
  late final ValueNotifier<int?> _networkIdNotifier;

  String _saleType = 'CASH'; // CASH or CREDIT
  List<VoucherPackageEntity> _packages = [];
  bool _isLoadingPackages = true;
  String _loadError = '';

  @override
  void initState() {
    super.initState();
    _selectedNetworkId = widget.networkId;
    _selectedPosId = widget.posId;
    _networkIdNotifier = ValueNotifier<int?>(_selectedNetworkId);
    _loadInitialData();
  }

  @override
  void dispose() {
    _networkIdNotifier.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingPackages = true;
      _loadError = '';
    });

    try {
      // إذا لم تكن الشبكة محددة، نجلب الشبكات المرتبطة بنقطة البيع
      if (_selectedNetworkId == null && _selectedPosId != null) {
        if (Get.isRegistered<GetNetworkPosListUseCase>()) {
          final posUseCase = Get.find<GetNetworkPosListUseCase>();
          _linkedNetworks = await posUseCase(
            posId: _selectedPosId,
            status: true,
          );
          if (_linkedNetworks.isNotEmpty) {
            _selectedNetworkId = _linkedNetworks.first.networkId;
            _networkIdNotifier.value = _selectedNetworkId;
          }
        }
      }

      if (_selectedNetworkId != null) {
        await _fetchPackagesForNetwork(_selectedNetworkId!);
      } else {
        if (mounted) {
          setState(() {
            _isLoadingPackages = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = 'تعذر استرجاع باقات الشبكة: $e';
          _isLoadingPackages = false;
        });
      }
    }
  }

  Future<void> _fetchPackagesForNetwork(int netId) async {
    try {
      if (Get.isRegistered<GetVoucherPackagesUseCase>()) {
        final useCase = Get.find<GetVoucherPackagesUseCase>();
        final result = await useCase(
          networkId: netId,
          status: true,
        );
        if (mounted) {
          setState(() {
            _packages = result;
            _isLoadingPackages = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadError = 'خدمة الباقات غير مسجلة حالياً';
            _isLoadingPackages = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = 'تعذر استرجاع باقات الشبكة: $e';
          _isLoadingPackages = false;
        });
      }
    }
  }

  void _onNetworkChanged(int? newNetId) {
    if (newNetId == null || newNetId == _selectedNetworkId) return;
    setState(() {
      _selectedNetworkId = newNetId;
      _networkIdNotifier.value = newNetId;
      _packageQuantities.clear();
      _packages.clear();
      _isLoadingPackages = true;
    });
    _fetchPackagesForNetwork(newNetId);
  }

  void _incrementQuantity(int packageId) {
    setState(() {
      _packageQuantities[packageId] = (_packageQuantities[packageId] ?? 0) + 1;
    });
  }

  void _decrementQuantity(int packageId) {
    setState(() {
      final current = _packageQuantities[packageId] ?? 0;
      if (current > 1) {
        _packageQuantities[packageId] = current - 1;
      } else {
        _packageQuantities.remove(packageId);
      }
    });
  }

  int get _totalVoucherCount {
    return _packageQuantities.values.fold(0, (sum, count) => sum + count);
  }

  double get _totalGrossAmount {
    double total = 0.0;
    for (final pkg in _packages) {
      final qty = _packageQuantities[pkg.packageId] ?? 0;
      if (qty > 0) {
        total += pkg.packageVoucherPrice * qty;
      }
    }
    return total;
  }

  double get _totalDiscountAmount {
    double discount = 0.0;
    for (final pkg in _packages) {
      final qty = _packageQuantities[pkg.packageId] ?? 0;
      if (qty > 0) {
        final percent = _saleType == 'CASH'
            ? pkg.packageDefaultCashDiscount
            : pkg.packageDefaultCreditDiscount;
        final gross = pkg.packageVoucherPrice * qty;
        discount += gross * (percent / 100);
      }
    }
    return discount;
  }

  double get _totalNetAmount => _totalGrossAmount - _totalDiscountAmount;

  Future<void> _submitRequest() async {
    if (_totalVoucherCount <= 0) {
      CustomSnackbar.show(
        title: 'تنبيه التوريد',
        message: 'يرجى تحديد كمية باقة واحدة على الأقل لتقديم الطلب',
        type: SnackType.warning,
      );
      return;
    }

    final items = <Map<String, dynamic>>[];
    for (final pkg in _packages) {
      final qty = _packageQuantities[pkg.packageId] ?? 0;
      if (qty > 0) {
        final percent = _saleType == 'CASH'
            ? pkg.packageDefaultCashDiscount
            : pkg.packageDefaultCreditDiscount;
        items.add({
          'package_id': pkg.packageId,
          'voucher_count': qty,
          'voucher_price': pkg.packageVoucherPrice,
          'item_discount': percent,
        });
      }
    }

    if (_selectedNetworkId == null) {
      CustomSnackbar.show(
        title: 'تنبيه النطاق',
        message: 'يرجى تحديد الشبكة الموردة للكروت أولاً',
        type: SnackType.warning,
      );
      return;
    }

    if (_selectedPosId == null) {
      CustomSnackbar.show(
        title: 'تنبيه النطاق',
        message: 'تعذر تحديد نقطة البيع الخاصة بحسابك لتقديم الطلب',
        type: SnackType.warning,
      );
      return;
    }

    final operationsController = Get.find<OperationsController>();
    final result = await operationsController.createVoucherRequest(
      networkId: _selectedNetworkId!,
      posId: _selectedPosId!,
      saleType: _saleType,
      items: items,
      requestNote: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (result != null) {
      Get.back(result: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 0. اختيار الشبكة الموردة (في حال تعدد الشبكات المرتبطة)
        if (widget.networkId == null && _linkedNetworks.length > 1) ...[
          CustomDropdown<int>(
            label: 'الشبكة الموردة للكروت *',
            hint: 'اختر الشبكة',
            prefixIcon: Icons.cell_tower_rounded,
            valueListenable: _networkIdNotifier,
            items: _linkedNetworks
                .map(
                  (net) => DropdownItem<int>(
                    value: net.networkId,
                    child: Text(net.networkName ?? 'شبكة #${net.networkId}'),
                  ),
                )
                .toList(),
            itemSearchText: (id) =>
                _linkedNetworks
                    .firstWhereOrNull((n) => n.networkId == id)
                    ?.networkName ??
                '',
            onChanged: _onNetworkChanged,
          ),
          AppSpacing.vMd,
        ],

        // 1. مفتاح نوع الشراء (نقداً أو آجل)
        _SaleTypeToggleSection(
          selectedSaleType: _saleType,
          onChanged: (newType) {
            setState(() {
              _saleType = newType;
            });
          },
        ),
        AppSpacing.vMd,

        // 2. قائمة الباقات والكميات
        if (_isLoadingPackages) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: SizedBox(
                width: 28.r,
                height: 28.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(colors.primary),
                ),
              ),
            ),
          ),
        ] else if (_loadError.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: colors.error, size: 20.r),
                AppSpacing.hSm,
                Expanded(
                  child: Text(
                    _loadError,
                    style: AppTypography.bodySmall.copyWith(color: colors.error),
                  ),
                ),
              ],
            ),
          ),
        ] else if (_packages.isEmpty) ...[
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Text(
                'لا توجد باقات كروت مفعلة حالياً لهذه الشبكة',
                style: AppTypography.bodyMedium.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ),
        ] else ...[
          Text(
            'باقات الكروت المتاحة',
            style: AppTypography.labelLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vXs,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _packages.length,
            separatorBuilder: (_, __) => AppSpacing.vSm,
            itemBuilder: (context, index) {
              final pkg = _packages[index];
              final qty = _packageQuantities[pkg.packageId] ?? 0;
              final discountPercent = _saleType == 'CASH'
                  ? pkg.packageDefaultCashDiscount
                  : pkg.packageDefaultCreditDiscount;

              return _PackageSelectorItem(
                package: pkg,
                quantity: qty,
                discountPercent: discountPercent,
                onIncrement: () => _incrementQuantity(pkg.packageId),
                onDecrement: () => _decrementQuantity(pkg.packageId),
              );
            },
          ),
        ],

        AppSpacing.vMd,

        // 3. حقل الملاحظات الاختياري
        CustomTextField(
          label: 'ملاحظات وتوجيهات التوريد',
          hint: 'أضف أي تفاصيل أو ملاحظات خاصة بالطلب (اختياري)...',
          controller: _notesController,
          maxLines: 2,
        ),
        AppSpacing.vLg,

        // 4. السند التلخيصي التقديري المباشر
        if (_totalVoucherCount > 0) ...[
          _LiveOrderSummaryBond(
            voucherCount: _totalVoucherCount,
            grossAmount: _totalGrossAmount,
            discountAmount: _totalDiscountAmount,
            netAmount: _totalNetAmount,
            saleType: _saleType,
          ),
          AppSpacing.vLg,
        ],

        // 5. أزرار الإجراء
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomButton.primary(
                text: 'إرسال طلب التوريد',
                icon: Icons.send_rounded,
                onPressed: _totalVoucherCount > 0 ? _submitRequest : null,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomButton.outline(
                text: 'إلغاء',
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ودجت التبديل بين الشراء النقدي والآجل
class _SaleTypeToggleSection extends StatelessWidget {
  final String selectedSaleType;
  final ValueChanged<String> onChanged;

  const _SaleTypeToggleSection({
    required this.selectedSaleType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SaleTypeOptionButton(
              title: 'شراء نقدي',
              icon: Icons.payments_rounded,
              isSelected: selectedSaleType == 'CASH',
              onTap: () => onChanged('CASH'),
            ),
          ),
          AppSpacing.hXs,
          Expanded(
            child: _SaleTypeOptionButton(
              title: 'شراء بالآجل',
              icon: Icons.credit_score_rounded,
              isSelected: selectedSaleType == 'CREDIT',
              onTap: () => onChanged('CREDIT'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleTypeOptionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SaleTypeOptionButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
            ),
            AppSpacing.hXs,
            Text(
              title,
              style: AppTypography.buttonMedium.copyWith(
                color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// عنصر الباقة مع عداد الكمية
class _PackageSelectorItem extends StatelessWidget {
  final VoucherPackageEntity package;
  final int quantity;
  final double discountPercent;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _PackageSelectorItem({
    required this.package,
    required this.quantity,
    required this.discountPercent,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSelected = quantity > 0;
    final unitPrice = package.packageVoucherPrice;
    final unitNetPrice = unitPrice - (unitPrice * (discountPercent / 100));

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected
            ? colors.primary.withValues(alpha: 0.05)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isSelected
              ? colors.primary
              : colors.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 1.5.w : 1.w,
        ),
      ),
      child: Row(
        children: [
          // شريط لون الباقة
          Container(
            width: 8.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: package.packageColor != null &&
                      package.packageColor!.startsWith('#')
                  ? Color(int.parse(
                      package.packageColor!.replaceFirst('#', '0xFF')))
                  : colors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
          AppSpacing.hSm,

          // تفاصيل الباقة والأسعار
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.packageName,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vXxs,
                Row(
                  children: [
                    Text(
                      '${AmountFormatter.formatValue(unitPrice)} ر.ي',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (discountPercent > 0) ...[
                      AppSpacing.hXs,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxs,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.tertiary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          'خصم ${AmountFormatter.formatValue(discountPercent, decimalPlaces: 0)}%',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      AppSpacing.hXs,
                      Text(
                        '(${AmountFormatter.formatValue(unitNetPrice)} صافي)',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // عداد الكمية الرقمي
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomInteractiveBounce(
                onTap: onDecrement,
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: quantity > 0
                        ? colors.surfaceContainerHigh
                        : colors.surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.remove_rounded,
                      size: 16.r,
                      color: quantity > 0 ? colors.onSurface : colors.outline,
                    ),
                  ),
                ),
              ),
              Container(
                constraints: BoxConstraints(minWidth: 36.w),
                alignment: Alignment.center,
                child: Text(
                  '$quantity',
                  style: AppTypography.titleMedium.copyWith(
                    color: isSelected ? colors.primary : colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomInteractiveBounce(
                onTap: onIncrement,
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: 16.r,
                      color: colors.onPrimary,
                    ),
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

/// بطاقة السند التلخيصي التقديري المباشر
class _LiveOrderSummaryBond extends StatelessWidget {
  final int voucherCount;
  final double grossAmount;
  final double discountAmount;
  final double netAmount;
  final String saleType;

  const _LiveOrderSummaryBond({
    required this.voucherCount,
    required this.grossAmount,
    required this.discountAmount,
    required this.netAmount,
    required this.saleType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.8),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ملخص قيمة الطلب التقديرية',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: saleType == 'CASH'
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  saleType == 'CASH' ? 'دفع نقدي فوري' : 'ذمة آجلة على المحفظة',
                  style: AppTypography.labelSmall.copyWith(
                    color: saleType == 'CASH' ? colors.primary : colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Divider(color: colors.outlineVariant.withValues(alpha: 0.4)),
          AppSpacing.vXs,
          _SummaryRow(
            label: 'إجمالي عدد الكروت:',
            value: '$voucherCount كرت',
          ),
          AppSpacing.vXxs,
          _SummaryRow(
            label: 'القيمة الإجمالية قبل الخصم:',
            value: '${AmountFormatter.formatValue(grossAmount)} ر.ي',
          ),
          if (discountAmount > 0) ...[
            AppSpacing.vXxs,
            _SummaryRow(
              label: 'إجمالي الخصم الممنوح:',
              value: '- ${AmountFormatter.formatValue(discountAmount)} ر.ي',
              isDiscount: true,
            ),
          ],
          AppSpacing.vXs,
          Divider(color: colors.outlineVariant.withValues(alpha: 0.4)),
          AppSpacing.vXs,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الصافي المستحق:',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${AmountFormatter.formatValue(netAmount)} ر.ي',
                style: AppTypography.currencyHero.copyWith(
                  color: colors.primary,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: isDiscount ? colors.tertiary : colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
