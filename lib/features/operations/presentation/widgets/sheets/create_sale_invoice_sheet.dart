import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_networks_use_case.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// نافذة إصدار فاتورة مبيعات مباشرة سياقية (CreateSaleInvoiceSheet)
/// ============================================================================
/// تتيح لمزود الشبكة إصدار فاتورة مبيعات مباشرة لنقطة بيع محددة
/// مع خصم الكروت وتسوية رصيد المحفظة والذمم اللحظية بنمط الباكيند المعتمد.
class CreateSaleInvoiceSheet extends StatefulWidget {
  final int? networkId;
  final int? preselectedPosId;
  final String? preselectedPosName;

  const CreateSaleInvoiceSheet({
    super.key,
    this.networkId,
    this.preselectedPosId,
    this.preselectedPosName,
  });

  /// عرض النافذة السفلية المنبثقة
  static Future<SaleInvoiceEntity?> show(
    BuildContext context, {
    int? networkId,
    int? preselectedPosId,
    String? preselectedPosName,
  }) {
    return CustomBottomSheet.show<SaleInvoiceEntity>(
      title: 'إصدار فاتورة مبيعات مباشرة',
      subtitle: 'توزيع وتوريد كروت مع التسوية المالية الفورية',
      leadingIcon: Container(
        padding: EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.receipt_long_rounded,
          color: context.colors.primary,
          size: 20.r,
        ),
      ),
      scrollable: true,
      child: CreateSaleInvoiceSheet(
        networkId: networkId,
        preselectedPosId: preselectedPosId,
        preselectedPosName: preselectedPosName,
      ),
    );
  }

  @override
  State<CreateSaleInvoiceSheet> createState() => _CreateSaleInvoiceSheetState();
}

class _CreateSaleInvoiceSheetState extends State<CreateSaleInvoiceSheet> {
  final TextEditingController _paidAmountController = TextEditingController();
  final Map<int, int> _packageQuantities = {};

  int? _selectedNetworkId;
  List<NetworkEntity> _networks = [];
  late final ValueNotifier<int?> _networkIdNotifier;

  int? _selectedPosId;
  String? _selectedPosName;

  String _saleType = 'CASH'; // CASH or CREDIT
  List<VoucherPackageEntity> _packages = [];
  List<NetworkPosEntity> _linkedPosList = [];

  bool _isLoading = true;
  String _loadError = '';

  @override
  void initState() {
    super.initState();
    _selectedNetworkId = widget.networkId;
    _networkIdNotifier = ValueNotifier<int?>(_selectedNetworkId);
    _selectedPosId = widget.preselectedPosId;
    _selectedPosName = widget.preselectedPosName;
    _loadInitialData();
  }

