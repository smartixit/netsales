import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// شريط اختيار الشبكة المزودة للحساب الجاري (PosNetworkSelectorCard)
/// ============================================================================
/// يتيح لوكيل نقطة البيع التبديل بين الشبكات المزودة المرتبطة به لفحص حسابه
/// الجاري المنفصل 100% مع كل شبكة على حدة، منعاً لأي خلط في الحسابات أو جمع الأرصدة.
class PosNetworkSelectorCard extends StatelessWidget {
  final List<NetworkPosEntity> networks;
  final NetworkPosEntity? selectedNetwork;
  final ValueChanged<NetworkPosEntity> onSelectNetwork;

  const PosNetworkSelectorCard({
    super.key,
    required this.networks,
    required this.selectedNetwork,
    required this.onSelectNetwork,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (networks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الشبكة المزودة (العلاقة الثنائية)',
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'حسابات جارية مستقلة',
              style: AppTypography.labelSmall.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        SizedBox(
          height: 52.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: networks.length,
            separatorBuilder: (context, index) => AppSpacing.hSm,
            itemBuilder: (context, index) {
              final item = networks[index];
              final isSelected = item.networkId == selectedNetwork?.networkId;
              final netName = item.networkName ?? 'شبكة #${item.networkId}';

              return CustomInteractiveBounce(
                onTap: () => onSelectNetwork(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primaryContainer.withValues(alpha: 0.6)
                        : colors.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.outlineVariant.withValues(alpha: 0.35),
                      width: isSelected ? 1.5.w : 0.8.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          color: isSelected ? colors.primary : colors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.wifi_tethering_rounded,
                            size: 16.r,
                            color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      AppSpacing.hSm,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            netName,
                            style: AppTypography.labelMedium.copyWith(
                              color: isSelected ? colors.primary : colors.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          Text(
                            item.isActive ? 'ارتباط نشط' : 'غير نشط',
                            style: AppTypography.labelSmall.copyWith(
                              color: item.isActive ? colors.success : colors.onSurfaceVariant,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
