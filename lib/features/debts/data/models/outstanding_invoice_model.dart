import 'package:netsales/features/debts/domain/entities/outstanding_invoice_entity.dart';

class PosOutstandingInvoiceModel extends PosOutstandingInvoiceEntity {
  const PosOutstandingInvoiceModel({
    required super.invoiceId,
    required super.invoiceUuid,
    required super.networkId,
    required super.posId,
    required super.invoiceTotalAmount,
    required super.paidAmount,
    required super.remainingAmount,
    required super.paymentStatus,
    required super.paymentStatusLabel,
    required super.invoiceDate,
    required super.daysOutstanding,
    required super.agingBucket,
  });

  factory PosOutstandingInvoiceModel.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '') ?? 0.0;
    }

    DateTime parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val != null) {
        try {
          return DateTime.parse(val.toString());
        } catch (_) {}
      }
      return DateTime.now();
    }

    return PosOutstandingInvoiceModel(
      invoiceId: (json['invoice_id'] as num?)?.toInt() ?? 0,
      invoiceUuid: json['invoice_uuid']?.toString() ?? '',
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      posId: (json['pos_id'] as num?)?.toInt() ?? 0,
      invoiceTotalAmount: parseAmount(json['invoice_total_amount']),
      paidAmount: parseAmount(json['paid_amount']),
      remainingAmount: parseAmount(json['remaining_amount']),
      paymentStatus: json['payment_status']?.toString() ?? 'UNPAID',
      paymentStatusLabel: json['payment_status_label']?.toString() ?? 'آجلة',
      invoiceDate: parseDate(json['invoice_date']),
      daysOutstanding: (json['days_outstanding'] as num?)?.toInt() ?? 0,
      agingBucket: json['aging_bucket']?.toString() ?? '0-30',
    );
  }
}

