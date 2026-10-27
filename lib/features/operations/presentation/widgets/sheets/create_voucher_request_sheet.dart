import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/operations_sale_type_bar.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/package_selection_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/request_financial_summary_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/sheet_action_dock.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// نافذة إنشاء وإرسال طلب توريد كروت سياقية (CreateVoucherRequestSheet)
/// ============================================================================
/// نافذة منبثقة عصرية تتيح لنقاط البيع اختيار الباقات وتحديد الكميات
/// مع كبسولات كميات سريعة وحساب الأسعار والخصومات فورياً.
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
  late final ValueNotifier<int?> _networkIdNotifier;
  int? _selectedPosId;
  List<NetworkPosEntity> _linkedNetworks = [];

  String _saleType = 'CASH'; // CASH or CREDIT
  List<VoucherPackageEntity> _packages = [];
  bool _isLoadingPackages = true;
  String _loadError = '';

  @override
  void initState() {
    super.initState();
    _selectedNetworkId = widget.networkId;
    _networkIdNotifier = ValueNotifier<int?>(_selectedNetworkId);
    _selectedPosId = widget.posId;
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
        final result = await useCase(networkId: netId, status: true);
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

  void _addPresetQuantity(int packageId, int amount) {
    setState(() {
      _packageQuantities[packageId] =
          (_packageQuantities[packageId] ?? 0) + amount;
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
                    .cast<NetworkPosEntity?>()
                    .firstWhere((n) => n?.networkId == id, orElse: () => null)
                    ?.networkName ??
                '',
            onChanged: _onNetworkChanged,
          ),
          AppSpacing.vMd,
        ],

        // 1. مفتاح نوع الشراء (نقداً أو آجل)
        OperationsSaleTypeBar(
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
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.error,
                    ),
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
                'لا توجد باقات كروت مفعلة حالياً لهذه الشبكة',
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
                'باقات الكروت المتاحة',
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
          RequestFinancialSummaryCard(
            voucherCount: _totalVoucherCount,
            grossAmount: _totalGrossAmount,
            discountAmount: _totalDiscountAmount,
            netAmount: _totalNetAmount,
            saleType: _saleType,
          ),
          AppSpacing.vLg,
        ],

        // 5. رصيف الإجراء والاعتماد
        SheetActionDock(
          totalCount: _totalVoucherCount,
          netAmount: _totalNetAmount,
          actionLabel: 'إرسال طلب التوريد',
          actionIcon: Icons.send_rounded,
          onAction: _totalVoucherCount > 0 ? _submitRequest : null,
          onCancel: () => Get.back(),
        ),
      ],
    );
  }
}
