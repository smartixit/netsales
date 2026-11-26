import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';

class CustomCircleShape extends StatelessWidget {
  const CustomCircleShape({
    super.key,
    this.left ,
    this.top ,
    this.right ,
    this.bottom ,
    this.size = 150,
    this.color,
  });

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color != null
              ? color!.withValues(alpha: 0.05)
              : colors.executiveGoldAccent.withValues(alpha: 0.05),
        ),
      ),
    );
  }
}
