import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/presentation/controllers/pos_invoices_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// رأس شاشة فواتير المشتريات المضمنة (Embedded Invoices Header)
class PosEmbeddedInvoicesHeader extends StatelessWidget {
  const PosEmbeddedInvoicesHeader({super.key, required this.controller});

  final PosInvoicesController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'فواتير المشتريات',
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomButton.icon(
            icon: Icons.refresh_rounded,
            tooltip: 'تحديث الفواتير',
            backgroundColor: Colors.transparent,
            foregroundColor: colors.onSurfaceVariant,
            onPressed: () => controller.loadInvoices(isRefresh: true),
          ),
        ],
      ),
    );
  }
}

