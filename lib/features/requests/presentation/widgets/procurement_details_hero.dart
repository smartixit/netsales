import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ترويسة تفاصيل طلب التوريد المتطورة المتطابقة مع بطاقات شاشة الطلبات
///
/// تجسد المعايير المعتمدة لهوية الطلب:
/// - أيقونة إيصال ثلاثية الأبعاد بتدرج لوني وحدود وظلال تتكيف ديناميكياً مع حالة الطلب.
/// - تدرج لوني خافت يتنفس من لون الحالة مع إطار وظلال زمردية/عنبرية ناعمة.
/// - شارات حالة البيع وحالة الطلب الرسمية من EnumPresentationRegistry.
/// - عرض التاريخ بالصيغة الزمنية الدقيقة DateFormatter.dateTime().
/// - إظهار أسماء القائمين على الاعتماد أو الرفض أو الإلغاء بشكل تنفيذي واضح.
class ProcurementDetailsHero extends StatelessWidget {
  const ProcurementDetailsHero({super.key, required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final parsedDate = DateTime.tryParse(
      request.requestDate ?? request.createdAt ?? '',
    );
    final dateLabel = parsedDate != null
        ? DateFormatter.dateTime(parsedDate)
        : (request.requestDate ?? request.createdAt ?? 'التاريخ غير متاح');

    final displayUuid =
        request.requestUuid != null && request.requestUuid!.trim().isNotEmpty
        ? request.requestUuid!.trim()
        : '#${request.requestId}';

    final isPending = request.isPending;
    final isApproved = request.isApproved;
    final isRejected = request.isRejected;
    final isCancelled = request.isCancelled;

    // تدرجات الأيقونة وحدودها وظلالها المتكيفة ديناميكياً تماماً كما في شاشة الطلبات
    final LinearGradient iconGradient;
    final Color iconBorderColor;
    final Color iconShadowColor;

    if (isPending) {
      iconGradient = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFD97706), Color(0xFFB45309)],
      );
      iconBorderColor = const Color(0xFFFFE082).withValues(alpha: .55);
      iconShadowColor = const Color(0xFFD97706).withValues(alpha: .28);
    } else if (isApproved) {
      iconGradient = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF087F68), Color(0xFF075B55)],
      );
      iconBorderColor = const Color(0xFFFFD98A).withValues(alpha: .40);
      iconShadowColor = const Color(0xFF087F68).withValues(alpha: .22);
    } else if (isRejected) {
      iconGradient = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
      );
      iconBorderColor = const Color(0xFFFCA5A5).withValues(alpha: .50);
      iconShadowColor = const Color(0xFFDC2626).withValues(alpha: .25);
    } else {
      // ملغي أو حالة افتراضية
      iconGradient = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF475569), Color(0xFF334155)],
      );
      iconBorderColor = const Color(0xFFCBD5E1).withValues(alpha: .40);
      iconShadowColor = const Color(0xFF475569).withValues(alpha: .20);
    }

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
                if (isApproved &&
                    request.reviewedByName != null &&
                    request.reviewedByName!.trim().isNotEmpty) ...[
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 11.5.r,
                        color: const Color(0xFF087F68),
                      ),
                      AppSpacing.hXxs,
                      Flexible(
                        child: Text(
                          'اعتمد بواسطة: ${request.reviewedByName!.trim()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF087F68),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (isRejected &&
                    request.reviewedByName != null &&
                    request.reviewedByName!.trim().isNotEmpty) ...[
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        size: 11.5.r,
                        color: const Color(0xFFDC2626),
                      ),
                      AppSpacing.hXxs,
                      Flexible(
                        child: Text(
                          'رُفض بواسطة: ${request.reviewedByName!.trim()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (isCancelled) ...[
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Icon(
                        Icons.block_rounded,
                        size: 11.5.r,
                        color: const Color(0xFF475569),
                      ),
                      AppSpacing.hXxs,
                      Flexible(
                        child: Text(
                          'أُلغي بواسطة: ${request.createdByName?.trim() ?? request.posName ?? 'نقطة البيع'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF475569),
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
