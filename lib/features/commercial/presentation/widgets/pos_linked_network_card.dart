import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة الشبكة المزودة التفاعلية المعروضة لنقطة البيع
class PosLinkedNetworkCard extends StatelessWidget {
  const PosLinkedNetworkCard({super.key, required this.link});

  final NetworkPosLinkEntity link;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final network = link.network;

    final isActive = link.status;
    final statusColor = isActive ? colors.success : colors.error;

    return CustomInteractiveBounce(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: Row(
          children: [
            // 1. شعار أو أيقونة الشبكة
            if (network?.networkProfileLogoUrl != null &&
                network!.networkProfileLogoUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: CustomCachedImage(
                  url: network.networkProfileLogoUrl!,
                  width: 48.r,
                  height: 48.r,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.hub_rounded,
                  color: colors.secondary,
                  size: 26.r,
                ),
              ),

            AppSpacing.hMd,

            // 2. اسم الشبكة ومعلوماتها
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network?.networkName ?? 'مزود شبكة #${link.networkId}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14.r,
                        color: colors.onSurfaceVariant,
                      ),
                      AppSpacing.hXxs,
                      Text(
                        network?.networkPhoneNumber.isNotEmpty == true
                            ? network!.networkPhoneNumber
                            : 'لا يوجد هاتف',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (network?.networkAddress != null &&
                      network!.networkAddress!.isNotEmpty) ...[
                    AppSpacing.vXxs,
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.r,
                          color: colors.onSurfaceVariant,
                        ),
                        AppSpacing.hXxs,
                        Expanded(
                          child: Text(
                            network.networkAddress!,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
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

            AppSpacing.hSm,

            // 3. شارة حالة الشراكة
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpacing.hXxs,
                  Text(
                    isActive ? 'نشط' : 'معطل',
                    style: AppTypography.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
