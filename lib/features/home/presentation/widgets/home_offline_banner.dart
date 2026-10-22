import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ============================================================================
/// شريط التنبيه اللحظي لقطع الاتصال (HomeOfflineBanner)
/// ============================================================================
/// يظهر في أعلى الشاشة الرئيسية بانسيابية فور انقطاع الاتصال بالإنترنت
/// ويختفي تلقائياً عند استعادة الاتصال دون إزعاج المستخدم بنوافذ معرقلة.
class HomeOfflineBanner extends StatelessWidget {
  final bool isOffline;

  const HomeOfflineBanner({
    super.key,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedSize(
      duration: AppMotion.normal,
      curve: AppMotion.standard,
      child: isOffline
          ? Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding,
                vertical: AppSpacing.xs,
              ),
              color: colors.errorContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: colors.onErrorContainer,
                    size: 16.r,
                  ),
                  AppSpacing.hXs,
                  Flexible(
                    child: Text(
                      'أنت غير متصل بالإنترنت حالياً (الوضع غير المتصل)',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
