import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ترويسة تفاصيل طلب التوريد بالعمق البصري القيادي والتدرج اللوني المتكيف
class ProcurementDetailsHero extends StatelessWidget {
  const ProcurementDetailsHero({super.key, required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final parsedDate = request.requestDate != null
        ? DateTime.tryParse(request.requestDate!)
        : null;
    final dateStr = parsedDate != null
        ? DateFormatter.fullDate(parsedDate)
        : (request.requestDate ?? '');

    final displayUuid =
        request.requestUuid != null && request.requestUuid!.trim().isNotEmpty
        ? request.requestUuid!.trim()
        : 'REQ-${request.requestId}';

    // التدرج اللوني التكيفي والحدود وفق حالة الطلب
    final List<Color> iconGradient;
    final IconData statusIcon;
    final Color badgeGlowColor;

    switch (request.status) {
      case RequestStatus.pending:
        iconGradient = const [Color(0xFFD97706), Color(0xFFB45309)];
        statusIcon = Icons.hourglass_top_rounded;
        badgeGlowColor = const Color(0xFFF59E0B);
        break;
      case RequestStatus.approved:
        iconGradient = const [Color(0xFF087F68), Color(0xFF075B55)];
        statusIcon = Icons.verified_rounded;
        badgeGlowColor = const Color(0xFF10B981);
        break;
      case RequestStatus.rejected:
        iconGradient = const [Color(0xFFDC2626), Color(0xFF991B1B)];
        statusIcon = Icons.cancel_rounded;
        badgeGlowColor = const Color(0xFFEF4444);
        break;
      case RequestStatus.cancelled:
      default:
        iconGradient = const [Color(0xFF475569), Color(0xFF334155)];
        statusIcon = Icons.block_rounded;
        badgeGlowColor = const Color(0xFF64748B);
        break;
    }

    final statusPresentation = EnumPresentationRegistry.resolveRequestStatus(
      request.status,
      serverLabel: request.statusLabel,
    );
    final saleTypePresentation = EnumPresentationRegistry.resolveSaleType(
      request.saleType,
      serverLabel: request.saleTypeLabel,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. الأيقونة القيادية ثلاثية الأبعاد
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: iconGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFFFD98A).withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: badgeGlowColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(statusIcon, color: Colors.white, size: 24.r),
          ),
          AppSpacing.hMd,

          // 2. المحتوى التعريفي والأختام
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // الصف الأول: رقم الطلب + زر النسخ
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayUuid,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.hXs,
                    CustomInteractiveBounce(
                      onTap: () => UrlLauncherService.copyToClipboard(
                        displayUuid,
                        confirmationMessage: 'تم نسخ رقم الطلب إلى الحافظة',
                      ),
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 14.r,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),

                // الصف الثاني: الشارات الأفقية القابلة للتمرير بسلاسة
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomStatusBadge(
                        label: statusPresentation.label,
                        tone: statusPresentation.tone,
                        icon: statusPresentation.icon,
                      ),
                      AppSpacing.hXs,
                      CustomChip.fromPresentation(saleTypePresentation),
                      if (request.modificationSummary?.hasModifications ==
                          true) ...[
                        AppSpacing.hXs,
                        const CustomChip(
                          label: 'معدل بعد المراجعة',
                          icon: Icons.published_with_changes_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
                if (dateStr.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  // الصف الثالث: التوقيت الكامل
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13.r,
                        color: colors.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          dateStr,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