  @override
  void dispose() {
    _networkIdNotifier.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _loadError = '';
    });

    try {
      // 1. جلب شبكات المزود المتاحة
      if (Get.isRegistered<GetNetworksUseCase>()) {
        _networks = await Get.find<GetNetworksUseCase>()();
        if (_selectedNetworkId == null && _networks.isNotEmpty) {
          _selectedNetworkId = _networks.first.networkId;
          _networkIdNotifier.value = _selectedNetworkId;
        }
      }

      // 2. جلب بيانات الشبكة المحددة (الباقات ونقاط البيع)
      if (_selectedNetworkId != null) {
        await _loadDataForNetwork(_selectedNetworkId!);
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = 'تعذر تحميل بيانات الإعداد: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDataForNetwork(int netId) async {
    // جلب باقات الشبكة
    if (Get.isRegistered<GetVoucherPackagesUseCase>()) {
      final pkgUseCase = Get.find<GetVoucherPackagesUseCase>();
      _packages = await pkgUseCase(
        networkId: netId,
        status: true,
      );
    }

    // جلب نقاط البيع المرتبطة بالشبكة إذا لم تكن محددة مسبقاً
    if (_selectedPosId == null &&
        Get.isRegistered<GetNetworkPosListUseCase>()) {
      final posUseCase = Get.find<GetNetworkPosListUseCase>();
      _linkedPosList = await posUseCase(
        networkId: netId,
        status: true,
      );
      if (_linkedPosList.isNotEmpty) {
        _selectedPosId = _linkedPosList.first.posId;
        _selectedPosName = _linkedPosList.first.posName;
      }
    } else if (Get.isRegistered<GetNetworkPosListUseCase>()) {
      final posUseCase = Get.find<GetNetworkPosListUseCase>();
      _linkedPosList = await posUseCase(
        networkId: netId,
        status: true,
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNetworkChanged(int? newNetId) {
    if (newNetId == null || newNetId == _selectedNetworkId) return;
    setState(() {
      _selectedNetworkId = newNetId;
      _networkIdNotifier.value = newNetId;
      _packageQuantities.clear();
      _packages.clear();
      _linkedPosList.clear();
      if (widget.preselectedPosId == null) {
        _selectedPosId = null;
        _selectedPosName = null;
      }
      _isLoading = true;
    });
    _loadDataForNetwork(newNetId);
  }

  void _incrementQuantity(int packageId) {
    setState(() {
      _packageQuantities[packageId] = (_packageQuantities[packageId] ?? 0) + 1;
      _syncPaidAmount();
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
      _syncPaidAmount();
    });
  }

  void _syncPaidAmount() {
    if (_saleType == 'CASH') {
      _paidAmountController.text = AmountFormatter.formatValue(_totalNetAmount);
    }
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

  double get _paidAmount {
    if (_saleType == 'CASH') return _totalNetAmount;
    final cleaned = AmountFormatter.clean(_paidAmountController.text);
    final parsed = double.tryParse(cleaned);
    return parsed ?? 0.0;
  }

  double get _remainingDebtAmount =>
      (_totalNetAmount - _paidAmount).clamp(0.0, double.infinity);

  Future<void> _submitInvoice() async {
    if (_selectedNetworkId == null) {
      CustomSnackbar.show(
        title: 'تنبيه النطاق',
        message: 'يرجى اختيار الشبكة الموردة للكروت أولاً',
        type: SnackType.warning,
      );
      return;
    }

    if (_selectedPosId == null) {
      CustomSnackbar.show(
        title: 'تنبيه',
        message: 'يرجى اختيار نقطة البيع المراد إصدار الفاتورة لها',
        type: SnackType.warning,
      );
      return;
    }

    if (_totalVoucherCount <= 0) {
      CustomSnackbar.show(
        title: 'تنبيه الفوترة',
        message: 'يرجى تحديد كمية باقة واحدة على الأقل لإصدار الفاتورة',
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
          'voucher_price': pkg.packageVoucherPrice,
          'voucher_count': qty,
          'item_discount': percent,
        });
      }
    }

    final operationsController = Get.find<OperationsController>();
    final result = await operationsController.createSaleInvoice(
      networkId: _selectedNetworkId!,
      posId: _selectedPosId!,
      saleType: _saleType,
      items: items,
      paidAmount: _paidAmount,
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
        // 0. اختيار الشبكة (في حال تعدد شبكات المزود وعدم التحديد المسبق)
        if (widget.networkId == null && _networks.length > 1) ...[
          CustomDropdown<int>(
            label: 'الشبكة الموردة للكروت *',
            hint: 'اختر الشبكة',
            prefixIcon: Icons.cell_tower_rounded,
            valueListenable: _networkIdNotifier,
            items: _networks
                .map(
                  (net) => DropdownItem<int>(
                    value: net.networkId,
                    child: Text(net.networkName),
                  ),
                )
                .toList(),
            itemSearchText: (id) =>
                _networks
                    .firstWhereOrNull((n) => n.networkId == id)
                    ?.networkName ??
                '',
            onChanged: _onNetworkChanged,
          ),
          AppSpacing.vMd,
        ],

        // 1. اختيار أو عرض نقطة البيع
        _PosAgentTargetCard(
          selectedPosId: _selectedPosId,
          selectedPosName: _selectedPosName,
          linkedPosList: _linkedPosList,
          isPreselected: widget.preselectedPosId != null,
          onPosSelected: (pos) {
            setState(() {
              _selectedPosId = pos.posId;
              _selectedPosName = pos.posName;
            });
          },
        ),
        AppSpacing.vMd,

        // 2. مفتاح نمط البيع (كاش أو آجل)
        _SaleTypeSegmentedBar(
          selectedSaleType: _saleType,
          onChanged: (newType) {
            setState(() {
              _saleType = newType;
              if (newType == 'CASH') {
                _paidAmountController.text = AmountFormatter.formatValue(_totalNetAmount);
              } else {
                _paidAmountController.clear();
              }
            });
          },
        ),
        AppSpacing.vMd,

        // 3. باقات الكروت المتاحة
        if (_isLoading) ...[
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
                'لا توجد باقات كروت نشطة مسجلة لهذه الشبكة',
                style: AppTypography.bodyMedium.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ),
        ] else ...[
          Text(
            'باقات الكروت المراد إصدارها',
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

              return _InvoicePackageItemCard(
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

        // 4. حقل المبلغ المدفوع نقداً في حالة البيع الآجل
        if (_saleType == 'CREDIT' && _totalNetAmount > 0) ...[
          CustomTextField(
            label: 'المبلغ المسدد نقداً الآن (إن وجد)',
            hint: '0.00',
            controller: _paidAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [AmountTextInputFormatter()],
            prefixIcon: Icon(Icons.paid_outlined, color: colors.primary, size: 20.r),
            onChanged: (_) => setState(() {}),
          ),
          AppSpacing.vMd,
        ],

        // 5. السند المالي الرقمي اللحظي
        if (_totalVoucherCount > 0) ...[
          _DirectInvoiceSummaryBond(
            voucherCount: _totalVoucherCount,
            grossAmount: _totalGrossAmount,
            discountAmount: _totalDiscountAmount,
            netAmount: _totalNetAmount,
            paidAmount: _paidAmount,
            remainingDebt: _remainingDebtAmount,
            saleType: _saleType,
          ),
          AppSpacing.vLg,
        ],

        // 6. أزرار الإجراء
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomButton.primary(
                text: 'إصدار الفاتورة والتسوية',
                icon: Icons.check_circle_rounded,
                onPressed: _totalVoucherCount > 0 && _selectedPosId != null
                    ? _submitInvoice
                    : null,
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

/// بطاقة تحديد أو استعراض نقطة البيع
class _PosAgentTargetCard extends StatelessWidget {
  final int? selectedPosId;
  final String? selectedPosName;
  final List<NetworkPosEntity> linkedPosList;
  final bool isPreselected;
  final ValueChanged<NetworkPosEntity> onPosSelected;

  const _PosAgentTargetCard({
    required this.selectedPosId,
    required this.selectedPosName,
    required this.linkedPosList,
    required this.isPreselected,
    required this.onPosSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isPreselected || linkedPosList.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: colors.primary,
                size: 18.r,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الوكيل / نقطة البيع',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    selectedPosName ?? 'نقطة بيع محددة',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر نقطة البيع المستلمة للكروت:',
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.vXs,
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: selectedPosId,
              icon: Icon(Icons.arrow_drop_down_rounded, color: colors.primary),
              items: linkedPosList.map((link) {
                return DropdownMenuItem<int>(
                  value: link.posId,
                  child: Text(
                    link.posName ?? 'نقطة بيع #${link.posId}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newId) {
                if (newId != null) {
                  final found = linkedPosList.firstWhere((l) => l.posId == newId);
                  onPosSelected(found);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط التبديل بين كاش وآجل
class _SaleTypeSegmentedBar extends StatelessWidget {
  final String selectedSaleType;
  final ValueChanged<String> onChanged;

  const _SaleTypeSegmentedBar({
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
            child: CustomInteractiveBounce(
              onTap: () => onChanged('CASH'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: selectedSaleType == 'CASH'
                      ? colors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.payments_rounded,
                      size: 16.r,
                      color: selectedSaleType == 'CASH'
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                    ),
                    AppSpacing.hXs,
                    Text(
                      'بيع نقدي (CASH)',
                      style: AppTypography.buttonMedium.copyWith(
                        color: selectedSaleType == 'CASH'
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                        fontWeight: selectedSaleType == 'CASH'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppSpacing.hXs,
          Expanded(
            child: CustomInteractiveBounce(
              onTap: () => onChanged('CREDIT'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: selectedSaleType == 'CREDIT'
                      ? colors.error
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_score_rounded,
                      size: 16.r,
                      color: selectedSaleType == 'CREDIT'
                          ? colors.onError
                          : colors.onSurfaceVariant,
                    ),
                    AppSpacing.hXs,
                    Text(
                      'بيع آجل (CREDIT)',
                      style: AppTypography.buttonMedium.copyWith(
                        color: selectedSaleType == 'CREDIT'
                            ? colors.onError
                            : colors.onSurfaceVariant,
                        fontWeight: selectedSaleType == 'CREDIT'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة الباقة مع العداد
class _InvoicePackageItemCard extends StatelessWidget {
  final VoucherPackageEntity package;
  final int quantity;
  final double discountPercent;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _InvoicePackageItemCard({
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
    final unitNet = unitPrice - (unitPrice * (discountPercent / 100));

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
                      Text(
                        '(${AmountFormatter.formatValue(unitNet)} بعد الخصم)',
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

/// بطاقة السند المالي الرقمي اللحظي
class _DirectInvoiceSummaryBond extends StatelessWidget {
  final int voucherCount;
  final double grossAmount;
  final double discountAmount;
  final double netAmount;
  final double paidAmount;
  final double remainingDebt;
  final String saleType;

  const _DirectInvoiceSummaryBond({
    required this.voucherCount,
    required this.grossAmount,
    required this.discountAmount,
    required this.netAmount,
    required this.paidAmount,
    required this.remainingDebt,
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
                'التسوية المالية للفاتورة',
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
                  color: remainingDebt <= 0.001
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  remainingDebt <= 0.001 ? 'مسددة بالكامل' : 'تسوية ذمة آجلة',
                  style: AppTypography.labelSmall.copyWith(
                    color: remainingDebt <= 0.001 ? colors.primary : colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Divider(color: colors.outlineVariant.withValues(alpha: 0.4)),
          AppSpacing.vXs,
          _InvoiceSummaryLine(
            label: 'إجمالي عدد الكروت:',
            value: '$voucherCount كرت',
          ),
          AppSpacing.vXxs,
          _InvoiceSummaryLine(
            label: 'المبلغ الإجمالي:',
            value: '${AmountFormatter.formatValue(grossAmount)} ر.ي',
          ),
          if (discountAmount > 0) ...[
            AppSpacing.vXxs,
            _InvoiceSummaryLine(
              label: 'الخصم المطبق:',
              value: '- ${AmountFormatter.formatValue(discountAmount)} ر.ي',
              isHighlight: true,
            ),
          ],
          AppSpacing.vXxs,
          _InvoiceSummaryLine(
            label: 'الصافي المطلوب:',
            value: '${AmountFormatter.formatValue(netAmount)} ر.ي',
          ),
          AppSpacing.vXxs,
          _InvoiceSummaryLine(
            label: 'المسدد نقداً:',
            value: '${AmountFormatter.formatValue(paidAmount)} ر.ي',
          ),
          if (remainingDebt > 0.001) ...[
            AppSpacing.vXxs,
            _InvoiceSummaryLine(
              label: 'متبقي دين آجل على المحفظة:',
              value: '${AmountFormatter.formatValue(remainingDebt)} ر.ي',
              isDebt: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _InvoiceSummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final bool isDebt;

  const _InvoiceSummaryLine({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.isDebt = false,
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
            color: isDebt ? colors.error : colors.onSurfaceVariant,
            fontWeight: isDebt ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: isDebt
                ? colors.error
                : (isHighlight ? colors.tertiary : colors.onSurface),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
