/// Immutable customer-facing billing contracts. Monetary values remain strings
/// from the API and are always paired with their original currency.
class BillingCurrencyEntity {
  const BillingCurrencyEntity({
    required this.currencyId,
    required this.code,
    required this.name,
    this.nativeName,
    this.symbol,
    this.decimalPlaces = 2,
  });

  final int currencyId;
  final String code;
  final String name;
  final String? nativeName;
  final String? symbol;
  final int decimalPlaces;
}

class BillingAccountEntity {
  const BillingAccountEntity({
    required this.billingAccountId,
    required this.accountNumber,
    required this.networkId,
    required this.status,
    required this.legalName,
    this.billingEmail,
    this.taxNumber,
    this.billingAddress,
    this.currency,
  });

  final int billingAccountId;
  final String accountNumber;
  final int networkId;
  final String status;
  final String legalName;
  final String? billingEmail;
  final String? taxNumber;
  final String? billingAddress;
  final BillingCurrencyEntity? currency;
}

class BillingSubscriptionEntity {
  const BillingSubscriptionEntity({
    required this.subscriptionId,
    required this.status,
    required this.statusLabel,
    required this.planName,
    this.currency,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.trialStart,
    this.trialEnd,
    this.gracePeriodEndsAt,
    this.cancelAtPeriodEnd = false,
    this.termsSnapshot,
  });

  final int subscriptionId;
  final String status;
  final String statusLabel;
  final String planName;
  final BillingCurrencyEntity? currency;
  final String? currentPeriodStart;
  final String? currentPeriodEnd;
  final String? trialStart;
  final String? trialEnd;
  final String? gracePeriodEndsAt;
  final bool cancelAtPeriodEnd;
  final Map<String, dynamic>? termsSnapshot;
}

class BillingInvoiceLineEntity {
  const BillingInvoiceLineEntity({
    required this.description,
    required this.quantity,
    required this.unitAmountMinor,
    required this.subtotalMinor,
    required this.discountMinor,
    required this.taxMinor,
    required this.totalMinor,
    this.currency,
  });

  final String description;
  final String quantity;
  final int unitAmountMinor;
  final int subtotalMinor;
  final int discountMinor;
  final int taxMinor;
  final int totalMinor;
  final BillingCurrencyEntity? currency;
}

class BillingInvoiceEntity {
  const BillingInvoiceEntity({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.status,
    required this.statusLabel,
    required this.total,
    required this.paid,
    required this.remaining,
    required this.totalMinor,
    required this.paidMinor,
    required this.remainingMinor,
    this.currency,
    this.issuedOn,
    this.dueOn,
    this.periodStart,
    this.periodEnd,
    this.subtotal,
    this.discount,
    this.tax,
    this.memo,
    this.lines = const [],
  });

  final int invoiceId;
  final String invoiceNumber;
  final String status;
  final String statusLabel;
  final String total;
  final String paid;
  final String remaining;
  final int totalMinor;
  final int paidMinor;
  final int remainingMinor;
  final BillingCurrencyEntity? currency;
  final String? issuedOn;
  final String? dueOn;
  final String? periodStart;
  final String? periodEnd;
  final String? subtotal;
  final String? discount;
  final String? tax;
  final String? memo;
  final List<BillingInvoiceLineEntity> lines;
}

class BillingPaymentEntity {
  const BillingPaymentEntity({
    required this.paymentId,
    required this.reference,
    required this.amount,
    required this.amountMinor,
    required this.status,
    this.currency,
    this.methodName,
    this.externalReference,
    this.invoiceNumber,
    this.receivedAt,
    this.verifiedAt,
  });

  final int paymentId;
  final String reference;
  final String amount;
  final int amountMinor;
  final String status;
  final BillingCurrencyEntity? currency;
  final String? methodName;
  final String? externalReference;
  final String? invoiceNumber;
  final String? receivedAt;
  final String? verifiedAt;
}

