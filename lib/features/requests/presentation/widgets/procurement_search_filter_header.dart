import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// بحث وفلاتر حالات طلب التوريد، مع تمرير أفقي مناسب لمساحة الهاتف.
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
    _RequestFilter(label: 'الكل', value: null),
    _RequestFilter(label: 'بانتظار المراجعة', value: 'PENDING'),
    _RequestFilter(label: 'معتمدة', value: 'APPROVED'),
    _RequestFilter(label: 'مرفوضة', value: 'REJECTED'),
    _RequestFilter(label: 'ملغاة', value: 'CANCELLED'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        AppSpacing.sm,
        AppSpacing.cardPadding,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: searchController,
            label: 'البحث في الطلبات',
            hint: 'رقم الطلب أو اسم الشبكة أو نقطة البيع',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchQuery.isNotEmpty
                ? CustomButton.icon(
                    icon: Icons.close_rounded,
                    tooltip: 'مسح البحث',
                    dimension: 36.r,
                    backgroundColor: Colors.transparent,
                    onPressed: onClearSearch,
                  )
                : null,
            isRequired: false,
          ),
          AppSpacing.vSm,
          SizedBox(
            height: 42.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => AppSpacing.hXs,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = selectedStatus == filter.value;
                return CustomInteractiveBounce(
                  onTap: () => onStatusChanged(filter.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary.withValues(alpha: 0.12)
                          : colors.surfaceContainerHighest.withValues(
                              alpha: 0.45,
                            ),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: selected
                            ? colors.primary.withValues(alpha: 0.42)
                            : colors.outlineVariant.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        filter.label,
                        style: AppTypography.labelMedium.copyWith(
                          color: selected
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestFilter {
  const _RequestFilter({required this.label, required this.value});

  final String label;
  final String? value;
}
