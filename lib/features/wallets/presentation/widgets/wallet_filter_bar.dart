import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// شريط البحث والفلترة لدفتر أستاذ المحفظة (WalletFilterBar)
/// ============================================================================
class WalletFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String selectedOperation;
  final ValueChanged<String> onSelectOperation;
  final List<Map<String, String>> operationOptions;

  const WalletFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.selectedOperation,
    required this.onSelectOperation,
    required this.operationOptions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. حقل البحث
        CustomTextField(
          controller: searchController,
          label: 'البحث',
          hint: 'البحث في القيود والحركات والبيان...',
          isRequired: false,
          prefixIcon: Icon(Icons.search_rounded, size: 20.r, color: colors.onSurfaceVariant),
          onChanged: onSearchChanged,
          suffixIcon: searchController.text.isNotEmpty
              ? CustomInteractiveBounce(
                  onTap: onClearSearch,
                  child: Icon(Icons.clear_rounded, size: 18.r, color: colors.onSurfaceVariant),
                )
              : null,
        ),

        AppSpacing.vSm,

        // 2. شرائح التصفية بحسب نوع العملية
        SizedBox(
          height: 36.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: operationOptions.length,
            separatorBuilder: (context, index) => AppSpacing.hXs,
            itemBuilder: (context, index) {
              final option = operationOptions[index];
              final isSelected = selectedOperation == option['key'];

              return CustomInteractiveBounce(
                onTap: () => onSelectOperation(option['key']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.outlineVariant.withValues(alpha: 0.3),
                      width: 0.8.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option['label']!,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? colors.onPrimary : colors.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
