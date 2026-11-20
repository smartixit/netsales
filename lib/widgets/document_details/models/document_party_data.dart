import 'package:flutter/material.dart';

/// بيانات الطرف التجاري في بطاقة أطراف المعاملة
class DocumentPartyData {
  const DocumentPartyData({
    required this.roleLabel,
    required this.name,
    this.phoneNumber,
    this.logoUrl,
    this.address,
    this.accentColor,
    this.iconGradient,
  });

  final String roleLabel;
  final String name;
  final String? phoneNumber;
  final String? logoUrl;
  final String? address;
  final Color? accentColor;
  final List<Color>? iconGradient;
}
