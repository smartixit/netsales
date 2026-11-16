import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_request_info_row.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// هوية طلب التوريد وحالته والأطراف المرتبطة به.
class ProcurementRequestOverviewPanel extends StatelessWidget {
  const ProcurementRequestOverviewPanel({
    super.key,
    required this.request,
  });

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = EnumPresentationRegistry.resolveRequestStatus(
      request.status,
      serverLabel: request.statusLabel,
    );
    final saleType = EnumPresentationRegistry.resolveSaleType(
      request.saleType,
      serverLabel: request.saleTypeLabel,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'حالة الطلب الحالية',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              CustomStatusBadge(
                label: status.label,
                tone: status.tone,
                icon: status.icon,
              ),
            ],
          ),
          AppSpacing.vSm,
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
          AppSpacing.vSm,
          ProcurementRequestInfoRow(
            label: 'الشبكة الموردة:',
            value: request.networkName ?? 'شبكة #${request.networkId}',
          ),
          ProcurementRequestInfoRow(
            label: 'نقطة البيع:',
            value: request.posName ?? 'نقطة بيع #${request.posId}',
          ),
          ProcurementRequestInfoRow(
            label: 'طريقة الدفع:',
            value: saleType.label,
          ),
          if (request.requestDate != null)
            ProcurementRequestInfoRow(
              label: 'تاريخ تقديم الطلب:',
              value: request.requestDate!,
            ),
          if (request.reviewDate != null)
            ProcurementRequestInfoRow(
              label: 'تاريخ المراجعة:',
              value: request.reviewDate!,
            ),
          if (request.invoiceId != null)
            ProcurementRequestInfoRow(
              label: 'الفاتورة المرتبطة:',
              value: request.invoiceUuid ?? 'فاتورة #${request.invoiceId}',
              isHighlight: true,
            ),
          if (request.requestNote != null &&
              request.requestNote!.isNotEmpty) ...[
            AppSpacing.vSm,
            Text(
              'ملاحظات الطلب',
              style: AppTypography.labelMedium.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vXxs,
            Text(
              request.requestNote!,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
