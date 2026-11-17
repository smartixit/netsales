import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// يعرض بيانات الفاتورة الناتجة عن الاعتماد كما أعادها الخادم، دون إعادة احتسابها.
class RequestApprovalResultSheet extends StatelessWidget {
  const RequestApprovalResultSheet({super.key, required this.result});

  final RequestApprovalResultEntity result;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final invoice = result.invoice;
    final payment = EnumPresentationRegistry.resolveInvoicePaymentStatus(
      invoice.paymentStatus,
      serverLabel: invoice.paymentStatusLabel,
    );
    final saleType = EnumPresentationRegistry.resolveSaleType(
      invoice.saleType,
      serverLabel: invoice.saleTypeLabel,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 58.r,
            height: 58.r,
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 32.r, color: colors.success),
          ),
        ),
        SizedBox(height: 12.h),
        Center(
          child: Text(
            'تم اعتماد الطلب بنجاح',
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Center(
          child: Text(
            'تم إنشاء فاتورة المبيعات المرتبطة بالطلب.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 18.h),
        _InvoiceResultRow(
          label: 'رقم الطلب',
          value:
              result.request.requestUuid ?? result.request.requestId.toString(),
        ),
        _InvoiceResultRow(
          label: 'رقم الفاتورة',
          value: invoice.invoiceUuid ?? invoice.invoiceId.toString(),
          highlight: true,
        ),
        _InvoiceResultRow(label: 'نوع البيع', value: saleType.label),
        Divider(height: 20.h, color: colors.outlineVariant),
        _InvoiceResultRow(
          label: 'إجمالي الفاتورة',
          value: AmountFormatter.formatValue(invoice.invoiceTotalAmount),
          emphasize: true,
        ),
        _InvoiceResultRow(
          label: 'المبلغ المسدد',
          value: AmountFormatter.formatValue(invoice.paidAmount),
        ),
        _InvoiceResultRow(
          label: 'المتبقي',
          value: AmountFormatter.formatValue(invoice.remainingAmount),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'حالة السداد',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            CustomStatusBadge(
              label: payment.label,
              tone: payment.tone,
              icon: payment.icon,
            ),
          ],
        ),
      ],
    );
  }
}

class _InvoiceResultRow extends StatelessWidget {
  const _InvoiceResultRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool highlight;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style:
                  (emphasize
                          ? AppTypography.titleSmall
                          : AppTypography.bodyMedium)
                      .copyWith(
                        color: highlight ? colors.primary : colors.onSurface,
                        fontWeight: emphasize || highlight
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
