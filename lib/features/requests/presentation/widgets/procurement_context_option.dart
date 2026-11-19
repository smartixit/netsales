import 'package:flutter/foundation.dart';

class ProcurementContextOption {
  const ProcurementContextOption({
    required this.id,
    required this.name,
    required this.detail,
    required this.logoUrl,
    required this.initial,
    required this.selected,
    required this.onTap,
  });

  final int id;
  final String name;
  final String detail;
  final String? logoUrl;
  final String initial;
  final bool selected;
  final VoidCallback onTap;
}
