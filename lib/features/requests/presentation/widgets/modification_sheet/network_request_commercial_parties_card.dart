import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// بطاقة الأطراف والسياق التجاري التنفيذية لمراجعة طلب التوريد
class NetworkRequestCommercialPartiesCard extends StatelessWidget {
  const NetworkRequestCommercialPartiesCard({super.key, required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final posName = request.displayPosName;
    final networkName = request.displayNetworkName;
    final saleTypeLabel =
        request.saleTypeLabel ??
        (request.saleType == SaleType.credit ? 'آجل' : 'نقدي');
    final isCash = request.saleType == SaleType.cash;
    final uuid = request.displayReference;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.40),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. ترويسة هوية الطلب ونوع السداد ──
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow.withValues(alpha: 0.6),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              border: Border(
                bottom: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.30),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.primary.withValues(alpha: 0.82),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلب توريد كروت',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              uuid,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          AppSpacing.hXxs,
                          CustomInteractiveBounce(
                            onTap: () {
                              UrlLauncherService.copyToClipboard(
                                uuid,
                                confirmationMessage: 'تم نسخ رقم الطلب',
                              );
                              CustomSnackbar.show(
                                title: 'تم النسخ',
                                message: 'تم نسخ $uuid للحافظة',
                                type: SnackType.info,
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(3.r),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 13.r,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomStatusBadge(
                  label: saleTypeLabel,
                  icon: isCash
                      ? Icons.payments_outlined
                      : Icons.account_balance_wallet_outlined,
                  tone: isCash ? SemanticTone.success : SemanticTone.info,
                  isCompact: true,
                ),
              ],
            ),
          ),

          // ── 2. مسار الشراكة التوريدية (المورّد ➔ المستلم) مع مساحات كاملة ──
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // الطرف الأول: الشبكة المورّدة
                Row(
                  children: [
                    CustomAvatarBadge(
                      imageUrl: request.networkLogo,
                      initials: TextFormatter.avatarInitial(networkName),
                      size: AvatarBadgeSize.sm,
                      customDimension: 36.r,
                      borderRadius: BorderRadius.circular(9.r),
                      gradientColors: const [
                        Color(0xFF0284C7),
                        Color(0xFF0369A1),
                      ],
                      hasPulse: false,
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الشبكة المورّدة',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.primary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            networkName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // موصل التدفق التجاري الرأسي
                Padding(
                  padding: EdgeInsets.only(right: 17.r, top: 4.r, bottom: 4.r),
                  child: Row(
                    children: [
                      Container(
                        width: 2.r,
                        height: 18.r,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      ),
                      AppSpacing.hSm,
                      Icon(
                        Icons.south_rounded,
                        size: 13.r,
                        color: colors.primary.withValues(alpha: 0.7),
                      ),
                      AppSpacing.hXxs,
                      Text(
                        'توريد واعتماد كميات الكروت',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 9.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // الطرف الثاني: نقطة البيع المستلمة
                Row(
                  children: [
                    CustomAvatarBadge(
                      imageUrl: request.posLogo,
                      initials: TextFormatter.avatarInitial(posName),
                      size: AvatarBadgeSize.sm,
                      customDimension: 36.r,
                      borderRadius: BorderRadius.circular(9.r),
                      gradientColors: const [
                        Color(0xFF087F68),
                        Color(0xFF065F46),
                      ],
                      hasPulse: false,
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نقطة البيع المستلمة',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.secondary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            posName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
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
        ],
      ),
    );
  }
}
