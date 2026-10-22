import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';

class SplashCircleVector extends StatelessWidget {
  const SplashCircleVector({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: -30,
          left: -20,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.04),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -60,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          right: 20,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.03),
            ),
          ),
        ),
      ],
    );
  }
}
