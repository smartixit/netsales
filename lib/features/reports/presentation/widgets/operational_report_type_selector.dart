import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

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

            if (selected) {
              final colors = Theme.of(context).colorScheme;
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  type.label,
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            return CustomButton.outline(
              text: type.label,
              onPressed: () => controller.selectType(type),
            );
          },
        ),
      ),
    );
  }
}
