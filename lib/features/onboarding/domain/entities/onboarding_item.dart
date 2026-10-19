import 'package:flutter/widgets.dart';

/// كيان بيانات شريحة التعريف في جولة البداية
class OnboardingItem {
  final String title;
  final String description;
  final String badge;
  final IconData icon;
  final String? animationAsset;
  final String? imageAsset;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.badge,
    required this.icon,
    this.animationAsset,
    this.imageAsset,
  });
}
