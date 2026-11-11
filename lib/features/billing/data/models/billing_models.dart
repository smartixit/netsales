import 'package:netsales/features/billing/domain/entities/billing_entities.dart';

Map<String, dynamic> _jsonMap(Object? value, String field) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException('استجابة الفوترة لا تحتوي على كائن صالح للحقل $field.');
}

String _text(Map<String, dynamic> json, String key, {String? fallback}) {
  final value = json[key];
  if (value == null) {
    if (fallback != null) return fallback;
    throw FormatException('حقل الفوترة المطلوب "$key" مفقود.');
  }
  return value.toString();
}

int _integer(Map<String, dynamic> json, String key, {int? fallback}) {
  final value = json[key];
  final parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
  if (parsed == null) {
    if (fallback != null) return fallback;
    throw FormatException('حقل الفوترة الرقمي "$key" غير صالح.');
  }
  return parsed;
}

BillingCurrencyEntity? _currency(Object? value) {
  if (value == null) return null;
  final json = _jsonMap(value, 'currency');
  return BillingCurrencyModel.fromJson(json);
}

class BillingCurrencyModel extends BillingCurrencyEntity {
  const BillingCurrencyModel({
    required super.currencyId,
    required super.code,
    required super.name,
    super.nativeName,
    super.symbol,
    super.decimalPlaces,
  });

  factory BillingCurrencyModel.fromJson(Map<String, dynamic> json) =>
      BillingCurrencyModel(
        currencyId: _integer(json, 'currency_id'),
        code: _text(json, 'code'),
        name: _text(json, 'name'),
        nativeName: json['native_name']?.toString(),
        symbol: json['symbol']?.toString(),
        decimalPlaces: _integer(json, 'decimal_places', fallback: 2),
      );
}

class BillingAccountModel extends BillingAccountEntity {
  const BillingAccountModel({
    required super.billingAccountId,
    required super.accountNumber,
    required super.networkId,
    required super.status,
    required super.legalName,
    super.billingEmail,
    super.taxNumber,
    super.billingAddress,
    super.currency,
  });

  factory BillingAccountModel.fromJson(Map<String, dynamic> json) =>
      BillingAccountModel(
        billingAccountId: _integer(json, 'billing_account_id'),
        accountNumber: _text(json, 'account_number'),
        networkId: _integer(json, 'network_id'),
        status: _text(json, 'status', fallback: 'UNKNOWN'),
        legalName: _text(json, 'legal_name', fallback: ''),
        billingEmail: json['billing_email']?.toString(),
        taxNumber: json['tax_number']?.toString(),
        billingAddress: json['billing_address']?.toString(),
        currency: _currency(json['default_currency']),
      );
}

class BillingSubscriptionModel extends BillingSubscriptionEntity {
  const BillingSubscriptionModel({
    required super.subscriptionId,
    required super.status,
    required super.statusLabel,
    required super.planName,
    super.currency,
    super.currentPeriodStart,
    super.currentPeriodEnd,
    super.trialStart,
    super.trialEnd,
    super.gracePeriodEndsAt,
    super.cancelAtPeriodEnd,
    super.termsSnapshot,
  });

  factory BillingSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] == null
        ? <String, dynamic>{}
        : _jsonMap(json['plan'], 'plan');
    final terms = json['terms_snapshot'];
    return BillingSubscriptionModel(
      subscriptionId: _integer(json, 'billing_subscription_id'),
      status: _text(json, 'status', fallback: 'UNKNOWN'),
      statusLabel: _text(json, 'status_label', fallback: _text(json, 'status', fallback: 'غير معروف')),
      planName: _text(plan, 'name', fallback: 'خطة اشتراك'),
      currency: _currency(json['currency']),
      currentPeriodStart: json['current_period_start']?.toString(),
      currentPeriodEnd: json['current_period_end']?.toString(),
      trialStart: json['trial_start']?.toString(),
      trialEnd: json['trial_end']?.toString(),
      gracePeriodEndsAt: json['grace_period_ends_at']?.toString(),
      cancelAtPeriodEnd: json['cancel_at_period_end'] == true,
      termsSnapshot: terms is Map ? Map<String, dynamic>.from(terms) : null,
    );
  }
}

