import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ترويسة تفاصيل المعاملات والوثائق المالية والتشغيلية الموحدة (CustomDocumentDetailsHero)
///
/// المرجع التصميمي المعتمد لترويسة صفحات التفاصيل (الطلبات، الفواتير، المصروفات):
/// - إطار فاخر بحواف 20.r / 24.r مع تدرج لوني ناعم وظلال مشبعة بلون الحالة.
/// - أيقونة حالة ديناميكية بحاوية متدرجة وشعاع ظلي دقيق.
/// - معرف المعاملة (UUID / Reference) مع زر نسخ سريع ورسالة تأكيد للمستخدم.
/// - شريط شارات أفقية للحالة ونوع المعاملة والشارات الإضافية (مثل: معدل بعد المراجعة).
/// - سطر التوثيق الزمني وسطر متخذ القرار/الفاعل إن وجد.
class CustomDocumentDetailsHero extends StatelessWidget {
  const CustomDocumentDetailsHero({
    super.key,
    required this.reference,
    required this.statusPresentation,
    this.typePresentation,
    required this.dateLabel,
    this.heroTitle,
    this.actorLabel,
    this.actorIcon,
    this.actorColor,
    this.extraBadge,
    this.copyConfirmationMessage,
  });

  final String reference;
  final EnumPresentation statusPresentation;
  final EnumPresentation? typePresentation;
  final String dateLabel;
  final String? heroTitle;
  final String? actorLabel;
  final IconData? actorIcon;
  final Color? actorColor;
  final Widget? extraBadge;
  final String? copyConfirmationMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final toneColor = statusPresentation.tone.color(context);
    final iconGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [toneColor, toneColor.withValues(alpha: 0.85)],
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
          color: iconShadowColor.withValues(alpha: .18),
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
          // ── الجهة الأولى: أيقونة المعاملة المتكيفة مع الحالة ──
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
              statusPresentation.icon,
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
                if (heroTitle != null) ...[
                  Text(
                    heroTitle!,
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],

                // السطر 1: معرف المعاملة مع زر النسخ السريع
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        reference,
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
                          reference,
                          confirmationMessage:
                              copyConfirmationMessage ??
                              'تم نسخ المعرّف إلى الحافظة',
                        );
                        CustomSnackbar.show(
                          title: 'تم النسخ',
                          message: 'تم نسخ المعرّف $reference إلى الحافظة',
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
                        statusPresentation,
                        isCompact: true,
                      ),
                      if (typePresentation != null) ...[
                        AppSpacing.hXs,
                        CustomStatusBadge.fromPresentation(
                          typePresentation!,
                          isCompact: true,
                        ),
                      ],
                      if (extraBadge != null) ...[AppSpacing.hXs, extraBadge!],
                    ],
                  ),
                ),
                AppSpacing.vXxs,

                // السطر 3: التاريخ والوقت
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

                // السطر 4: توثيق متخذ القرار / الفاعل
                if (actorLabel != null && actorLabel!.trim().isNotEmpty) ...[
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Icon(
                        actorIcon ?? Icons.verified_user_outlined,
                        size: 11.5.r,
                        color: actorColor ?? colors.emeraldDark,
                      ),
                      AppSpacing.hXxs,
                      Flexible(
                        child: Text(
                          actorLabel!.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: actorColor ?? colors.emeraldDark,
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
