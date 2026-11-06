import 'package:flutter/foundation.dart';

@immutable
class DashboardUserProfile {
  const DashboardUserProfile({
    required this.name,
    this.subtitle,
    this.avatarUrl,
    this.initials,
  });

  final String name;
  final String? subtitle;
  final String? avatarUrl;
  final String? initials;
}
