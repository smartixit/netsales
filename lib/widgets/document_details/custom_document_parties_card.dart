import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/document_details/models/document_party_data.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

export 'package:netsales/widgets/document_details/models/document_party_data.dart';

/// بطاقة أطراف المعاملة والشراكة التوريدية الموحدة (CustomDocumentPartiesCard)
///
/// المرجع المعتمد لعرض طرفي المعاملة (المزود ونقطة البيع) في تفاصيل الطلبات والفواتير:
/// - حاوية بحواف AppRadius.card مع حدود ناعمة وظل متناسق.
/// - ترويسة بهوية المعاملة مع شارة طريقة السداد أو الصفة التعاقدية.
/// - عرض الطرف الأول (المورّد) وموصل التدفق التجاري والطرف الثاني (المشتري/نقطة البيع).
/// - زر اتصال تفاعلي مباشر برقم الهاتف مع حماية تامة ضد التجاوز.
class CustomDocumentPartiesCard extends StatelessWidget {
  const CustomDocumentPartiesCard({
    super.key,
    this.title = 'أطراف المعاملة التجارية',
    this.badgeText,
    required this.firstParty,
    required this.secondParty,
    this.flowLabel,
  });

  final String title;
  final String? badgeText;
  final DocumentPartyData firstParty;
  final DocumentPartyData secondParty;
  final String? flowLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          // ── ترويسة بطاقة الأطراف ──
          Row(
            children: [
              Icon(Icons.hub_outlined, size: 16.r, color: colors.primary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeText != null) ...[
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
                    badgeText!,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          AppSpacing.vSm,
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
          AppSpacing.vMd,

          // 1. الطرف الأول
          _DocumentPartyTile(party: firstParty),

          // موصل التدفق التجاري إن وجد
          if (flowLabel != null)
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
                    flowLabel!,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            SizedBox(height: 8.h),
          ],

          // 2. الطرف الثاني
          _DocumentPartyTile(party: secondParty),
        ],
      ),
    );
  }
}

class _DocumentPartyTile extends StatelessWidget {
  const _DocumentPartyTile({required this.party});

  final DocumentPartyData party;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = party.accentColor ?? colors.primary;
    final initials = TextFormatter.avatarInitial(party.name);

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // شعار الطرف
          CustomAvatarBadge(
            imageUrl: party.logoUrl,
            initials: initials,
            size: AvatarBadgeSize.sm,
            customDimension: 38.r,
          ),
          AppSpacing.hSm,

          // بيانات الاسم والصفة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  party.roleLabel,
                  style: AppTypography.caption.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 9.5.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  party.name,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (party.address != null &&
                    party.address!.trim().isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    party.address!.trim(),
                    style: AppTypography.caption.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 9.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // زر الاتصال المباشر إن توفر رقم هاتف
          if (party.phoneNumber != null &&
              party.phoneNumber!.trim().isNotEmpty) ...[
            AppSpacing.hSm,
            CustomButton.icon(
              icon: Icons.phone_outlined,
              backgroundColor: colors.surfaceContainer,
              size: AppButtonSize.small,
              shape: AppButtonShape.rounded,
              onPressed: () =>
                  UrlLauncherService.callPhone(party.phoneNumber!.trim()),
            ),
            // CustomInteractiveBounce(
            //   onTap: () =>

            //   child: Container(
            //     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            //     decoration: BoxDecoration(
            //       color: colors.surfaceContainerHigh,
            //       borderRadius: BorderRadius.circular(8.r),
            //       border: Border.all(
            //         color: colors.outlineVariant.withValues(alpha: 0.4),
            //       ),
            //     ),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(
            //           Icons.phone_outlined,
            //           size: 13.r,
            //           color: colors.primary,
            //         ),
            //         // SizedBox(width: 4.w),
            //         // Text(
            //         //   party.phoneNumber!.trim(),
            //         //   style: AppTypography.caption.copyWith(
            //         //     color: colors.onSurface,
            //         //     fontWeight: FontWeight.w700,
            //         //     fontSize: 10.sp,
            //         //   ),
            //         // ),
            // ],
            // ),
            // ),
            // ),
          ],
        ],
      ),
    );
  }
}
