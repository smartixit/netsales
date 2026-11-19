import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ترويسة تفاصيل طلب التوريد المتطورة المتطابقة مع بطاقات شاشة الطلبات
class ProcurementDetailsHero extends StatelessWidget {
  const ProcurementDetailsHero({super.key, required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateLabel = request.formattedRequestDate;
    final displayUuid = request.displayReference;
    final status = EnumPresentationRegistry.resolveRequestStatus(
      request.status,
      serverLabel: request.statusLabel,
    );
    final saleType = EnumPresentationRegistry.resolveSaleType(
      request.saleType,
      serverLabel: request.saleTypeLabel,
    );

    final toneColor = status.tone.color(context);
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            iconShadowColor.withValues(alpha: .065),
            iconShadowColor.withValues(alpha: .015),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: iconShadowColor.withValues(alpha: .15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: iconShadowColor.withValues(alpha: .065),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── الجهة الأولى (اليمين): أيقونة الطلب المتكيفة مع الحالة ──
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
            child: Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 22.r,
            ),
          ),
          AppSpacing.hSm,

          // ── الجهة الثانية: التفاصيل والترقيم والشارات والتوقيت ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // السطر 1: رقم الطلب مع زر النسخ السريع
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayUuid,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.hXxs,
                    CustomInteractiveBounce(
                      onTap: () {
                        UrlLauncherService.copyToClipboard(
                          displayUuid,
                          confirmationMessage: 'تم نسخ معرف الطلب',
                        );
                        CustomSnackbar.show(
                          title: 'تم النسخ',
                          message: 'تم نسخ المعرف $displayUuid إلى الحافظة',
                          type: SnackType.info,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: .4),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 12.r,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vXxs,

                // السطر 2: الشارات الأفقية الرسمية المقاومة للقص
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomStatusBadge.fromPresentation(
                        status,
                        isCompact: true,
                      ),
                      AppSpacing.hXs,
                      CustomStatusBadge.fromPresentation(
                        saleType,
                        isCompact: true,
                      ),
                      if (request.modificationSummary?.hasModifications ==
                          true) ...[
                        AppSpacing.hXs,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.published_with_changes_rounded,
                                size: 10.r,
                                color: colors.primary,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'معدل بعد المراجعة',
                                style: AppTypography.caption.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.vXxs,

                // السطر 3: التاريخ والوقت كاملاً
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 11.5.r,
                      color: colors.onSurfaceVariant,
                    ),
                    AppSpacing.hXxs,
                    Flexible(
                      child: Text(
                        dateLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                // السطر 4: توثيق متخذ القرار (اسم المعتمد / الرافض / الملغي)
                if (request.isApproved &&
                    request.reviewedByName != null &&
                    request.reviewedByName!.trim().isNotEmpty) ...[
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 11.5.r,
                        color: colors.emeraldDark,
                      ),
                      AppSpacing.hXxs,
                      Flexible(
                        child: Text(
                          'اعتمد بواسطة: ${request.reviewedByName!.trim()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: colors.emeraldDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (request.isRejected &&
                    request.reviewedByName != null &&
                    request.reviewedByName!.trim().isNotEmpty) ...[
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        size: 11.5.r,
                        color: colors.error,
                      ),
                      AppSpacing.hXxs,
                      Flexible(
                        child: Text(
                          'رُفض بواسطة: ${request.reviewedByName!.trim()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (request.isCancelled) ...[
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Icon(
                        Icons.block_rounded,
                        size: 11.5.r,
                        color: colors.onSurfaceVariant,
                      ),
                      AppSpacing.hXxs,
                      Flexible(
                        child: Text(
                          'أُلغي بواسطة: ${request.createdByName?.trim() ?? request.posName ?? 'نقطة البيع'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