class BillingInvoiceLineModel extends BillingInvoiceLineEntity {
  const BillingInvoiceLineModel({
    required super.description,
    required super.quantity,
    required super.unitAmountMinor,
    required super.subtotalMinor,
    required super.discountMinor,
    required super.taxMinor,
    required super.totalMinor,
    super.currency,
  });

  factory BillingInvoiceLineModel.fromJson(Map<String, dynamic> json) =>
      BillingInvoiceLineModel(
        description: _text(json, 'description', fallback: ''),
        quantity: _text(json, 'quantity', fallback: '0'),
        unitAmountMinor: _integer(json, 'unit_amount_minor', fallback: 0),
        subtotalMinor: _integer(json, 'subtotal_minor', fallback: 0),
        discountMinor: _integer(json, 'discount_minor', fallback: 0),
        taxMinor: _integer(json, 'tax_minor', fallback: 0),
        totalMinor: _integer(json, 'total_minor', fallback: 0),
        currency: _currency(json['currency']),
      );
}

class BillingInvoiceModel extends BillingInvoiceEntity {
  const BillingInvoiceModel({
    required super.invoiceId,
    required super.invoiceNumber,
    required super.status,
    required super.statusLabel,
    required super.total,
    required super.paid,
    required super.remaining,
    required super.totalMinor,
    required super.paidMinor,
    required super.remainingMinor,
    super.currency,
    super.issuedOn,
    super.dueOn,
    super.periodStart,
    super.periodEnd,
    super.subtotal,
    super.discount,
    super.tax,
    super.memo,
    super.lines,
  });

  factory BillingInvoiceModel.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    final lines = rawLines is List
        ? rawLines
            .map((value) => BillingInvoiceLineModel.fromJson(
                  _jsonMap(value, 'invoice line'),
                ))
            .toList(growable: false)
        : const <BillingInvoiceLineEntity>[];
    return BillingInvoiceModel(
      invoiceId: _integer(json, 'invoice_id'),
      invoiceNumber: _text(json, 'invoice_number'),
      status: _text(json, 'status', fallback: 'UNKNOWN'),
      statusLabel: _text(json, 'status_label', fallback: _text(json, 'status', fallback: 'غير معروف')),
      currency: _currency(json['currency']),
      total: _text(json, 'total', fallback: '0'),
      paid: _text(json, 'paid', fallback: '0'),
      remaining: _text(json, 'remaining', fallback: '0'),
      totalMinor: _integer(json, 'total_minor', fallback: 0),
      paidMinor: _integer(json, 'paid_minor', fallback: 0),
      remainingMinor: _integer(json, 'remaining_minor', fallback: 0),
      issuedOn: json['issued_on']?.toString(),
      dueOn: json['due_on']?.toString(),
      periodStart: json['period_start']?.toString(),
      periodEnd: json['period_end']?.toString(),
      subtotal: json['subtotal']?.toString(),
      discount: json['discount']?.toString(),
      tax: json['tax']?.toString(),
      memo: json['memo']?.toString(),
      lines: lines,
    );
  }
}

class BillingPaymentModel extends BillingPaymentEntity {
  const BillingPaymentModel({
    required super.paymentId,
    required super.reference,
    required super.amount,
    required super.amountMinor,
    required super.status,
    super.currency,
    super.methodName,
    super.externalReference,
    super.invoiceNumber,
    super.receivedAt,
    super.verifiedAt,
  });

  factory BillingPaymentModel.fromJson(Map<String, dynamic> json) {
    final method = json['payment_method'] == null
        ? <String, dynamic>{}
        : _jsonMap(json['payment_method'], 'payment_method');
    return BillingPaymentModel(
      paymentId: _integer(json, 'payment_id'),
      reference: _text(json, 'payment_reference'),
      amount: _text(json, 'amount', fallback: '0'),
      amountMinor: _integer(json, 'amount_minor', fallback: 0),
      status: _text(json, 'status', fallback: 'UNKNOWN'),
      currency: _currency(json['currency']),
      methodName: method['name']?.toString(),
      externalReference: json['external_reference']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      receivedAt: json['received_at']?.toString(),
      verifiedAt: json['verified_at']?.toString(),
    );
  }
}