class BillingCreditNoteEntity {
  const BillingCreditNoteEntity({
    required this.creditNoteId,
    required this.number,
    required this.status,
    required this.total,
    required this.totalMinor,
    required this.appliedToReceivableMinor,
    required this.refundableMinor,
    required this.refundedMinor,
    this.currency,
    this.invoiceNumber,
    this.reason,
    this.issuedAt,
  });

  final int creditNoteId;
  final String number;
  final String status;
  final String total;
  final int totalMinor;
  final int appliedToReceivableMinor;
  final int refundableMinor;
  final int refundedMinor;
  final BillingCurrencyEntity? currency;
  final String? invoiceNumber;
  final String? reason;
  final String? issuedAt;
}

class BillingRefundEntity {
  const BillingRefundEntity({
    required this.refundId,
    required this.reference,
    required this.amount,
    required this.amountMinor,
    required this.status,
    this.currency,
    this.paymentReference,
    this.invoiceNumber,
    this.reason,
    this.processedAt,
  });

  final int refundId;
  final String reference;
  final String amount;
  final int amountMinor;
  final String status;
  final BillingCurrencyEntity? currency;
  final String? paymentReference;
  final String? invoiceNumber;
  final String? reason;
  final String? processedAt;
}

class BillingStatementBalanceEntity {
  const BillingStatementBalanceEntity({
    required this.currency,
    required this.openingReceivableMinor,
    required this.openingReceivable,
    required this.invoicedMinor,
    required this.invoiced,
    required this.verifiedPaymentsMinor,
    required this.verifiedPayments,
    required this.creditsAppliedMinor,
    required this.creditsApplied,
    required this.closingReceivableMinor,
    required this.closingReceivable,
    required this.counts,
  });

  final BillingCurrencyEntity currency;
  final int openingReceivableMinor;
  final String openingReceivable;
  final int invoicedMinor;
  final String invoiced;
  final int verifiedPaymentsMinor;
  final String verifiedPayments;
  final int creditsAppliedMinor;
  final String creditsApplied;
  final int closingReceivableMinor;
  final String closingReceivable;
  final Map<String, int> counts;
}

class BillingStatementEntity {
  const BillingStatementEntity({
    required this.billingAccountId,
    required this.accountNumber,
    required this.from,
    required this.to,
    required this.timezone,
    required this.balances,
    required this.currencyAggregation,
  });

  final int billingAccountId;
  final String accountNumber;
  final String from;
  final String to;
  final String timezone;
  final List<BillingStatementBalanceEntity> balances;
  final String currencyAggregation;
}

class BillingPriceEntity {
  const BillingPriceEntity({
    required this.priceId,
    required this.unitAmount,
    required this.unitAmountMinor,
    required this.setupFee,
    required this.setupFeeMinor,
    required this.billingInterval,
    required this.billingIntervalLabel,
    required this.intervalCount,
    required this.isActive,
    this.currency,
    this.trialPolicyVersionId,
    this.dunningPolicyVersionId,
  });

  final int priceId;
  final String unitAmount;
  final int unitAmountMinor;
  final String setupFee;
  final int setupFeeMinor;
  final String billingInterval;
  final String billingIntervalLabel;
  final int intervalCount;
  final bool isActive;
  final BillingCurrencyEntity? currency;
  final int? trialPolicyVersionId;
  final int? dunningPolicyVersionId;
}

class BillingPlanEntity {
  const BillingPlanEntity({
    required this.planId,
    required this.planKey,
    required this.name,
    required this.description,
    required this.isPublic,
    required this.isActive,
    required this.prices,
    this.productName,
    this.versionNumber,
    this.trialDurationValue,
    this.trialDurationUnit,
  });

  final int planId;
  final String planKey;
  final String name;
  final String description;
  final bool isPublic;
  final bool isActive;
  final String? productName;
  final int? versionNumber;
  final int? trialDurationValue;
  final String? trialDurationUnit;
  final List<BillingPriceEntity> prices;
}
