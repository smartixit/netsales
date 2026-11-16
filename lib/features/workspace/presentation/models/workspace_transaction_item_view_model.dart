import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';

/// Immutable presentation model for a transaction row in a workspace dashboard.
///
/// This type intentionally lives in the presentation layer because its fields
/// describe UI rendering and interactions rather than business-domain data.
class WorkspaceTransactionItemViewModel {
  final String title;
  final String? reference;
  final String subtitle;
  final String formattedAmount;
  final Color? amountColor;
  final EnumPresentation statusPresentation;
  final String? initials;
  final String? imageUrl;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final String? actionLabel;

  const WorkspaceTransactionItemViewModel({
    required this.title,
    required this.subtitle,
    required this.formattedAmount,
    required this.statusPresentation,
    this.reference,
    this.amountColor,
    this.initials,
    this.imageUrl,
    this.icon,
    this.onTap,
    this.onAction,
    this.actionLabel,
  });
}
