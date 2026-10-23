import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// ============================================================================
/// شريط البحث والتصفية الموحد للعمليات (OperationsSearchAndFilterBar)
/// ============================================================================
/// يوفر حقل بحث سريع مع أزرار تصفية متكيفة تلقائياً حسب القطاع النشط.
class OperationsSearchAndFilterBar extends StatelessWidget {
  final OperationsController controller;

  const OperationsSearchAndFilterBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. حقل البحث النصي الموحد
        CustomTextField(
          controller: controller.searchController,
          label: 'البحث في العمليات',
          hint: 'ابحث برقم المرجع أو اسم نقطة البيع أو الشبكة...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.onSurfaceVariant,
            size: 20.r,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchController,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 18.r,
                  color: colors.onSurfaceVariant,
                ),
                onPressed: controller.clearSearch,
              );
            },
          ),
          textInputAction: TextInputAction.search,
          onFieldSubmitted: controller.onSearchSubmitted,
        ),

        AppSpacing.vSm,

        // 2. أزرار التصفية المتكيفة حسب القطاع النشط
        Obx(() {
          final isInvoiceTab = controller.activeSegmentIndex.value == 0;

          if (isInvoiceTab) {
            final activeFilter = controller.selectedInvoiceFilter.value;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'الكل',
                    isSelected: activeFilter == 'ALL',
                    onTap: () => controller.filterInvoices('ALL'),
                  ),
                  AppSpacing.hXs,
                  _FilterChip(
                    label: 'مبيعات نقدية',
                    isSelected: activeFilter == 'CASH',
                    onTap: () => controller.filterInvoices('CASH'),
                  ),
                  AppSpacing.hXs,
                  _FilterChip(
                    label: 'مبيعات آجلة',
                    isSelected: activeFilter == 'CREDIT',
                    onTap: () => controller.filterInvoices('CREDIT'),
                  ),
                  AppSpacing.hXs,
                  _FilterChip(
                    label: 'غير مسددة (مديونية)',
                    isSelected: activeFilter == 'UNPAID',
                    onTap: () => controller.filterInvoices('UNPAID'),
                  ),
                ],
              ),
            );
          } else {
            final activeFilter = controller.selectedRequestFilter.value;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'كافة الطلبات',
                    isSelected: activeFilter == 'ALL',
                    onTap: () => controller.filterRequests('ALL'),
                  ),
                  AppSpacing.hXs,
                  _FilterChip(
                    label: 'بانتظار الاعتماد',
                    isSelected: activeFilter == 'PENDING',
                    onTap: () => controller.filterRequests('PENDING'),
                  ),
                  AppSpacing.hXs,
                  _FilterChip(
                    label: 'طلبات معتمدة',
                    isSelected: activeFilter == 'APPROVED',
                    onTap: () => controller.filterRequests('APPROVED'),
                  ),
                  AppSpacing.hXs,
                  _FilterChip(
                    label: 'طلبات مرفوضة',
                    isSelected: activeFilter == 'REJECTED',
                    onTap: () => controller.filterRequests('REJECTED'),
                  ),
                ],
              ),
            );
          }
        }),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: AppRadius.fullRadius,
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 1.2.w : 1.w,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? colors.primary : colors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
