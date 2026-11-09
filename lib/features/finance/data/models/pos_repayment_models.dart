import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/entities/repayment_allocation_invoice_entity.dart';

class RepaymentAllocationInvoiceModel extends RepaymentAllocationInvoiceEntity {
  const RepaymentAllocationInvoiceModel({
    required super.invoiceUuid,
    required super.totalAmount,
    required super.paidAmount,
    required super.remainingAmount,
    required super.paymentStatus,
    required super.paymentStatusLabel,
    required super.invoiceDate,
    required super.saleType,
    required super.saleTypeLabel,
  });

  factory RepaymentAllocationInvoiceModel.fromJson(Map<String, dynamic> json) {
    return RepaymentAllocationInvoiceModel(
      invoiceUuid: json['invoice_uuid'] as String,
      totalAmount: (json['invoice_total_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      paymentStatus: json['payment_status'] as String,
      paymentStatusLabel: json['payment_status_label'] as String,
      invoiceDate: json['invoice_date'] as String,
      saleType: json['sale_type'] as String,
      saleTypeLabel: json['sale_type_label'] as String,
    );
  }
}

class RepaymentAllocationModel extends RepaymentAllocationEntity {
  const RepaymentAllocationModel({
    required super.allocationId,
    required super.repaymentId,
    required super.invoiceId,
    required super.networkId,
    required super.posId,
    required super.allocatedAmount,
    required super.invoice,
    super.status,
    super.allocatedAt,
  });

  factory RepaymentAllocationModel.fromJson(Map<String, dynamic> json) {
    final rawInvoice = json['invoice'];
    if (rawInvoice is! Map<String, dynamic>) {
      throw const FormatException(
        'Repayment allocation contract violation: nested invoice is required.',
      );
    }

    return RepaymentAllocationModel(
      allocationId: json['allocation_id'] as int,
      repaymentId: json['repayment_id'] as int,
      invoiceId: json['invoice_id'] as int,
      networkId: json['network_id'] as int,
      posId: json['pos_id'] as int,
      allocatedAmount: (json['allocated_amount'] as num).toDouble(),
      status: json['status'] as String,
      allocatedAt: json['allocated_at'] as String,
      invoice: RepaymentAllocationInvoiceModel.fromJson(rawInvoice),
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
      for (final allocation in rawAllocations) {
        if (allocation is Map<String, dynamic>) {
          parsedAllocations.add(RepaymentAllocationModel.fromJson(allocation));
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
