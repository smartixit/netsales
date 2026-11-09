import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// شريط البحث والفلترة القطاعية لطلبات التوريد
class ProcurementSearchFilterHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearSearch;

  const ProcurementSearchFilterHeader({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    int selectedIndex = 0;
    if (selectedStatus == 'PENDING') {
      selectedIndex = 1;
    } else if (selectedStatus == 'APPROVED') {
      selectedIndex = 2;
    } else if (selectedStatus == 'REJECTED') {
      selectedIndex = 3;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: searchController,
            label: 'البحث في طلبات التوريد',
            hint: 'ابحث برقم الطلب أو اسم الجهة...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchQuery.isNotEmpty
                ? CustomButton.icon(
                    icon: Icons.clear_rounded,
                    tooltip: 'مسح البحث',
                    dimension: 36.r,
                    iconSize: 18.r,
                    backgroundColor: Colors.transparent,
                    onPressed: onClearSearch,
                  )
                : null,
            isRequired: false,
          ),
          AppSpacing.vSm,
          CustomSegmentedBar(
            selectedIndex: selectedIndex,
            onSegmentChanged: (idx) {
              if (idx == 0) {
                onStatusChanged(null);
              } else if (idx == 1) {
                onStatusChanged('PENDING');
              } else if (idx == 2) {
                onStatusChanged('APPROVED');
              } else if (idx == 3) {
                onStatusChanged('REJECTED');
              }
            },
            items: const [
              CustomSegmentItem(label: 'الكل', icon: Icons.list_alt_rounded),
              CustomSegmentItem(
                label: 'قيد الانتظار',
                icon: Icons.hourglass_top_rounded,
              ),
              CustomSegmentItem(
                label: 'معتمدة',
                icon: Icons.check_circle_outline_rounded,
              ),
              CustomSegmentItem(label: 'مرفوضة', icon: Icons.cancel_outlined),
            ],
          ),
        ],
      ),
    );
  }
}
