import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ترويسة البحث والتصفية المتقدمة لطلبات التوريد (Search & Filter Header)
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
    _RequestFilter(
      label: 'كل الطلبات',
      value: null,
      icon: Icons.all_inbox_rounded,
    ),
    _RequestFilter(
      label: 'قيد المراجعة',
      value: 'PENDING',
      icon: Icons.hourglass_top_rounded,
    ),
    _RequestFilter(
      label: 'معتمدة',
      value: 'APPROVED',
      icon: Icons.check_circle_outline_rounded,
    ),
    _RequestFilter(
      label: 'مرفوضة',
      value: 'REJECTED',
      icon: Icons.cancel_outlined,
    ),
    _RequestFilter(
      label: 'ملغاة',
      value: 'CANCELLED',
      icon: Icons.block_rounded,
    ),
  ];

  Future<void> _openFilters(BuildContext context) async {
    await CustomBottomSheet.showActions<void>(
      title: 'تصفية طلبات التوريد',
      subtitle: 'اختر حالة الطلبات التي ترغب في استعراضها',
      leadingIcon: Icons.filter_list_rounded,
      items: _filters
          .map((filter) {
            final isSelected = selectedStatus == filter.value;
            return CustomBottomSheetActionItem(
              title: filter.label,
              icon: filter.icon,
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: context.colors.primary,
                      size: 20.r,
                    )
                  : null,
              onTap: () => onStatusChanged(filter.value),
            );
          })
          .toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeFilter = _filters.firstWhere(
      (filter) => filter.value == selectedStatus,
      orElse: () => _filters.first,
    );
    final hasActiveFilter = selectedStatus != null;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: searchController,
                  label: '',
                  hint: 'ابحث برقم الطلب أو اسم الشبكة...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.onSurfaceVariant,
                    size: 20.r,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? CustomButton.icon(
                          icon: Icons.close_rounded,
                          tooltip: 'مسح البحث',
                          dimension: 30.r,
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
              Container(
                decoration: BoxDecoration(
                  color: hasActiveFilter
                      ? colors.primary.withValues(alpha: .12)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: hasActiveFilter
                        ? colors.primary
                        : colors.outlineVariant.withValues(alpha: .6),
                    width: hasActiveFilter ? 1.5 : 1.0,
                  ),
                ),
                child: CustomButton.icon(
                  icon: Icons.tune_rounded,
                  tooltip: 'تصفية الحالات',
                  dimension: 48.r,
                  backgroundColor: Colors.transparent,
                  foregroundColor: hasActiveFilter
                      ? colors.primary
                      : colors.onSurfaceVariant,
                  onPressed: () => _openFilters(context),
                ),
              ),
            ],
          ),
          if (hasActiveFilter) ...[
            AppSpacing.vXs,
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.r,
                    vertical: 4.r,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: .25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        activeFilter.icon,
                        size: 13.r,
                        color: colors.primary,
                      ),
                      AppSpacing.hXxs,
                      Text(
                        activeFilter.label,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.hXxs,
                      GestureDetector(
                        onTap: () => onStatusChanged(null),
                        child: Icon(
                          Icons.cancel_rounded,
                          size: 14.r,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
