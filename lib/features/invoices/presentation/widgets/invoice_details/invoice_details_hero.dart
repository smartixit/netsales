import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// الترويسة القيادية لصفحة تفاصيل الفاتورة المالية (Invoice Details Hero)
class InvoiceDetailsHero extends StatelessWidget {
  const InvoiceDetailsHero({super.key, required this.invoice});

  final InvoiceEntity invoice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final paymentPresentation =
        EnumPresentationRegistry.resolveInvoicePaymentStatus(
          invoice.paymentStatus,
          serverLabel: invoice.paymentStatusLabel,
        );

    final saleTypePresentation = EnumPresentationRegistry.resolveSaleType(
      invoice.saleType,
      serverLabel: invoice.saleTypeLabel,
    );

    final toneColor = paymentPresentation.tone.color(context);
    final displayRef = invoice.displayReference;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            toneColor.withValues(alpha: 0.12),
            colors.surface,
            colors.surface,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border.all(
          color: toneColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: toneColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // أيقونة الحالة الديناميكية
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      toneColor,
                      toneColor.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: toneColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  paymentPresentation.icon,
                  color: Colors.white,
                  size: 24.r,
                ),
              ),
              AppSpacing.hMd,

              // عنوان الفاتورة ومعرفها مع زر النسخ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'فاتورة مبيعات معتمدة',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayRef,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        AppSpacing.hXxs,
                        CustomInteractiveBounce(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: invoice.invoiceUuid ?? invoice.invoiceId.toString()),
                            );
                            CustomSnackbar.show(
                              title: 'تم النسخ',
                              message: 'تم نسخ معرّف الفاتورة إلى الحافظة.',
                              type: SnackType.info,
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(3.r),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 14.r,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // شريط الشارات والتوثيق الزمني
          Row(
            children: [
              CustomStatusBadge(
                label: invoice.paymentStatusLabel ?? paymentPresentation.label,
                tone: paymentPresentation.tone,
                icon: paymentPresentation.icon,
              ),
              AppSpacing.hSm,
              CustomChip(
                label: invoice.saleTypeLabel ?? saleTypePresentation.label,
                icon: saleTypePresentation.icon,
                isCompact: true,
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13.r,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    invoice.formattedInvoiceDate,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
