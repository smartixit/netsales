import 'package:flutter/material.dart';

/// عنصر مواصفات فردي لباقة التوريد
class ProcurementPackageSpecificationItem {
  const ProcurementPackageSpecificationItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