class BillingCreditNoteModel extends BillingCreditNoteEntity {
  const BillingCreditNoteModel({
    required super.creditNoteId,
    required super.number,
    required super.status,
    required super.total,
    required super.totalMinor,
    required super.appliedToReceivableMinor,
    required super.refundableMinor,
    required super.refundedMinor,
    super.currency,
    super.invoiceNumber,
    super.reason,
    super.issuedAt,
  });

  factory BillingCreditNoteModel.fromJson(Map<String, dynamic> json) =>
      BillingCreditNoteModel(
        creditNoteId: _integer(json, 'credit_note_id'),
        number: _text(json, 'credit_note_number'),
        status: _text(json, 'status', fallback: 'UNKNOWN'),
        total: _text(json, 'total', fallback: '0'),
        totalMinor: _integer(json, 'total_minor', fallback: 0),
        appliedToReceivableMinor: _integer(json, 'applied_to_receivable_minor', fallback: 0),
        refundableMinor: _integer(json, 'refundable_minor', fallback: 0),
        refundedMinor: _integer(json, 'refunded_minor', fallback: 0),
        currency: _currency(json['currency']),
        invoiceNumber: json['invoice_number']?.toString(),
        reason: json['reason']?.toString(),
        issuedAt: json['issued_at']?.toString(),
      );
}

class BillingRefundModel extends BillingRefundEntity {
  const BillingRefundModel({
    required super.refundId,
    required super.reference,
    required super.amount,
    required super.amountMinor,
    required super.status,
    super.currency,
    super.paymentReference,
    super.invoiceNumber,
    super.reason,
    super.processedAt,
  });

  factory BillingRefundModel.fromJson(Map<String, dynamic> json) =>
      BillingRefundModel(
        refundId: _integer(json, 'refund_id'),
        reference: _text(json, 'refund_reference'),
        amount: _text(json, 'amount', fallback: '0'),
        amountMinor: _integer(json, 'amount_minor', fallback: 0),
        status: _text(json, 'status', fallback: 'UNKNOWN'),
        currency: _currency(json['currency']),
        paymentReference: json['payment_reference']?.toString(),
        invoiceNumber: json['invoice_number']?.toString(),
        reason: json['reason']?.toString(),
        processedAt: json['processed_at']?.toString(),
      );
}

class BillingStatementModel extends BillingStatementEntity {
  const BillingStatementModel({
    required super.billingAccountId,
    required super.accountNumber,
    required super.from,
    required super.to,
    required super.timezone,
    required super.balances,
    required super.currencyAggregation,
  });

  factory BillingStatementModel.fromJson(Map<String, dynamic> json) {
    final period = _jsonMap(json['period'], 'period');
    final rawBalances = json['balances_by_currency'];
    if (rawBalances is! List) {
      throw const FormatException('بيانات أرصدة كشف الحساب غير صالحة.');
    }
    final balances = rawBalances.map((value) {
      final row = _jsonMap(value, 'statement balance');
      final currency = BillingCurrencyModel.fromJson(
        _jsonMap(row['currency'], 'statement currency'),
      );
      final rawCounts = _jsonMap(row['counts'], 'statement counts');
      return BillingStatementBalanceEntity(
        currency: currency,
        openingReceivableMinor: _integer(row, 'opening_receivable_minor', fallback: 0),
        openingReceivable: _text(row, 'opening_receivable', fallback: '0'),
        invoicedMinor: _integer(row, 'invoiced_minor', fallback: 0),
        invoiced: _text(row, 'invoiced', fallback: '0'),
        verifiedPaymentsMinor: _integer(row, 'verified_payments_minor', fallback: 0),
        verifiedPayments: _text(row, 'verified_payments', fallback: '0'),
        creditsAppliedMinor: _integer(row, 'credits_applied_minor', fallback: 0),
        creditsApplied: _text(row, 'credits_applied', fallback: '0'),
        closingReceivableMinor: _integer(row, 'closing_receivable_minor', fallback: 0),
        closingReceivable: _text(row, 'closing_receivable', fallback: '0'),
        counts: rawCounts.map((key, value) => MapEntry(
          key,
          value is int ? value : int.tryParse(value.toString()) ?? 0,
        )),
      );
    }).toList(growable: false);
    return BillingStatementModel(
      billingAccountId: _integer(json, 'billing_account_id'),
      accountNumber: _text(json, 'account_number'),
      from: _text(period, 'from'),
      to: _text(period, 'to'),
      timezone: _text(period, 'timezone', fallback: 'UTC'),
      balances: balances,
      currencyAggregation: _text(json, 'currency_aggregation'),
    );
  }
}

