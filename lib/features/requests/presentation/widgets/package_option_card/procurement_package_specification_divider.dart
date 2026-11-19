import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// فاصل رأسي بين مواصفات الباقة
class ProcurementPackageSpecificationDivider extends StatelessWidget {
  const ProcurementPackageSpecificationDivider({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 49.r,
      color: color.withValues(alpha: .72),
    );
  }
}
