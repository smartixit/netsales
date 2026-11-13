import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/widgets/lists/custom_collection_filter_state.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// Shared server-side search/status controls for cursor-backed collections.
class CustomCollectionFilterBar extends StatelessWidget {
  const CustomCollectionFilterBar({
    required this.state,
    required this.searchLabel,
    required this.searchHint,
    required this.onSearchChanged,
    this.statusLabel = 'الحالة',
    this.statusHint = 'كل الحالات',
    this.statusOptions = const [],
    this.onStatusChanged,
    super.key,
  });

  final BillingCollectionFilterState state;
  final String searchLabel;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final String statusLabel;
  final String statusHint;
  final List<DropdownItem<String>> statusOptions;
  final ValueChanged<String?>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final search = CustomTextField(
            controller: state.searchController,
            label: searchLabel,
            hint: searchHint,
            isRequired: false,
            prefixIcon: const Icon(Icons.search_rounded),
            textInputAction: TextInputAction.search,
            onChanged: onSearchChanged,
          );
          if (statusOptions.isEmpty || onStatusChanged == null) {
            return search;
          }

          final status = Obx(
            () => CustomDropdown<String>(
              items: statusOptions,
              rxValue: state.selectedStatus,
              onChanged: onStatusChanged,
              label: statusLabel,
              hint: statusHint,
            ),
          );

          if (constraints.maxWidth < 640) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [search, const SizedBox(height: 8), status],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: search),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: status),
            ],
          );
        },
      ),
    );
  }
}
