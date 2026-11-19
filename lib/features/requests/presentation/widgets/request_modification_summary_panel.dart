import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_summary_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/request_modification_summary_count.dart';
import 'package:netsales/features/requests/presentation/widgets/request_modification_summary_value_row.dart';
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
          RequestModificationSummaryValueRow(
            label: 'قيمة الطلب الأصلي',
            value: AmountFormatter.formatValue(summary.originalTotal),
          ),
          AppSpacing.vSm,
          RequestModificationSummaryValueRow(
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
                child: RequestModificationSummaryCount(
                  label: 'بنود الطلب',
                  value: summary.originalItemsCount,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: RequestModificationSummaryCount(
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
