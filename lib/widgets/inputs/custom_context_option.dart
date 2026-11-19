import 'package:flutter/material.dart';

/// خيار سياق الهوية التنظيمية للمكون العام CustomContextSelector
class CustomContextOption {
  final int id;
  final String name;
  final String detail;
  final String? logoUrl;
  final String initial;
  final bool selected;
  final VoidCallback onTap;

  const CustomContextOption({
    required this.id,
    required this.name,
    required this.detail,
    this.logoUrl,
    required this.initial,
    required this.selected,
    required this.onTap,
  });
}
