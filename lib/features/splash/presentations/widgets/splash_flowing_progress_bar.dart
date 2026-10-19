import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_motion.dart';

/// شريط تحميل انسيابي متحرك ومستمر (Indeterminate Flowing Progress Bar)
/// يتحرك بسلاسة فيزيائية دون نسب رقمية ويعتمد حصرياً على رموز الـ Core الموحدة.
class SplashFlowingProgressBar extends StatefulWidget {
  const SplashFlowingProgressBar({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<SplashFlowingProgressBar> createState() =>
      _SplashFlowingProgressBarState();
}

class _SplashFlowingProgressBarState extends State<SplashFlowingProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.shimmer,
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.standard,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalWidth = widget.width ?? 140.w;
    final barHeight = widget.height ?? 4.h;
    final sliderWidth = totalWidth * 0.42;

    return Container(
      width: totalWidth,
      height: barHeight,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final travelDistance = totalWidth - sliderWidth;
          final progress = AppMotion.disabled(context) ? 0.5 : _animation.value;
          final offset = travelDistance * progress;

          return Stack(
            children: [
              Positioned(
                left: offset,
                top: 0,
                bottom: 0,
                width: sliderWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.flowingBar(context),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: AppElevation.glow(
                      context,
                      colors.primary,
                      alpha: 0.35,
                      blur: 8,
                      spread: 1,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
