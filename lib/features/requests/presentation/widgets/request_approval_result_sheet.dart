import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// قسيمة إشعار الفوترة والاعتماد التنفيذية المعتمدة (Executive Approved Invoice Voucher)
///
/// تجسد المعايير المحاسبية والتنظيمية العليا لمنصة NetSales:
/// - أيقونة إنجاز ثلاثية الأبعاد بوهج زمردي خافت.
/// - لوحة الصافي السيادي المعتمد للفاتورة مع شارة السداد الرسمية.
/// - بطاقة الهوية التوثيقية المزدوجة (رقم الطلب ➔ رقم الفاتورة) مع نسخ سريع.
/// - جدول التدقيق المحاسبي المعتمد لمطابقة المقبوضات والذمم المتبقية.
/// - مسار الربط بين الشبكة المورّدة ونقطة البيع المستلمة.
class RequestApprovalResultSheet extends StatelessWidget {
  const RequestApprovalResultSheet({super.key, required this.result});

  final RequestApprovalResultEntity result;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final invoice = result.invoice;
    final request = result.request;

    final payment = EnumPresentationRegistry.resolveInvoicePaymentStatus(
      invoice.paymentStatus,
      serverLabel: invoice.paymentStatusLabel,
    );
    final saleType = EnumPresentationRegistry.resolveSaleType(
      invoice.saleType,
      serverLabel: invoice.saleTypeLabel,
    );

    final requestUuid =
        request.requestUuid != null && request.requestUuid!.trim().isNotEmpty
            ? request.requestUuid!.trim()
            : '#${request.requestId}';

    final invoiceUuid =
        invoice.invoiceUuid != null && invoice.invoiceUuid!.trim().isNotEmpty
            ? invoice.invoiceUuid!.trim()
            : '#${invoice.invoiceId}';

    final networkName =
        request.networkName ?? invoice.networkName ?? 'شبكة التوريد';
    final posName = request.posName ?? invoice.posName ?? 'نقطة البيع المستلمة';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. رأس النجاح التنفيذي المشرق (Success Header) ──
        Center(
          child: Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF0D7A5F), Color(0xFF065440)],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2ECC71).withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D7A5F).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.check_rounded,
                size: 34,
                color: Colors.white,
              ),
            ),
          ),
        ),
        AppSpacing.vSm,
        Center(
          child: Text(
            'تم اعتماد الطلب بنجاح',
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        AppSpacing.vXxs,
        Center(
          child: Text(
            'تم إصدار فاتورة المبيعات الرسمية وقيد أثرها المحاسبي بالخادم.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        AppSpacing.vMd,

        // ── 2. لوحة الصافي السيادي المعتمد (The Sovereign Invoice Hero) ──
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF087A5F), Color(0xFF044836)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF087A5F).withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'إجمالي الفاتورة المعتمدة',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.r,
                      vertical: 3.r,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'فاتورة نافذة رسمياً',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.vXs,
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${AmountFormatter.formatValue(invoice.invoiceTotalAmount)} ر.ي',
                  textDirection: TextDirection.rtl,
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontSize: 27.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              AppSpacing.vXs,
              Row(
                children: [
                  CustomStatusBadge(
                    label: payment.label,
                    tone: payment.tone,
                    icon: payment.icon,
                    isCompact: true,
                  ),
                  AppSpacing.hXs,
                  CustomStatusBadge(
                    label: saleType.label,
                    tone: saleType.tone,
                    icon: saleType.icon,
                    isCompact: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.vMd,

        // ── 3. بطاقة الوثائق المزدوجة ومسار الشراكة التجارية ──
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.40),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _DocumentIdentityTile(
                title: 'رقم الفاتورة الصادرة',
                uuid: invoiceUuid,
                icon: Icons.receipt_long_rounded,
                isPrimary: true,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.r),
                child: Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              _DocumentIdentityTile(
                title: 'رقم الطلب الأصلي',
                uuid: requestUuid,
                icon: Icons.shopping_bag_outlined,
                isPrimary: false,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.r),
                child: Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              // مسار الشراكة التوريدية
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الشبكة المورّدة',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                        Text(
                          networkName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 14.r,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نقطة البيع المستلمة',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                        Text(
                          posName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.vMd,

        // ── 4. جدول التسوية المحاسبية التنفيذي ──
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FinancialRow(
                label: 'إجمالي الفاتورة',
                value: AmountFormatter.formatValue(invoice.invoiceTotalAmount),
                isEmphasized: true,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.r),
                child: Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              _FinancialRow(
                label: 'المبلغ المسدد',
                value: AmountFormatter.formatValue(invoice.paidAmount),
                toneColor: colors.tertiary,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.r),
                child: Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              _FinancialRow(
                label: 'المتبقي',
                value: AmountFormatter.formatValue(invoice.remainingAmount),
                toneColor: invoice.remainingAmount > 0
                    ? colors.secondary
                    : colors.onSurfaceVariant,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.r),
                child: Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              _FinancialRow(
                label: 'نوع البيع',
                value: saleType.label,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.r),
                child: Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              _FinancialRow(
                label: 'حالة السداد',
                value: payment.label,
                badgeTone: payment.tone,
              ),
            ],
          ),
        ),
        AppSpacing.vMd,

        // ── 5. بطاقة الإشعار التشغيلي الموثوق ──
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 16.r,
                color: colors.primary,
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  'تم إشعار نقطة البيع فورياً بصدور الفاتورة، ويمكنك الآن فتحها لطباعتها أو تصديرها.',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DocumentIdentityTile extends StatelessWidget {
  const _DocumentIdentityTile({
    required this.title,
    required this.uuid,
    required this.icon,
    required this.isPrimary,
  });

  final String title;
  final String uuid;
  final IconData icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            color: isPrimary
                ? colors.primary.withValues(alpha: 0.12)
                : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 16.r,
              color: isPrimary ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ),
        AppSpacing.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
              Text(
                uuid,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: isPrimary ? colors.primary : colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        CustomInteractiveBounce(
          onTap: () {
            UrlLauncherService.copyToClipboard(
              uuid,
              confirmationMessage: 'تم النسخ للحافظة',
            );
            CustomSnackbar.show(
              title: 'تم النسخ',
              message: 'تم نسخ $uuid للحافظة',
              type: SnackType.info,
            );
          },
          child: Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.copy_rounded,
              size: 13.r,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _FinancialRow extends StatelessWidget {
  const _FinancialRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
    this.toneColor,
    this.badgeTone,
  });

  final String label;
  final String value;
  final bool isEmphasized;
  final Color? toneColor;
  final SemanticTone? badgeTone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isEmphasized ? colors.onSurface : colors.onSurfaceVariant,
              fontWeight: isEmphasized ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        if (badgeTone != null)
          CustomStatusBadge(
            label: value,
            tone: badgeTone!,
            isCompact: true,
          )
        else
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label == 'نوع البيع' ? value : '$value ر.ي',
              textDirection: TextDirection.rtl,
              style: (isEmphasized
                      ? AppTypography.titleSmall
                      : AppTypography.bodyMedium)
                  .copyWith(
                color: toneColor ?? (isEmphasized ? colors.primary : colors.onSurface),
                fontWeight: isEmphasized ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
