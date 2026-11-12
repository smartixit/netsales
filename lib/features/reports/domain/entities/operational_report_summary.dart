import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';

class OperationalReportMetric {
  const OperationalReportMetric({
    required this.label,
    required this.value,
    this.isCurrency = false,
  });

  final String label;
  final String value;
  final bool isCurrency;
}

class OperationalReportSummary {
  const OperationalReportSummary(this.values);

  final Map<String, dynamic> values;

  String _value(String key) => (values[key] ?? 0).toString();

  List<OperationalReportMetric> metricsFor(OperationalReportType type) {
    final count = OperationalReportMetric(
      label: 'عدد السجلات',
      value: _value('record_count'),
    );

    return switch (type) {
      OperationalReportType.sales => [
        count,
        OperationalReportMetric(
          label: 'إجمالي المبيعات',
          value: _value('total_amount'),
          isCurrency: true,
        ),
        OperationalReportMetric(
          label: 'المبالغ المحصلة',
          value: _value('paid_amount'),
          isCurrency: true,
        ),
        OperationalReportMetric(
          label: 'المبالغ المتبقية',
          value: _value('remaining_amount'),
          isCurrency: true,
        ),
      ],
      OperationalReportType.expenses => [
        count,
        OperationalReportMetric(
          label: 'إجمالي المصروفات',
          value: _value('total_amount'),
          isCurrency: true,
        ),
      ],
      OperationalReportType.networkWallet ||
      OperationalReportType.posWallet => [
        count,
        OperationalReportMetric(
          label: 'إجمالي الإيداعات',
          value: _value('deposits'),
          isCurrency: true,
        ),
        OperationalReportMetric(
          label: 'إجمالي السحوبات',
          value: _value('withdrawals'),
          isCurrency: true,
        ),
      ],
      OperationalReportType.repayments => [
        count,
        OperationalReportMetric(
          label: 'إجمالي السداد',
          value: _value('total_amount'),
          isCurrency: true,
        ),
        OperationalReportMetric(
          label: 'سندات مكتملة',
          value: _value('completed_count'),
        ),
        OperationalReportMetric(
          label: 'سندات معكوسة',
          value: _value('reversed_count'),
        ),
        OperationalReportMetric(
          label: 'قيمة السندات المعكوسة',
          value: _value('reversed_amount'),
          isCurrency: true,
        ),
      ],
      OperationalReportType.debtAging => [
        count,
        OperationalReportMetric(
          label: 'إجمالي الذمم القائمة',
          value: _value('total_outstanding'),
          isCurrency: true,
        ),
        OperationalReportMetric(
          label: 'من 0 إلى 30 يوماً',
          value: _value('bucket_0_30'),
          isCurrency: true,
        ),
        OperationalReportMetric(
          label: 'من 31 إلى 60 يوماً',
          value: _value('bucket_31_60'),
          isCurrency: true,
        ),
        OperationalReportMetric(
          label: 'من 61 إلى 90 يوماً',
          value: _value('bucket_61_90'),
          isCurrency: true,
        ),
        OperationalReportMetric(
          label: 'أكثر من 90 يوماً',
          value: _value('bucket_over_90'),
          isCurrency: true,
        ),
      ],
      OperationalReportType.requests => [
        count,
        OperationalReportMetric(
          label: 'إجمالي الطلبات',
          value: _value('total_amount'),
          isCurrency: true,
        ),
        OperationalReportMetric(
          label: 'طلبات معلقة',
          value: _value('pending_count'),
        ),
        OperationalReportMetric(
          label: 'طلبات معتمدة',
          value: _value('approved_count'),
        ),
        OperationalReportMetric(
          label: 'طلبات مرفوضة',
          value: _value('rejected_count'),
        ),
      ],
    };
  }
}
