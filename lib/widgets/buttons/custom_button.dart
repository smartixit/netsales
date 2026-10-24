import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';

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

/// أحجام الأزرار القياسية المتوافقة مع ScreenUtil
enum AppButtonSize { small, medium, large, custom }

/// الأشكال الهندسية للأزرار
enum AppButtonShape { rounded, pill, circle, square }

/// موضع الأيقونة بالنسبة للنص
enum AppButtonIconPosition { start, end }

/// ============================================================================
/// كلاس الزر الموحد فائق المرونة والمخصص للإنتاج (Enterprise Unified Button)
/// ============================================================================
/// مدمج كلياً مع:
/// - AppRadius & AppSpacing (core/constants)
/// - AppElevation, AppMotion & AppTypography (core/themes)
/// - CustomInteractiveBounce (micro-interaction scale)
/// - ScreenUtil (.h, .w, .sp, .r) لكافة الأبعاد
class CustomButton extends StatelessWidget {
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

  /// أيقونة افتراضية (للتوافقية العكسية - توضع في البداية أو النهاية وفقاً لـ iconPosition)
  final dynamic icon;
  final AppButtonIconPosition iconPosition;
  final double? iconSize;

  final bool loading;
  final bool enabled;
  final bool enableFeedback;
  final bool enableScaleAnimation;
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

