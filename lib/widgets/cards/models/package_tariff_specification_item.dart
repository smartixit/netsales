import 'package:flutter/material.dart';

/// عنصر مواصفات فردي لبطاقة تسعير الباقة الموحدة (Universal Package Tariff Specification)
class PackageTariffSpecificationItem {
  const PackageTariffSpecificationItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
