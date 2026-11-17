import 'package:flutter/material.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة 404 موحدة بصرياً مع نظام الحالات المركزي.
class CustomNotFoundState extends StatelessWidget {
  const CustomNotFoundState({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      useSurfaceMesh: true,
      body: const CustomStateView.notFound(
        title: 'الصفحة المطلوبة غير موجودة',
        subtitle: 'قد يكون الرابط غير صحيح أو أن الصفحة لم تعد متاحة.',
        badgeLabel: '404 • NOT FOUND',
        icon: Icons.search_off_rounded,
        presentation: CustomStatePresentation.fullscreen,
      ),
    );
  }
}