class BillingPriceModel extends BillingPriceEntity {
  const BillingPriceModel({
    required super.priceId,
    required super.unitAmount,
    required super.unitAmountMinor,
    required super.setupFee,
    required super.setupFeeMinor,
    required super.billingInterval,
    required super.billingIntervalLabel,
    required super.intervalCount,
    required super.isActive,
    super.currency,
    super.trialPolicyVersionId,
    super.dunningPolicyVersionId,
  });

  factory BillingPriceModel.fromJson(Map<String, dynamic> json) =>
      BillingPriceModel(
        priceId: _integer(json, 'price_id'),
        unitAmount: _text(json, 'unit_amount', fallback: '0'),
        unitAmountMinor: _integer(json, 'unit_amount_minor', fallback: 0),
        setupFee: _text(json, 'setup_fee', fallback: '0'),
        setupFeeMinor: _integer(json, 'setup_fee_minor', fallback: 0),
        billingInterval: _text(json, 'billing_interval', fallback: 'ONCE'),
        billingIntervalLabel: _text(json, 'billing_interval_label', fallback: 'مرة واحدة'),
        intervalCount: _integer(json, 'interval_count', fallback: 1),
        isActive: json['is_active'] == true,
        currency: _currency(json['currency']),
        trialPolicyVersionId: json['trial_policy_version_id'] == null
            ? null
            : _integer(json, 'trial_policy_version_id'),
        dunningPolicyVersionId: json['dunning_policy_version_id'] == null
            ? null
            : _integer(json, 'dunning_policy_version_id'),
      );
}

class BillingPlanModel extends BillingPlanEntity {
  const BillingPlanModel({
    required super.planId,
    required super.planKey,
    required super.name,
    required super.description,
    required super.isPublic,
    required super.isActive,
    required super.prices,
    super.productName,
    super.versionNumber,
    super.trialDurationValue,
    super.trialDurationUnit,
  });

  factory BillingPlanModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] == null
        ? null
        : _jsonMap(json['product'], 'product');
    final version = json['current_version'] == null
        ? null
        : _jsonMap(json['current_version'], 'current_version');
    final rawPrices = version?['prices'];
    final prices = rawPrices is List
        ? rawPrices.map((value) => BillingPriceModel.fromJson(
            _jsonMap(value, 'billing price'),
          )).toList(growable: false)
        : const <BillingPriceEntity>[];
    final trial = version?['trial_policy'] == null
        ? null
        : _jsonMap(version?['trial_policy'], 'trial_policy');

    return BillingPlanModel(
      planId: _integer(json, 'plan_id'),
      planKey: _text(json, 'plan_key'),
      name: _text(json, 'name'),
      description: _text(json, 'description', fallback: ''),
      isPublic: json['is_public'] == true,
      isActive: json['is_active'] == true,
      productName: product?['name']?.toString(),
      versionNumber: version == null ? null : _integer(version, 'version_number', fallback: 0),
      trialDurationValue: trial == null ? null : _integer(trial, 'duration_value', fallback: 0),
      trialDurationUnit: trial?['duration_unit']?.toString(),
      prices: prices,
    );
  }
}
