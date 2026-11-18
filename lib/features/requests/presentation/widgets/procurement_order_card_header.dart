import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ترويسة بطاقة طلب التوريد (Order Card Header - Executive Edition)
///
/// تعرض هوية الطلب الديناميكية المتوافقة مع حالة الطلب:
/// - أيقونة الطلب بتدرج وظلال تتكيف مع الحالة (معلق = عنبري، معتمد = زمردي، مرفوض = قرمزي، ملغي = رمادي).
/// - معرّف الطلب بالكامل مع زر النسخ وزر الانتقال السريع للفاتورة (إن وجدت).
/// - اسم وشعار الطرف الآخر في العملية التوريدية عبر CustomAvatarBadge مع الحرف الأول كبديل.
/// - شارات الحالة الدلالية ونوع البيع مع إمكانية التمرير الأفقي.
/// - التاريخ والوقت المنسق عبر DateFormatter.dateTime واسم المراجع ومقدم الطلب.
class ProcurementOrderCardHeader extends StatelessWidget {
  const ProcurementOrderCardHeader({
    super.key,
    required this.request,
    required this.status,
    required this.saleType,
    this.isNetworkView = false,
  });

  final RequestEntity request;
  final EnumPresentation status;
  final EnumPresentation saleType;
  final bool isNetworkView;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayUuid = request.requestUuid?.isNotEmpty == true
        ? request.requestUuid!
        : '#${request.requestId}';

    final parsedDate = DateTime.tryParse(
      request.requestDate ?? request.createdAt ?? '',
    );
    final dateLabel = parsedDate != null
        ? DateFormatter.dateTime(parsedDate)
        : (request.requestDate ?? request.createdAt ?? 'التاريخ غير متاح');

    // تحديد الطرف الآخر في المعاملة: في مساحة الشبكة الطرف هو نقطة البيع، وفي مساحة نقطة البيع الطرف هو الشبكة
    final partyName = isNetworkView
        ? (request.posName?.isNotEmpty == true
              ? request.posName!
              : 'نقطة بيع #${request.posId}')
        : (request.networkName?.isNotEmpty == true
              ? request.networkName!
              : 'شبكة #${request.networkId}');
    final partyLogo = isNetworkView ? request.posLogo : request.networkLogo;
    final partyInitial = TextFormatter.avatarInitial(partyName);

    // تدرج لوني وظلال متوافقة ديناميكياً مع حالة الطلب
    final LinearGradient iconGradient;
    final Color iconBorderColor;
    final Color iconShadowColor;
    final IconData statusIcon;

    if (request.isPending) {
      iconGradient = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFD97706), Color(0xFFB45309)],
      );
      iconBorderColor = const Color(0xFFFFE082).withValues(alpha: .55);
      iconShadowColor = const Color(0xFFD97706).withValues(alpha: .28);
      statusIcon = Icons.hourglass_top_rounded;
    } else if (request.isApproved) {
      iconGradient = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF087F68), Color(0xFF075B55)],
      );
      iconBorderColor = const Color(0xFFFFD98A).withValues(alpha: .40);
      iconShadowColor = const Color(0xFF087F68).withValues(alpha: .22);
      statusIcon = Icons.check_circle_rounded;
    } else if (request.isRejected) {
      iconGradient = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFBE123C), Color(0xFF9F1239)],
      );
      iconBorderColor = const Color(0xFFFECDD3).withValues(alpha: .45);
      iconShadowColor = const Color(0xFFBE123C).withValues(alpha: .24);
      statusIcon = Icons.cancel_rounded;
    } else {
      iconGradient = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF64748B), Color(0xFF475569)],
      );
      iconBorderColor = const Color(0xFFE2E8F0).withValues(alpha: .40);
      iconShadowColor = const Color(0xFF64748B).withValues(alpha: .20);
      statusIcon = Icons.block_rounded;
    }

    // هوية الفاعلين: المراجع ومقدم الطلب
    final reviewedName = request.reviewedByName?.trim();
    final createdName = request.createdByName?.trim();

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
          // ── أيقونة الطلب الديناميكية ──
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
                // السطر 1: معرف الطلب + زر النسخ + زر الفاتورة
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
                                displayUuid,
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
                              UrlLauncherService.copyToClipboard(
                                displayUuid,
                                confirmationMessage: 'تم نسخ معرف الطلب',
                              );
                              CustomSnackbar.show(
                                title: 'تم النسخ',
                                message:
                                    'تم نسخ المعرف $displayUuid إلى الحافظة',
                                type: SnackType.info,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(
                                    alpha: .4,
                                  ),
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
                    ),
                    if (request.invoiceId != null &&
                        request.invoiceId! > 0) ...[
                      AppSpacing.hSm,
                      CustomInteractiveBounce(
                        onTap: () {
                          final route =
                              (Get.isRegistered<WorkspaceService>() &&
                                  WorkspaceService.to.activeWorkspace ==
                                      AppWorkspace.pos)
                              ? AppRoutes.purchaseInvoiceDetails
                              : AppRoutes.saleInvoiceDetails;
                          Get.toNamed<void>(
                            route,
                            arguments: request.invoiceId,
                          );
                        },
                        child: Tooltip(
                          message:
                              'الذهاب للفاتورة #${request.invoiceUuid ?? request.invoiceId}',
                          child: Container(
                            padding: EdgeInsets.all(5.r),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(7.r),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: .30),
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: .06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              size: 14.r,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                AppSpacing.vXxs,

                // السطر 2: هوية الطرف المقابل بشعاره الحقيقي أو حرفه الأول
                Row(
                  children: [
                    CustomAvatarBadge(
                      imageUrl: partyLogo,
                      initials: partyInitial,
                      size: AvatarBadgeSize.sm,
                      customDimension: 22.r,
                      borderRadius: BorderRadius.circular(6.r),
                      hasPulse: false,
                    ),
                    AppSpacing.hXxs,
                    Flexible(
                      child: Text(
                        partyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vXxs,

                // السطر 3: الشارات الدلالية لحالة الطلب ونوع البيع
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
                      if (reviewedName != null && reviewedName.isNotEmpty) ...[
                        AppSpacing.hXs,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.r,
                            vertical: 2.r,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.35,
                              ),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 11.r,
                                color: colors.onSurfaceVariant,
                              ),
                              AppSpacing.hXxs,
                              Text(
                                request.isApproved
                                    ? 'المعتمد: $reviewedName'
                                    : (request.isRejected
                                          ? 'المراجع: $reviewedName'
                                          : 'المراجع: $reviewedName'),
                                style: AppTypography.caption.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (createdName != null && createdName.isNotEmpty) ...[
                        AppSpacing.hXs,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.r,
                            vertical: 2.r,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.35,
                              ),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_add_outlined,
                                size: 11.r,
                                color: colors.onSurfaceVariant,
                              ),
                              AppSpacing.hXxs,
                              Text(
                                'مقدم الطلب: $createdName',
                                style: AppTypography.caption.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
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

                // السطر 4: الوقت والتاريخ بالكامل
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
