import 'package:flutter/material.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// ترويسة البحث والتصفية لأعضاء وفريق العمل المعتمدة على [CustomSearchFilterBar]
///
/// تستهلك خيارات التصفية مؤشرات الحالات مباشرة من محرك [EnumPresentationRegistry].
class MembersSearchFilterHeader extends StatelessWidget {
  const MembersSearchFilterHeader({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearSearch,
    this.searchHint = 'بحث بالاسم، رقم الهاتف، أو المسمى الوظيفي...',
  });

  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearSearch;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    final active = EnumPresentationRegistry.resolveMembershipStatus(
      MembershipStatus.active,
    );
    final suspended = EnumPresentationRegistry.resolveMembershipStatus(
      MembershipStatus.suspended,
    );
    final invited = EnumPresentationRegistry.resolveMembershipStatus(
      MembershipStatus.invited,
    );

    final statusOptions = <CustomSearchFilterOption<String?>>[
      const CustomSearchFilterOption<String?>(
        label: 'كافة الأعضاء',
        value: null,
        icon: Icons.all_inbox_rounded,
      ),
      CustomSearchFilterOption<String?>(
        label: active.label,
        value: MembershipStatus.active.wireValue,
        icon: active.icon,
      ),
      CustomSearchFilterOption<String?>(
        label: suspended.label,
        value: MembershipStatus.suspended.wireValue,
        icon: suspended.icon,
      ),
      CustomSearchFilterOption<String?>(
        label: invited.label,
        value: MembershipStatus.invited.wireValue,
        icon: invited.icon,
      ),
    ];

    return CustomSearchFilterBar<String?>(
      searchController: searchController,
      searchQuery: searchQuery,
      searchHint: searchHint,
      onClearSearch: onClearSearch,
      filterOptions: statusOptions,
      selectedFilter: selectedStatus,
      onFilterChanged: onStatusChanged,
      filterSheetTitle: 'تصفية أعضاء الفريق',
      filterSheetSubtitle: 'اختر حالة العضوية التي ترغب في استعراضها',
      filterButtonTooltip: 'تصفية حسب حالة العضوية',
    );
  }
}
