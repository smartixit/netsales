import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppFloatingButton extends StatefulWidget {
  const CustomAppFloatingButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
  });

  final VoidCallback onPressed;

  final IconData icon;

  @override
  State<CustomAppFloatingButton> createState() =>
      _CustomAppFloatingButtonState();
}

class _CustomAppFloatingButtonState extends State<CustomAppFloatingButton> {
  double _scale = 1.0;

  void _animate(bool pressed) {
    if (!mounted) return;
    setState(() {
      _scale = pressed ? 0.88 : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutBack,
      child: Container(
        width: 56.r,
        height: 56.r,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [colors.primary, colors.secondary],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: colors.shadow.withValues(alpha: .15),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Listener(
            onPointerDown: (_) => _animate(true),
            onPointerUp: (_) => _animate(false),
            onPointerCancel: (_) => _animate(false),
            child: InkWell(
              borderRadius: BorderRadius.circular(28.r),
              onTap: widget.onPressed,
              child: Icon(widget.icon, color: colors.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
