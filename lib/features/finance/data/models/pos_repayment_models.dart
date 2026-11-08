import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';

class RepaymentAllocationModel extends RepaymentAllocationEntity {
  const RepaymentAllocationModel({
    required super.allocationId,
    required super.repaymentId,
    required super.invoiceId,
    required super.networkId,
    required super.posId,
    required super.allocatedAmount,
    super.status,
    super.allocatedAt,
    super.invoiceUuid,
  });

  factory RepaymentAllocationModel.fromJson(Map<String, dynamic> json) {
    String? invUuid;
    if (json['invoice'] is Map<String, dynamic>) {
      invUuid =
          (json['invoice'] as Map<String, dynamic>)['invoice_uuid'] as String?;
    }

    return RepaymentAllocationModel(
      allocationId: json['allocation_id'] as int? ?? 0,
      repaymentId: json['repayment_id'] as int? ?? 0,
      invoiceId: json['invoice_id'] as int? ?? 0,
      networkId: json['network_id'] as int? ?? 0,
      posId: json['pos_id'] as int? ?? 0,
      allocatedAmount: (json['allocated_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String?,
      allocatedAt: json['allocated_at'] as String?,
      invoiceUuid: invUuid,
    );
  }
}

class PosRepaymentModel extends PosRepaymentEntity {
  const PosRepaymentModel({
    required super.repaymentId,
    super.repaymentUuid,
    required super.networkId,
    required super.posId,
    required super.amount,
    super.paymentMethod,
    super.referenceNumber,
    super.notes,
    super.repaymentDate,
    super.status,
    super.createdBy,
    super.reversedAt,
    super.reversedBy,
    super.reversalReason,
    super.reversalRepaymentId,
    super.createdAt,
    super.networkName,
    super.posName,
    super.allocations = const [],
  });

  factory PosRepaymentModel.fromJson(Map<String, dynamic> json) {
    String? netName;
    if (json['network'] is Map<String, dynamic>) {
      netName =
          (json['network'] as Map<String, dynamic>)['network_name'] as String?;
    }

    String? pName;
    if (json['pos'] is Map<String, dynamic>) {
      pName = (json['pos'] as Map<String, dynamic>)['pos_name'] as String?;
    }

    final rawAllocations = json['allocations'];
    final parsedAllocations = <RepaymentAllocationModel>[];
    if (rawAllocations is List) {
      for (final a in rawAllocations) {
        if (a is Map<String, dynamic>) {
          parsedAllocations.add(RepaymentAllocationModel.fromJson(a));
        }
      }
    }

    return PosRepaymentModel(
      repaymentId: json['repayment_id'] as int? ?? 0,
      repaymentUuid: json['repayment_uuid'] as String?,
      networkId: json['network_id'] as int? ?? 0,
      posId: json['pos_id'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String?,
      referenceNumber: json['reference_number'] as String?,
      notes: json['notes'] as String?,
      repaymentDate: json['repayment_date'] as String?,
      status: json['status'] as String?,
      createdBy: json['created_by'] as int?,
      reversedAt: json['reversed_at'] as String?,
      reversedBy: json['reversed_by'] as int?,
      reversalReason: json['reversal_reason'] as String?,
      reversalRepaymentId: json['reversal_repayment_id'] as int?,
      createdAt: json['created_at'] as String?,
      networkName: netName,
      posName: pName,
      allocations: parsedAllocations,
    );
  }
}
