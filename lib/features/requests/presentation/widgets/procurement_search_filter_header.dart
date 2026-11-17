import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// Compact search and server-side status filtering for procurement orders.
class ProcurementSearchFilterHeader extends StatelessWidget {
  const ProcurementSearchFilterHeader({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearSearch,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearSearch;

  static const _filters = <_RequestFilter>[
    _RequestFilter(label: 'كل الطلبات', value: null, icon: Icons.all_inbox_rounded),
    _RequestFilter(label: 'قيد المراجعة', value: 'PENDING', icon: Icons.schedule_rounded),
    _RequestFilter(label: 'معتمدة', value: 'APPROVED', icon: Icons.check_circle_outline_rounded),
    _RequestFilter(label: 'مرفوضة', value: 'REJECTED', icon: Icons.cancel_outlined),
    _RequestFilter(label: 'ملغاة', value: 'CANCELLED', icon: Icons.delete_outline_rounded),
  ];

  Future<void> _openFilters() async {
    await CustomBottomSheet.showActions<void>(
      title: 'تصفية الطلبات',
      subtitle: 'اختر حالة الطلب التي تريد عرضها',
      leadingIcon: Icons.filter_list_rounded,
      items: _filters.map((filter) {
        final selected = selectedStatus == filter.value;
        return CustomBottomSheetActionItem(
          title: filter.label,
          icon: filter.icon,
          trailing: selected ? Icon(Icons.check_circle_rounded, size: 20.r) : null,
          onTap: () => onStatusChanged(filter.value),
        );
      }).toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedLabel = _filters.firstWhere(
      (filter) => filter.value == selectedStatus,
      orElse: () => _filters.first,
    ).label;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        AppSpacing.md,
        AppSpacing.cardPadding,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: searchController,
              label: 'البحث في الطلبات',
              hint: 'رقم الطلب أو اسم الشبكة أو نقطة البيع',
              prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
              suffixIcon: searchQuery.isNotEmpty
                  ? CustomButton.icon(
                      icon: Icons.close_rounded,
                      tooltip: 'مسح البحث',
                      dimension: 34.r,
                      backgroundColor: Colors.transparent,
                      foregroundColor: colors.onSurfaceVariant,
                      onPressed: onClearSearch,
                    )
                  : null,
              isRequired: false,
              isDense: true,
            ),
          ),
          AppSpacing.hSm,
          CustomButton.icon(
            icon: Icons.filter_list_rounded,
            tooltip: 'تصفية الطلبات: $selectedLabel',
            dimension: 52.r,
            backgroundColor: selectedStatus == null
                ? colors.surfaceContainerHighest
                : colors.primary.withValues(alpha: 0.12),
            foregroundColor: selectedStatus == null
                ? colors.onSurfaceVariant
                : colors.primary,
            borderColor: selectedStatus == null ? colors.outlineVariant : colors.primary,
            onPressed: _openFilters,
          ),
        ],
      ),
    );
  }
}

class _RequestFilter {
  const _RequestFilter({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String? value;
  final IconData icon;
}
