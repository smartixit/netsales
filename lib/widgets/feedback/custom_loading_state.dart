import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

class CustomLoadingState extends StatelessWidget {
  const CustomLoadingState({
    super.key,
    this.message,
    this.useSkeleton = false,
    this.skeleton,
  });

  final String? message;
  final bool useSkeleton;
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (useSkeleton && skeleton != null) {
      return skeleton!;
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120.w,
            height: 120.w,
            child: Lottie.asset(
              'assets/animations/loading.json',
              repeat: true,
            ),
          ),
          if (message != null) ...[
            AppSpacing.vMd,
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
