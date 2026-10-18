import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';

/// أنماط الأزرار المتاحة في النظام
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
  icon,
  floating,
  custom,
}

/// أحجام الأزرار القياسية
enum AppButtonSize {
  small,
  medium,
  large,
  custom,
}

/// الأشكال الهندسية للأزرار
enum AppButtonShape {
  rounded,
  pill,
  circle,
  square,
}

/// موضع الأيقونة بالنسبة للنص (للتوافقية العكسية مع معامل icon)
enum AppButtonIconPosition {
  start,
  end,
}

/// ============================================================================
/// كلاس الزر الموحد فائق المرونة والمخصص للإنتاج (Enterprise Unified Button)
/// ============================================================================
/// يجمع كافة أنواع الأزرار (أساسي، ثانوي، تحذيري، مفرغ، نصي، أيقونة، عائم)
/// يدعم prefix و suffix معاً (أيقونات أو Widgets)، والـ Scale Animation ومؤشر التحميل.
class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.shape = AppButtonShape.rounded,
    this.prefix,
    this.suffix,
    this.icon,
    this.iconPosition = AppButtonIconPosition.start,
    this.iconSize,
    this.loading = false,
    this.enabled = true,
    this.enableFeedback = true,
    this.enableScaleAnimation = true,
    this.scaleFactor = 0.95,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.gradient,
    this.shadow,
    this.textStyle,
    this.tooltip,
  });

  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final AppButtonShape shape;

  /// عنصر أو أيقونة في بداية الزر (IconData أو Widget)
  final dynamic prefix;

  /// عنصر أو أيقونة في نهاية الزر (IconData أو Widget مثل سهم أو شارة)
  final dynamic suffix;

  /// أيقونة افتراضية (للتوافقية العكسية - يوضع في البداية أو النهاية وفقاً لـ iconPosition)
  final dynamic icon;
  final AppButtonIconPosition iconPosition;
  final double? iconSize;

  final bool loading;
  final bool enabled;
  final bool enableFeedback;
  final bool enableScaleAnimation;
  final double scaleFactor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final Gradient? gradient;
  final List<BoxShadow>? shadow;
  final TextStyle? textStyle;
  final String? tooltip;

  // ---------------------------------------------------------------------------
  // Factory Constructors للوصول السريع والبديهي لكافة الأنماط
  // ---------------------------------------------------------------------------

  /// 1. زر أساسي (Primary) - بلون الهوية المتدرج أو المصمت
  factory CustomButton.primary({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    AppButtonShape shape = AppButtonShape.rounded,
    dynamic prefix,
    dynamic suffix,
    dynamic icon,
    AppButtonIconPosition iconPosition = AppButtonIconPosition.start,
    double? iconSize,
    bool loading = false,
    bool enabled = true,
    bool enableFeedback = true,
    bool enableScaleAnimation = true,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? backgroundColor,
    Color? foregroundColor,
    Gradient? gradient,
    List<BoxShadow>? shadow,
    TextStyle? textStyle,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      size: size,
      shape: shape,
      prefix: prefix,
      suffix: suffix,
      icon: icon,
      iconPosition: iconPosition,
      iconSize: iconSize,
      loading: loading,
      enabled: enabled,
      enableFeedback: enableFeedback,
      enableScaleAnimation: enableScaleAnimation,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      gradient: gradient,
      shadow: shadow,
      textStyle: textStyle,
      child: child,
    );
  }

  /// 2. زر ثانوي (Secondary) - خلفية هادئة متباينة
  factory CustomButton.secondary({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    AppButtonShape shape = AppButtonShape.rounded,
    dynamic prefix,
    dynamic suffix,
    dynamic icon,
    AppButtonIconPosition iconPosition = AppButtonIconPosition.start,
    double? iconSize,
    bool loading = false,
    bool enabled = true,
    bool enableFeedback = true,
    bool enableScaleAnimation = true,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? backgroundColor,
    Color? foregroundColor,
    List<BoxShadow>? shadow,
    TextStyle? textStyle,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      size: size,
      shape: shape,
      prefix: prefix,
      suffix: suffix,
      icon: icon,
      iconPosition: iconPosition,
      iconSize: iconSize,
      loading: loading,
      enabled: enabled,
      enableFeedback: enableFeedback,
      enableScaleAnimation: enableScaleAnimation,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shadow: shadow,
      textStyle: textStyle,
      child: child,
    );
  }

  /// 3. زر تفريغ خارجي (Outline) - شفاف مع حدود ملونة
  factory CustomButton.outline({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    AppButtonShape shape = AppButtonShape.rounded,
    dynamic prefix,
    dynamic suffix,
    dynamic icon,
    AppButtonIconPosition iconPosition = AppButtonIconPosition.start,
    double? iconSize,
    bool loading = false,
    bool enabled = true,
    bool enableFeedback = true,
    bool enableScaleAnimation = true,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? foregroundColor,
    Color? borderColor,
    double borderWidth = 1.5,
    TextStyle? textStyle,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.outline,
      size: size,
      shape: shape,
      prefix: prefix,
      suffix: suffix,
      icon: icon,
      iconPosition: iconPosition,
      iconSize: iconSize,
      loading: loading,
      enabled: enabled,
      enableFeedback: enableFeedback,
      enableScaleAnimation: enableScaleAnimation,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      textStyle: textStyle,
      child: child,
    );
  }

  /// 4. زر نصي (Text / Ghost) - بدون خلفية أو حدود
  factory CustomButton.text({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    AppButtonShape shape = AppButtonShape.rounded,
    dynamic prefix,
    dynamic suffix,
    dynamic icon,
    AppButtonIconPosition iconPosition = AppButtonIconPosition.start,
    double? iconSize,
    bool loading = false,
    bool enabled = true,
    bool enableFeedback = true,
    bool enableScaleAnimation = true,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? foregroundColor,
    TextStyle? textStyle,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.text,
      size: size,
      shape: shape,
      prefix: prefix,
      suffix: suffix,
      icon: icon,
      iconPosition: iconPosition,
      iconSize: iconSize,
      loading: loading,
      enabled: enabled,
      enableFeedback: enableFeedback,
      enableScaleAnimation: enableScaleAnimation,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      foregroundColor: foregroundColor,
      textStyle: textStyle,
      child: child,
    );
  }

  /// 5. زر تحذيري / خطر (Danger) - أحمر لعمليات الحذف والرفض
  factory CustomButton.danger({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    AppButtonShape shape = AppButtonShape.rounded,
    dynamic prefix,
    dynamic suffix,
    dynamic icon,
    AppButtonIconPosition iconPosition = AppButtonIconPosition.start,
    double? iconSize,
    bool loading = false,
    bool enabled = true,
    bool enableFeedback = true,
    bool enableScaleAnimation = true,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? backgroundColor,
    Color? foregroundColor,
    List<BoxShadow>? shadow,
    TextStyle? textStyle,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.danger,
      size: size,
      shape: shape,
      prefix: prefix,
      suffix: suffix,
      icon: icon,
      iconPosition: iconPosition,
      iconSize: iconSize,
      loading: loading,
      enabled: enabled,
      enableFeedback: enableFeedback,
      enableScaleAnimation: enableScaleAnimation,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shadow: shadow,
      textStyle: textStyle,
      child: child,
    );
  }

  /// 6. زر أيقونة مخصص (Icon) - مربع أو دائري
  factory CustomButton.icon({
    Key? key,
    required dynamic icon,
    required VoidCallback? onPressed,
    String? tooltip,
    AppButtonSize size = AppButtonSize.medium,
    AppButtonShape shape = AppButtonShape.rounded,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    double? borderWidth,
    double? iconSize,
    double? dimension,
    bool loading = false,
    bool enabled = true,
    bool enableFeedback = true,
    bool enableScaleAnimation = true,
    List<BoxShadow>? shadow,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      variant: AppButtonVariant.icon,
      size: size,
      shape: shape,
      icon: icon,
      iconSize: iconSize,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      width: dimension,
      height: dimension,
      loading: loading,
      enabled: enabled,
      enableFeedback: enableFeedback,
      enableScaleAnimation: enableScaleAnimation,
      shadow: shadow,
    );
  }

  /// 7. زر عائم (Floating Action Button) - دائري مع ظل بارز وتدرج
  factory CustomButton.floating({
    Key? key,
    required dynamic icon,
    required VoidCallback? onPressed,
    String? tooltip,
    double size = 56.0,
    Gradient? gradient,
    Color? backgroundColor,
    Color? foregroundColor,
    double? iconSize,
    bool loading = false,
    bool enabled = true,
    bool enableFeedback = true,
    bool enableScaleAnimation = true,
    List<BoxShadow>? shadow,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      variant: AppButtonVariant.floating,
      shape: AppButtonShape.circle,
      icon: icon,
      iconSize: iconSize,
      tooltip: tooltip,
      width: size,
      height: size,
      gradient: gradient,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      loading: loading,
      enabled: enabled,
      enableFeedback: enableFeedback,
      enableScaleAnimation: enableScaleAnimation,
      shadow: shadow,
    );
  }

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  double _scale = 1.0;

  void _animate(bool pressed) {
    if (!widget.enableScaleAnimation || !mounted) return;
    setState(() {
      _scale = pressed ? widget.scaleFactor : 1.0;
    });
  }

  void _handleTap() {
    if (!widget.enabled || widget.loading || widget.onPressed == null) return;
    if (widget.enableFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  // ---------------------------------------------------------------------------
  // حساب الأبعاد ودرجات التدوير ديناميكياً
  // ---------------------------------------------------------------------------

  double get _effectiveHeight {
    if (widget.height != null) return widget.height!;
    if (widget.variant == AppButtonVariant.floating) return 56.r;
    if (widget.variant == AppButtonVariant.icon) {
      return switch (widget.size) {
        AppButtonSize.small => 40.h,
        AppButtonSize.medium => 52.h,
        AppButtonSize.large => 64.h,
        AppButtonSize.custom => 52.h,
      };
    }
    return switch (widget.size) {
      AppButtonSize.small => 40.h,
      AppButtonSize.medium => 56.h,
      AppButtonSize.large => 68.h,
      AppButtonSize.custom => 56.h,
    };
  }

  BorderRadius get _effectiveBorderRadius {
    if (widget.shape == AppButtonShape.circle) {
      return BorderRadius.circular(999.r);
    }
    if (widget.shape == AppButtonShape.pill) {
      return BorderRadius.circular(999.r);
    }
    if (widget.shape == AppButtonShape.square) {
      return BorderRadius.zero;
    }
    if (widget.borderRadius != null) {
      return BorderRadius.circular(widget.borderRadius!.r);
    }
    return switch (widget.size) {
      AppButtonSize.small => BorderRadius.circular(AppRadius.sm),
      AppButtonSize.medium => BorderRadius.circular(AppRadius.md),
      AppButtonSize.large => BorderRadius.circular(AppRadius.lg),
      AppButtonSize.custom => BorderRadius.circular(AppRadius.button),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDisabled = !widget.enabled || widget.loading;

    // 1. حساب الألوان التلقائية وفقاً للنمط
    Color? resolvedBgColor;
    Color resolvedFgColor;
    Gradient? resolvedGradient;
    Border? resolvedBorder;
    List<BoxShadow>? resolvedShadow = widget.shadow;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        resolvedGradient = widget.gradient ??
            LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [colors.primary, colors.secondary],
            );
        resolvedBgColor = widget.backgroundColor ?? colors.primary;
        resolvedFgColor = widget.foregroundColor ?? colors.onPrimary;
        resolvedShadow ??= [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: colors.primary.withValues(alpha: 0.22),
          ),
        ];
        break;

      case AppButtonVariant.secondary:
        resolvedBgColor = widget.backgroundColor ?? colors.secondaryContainer;
        resolvedFgColor = widget.foregroundColor ?? colors.onSecondaryContainer;
        break;

      case AppButtonVariant.danger:
        resolvedBgColor = widget.backgroundColor ?? colors.error;
        resolvedFgColor = widget.foregroundColor ?? colors.onError;
        resolvedShadow ??= [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: colors.error.withValues(alpha: 0.22),
          ),
        ];
        break;

      case AppButtonVariant.outline:
        resolvedBgColor = widget.backgroundColor ?? Colors.transparent;
        resolvedFgColor = widget.foregroundColor ?? colors.primary;
        resolvedBorder = Border.all(
          color: widget.borderColor ?? colors.primary,
          width: widget.borderWidth ?? 1.5,
        );
        break;

      case AppButtonVariant.text:
        resolvedBgColor = Colors.transparent;
        resolvedFgColor = widget.foregroundColor ?? colors.primary;
        break;

      case AppButtonVariant.icon:
        resolvedBgColor = widget.backgroundColor ?? colors.surfaceContainerHighest;
        resolvedFgColor = widget.foregroundColor ?? colors.primary;
        if (widget.borderColor != null) {
          resolvedBorder = Border.all(
            color: widget.borderColor!,
            width: widget.borderWidth ?? 1.0,
          );
        }
        break;

      case AppButtonVariant.floating:
        resolvedGradient = widget.gradient ??
            LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [colors.primary, colors.secondary],
            );
        resolvedBgColor = widget.backgroundColor ?? colors.primary;
        resolvedFgColor = widget.foregroundColor ?? colors.onPrimary;
        resolvedShadow ??= [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: colors.shadow.withValues(alpha: 0.20),
          ),
        ];
        break;

      case AppButtonVariant.custom:
        resolvedBgColor = widget.backgroundColor ?? colors.primary;
        resolvedFgColor = widget.foregroundColor ?? colors.onPrimary;
        resolvedGradient = widget.gradient;
        if (widget.borderColor != null) {
          resolvedBorder = Border.all(
            color: widget.borderColor!,
            width: widget.borderWidth ?? 1.0,
          );
        }
        break;
    }

    // 2. بناء المحتوى الداخلي للزر (نص، prefix, suffix، مؤشر تحميل)
    Widget content;
    if (widget.loading) {
      final spinnerSize = (widget.size == AppButtonSize.small ? 18.0 : 22.0).r;
      content = Center(
        child: SizedBox(
          width: spinnerSize,
          height: spinnerSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(resolvedFgColor),
          ),
        ),
      );
    } else if (widget.child != null) {
      content = Center(child: widget.child);
    } else if (widget.variant == AppButtonVariant.icon || widget.variant == AppButtonVariant.floating) {
      content = Center(child: _buildItemWidget(widget.icon, resolvedFgColor));
    } else {
      final textWidget = widget.text != null
          ? Text(
              widget.text!,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: widget.textStyle ??
                  theme.textTheme.labelLarge?.copyWith(
                    color: resolvedFgColor,
                    fontWeight: FontWeight.w700,
                    fontSize: widget.size == AppButtonSize.small ? 13.sp : 15.sp,
                  ),
            )
          : null;

      // استخراج الـ prefix والـ suffix بمرونة
      final dynamic resolvedPrefixSource = widget.prefix ??
          (widget.iconPosition == AppButtonIconPosition.start ? widget.icon : null);
      final dynamic resolvedSuffixSource = widget.suffix ??
          (widget.iconPosition == AppButtonIconPosition.end ? widget.icon : null);

      final Widget? prefixWidget = _buildItemWidget(resolvedPrefixSource, resolvedFgColor);
      final Widget? suffixWidget = _buildItemWidget(resolvedSuffixSource, resolvedFgColor);

      if (prefixWidget != null || suffixWidget != null) {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixWidget != null) ...[
              prefixWidget,
              AppSpacing.hSm,
            ],
            if (textWidget != null)
              Flexible(child: textWidget),
            if (suffixWidget != null) ...[
              AppSpacing.hSm,
              suffixWidget,
            ],
          ],
        );
      } else if (textWidget != null) {
        content = Center(child: textWidget);
      } else {
        content = const SizedBox.shrink();
      }
    }

    // 3. تحديد العرض والارتفاع
    double? effectiveWidth = widget.width;
    if (effectiveWidth == null) {
      if (widget.variant == AppButtonVariant.icon || widget.variant == AppButtonVariant.floating) {
        effectiveWidth = _effectiveHeight;
      } else if (widget.variant == AppButtonVariant.text) {
        effectiveWidth = null; // Auto-fit
      } else {
        effectiveWidth = double.infinity;
      }
    }

    Widget buttonBody = AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.55 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: widget.margin,
          width: effectiveWidth,
          height: _effectiveHeight,
          decoration: BoxDecoration(
            gradient: resolvedGradient,
            color: resolvedGradient == null ? resolvedBgColor : null,
            borderRadius: _effectiveBorderRadius,
            border: resolvedBorder,
            boxShadow: resolvedShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: _effectiveBorderRadius,
              onTap: isDisabled ? null : _handleTap,
              child: Padding(
                padding: widget.padding ??
                    (widget.variant == AppButtonVariant.text
                        ? EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs)
                        : EdgeInsets.symmetric(horizontal: AppSpacing.md)),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );

    // إضافة مستمع اللمس للـ Scale Animation
    if (widget.enableScaleAnimation && !isDisabled) {
      buttonBody = Listener(
        onPointerDown: (_) => _animate(true),
        onPointerUp: (_) => _animate(false),
        onPointerCancel: (_) => _animate(false),
        child: buttonBody,
      );
    }

    // إضافة Tooltip إن وجد
    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      buttonBody = Tooltip(message: widget.tooltip!, child: buttonBody);
    }

    return buttonBody;
  }

  Widget? _buildItemWidget(dynamic item, Color fallbackColor) {
    if (item == null) return null;
    if (item is IconData) {
      final size = widget.iconSize ??
          (widget.size == AppButtonSize.small ? 18.sp : (widget.variant == AppButtonVariant.icon ? 26.sp : 20.sp));
      return Icon(item, color: fallbackColor, size: size);
    }
    if (item is Widget) {
      return item;
    }
    return null;
  }
}
