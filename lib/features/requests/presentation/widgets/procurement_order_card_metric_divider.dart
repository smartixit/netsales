import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProcurementOrderCardMetricDivider extends StatelessWidget {
  const ProcurementOrderCardMetricDivider({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.0,
      height: 28.h,
      color: color,
      margin: EdgeInsets.symmetric(horizontal: 4.r),
    );
  }
}
