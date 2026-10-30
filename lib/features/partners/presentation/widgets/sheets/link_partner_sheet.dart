import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// ورقة ربط وتوثيق عقد توزيع جديد (LinkPartnerSheet)
/// ============================================================================
/// تتيح ربط مزود شبكة بنقطة بيع معتمدة، وتنشئ الحساب المشترك تلقائياً عبر الباكيند.
class LinkPartnerSheet extends StatefulWidget {
  final PartnersController controller;
  final int? preselectedNetworkId;
  final String? preselectedPosUuid;

  const LinkPartnerSheet({
    super.key,
    required this.controller,
    this.preselectedNetworkId,
    this.preselectedPosUuid,
  });

  static Future<void> show(
    BuildContext context, {
    required PartnersController controller,
    int? preselectedNetworkId,
    String? preselectedPosUuid,
  }) {
    return CustomBottomSheet.show<void>(
      title: 'توثيق عقد توزيع وشراكة جديد',
      subtitle: 'ربط مزود شبكة إنترنت بوكيل نقطة بيع معتمد',
      leadingIcon: Icons.link_rounded,
      scrollable: true,
      child: LinkPartnerSheet(
        controller: controller,
        preselectedNetworkId: preselectedNetworkId,
        preselectedPosUuid: preselectedPosUuid,
      ),
    );
  }

  @override
  State<LinkPartnerSheet> createState() => _LinkPartnerSheetState();
}

class _LinkPartnerSheetState extends State<LinkPartnerSheet> {
  late final ValueNotifier<int?> _networkIdNotifier;
  late final ValueNotifier<String?> _posUuidNotifier;
  final ValueNotifier<bool> _statusNotifier = ValueNotifier<bool>(true);
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _networkIdNotifier = ValueNotifier<int?>(widget.preselectedNetworkId);
    _posUuidNotifier = ValueNotifier<String?>(widget.preselectedPosUuid);
  }

  @override
  void dispose() {
    _networkIdNotifier.dispose();
    _posUuidNotifier.dispose();
    _statusNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final networkId = _networkIdNotifier.value;
    final posUuid = _posUuidNotifier.value;

    if (networkId == null || networkId <= 0) {
      CustomSnackbar.show(
        title: 'حقل إلزامي',
        message: 'يُرجى اختيار مزود الشبكة المراد الربط به أولاً.',
        type: SnackType.warning,
      );
      return;
    }

    if (posUuid == null || posUuid.trim().isEmpty) {
      CustomSnackbar.show(
        title: 'حقل إلزامي',
        message: 'يُرجى اختيار نقطة البيع / الوكيل المعتمد.',
        type: SnackType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await widget.controller.createContract(
      networkId: networkId,
      posUuid: posUuid,
      status: _statusNotifier.value,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeNetworks =
        widget.controller.networks.where((n) => n.isActive).toList();
    final activePosList =
        widget.controller.posList.where((p) => p.isActive).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // 1. حاوية الشرح الإرشادي للتوزيع
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.2),
            borderRadius: AppRadius.mdRadius,
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.25),
              width: 0.8.w,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.hub_rounded,
                size: 20.r,
                color: colors.primary,
              ),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'عند توثيق العقد، يتم فتح محفظة ائتمانية وتوزيعية مشتركة تلقائياً للوكيل على شبكة المزود، مما يتيح إصدار الفواتير وشحن الأرصدة.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        AppSpacing.vMd,

        // 2. قائمة اختيار مزود الشبكة
        CustomDropdown<int>(
          label: 'مزود الشبكة',
          hint: 'اختر مزود الشبكة...',
          prefixIcon: Icons.wifi_tethering_rounded,
          valueListenable: _networkIdNotifier,
          items: activeNetworks.map((net) {
            return DropdownItem<int>(
              value: net.networkId,
              child: Text(
                '${net.networkName} (${net.governorateName ?? ''})',
              ),
            );
          }).toList(),
          onChanged: (id) => _networkIdNotifier.value = id,
        ),

        AppSpacing.vMd,

        // 3. قائمة اختيار نقطة البيع
        CustomDropdown<String>(
          label: 'نقطة البيع والوكيل',
          hint: 'اختر نقطة البيع...',
          prefixIcon: Icons.storefront_rounded,
          valueListenable: _posUuidNotifier,
          items: activePosList.map((pos) {
            return DropdownItem<String>(
              value: pos.posUuid,
              child: Text(
                '${pos.posName} • ${pos.agentName ?? ''} (${pos.governorateName ?? ''})',
              ),
            );
          }).toList(),
          onChanged: (uuid) => _posUuidNotifier.value = uuid,
        ),

        AppSpacing.vMd,

        // 4. خيار تفعيل العقد اللحظي
        ValueListenableBuilder<bool>(
          valueListenable: _statusNotifier,
          builder: (context, isActive, _) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: AppRadius.mdRadius,
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isActive
                        ? Icons.check_circle_rounded
                        : Icons.pause_circle_outline,
                    color: isActive ? colors.success : colors.onSurfaceVariant,
                    size: 20.r,
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفعيل العقد مباشرة',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          isActive
                              ? 'سيكون بإمكان نقطة البيع طلب الكروت فوراً'
                              : 'سيكون العقد مجمداً ومؤقتاً لحين التفعيل اليدوي',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: isActive,
                    activeTrackColor: colors.primary,
                    onChanged: (val) => _statusNotifier.value = val,
                  ),
                ],
              ),
            );
          },
        ),

        AppSpacing.vLg,

        // 5. زر توثيق العقد
        CustomButton.primary(
          text: 'توثيق العقد وبدء التوزيع',
          icon: Icons.link_rounded,
          loading: _isSubmitting,
          onPressed: _handleSubmit,
        ),

        AppSpacing.vMd,
      ],
    ),
  );
}
}
