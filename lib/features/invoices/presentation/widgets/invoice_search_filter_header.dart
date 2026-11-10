import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// رأس شاشة البحث والفلترة لفواتير المبيعات والمشتريات
class InvoiceSearchFilterHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedSaleType;
  final ValueChanged<String?> onSaleTypeChanged;
  final VoidCallback onClear;
  final String searchHint;

  const InvoiceSearchFilterHeader({
    super.key,
    required this.searchController,
    required this.selectedSaleType,
    required this.onSaleTypeChanged,
    required this.onClear,
    this.searchHint = 'بحث برقم الفاتورة، UUID، أو اسم الطرف التجاري...',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // شريط البحث بالنص
          CustomTextField(
            controller: searchController,
            label: 'بحث في الفواتير',
            hint: searchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      searchController.clear();
                      onClear();
                    },
                  )
                : null,
            isRequired: false,
          ),

          AppSpacing.vSm,

          // فلاتر نوع البيع (الكل، كاش، آجل)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _InvoiceFilterChip(
                  label: 'كافة المعاملات',
                  isSelected: selectedSaleType == null,
                  onSelected: () => onSaleTypeChanged(null),
                ),
                AppSpacing.hSm,
                _InvoiceFilterChip(
                  label: 'نقدية (كاش)',
                  isSelected: selectedSaleType == 'CASH',
                  onSelected: () => onSaleTypeChanged('CASH'),
                ),
                AppSpacing.hSm,
                _InvoiceFilterChip(
                  label: 'آجلة (ائتمان)',
                  isSelected: selectedSaleType == 'CREDIT',
                  onSelected: () => onSaleTypeChanged('CREDIT'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _InvoiceFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary
              : colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? colors.onPrimary : colors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
