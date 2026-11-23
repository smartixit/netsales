import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';

/// شريط الهوية اللونية الجانبي لبطاقة باقة الكروت (Package Card Spine)
class PackageCardSpine extends StatelessWidget {
  const PackageCardSpine({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.xs + AppSpacing.xxs,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(AppRadius.card),
        ),
      ),
    );
  }
}
