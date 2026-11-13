import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/widgets/badges/custom_filter_chip.dart';

class OperationalReportTypeSelector extends StatelessWidget {
  const OperationalReportTypeSelector({
    required this.controller,
    required this.types,
    super.key,
  });

  final OperationalReportsController controller;
  final List<OperationalReportType> types;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: types.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final type = types[index];
            final selected = controller.selectedType.value == type;

            return CustomFilterChip(
              label: controller.reportLabel(type),
              isSelected: selected,
              onSelected: () => controller.selectType(type),
              isCompact: false,
            );
          },
        ),
      ),
    );
  }
}
