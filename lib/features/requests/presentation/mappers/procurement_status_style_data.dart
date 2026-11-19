import 'package:flutter/material.dart';

/// بيانات التنسيق اللوني والظلال والأيقونات لحالة طلب التوريد
class ProcurementStatusStyleData {
  final LinearGradient iconGradient;
  final Color iconBorderColor;
  final Color iconShadowColor;
  final IconData statusIcon;

  const ProcurementStatusStyleData({
    required this.iconGradient,
    required this.iconBorderColor,
    required this.iconShadowColor,
    required this.statusIcon,
  });
}
