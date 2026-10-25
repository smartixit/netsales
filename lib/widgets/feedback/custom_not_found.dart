import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class CustomNotFound extends StatelessWidget {
  const CustomNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomAppScaffold(
      useSurfaceMesh: true,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 56.r,
                color: colors.error,
              ),
              AppSpacing.vMd,
              Text(
                'الصفحة المطلوبة غير موجودة',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
