import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_summary_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// يعرض المقارنة التي يرسلها الخادم بين الطلب الأصلي والاعتماد النهائي.
class RequestModificationSummaryPanel extends StatelessWidget {
  const RequestModificationSummaryPanel({super.key, required this.summary});

  final RequestModificationSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'نتيجة مراجعة الشبكة',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomStatusBadge(
                label: summary.hasModifications
                    ? 'تم تعديل الطلب'
                    : 'اعتمد كما أُرسل',
                tone: summary.hasModifications
                    ? SemanticTone.warning
                    : SemanticTone.success,
                icon: summary.hasModifications
                    ? Icons.edit_note_rounded
                    : Icons.verified_rounded,
              ),
            ],
          ),
          AppSpacing.vMd,
          _RequestModificationSummaryValueRow(
            label: 'قيمة الطلب الأصلي',
            value: AmountFormatter.formatValue(summary.originalTotal),
          ),
          AppSpacing.vSm,
          _RequestModificationSummaryValueRow(
            label: 'قيمة الاعتماد النهائي',
            value: AmountFormatter.formatValue(summary.approvedTotal),
            emphasize: true,
          ),
          Divider(
            height: AppSpacing.lg,
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
          Row(
            children: [
              Expanded(
                child: _RequestModificationSummaryCount(
                  label: 'بنود الطلب',
                  value: summary.originalItemsCount,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: _RequestModificationSummaryCount(
                  label: 'البنود المعتمدة',
                  value: summary.approvedItemsCount,
                ),
              ),
            ],
          ),
          AppSpacing.vXs,
          Text(
            'هذه القيم ملخص من الخادم؛ تفاصيل المبالغ والبنود النهائية موجودة في الفاتورة المرتبطة.',
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestModificationSummaryValueRow extends StatelessWidget {
  const _RequestModificationSummaryValueRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style:
              (emphasize ? AppTypography.titleSmall : AppTypography.bodyMedium)
                  .copyWith(
                    color: emphasize ? colors.primary : colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
        ),
      ],
    );
  }
}

class _RequestModificationSummaryCount extends StatelessWidget {
  const _RequestModificationSummaryCount({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: AppTypography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