  /// 1. زر أساسي (Primary)
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
  }) => _create(
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

  /// 2. زر ثانوي (Secondary)
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
  }) => _create(
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

  /// 3. زر مفرغ بحدود خارجية (Outline)
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
    double? borderWidth,
    TextStyle? textStyle,
  }) => _create(
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
    borderWidth: borderWidth ?? 1.5.w,
    textStyle: textStyle,
    child: child,
  );

  /// 4. زر نصي (Text / Ghost)
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
  }) => _create(
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
    foregroundColor: foregroundColor ?? Get.context!.colors.primary,
    textStyle: textStyle,
    child: child,
  );

  /// 5. زر خطر / تحذيري (Danger)
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
  }) => _create(
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

  /// 6. زر أيقونة مخصص (Icon)
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
  }) => _create(
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

  /// 7. زر عائم دائري (Floating Action Button)
  factory CustomButton.floating({
    Key? key,
    required dynamic icon,
    required VoidCallback? onPressed,
    String? tooltip,
    double? size,
    Gradient? gradient,
    Color? backgroundColor,
    Color? foregroundColor,
    double? iconSize,
    bool loading = false,
    bool enabled = true,
    bool enableFeedback = true,
    bool enableScaleAnimation = true,
    List<BoxShadow>? shadow,
  }) => _create(
    key: key,
    onPressed: onPressed,
    variant: AppButtonVariant.floating,
    shape: AppButtonShape.circle,
    icon: icon,
    iconSize: iconSize,
    tooltip: tooltip,
    width: size ?? 56.r,
    height: size ?? 56.r,
    gradient: gradient,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    loading: loading,
    enabled: enabled,
    enableFeedback: enableFeedback,
    enableScaleAnimation: enableScaleAnimation,
    shadow: shadow,
  );

  /// مساعد داخلي لمنع تكرار كود إنشاء الكائن عبر الـ Factory Constructors
  static CustomButton _create({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    required AppButtonVariant variant,
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
    Color? borderColor,
    double? borderWidth,
    Gradient? gradient,
    List<BoxShadow>? shadow,
    TextStyle? textStyle,
    String? tooltip,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: variant,
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
      borderColor: borderColor,
      borderWidth: borderWidth,
      gradient: gradient,
      shadow: shadow,
      textStyle: textStyle,
      tooltip: tooltip,
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // حساب الأبعاد ودرجات التدوير ديناميكياً مع ScreenUtil & AppRadius
  // ---------------------------------------------------------------------------

  double get _effectiveHeight {
    if (height != null) return height!;
    if (variant == AppButtonVariant.floating) return 56.r;
    if (variant == AppButtonVariant.icon) {
      return switch (size) {
        AppButtonSize.small => 40.h,
        AppButtonSize.medium => 52.h,
        AppButtonSize.large => 64.h,
        AppButtonSize.custom => 52.h,
      };
    }
    return switch (size) {
      AppButtonSize.small => 40.h,
      AppButtonSize.medium => 56.h,
      AppButtonSize.large => 68.h,
      AppButtonSize.custom => 56.h,
    };
  }

  BorderRadius get _effectiveBorderRadius {
    if (shape == AppButtonShape.circle || shape == AppButtonShape.pill) {
      return AppRadius.fullRadius;
    }
    if (shape == AppButtonShape.square) {
      return AppRadius.noneRadius;
    }
    if (borderRadius != null) {
      return BorderRadius.circular(borderRadius!.r);
    }
    return switch (size) {
      AppButtonSize.small => AppRadius.smRadius,
      AppButtonSize.medium => AppRadius.mdRadius,
      AppButtonSize.large => AppRadius.lgRadius,
      AppButtonSize.custom => BorderRadius.circular(AppRadius.button),
    };
  }

  void _handleTap() {
    if (!enabled || loading || onPressed == null) return;
    if (enableFeedback) {
      HapticFeedback.lightImpact();
    }
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDisabled = !enabled || loading;

    // 1. حساب الألوان والظلال عبر AppElevation ونظام الثيمات
    Color? resolvedBgColor;
    Color resolvedFgColor;
    Gradient? resolvedGradient;
    Border? resolvedBorder;
    List<BoxShadow>? resolvedShadow = shadow;

    switch (variant) {
      case AppButtonVariant.primary:
        resolvedGradient =
            gradient ??
            LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [colors.primary, colors.secondary],
            );
        resolvedBgColor = backgroundColor ?? colors.primary;
        resolvedFgColor = foregroundColor ?? colors.onPrimary;
        resolvedShadow ??= AppElevation.tinted(
          context,
          colors.primary,
          alpha: 0.22,
          blur: 16.r,
          dy: 6.h,
        );
        break;

      case AppButtonVariant.secondary:
        resolvedBgColor = backgroundColor ?? colors.secondaryContainer;
        resolvedFgColor = foregroundColor ?? colors.onSecondaryContainer;
        break;

      case AppButtonVariant.danger:
        resolvedBgColor = backgroundColor ?? colors.error;
        resolvedFgColor = foregroundColor ?? colors.onError;
        resolvedShadow ??= AppElevation.tinted(
          context,
          colors.error,
          alpha: 0.22,
          blur: 16.r,
          dy: 6.h,
        );
        break;

      case AppButtonVariant.outline:
        resolvedBgColor = backgroundColor ?? Colors.transparent;
        resolvedFgColor = foregroundColor ?? colors.primary;
        resolvedBorder = Border.all(
          color: borderColor ?? colors.primary,
          width: borderWidth ?? 1.5.w,
        );
        break;

      case AppButtonVariant.text:
        resolvedBgColor = Colors.transparent;
        resolvedFgColor = foregroundColor ?? colors.primary;
        break;

      case AppButtonVariant.icon:
        resolvedBgColor = backgroundColor ?? colors.surfaceContainerHighest;
        resolvedFgColor = foregroundColor ?? colors.primary;
        if (borderColor != null) {
          resolvedBorder = Border.all(
            color: borderColor!,
            width: borderWidth ?? 1.0.w,
          );
        }
        break;

      case AppButtonVariant.floating:
        resolvedGradient =
            gradient ??
            LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [colors.primary, colors.secondary],
            );
        resolvedBgColor = backgroundColor ?? colors.primary;
        resolvedFgColor = foregroundColor ?? colors.onPrimary;
        resolvedShadow ??= AppElevation.level4(context);
        break;

      case AppButtonVariant.custom:
        resolvedBgColor = backgroundColor ?? colors.primary;
        resolvedFgColor = foregroundColor ?? colors.onPrimary;
        resolvedGradient = gradient;
        if (borderColor != null) {
          resolvedBorder = Border.all(
            color: borderColor!,
            width: borderWidth ?? 1.0.w,
          );
        }
        break;
    }

    // 2. بناء المحتوى مع AppTypography و ScreenUtil
    Widget content;
    if (loading) {
      final spinnerSize = (size == AppButtonSize.small ? 18.0 : 22.0).r;
      content = Center(
        child: SizedBox(
          width: spinnerSize,
          height: spinnerSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.2.w,
            valueColor: AlwaysStoppedAnimation<Color>(resolvedFgColor),
          ),
        ),
      );
    } else if (child != null) {
      content = Center(child: child);
    } else if (variant == AppButtonVariant.icon ||
        variant == AppButtonVariant.floating) {
      content = Center(child: _buildItemWidget(icon, resolvedFgColor));
    } else {
      final textWidget = text != null
          ? Text(
              text!,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style:
                  textStyle ??
                  (size == AppButtonSize.small
                          ? AppTypography.buttonSmall
                          : (size == AppButtonSize.large
                                ? AppTypography.buttonMedium
                                : AppTypography.buttonMedium))
                      .copyWith(color: resolvedFgColor),
            )
          : null;

      final dynamic resolvedPrefixSource =
          prefix ?? (iconPosition == AppButtonIconPosition.start ? icon : null);
      final dynamic resolvedSuffixSource =
          suffix ?? (iconPosition == AppButtonIconPosition.end ? icon : null);

      final Widget? prefixWidget = _buildItemWidget(
        resolvedPrefixSource,
        resolvedFgColor,
      );
      final Widget? suffixWidget = _buildItemWidget(
        resolvedSuffixSource,
        resolvedFgColor,
      );

      if (prefixWidget != null || suffixWidget != null) {
        if (textWidget == null) {
          content = Center(child: prefixWidget ?? suffixWidget);
        } else {
          content = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixWidget != null) ...[prefixWidget, AppSpacing.hSm],
              Flexible(child: textWidget),
              if (suffixWidget != null) ...[AppSpacing.hSm, suffixWidget],
            ],
          );
        }
      } else if (textWidget != null) {
        content = Center(child: textWidget);
      } else {
        content = const SizedBox.shrink();
      }
    }

    // 3. تحديد العرض النهائي
    double? effectiveWidth = width;
    if (effectiveWidth == null) {
      if (variant == AppButtonVariant.icon ||
          variant == AppButtonVariant.floating) {
        effectiveWidth = _effectiveHeight;
      } else if (variant == AppButtonVariant.text ||
          size == AppButtonSize.small) {
        effectiveWidth = null;
      } else {
        effectiveWidth = double.infinity;
      }
    }

    // 4. بناء هيكل الزر مع الحواف والظلال والتأثيرات
    Widget buttonBody = AnimatedOpacity(
      opacity: isDisabled ? 0.55 : 1.0,
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      child: Container(
        margin: margin,
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
            onTap: (enableScaleAnimation && !isDisabled)
                ? null
                : (isDisabled ? null : _handleTap),
            child: Padding(
              padding:
                  padding ??
                  (variant == AppButtonVariant.icon ||
                          variant == AppButtonVariant.floating
                      ? EdgeInsets.zero
                      : (variant == AppButtonVariant.text
                          ? EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            )
                          : EdgeInsets.symmetric(
                              horizontal: AppSpacing.buttonPaddingH / 1.5,
                            ))),
              child: content,
            ),
          ),
        ),
      ),
    );

    // 5. ربط تفاعل اللمس النابض مع CustomInteractiveBounce من lib/widgets
    if (enableScaleAnimation && !isDisabled) {
      buttonBody = CustomInteractiveBounce(
        onTap: _handleTap,
        child: buttonBody,
      );
    }

    // 6. إضافة Tooltip إن وجد
    if (tooltip != null && tooltip!.isNotEmpty) {
      buttonBody = Tooltip(message: tooltip!, child: buttonBody);
    }

    return buttonBody;
  }

  Widget? _buildItemWidget(dynamic item, Color fallbackColor) {
    if (item == null) return null;
    if (item is IconData) {
      final size =
          iconSize ??
          (this.size == AppButtonSize.small
              ? 18.sp
              : (variant == AppButtonVariant.icon ? 26.sp : 20.sp));
      return Icon(item, color: fallbackColor, size: size);
    }
    if (item is Widget) {
      return item;
    }
    return null;
  }
}
