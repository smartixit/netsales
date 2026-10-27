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
import 'package:netsales/features/operations/presentation/widgets/sheets/components/invoice_financial_summary_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/operations_sale_type_bar.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/package_selection_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/pos_agent_selector_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/sheet_action_dock.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_networks_use_case.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
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
  late final ValueNotifier<int?> _networkIdNotifier;
  List<NetworkEntity> _networks = [];

  int? _selectedPosId;
  late final ValueNotifier<int?> _posIdNotifier;
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
    _posIdNotifier = ValueNotifier<int?>(_selectedPosId);
    _selectedPosName = widget.preselectedPosName;
    _loadInitialData();
  }

  @override
  void dispose() {
    _networkIdNotifier.dispose();
    _posIdNotifier.dispose();
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
        _posIdNotifier.value = _selectedPosId;
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
        _posIdNotifier.value = null;
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

  void _addPresetQuantity(int packageId, int amount) {
    setState(() {
      _packageQuantities[packageId] =
          (_packageQuantities[packageId] ?? 0) + amount;
      _syncPaidAmount();
    });
  }

  void _syncPaidAmount() {
    if (_saleType == 'CASH') {
      _paidAmountController.text =
          AmountFormatter.formatValue(_totalNetAmount);
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
                    .cast<NetworkEntity?>()
                    .firstWhere(
                      (n) => n?.networkId == id,
                      orElse: () => null,
                    )
                    ?.networkName ??
                '',
            onChanged: _onNetworkChanged,
          ),
          AppSpacing.vMd,
        ],

        // 1. اختيار أو عرض نقطة البيع
        PosAgentSelectorCard(
          posIdNotifier: _posIdNotifier,
          selectedPosName: _selectedPosName,
          linkedPosList: _linkedPosList,
          isPreselected: widget.preselectedPosId != null,
          onPosSelected: (pos) {
            setState(() {
              _selectedPosId = pos.posId;
              _posIdNotifier.value = pos.posId;
              _selectedPosName = pos.posName;
            });
          },
        ),
        AppSpacing.vMd,

        // 2. مفتاح نمط البيع (كاش أو آجل)
        OperationsSaleTypeBar(
          selectedSaleType: _saleType,
          onChanged: (newType) {
            setState(() {
              _saleType = newType;
              if (newType == 'CASH') {
                _paidAmountController.text =
                    AmountFormatter.formatValue(_totalNetAmount);
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
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.08),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colors.error,
                  size: 20.r,
                ),
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
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: AppRadius.mdRadius,
            ),
            child: Center(
              child: Text(
                'لا توجد باقات كروت نشطة مسجلة لهذه الشبكة',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'باقات الكروت المراد إصدارها',
                style: AppTypography.labelLarge.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (_totalVoucherCount > 0)
                Text(
                  '$_totalVoucherCount كرت محدد',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
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

              return PackageSelectionCard(
                package: pkg,
                quantity: qty,
                discountPercent: discountPercent,
                onIncrement: () => _incrementQuantity(pkg.packageId),
                onDecrement: () => _decrementQuantity(pkg.packageId),
                onAddPreset: (preset) =>
                    _addPresetQuantity(pkg.packageId, preset),
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
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [AmountTextInputFormatter()],
            prefixIcon:
                Icon(Icons.paid_outlined, color: colors.primary, size: 20.r),
            onChanged: (_) => setState(() {}),
          ),
          AppSpacing.vMd,
        ],

        // 5. السند المالي الرقمي اللحظي
        if (_totalVoucherCount > 0) ...[
          InvoiceFinancialSummaryCard(
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

        // 6. رصيف الإجراء والاعتماد
        SheetActionDock(
          totalCount: _totalVoucherCount,
          netAmount: _totalNetAmount,
          actionLabel: 'إصدار الفاتورة والتسوية',
          actionIcon: Icons.check_circle_rounded,
          onAction: _totalVoucherCount > 0 && _selectedPosId != null
              ? _submitInvoice
              : null,
          onCancel: () => Get.back(),
        ),
      ],
    );
  }
}
