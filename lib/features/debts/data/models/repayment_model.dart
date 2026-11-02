import 'package:netsales/features/debts/domain/entities/repayment_entity.dart';

class PosRepaymentAllocationModel extends PosRepaymentAllocationEntity {
  const PosRepaymentAllocationModel({
    required super.allocationId,
    required super.repaymentId,
    required super.invoiceId,
    super.invoiceUuid,
    required super.allocatedAmount,
    required super.status,
    required super.allocatedAt,
  });

  factory PosRepaymentAllocationModel.fromJson(Map<String, dynamic> json) {
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

    final invoiceMap = json['invoice'] is Map ? (json['invoice'] as Map) : null;

    return PosRepaymentAllocationModel(
      allocationId: (json['allocation_id'] as num?)?.toInt() ?? 0,
      repaymentId: (json['repayment_id'] as num?)?.toInt() ?? 0,
      invoiceId: (json['invoice_id'] as num?)?.toInt() ?? 0,
      invoiceUuid: invoiceMap?['invoice_uuid']?.toString() ?? json['invoice_uuid']?.toString(),
      allocatedAmount: parseAmount(json['allocated_amount']),
      status: json['status']?.toString() ?? 'ACTIVE',
      allocatedAt: parseDate(json['allocated_at']),
    );
  }
}

class PosRepaymentModel extends PosRepaymentEntity {
  const PosRepaymentModel({
    required super.repaymentId,
    required super.repaymentUuid,
    required super.networkId,
    required super.posId,
    super.posName,
    required super.amount,
    required super.paymentMethod,
    super.referenceNumber,
    super.notes,
    required super.repaymentDate,
    required super.status,
    required super.createdBy,
    super.reversedAt,
    super.reversedBy,
    super.reversalReason,
    required super.allocations,
    required super.createdAt,
  });

  factory PosRepaymentModel.fromJson(Map<String, dynamic> json) {
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

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    final posMap = json['pos'] is Map ? (json['pos'] as Map) : null;
    final allocationsList = json['allocations'] is List ? (json['allocations'] as List<dynamic>) : const <dynamic>[];

    return PosRepaymentModel(
      repaymentId: (json['repayment_id'] as num?)?.toInt() ?? 0,
      repaymentUuid: json['repayment_uuid']?.toString() ?? '',
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      posId: (json['pos_id'] as num?)?.toInt() ?? 0,
      posName: posMap?['pos_name']?.toString() ?? json['pos_name']?.toString(),
      amount: parseAmount(json['amount']),
      paymentMethod: json['payment_method']?.toString() ?? 'CASH',
      referenceNumber: json['reference_number']?.toString(),
      notes: json['notes']?.toString(),
      repaymentDate: parseDate(json['repayment_date']),
      status: json['status']?.toString() ?? 'ACTIVE',
      createdBy: (json['created_by'] as num?)?.toInt() ?? 0,
      reversedAt: parseNullableDate(json['reversed_at']),
      reversedBy: (json['reversed_by'] as num?)?.toInt(),
      reversalReason: json['reversal_reason']?.toString(),
      allocations: allocationsList
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => PosRepaymentAllocationModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      createdAt: parseDate(json['created_at']),
    );
  }
}
