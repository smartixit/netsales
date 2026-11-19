import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_party_tile.dart';

/// بطاقة أطراف العملية التجارية والشراكة التوريدية
class ProcurementDetailsPartiesCard extends StatelessWidget {
  const ProcurementDetailsPartiesCard({super.key, required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final saleType = EnumPresentationRegistry.resolveSaleType(
      request.saleType,
      serverLabel: request.saleTypeLabel,
    );

    final networkName =
        request.networkName != null && request.networkName!.trim().isNotEmpty
        ? request.networkName!
        : 'شبكة #${request.networkId}';

    final posName =
        request.posName != null && request.posName!.trim().isNotEmpty
        ? request.posName!
        : 'نقطة بيع #${request.posId}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.hub_outlined, size: 16.r, color: colors.primary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'أطراف العملية التوريدية',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpacing.hXs,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'طريقة السداد: ${saleType.label}',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
          AppSpacing.vMd,

          // 1. الطرف المورّد (الشبكة)
          ProcurementDetailsPartyTile(
            roleLabel: 'الجهة المورّدة (مزود الشبكة)',
            partyName: networkName,
            phoneNumber: request.networkPhone,
            logoUrl: request.networkLogo,
            iconGradient: [colors.skyAccent, colors.primary],
          ),

          // موصل التدفق
          Padding(
            padding: EdgeInsets.only(right: 20.w, top: 4.h, bottom: 4.h),
            child: Row(
              children: [
                Container(
                  width: 2.w,
                  height: 16.h,
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_downward_rounded,
                  size: 14.r,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                SizedBox(width: 6.w),
                Text(
                  'توريد كروت باقات الإنترنت',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),

          // 2. الطرف الطالب (نقطة البيع)
          ProcurementDetailsPartyTile(
            roleLabel: 'الجهة الطالبة (نقطة البيع)',
            partyName: posName,
            phoneNumber: request.posPhone,
            logoUrl: request.posLogo,
            iconGradient: [colors.emeraldDark, colors.emeraldDeep],
          ),
        ],
      ),
    );
  }
}
