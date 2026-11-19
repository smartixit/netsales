import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ترويسة بطاقة الفاتورة المالية (Invoice Card Header - Executive Edition)
class InvoiceCardHeader extends StatelessWidget {
  const InvoiceCardHeader({
    super.key,
    required this.invoice,
    required this.paymentPresentation,
    required this.saleTypePresentation,
    this.isNetworkView = true,
    this.onRequestTap,
  });

  final InvoiceEntity invoice;
  final EnumPresentation paymentPresentation;
  final EnumPresentation saleTypePresentation;
  final bool isNetworkView;
  final VoidCallback? onRequestTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayRef = invoice.displayReference;
    final dateLabel = invoice.formattedInvoiceDate;

    final partyName = isNetworkView
        ? invoice.displayPosName
        : invoice.displayNetworkName;
    final partyLogo = isNetworkView
        ? invoice.posLogoUrl
        : invoice.networkLogoUrl;
    final partyInitial = TextFormatter.avatarInitial(partyName);

    final toneColor = paymentPresentation.tone.color(context);
    final iconGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        toneColor,
        toneColor.withValues(alpha: 0.85),
      ],
    );
    final iconBorderColor = toneColor.withValues(alpha: 0.40);
    final iconShadowColor = toneColor.withValues(alpha: 0.25);
    final statusIcon = paymentPresentation.icon;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            iconShadowColor.withValues(alpha: .06),
            iconShadowColor.withValues(alpha: .015),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: iconShadowColor.withValues(alpha: .08),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── أيقونة الفاتورة الديناميكية ──
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              gradient: iconGradient,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: iconBorderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: iconShadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(statusIcon, color: Colors.white, size: 22.r),
          ),
          AppSpacing.hSm,

          // ── التفاصيل والبيانات القيادية ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // السطر 1: معرف الفاتورة + زر النسخ
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                'فاتورة #$displayRef',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleSmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
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
                                message: 'تم نسخ معرّف الفاتورة إلى الحافظة بنجاح.',
                                type: SnackType.info,
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(3.r),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 14.r,
                                color: colors.onSurfaceVariant.withValues(alpha: .7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (invoice.hasRequest && onRequestTap != null) ...[
                      AppSpacing.hXxs,
                      CustomInteractiveBounce(
                        onTap: onRequestTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: .25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.link_rounded,
                                size: 11.r,
                                color: colors.primary,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'طلب #${invoice.requestId}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.primary,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),

                // السطر 2: هوية الطرف التجاري الآخر مع صورته أو رمزه
                Row(
                  children: [
                    CustomAvatarBadge(
                      imageUrl: partyLogo,
                      initials: partyInitial,
                      size: AvatarBadgeSize.sm,
                      customDimension: 24.r,
                      hasPulse: false,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        partyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),

                // السطر 3: شريط الشارات وتاريخ الفاتورة
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomStatusBadge(
                          label: invoice.paymentStatusLabel ??
                              paymentPresentation.label,
                          tone: paymentPresentation.tone,
                          icon: paymentPresentation.icon,
                          isCompact: true,
                        ),
                        AppSpacing.hXxs,
                        CustomChip(
                          label: invoice.saleTypeLabel ??
                              saleTypePresentation.label,
                          icon: saleTypePresentation.icon,
                          isCompact: true,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11.r,
                          color: colors.onSurfaceVariant.withValues(alpha: .7),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          dateLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
