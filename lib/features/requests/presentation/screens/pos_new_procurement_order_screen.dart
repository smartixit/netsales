import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_cart_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_checkout_bar.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_network_context_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_selection_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_pos_context_section.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

/// مساحة اكتشاف وتكوين طلب واحدة؛ السعر والكمية والإجمالي تتحدث محلياً وفورياً.
class PosNewProcurementOrderScreen extends GetView<PosProcurementController> {
  const PosNewProcurementOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomAppScaffold(
      appBarTitle: controller.isEditing.value ? 'تعديل طلب التوريد' : 'اكتشاف باقات التوريد',
      appBarSubtitle: 'قارن التعرفة واضبط الكمية وشاهد إجمالي الطلب مباشرة',
      showBackButton: true,
      bottomNavigationBar: const ProcurementCheckoutBar(),
      maxWidth: AppBreakpoints.desktopMax,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 960;
          final side = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IntroPanel(),
              AppSpacing.vMd,
              _ContextPanel(),
              AppSpacing.vMd,
              _SaleTypePanel(),
              AppSpacing.vLg,
              const ProcurementPackageSelectionSection(),
              AppSpacing.vLg,
              CustomTextField(
                controller: controller.notesController,
                label: 'ملاحظة للشبكة (اختياري)',
                hint: 'أضف توضيحاً مختصراً حول طلب التوريد',
                maxLines: 2,
                isRequired: false,
              ),
            ],
          );
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.all(constraints.maxWidth < 360 ? AppSpacing.sm : AppSpacing.md),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: side),
                      AppSpacing.hLg,
                      SizedBox(
                        width: 350,
                        child: Column(
                          children: [
                            const _LiveCartPanel(),
                            AppSpacing.vMd,
                            const _PolicyPanel(),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      side,
                      AppSpacing.vLg,
                      const _LiveCartPanel(),
                      AppSpacing.vMd,
                      const _PolicyPanel(),
                    ],
                  ),
          );
        },
      ),
    ));
  }
}

class _IntroPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [colors.primary.withValues(alpha: .14), colors.surfaceContainerLow],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withValues(alpha: .18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome_rounded, color: colors.primary, size: 18),
            AppSpacing.hXs,
            Text('PROCUREMENT WORKSPACE', style: AppTypography.labelSmall.copyWith(
              color: colors.primary, fontWeight: FontWeight.w800, letterSpacing: 1.1,
            )),
          ]),
          AppSpacing.vSm,
          Text('كوّن طلب التوريد الخاص بك', style: AppTypography.headlineSmall.copyWith(
            color: colors.onSurface, fontWeight: FontWeight.w900,
          )),
          AppSpacing.vXs,
          Text('كل تفاصيل الباقة وتعرفة نقطة البيع والكمية والسلة في مساحة واحدة، دون انتقال بين خطوات منفصلة.',
            style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant, height: 1.5)),
        ],
      ),
    );
  }
}

class _ContextPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('سياق التوريد', style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface, fontWeight: FontWeight.w800,
          )),
          AppSpacing.vSm,
          const ProcurementPosContextSection(),
          AppSpacing.vSm,
          const ProcurementNetworkContextSection(),
        ],
      ),
    );
  }
}

class _SaleTypePanel extends GetView<PosProcurementController> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('طريقة البيع والتعرفة', style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface, fontWeight: FontWeight.w800,
          )),
          AppSpacing.vXxs,
          Text('تتغير أسعار الباقات وإجمالي السلة فور اختيار النوع.', style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
          )),
          AppSpacing.vSm,
          Obx(() => CustomSegmentedBar(
            selectedIndex: controller.selectedSaleType.value == SaleType.cash ? 0 : 1,
            onSegmentChanged: (index) {
              controller.selectedSaleType.value = index == 0 ? SaleType.cash : SaleType.credit;
            },
            items: const [
              CustomSegmentItem(label: 'نقدي', icon: Icons.payments_outlined),
              CustomSegmentItem(label: 'آجل', icon: Icons.credit_card_outlined),
            ],
          )),
        ],
      ),
    );
  }
}

class _LiveCartPanel extends GetView<PosProcurementController> {
  const _LiveCartPanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: .22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.shopping_bag_outlined, color: colors.primary),
            AppSpacing.hXs,
            Expanded(child: Text('سلة الطلب', style: AppTypography.titleSmall.copyWith(
              color: colors.onSurface, fontWeight: FontWeight.w800,
            ))),
            Obx(() => Text('${controller.procurementCart.length} باقة',
              style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant))),
          ]),
          AppSpacing.vSm,
          const ProcurementCartSection(),
          AppSpacing.vSm,
          Divider(color: colors.outlineVariant.withValues(alpha: .5)),
          AppSpacing.vSm,
          Row(children: [
            Expanded(child: Text('الإجمالي الحالي', style: AppTypography.labelMedium.copyWith(
              color: colors.onSurfaceVariant, fontWeight: FontWeight.w700,
            ))),
            Obx(() => Text(
              '${AmountFormatter.formatValue(controller.liveOrderTotalMinor / 100)} ر.ي',
              style: AppTypography.titleLarge.copyWith(color: colors.primary, fontWeight: FontWeight.w900),
            )),
          ]),
          AppSpacing.vXs,
          Obx(() => Text(
            'إجمالي الخصم: ${AmountFormatter.formatValue(controller.liveOrderDiscountMinor / 100)} ر.ي',
            style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant),
          )),
        ],
      ),
    );
  }
}

class _PolicyPanel extends StatelessWidget {
  const _PolicyPanel();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.primary, size: 18),
          AppSpacing.hSm,
          Expanded(child: Text(
            'يُرسل الطلب إلى الشبكة للمراجعة. لا تُنشأ فاتورة أو تسوية مالية إلا بعد اعتماد الطلب.',
            style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant, height: 1.45),
          )),
        ],
      ),
    );
  }
}
