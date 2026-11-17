import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_checkout_bar.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_network_context_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_selection_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_pos_context_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_sale_type_selector.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// مساحة إنشاء طلب التوريد الواحدة: السياق، الباقات، الكميات والإرسال دون شاشة مراجعة منفصلة.
class PosNewProcurementOrderScreen extends GetView<PosProcurementController> {
  const PosNewProcurementOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      final isEditMode = controller.isEditing.value;
      final title = isEditMode
          ? 'تعديل طلب التوريد #${controller.editingRequestId.value}'
          : 'طلب توريد جديد';
      return CustomAppScaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        bottomNavigationBar: const ProcurementCheckoutBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth < AppBreakpoints.mobileSmallMax
                ? AppSpacing.sm
                : AppSpacing.cardPadding;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.maxFormWidth,
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.md,
                    horizontalPadding,
                    AppSpacing.xl,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProcurementHeroCard(
                          isEditMode: isEditMode,
                          requestId: controller.editingRequestId.value,
                        ),
                        AppSpacing.vMd,
                        const ProcurementNetworkContextSection(),
                        AppSpacing.vSm,
                        const ProcurementPosContextSection(),
                        AppSpacing.vLg,
                        _SectionHeading(
                          title: 'طريقة التسعير',
                          subtitle:
                              'تتغير تعرفة العرض حسب طريقة الدفع المختارة.',
                        ),
                        AppSpacing.vSm,
                        const ProcurementSaleTypeSelector(),
                        AppSpacing.vLg,
                        const ProcurementPackageSelectionSection(),
                        AppSpacing.vLg,
                        CustomTextField(
                          controller: controller.notesController,
                          label: 'ملاحظات للشبكة (اختياري)',
                          hint: 'أضف توضيحاً يساعد الشبكة على معالجة الطلب',
                          maxLines: 3,
                          isRequired: false,
                        ),
                        AppSpacing.vSm,
                        Text(
                          'سيبقى الطلب قيد الانتظار حتى تراجعه الشبكة وتعتمده. لا تُنشأ فاتورة عند الإرسال.',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _ProcurementHeroCard extends StatelessWidget {
  const _ProcurementHeroCard({required this.isEditMode, this.requestId});
  final bool isEditMode;
  final int? requestId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF087F68), Color(0xFF075B55), Color(0xFF123F49)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: const Color(0xFFFFD98A).withValues(alpha: .32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF087F68).withValues(alpha: .23),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -18,
            top: -28,
            child: Container(
              width: 112.r,
              height: 112.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .055),
              ),
            ),
          ),
          PositionedDirectional(
            end: 40,
            bottom: -48,
            child: Container(
              width: 90.r,
              height: 90.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .08),
                  width: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(17.r),
                    border: Border.all(
                      color: const Color(0xFFFFE7B0).withValues(alpha: .38),
                    ),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: const Color(0xFFFFE7B0),
                    size: 27.r,
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditMode ? 'تحديث طلب التوريد' : 'مساحة طلب التوريد',
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      AppSpacing.vXs,
                      Text(
                        isEditMode
                            ? 'مراجعة تفاصيل الطلب #${requestId ?? ''} وتعديل الكميات قبل حفظ التغييرات.'
                            : 'اختر الشبكة ونقطة البيع، ثم كوّن طلبك مباشرة من الباقات والأسعار المتاحة.',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: .88),
                          height: 1.55,
                        ),
                      ),

                      // AppSpacing.vSm,
                      // Container(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: AppSpacing.sm,
                      //     vertical: AppSpacing.xs,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: const Color(0xFFFFE7B0).withValues(alpha: .13),
                      //     borderRadius: BorderRadius.circular(AppRadius.full),
                      //     border: Border.all(
                      //       color: const Color(0xFFFFE7B0)
                      //           .withValues(alpha: .24),
                      //     ),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(
                      //         Icons.bolt_rounded,
                      //         size: 14.r,
                      //         color: const Color(0xFFFFE7B0),
                      //       ),
                      //       AppSpacing.hXxs,
                      //       Text(
                      //         'اختيار مباشر • تحديث فوري للكمية',
                      //         style: AppTypography.labelSmall.copyWith(
                      //           color: const Color(0xFFFFE7B0),
                      //           fontWeight: FontWeight.w700,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        AppSpacing.vXxs,
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
