import 'package:flutter/material.dart';
import 'package:netsales/core/enums/billing_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// يعرض حالة Billing عبر EnumPresentationRegistry وCustomStatusBadge فقط.
class BillingStatusBadge extends StatelessWidget {
  const BillingStatusBadge({
    super.key,
    required this.status,
    this.serverLabel,
    this.english = false,
    this.compact = false,
  });

  final String? status;
  final String? serverLabel;
  final bool english;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final presentation = EnumPresentationRegistry.resolveBillingStatus(
      BillingStatus.fromWire(status),
      serverLabel: serverLabel,
      english: english,
    );
    return CustomStatusBadge.fromPresentation(
      presentation,
      isCompact: compact,
    );
  }
}
