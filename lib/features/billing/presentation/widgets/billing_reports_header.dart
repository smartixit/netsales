import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class BillingReportsHeader extends StatelessWidget {
  const BillingReportsHeader({
    required this.isExportingPdf,
    required this.isExportingCsv,
    required this.isLoading,
    required this.title,
    required this.subtitle,
    required this.onExportPdf,
    required this.onExportCsv,
    required this.onRefresh,
    super.key,
  });

  final bool isExportingPdf;
  final bool isExportingCsv;
  final bool isLoading;
  final String title;
  final String subtitle;
  final VoidCallback onExportPdf;
  final VoidCallback onExportCsv;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleLarge),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        CustomButton.outline(
          text: title == 'Subscription reports' ? 'Detailed PDF' : 'PDF تفصيلي',
          prefix: Icons.picture_as_pdf_outlined,
          loading: isExportingPdf,
          onPressed: isExportingPdf ? null : onExportPdf,
        ),
        CustomButton.outline(
          text: title == 'Subscription reports' ? 'Export CSV' : 'تصدير CSV',
          prefix: Icons.download_rounded,
          loading: isExportingCsv,
          onPressed: isLoading || isExportingCsv ? null : onExportCsv,
        ),
        CustomButton.outline(
          text: title == 'Subscription reports' ? 'Refresh' : 'تحديث',
          prefix: Icons.refresh_rounded,
          onPressed: isLoading ? null : onRefresh,
        ),
      ],
    );
  }
}
