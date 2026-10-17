import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';

enum AppButtonSize { small, medium, large }

class CustomAppButton extends StatefulWidget {
  const CustomAppButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.enabled = true,
    this.loading = false,
    this.gradient,
    this.backgroundColor,
  });

  final Widget child;

  final VoidCallback? onPressed;

  final AppButtonSize size;

  final bool enabled;

  final bool loading;

  final Gradient? gradient;

  final Color? backgroundColor;

  @override
  State<CustomAppButton> createState() => _CustomAppButtonState();
}

class _CustomAppButtonState extends State<CustomAppButton> {
  double _scale = 1.0;

  void _animate(bool pressed) {
    if (!mounted) return;

    setState(() {
      _scale = pressed ? 0.96 : 1.0;
    });
  }

  double get height {
    return switch (widget.size) {
      AppButtonSize.small => 40.h,
      AppButtonSize.medium => 60.h,
      AppButtonSize.large => 80.h,
    };
  }

  double get radius {
    return switch (widget.size) {
      AppButtonSize.small => AppRadius.sm,
      AppButtonSize.medium => AppRadius.md,
      AppButtonSize.large => AppRadius.lg,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final disabled = !widget.enabled || widget.loading;

    return AnimatedScale(
      scale: _scale,

      duration: const Duration(milliseconds: 120),

      curve: Curves.easeOutBack,

      child: Opacity(
        opacity: disabled ? .55 : 1,

        child: SizedBox(
          height: height,

          width: double.infinity,

          child: Listener(
            onPointerDown: disabled ? null : (_) => _animate(true),

            onPointerUp: disabled ? null : (_) => _animate(false),

            onPointerCancel: disabled ? null : (_) => _animate(false),

            child: Container(
              decoration: BoxDecoration(
                gradient: widget.gradient,

                color: widget.gradient == null
                    ? widget.backgroundColor ?? theme.colorScheme.primary
                    : null,

                borderRadius: BorderRadius.circular(radius),

                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,

                    offset: const Offset(0, 8),

                    color: theme.colorScheme.shadow.withValues(alpha: .12),
                  ),
                ],
              ),

              child: Material(
                color: Colors.transparent,

                child: InkWell(
                  borderRadius: BorderRadius.circular(radius),

                  onTap: disabled ? null : widget.onPressed,

                  child: Center(
                    child: widget.loading
                        ? SizedBox(
                            width: 22.w,
                            height: 22.h,

                            child: CircularProgressIndicator(
                              strokeWidth: 2,

                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
