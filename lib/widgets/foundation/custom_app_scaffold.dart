import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// الهيكل القياسي الموحد لكافة شاشات نظام NetSales (CustomAppScaffold)
///
/// يعالج المشكلات البصرية ويزيل تكرار الأكواد:
/// 1. مظهر Edge-to-Edge: امتداد الخلفية الشبكية [surfaceMesh] خلف الـ AppBar لمنع أي حد قاطع عند التمرير.
/// 2. تأثير زجاجي بلوري (Frosted Glass Blur): تلاشٍ ناعم للبطاقات والمحتوى عند انزلاقه خلف زر الرجوع.
/// 3. زر الرجوع الموحد: اعتماد [CustomButton.icon] بالمقاسات القياسية المعتمدة في AGENTS.md.
/// 4. شريط العنوان التلقائي: بناء ترويسة العنوان والعنوان الفرعي والأزرار الجانبية دون الحاجة لـ AppBar يدوي.
/// 5. التجاوب الفوري: دعم [maxWidth] المدمج لتقييد العرض في الشاشات الكبيرة تلقائياً.
class CustomAppScaffold extends StatelessWidget {
  const CustomAppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.appBarTitle,
    this.appBarSubtitle,
    this.appBarTitleWidget,
    this.appBarBg,
    this.centerTitle,
    this.showBackButton = false,
    this.onBackPressed,
    this.leading,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.useSurfaceMesh = false,
    this.backgroundGradient,
    this.extendBodyBehindAppBar,
    this.enableGlassAppBar = true,
    this.safeArea = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.maxWidth,
    this.contentPadding,
    this.resizeToAvoidBottomInset,
  });

  /// محتوى الشاشة الأساسي
  final Widget body;

  /// كائن AppBar مخصص بالكامل (في حال رغبة الشاشة بتجاوز البناء التلقائي)
  final PreferredSizeWidget? appBar;

  /// عنوان الشاشة النصي في شريط العنوان
  final String? appBarTitle;

  /// العنوان الفرعي التوضيحي أسفل العنوان الأساسي
  final String? appBarSubtitle;

  /// ودجت عنوان مخصص
  final Widget? appBarTitleWidget;

  /// لون خلفية الـ AppBar (افتراضياً شفاف تماماً)
  final Color? appBarBg;

  /// توسيط العنوان
  final bool? centerTitle;

  /// إظهار زر الرجوع القياسي الموحد
  final bool showBackButton;

  /// إجراء مخصص عند الضغط على زر الرجوع (افتراضياً Get.back)
  final VoidCallback? onBackPressed;

  /// ودجت leading مخصص بالكامل
  final Widget? leading;

  /// قائمة أزرار وإجراءات الـ AppBar في الطرف الآخر
  final List<Widget>? actions;

  /// الشريط السفلي
  final Widget? bottomNavigationBar;

  /// الزر العائم
  final Widget? floatingActionButton;

  /// موضع الزر العائم
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// لون خلفية الشاشة (عند عدم استخدام التدرجات)
  final Color? backgroundColor;

  /// تفعيل تدرج surfaceMesh السيادي لكامل خلفية الشاشة Edge-to-Edge
  final bool useSurfaceMesh;

  /// تدرج خلفية مخصص
  final Gradient? backgroundGradient;

  /// امتداد المحتوى خلف شريط الـ AppBar لمنع أي حد قاطع
  final bool? extendBodyBehindAppBar;

  /// تفعيل التأثير البلوري الزجاجي الناعم خلف الـ AppBar عند تمرير المحتوى تحته
  final bool enableGlassAppBar;

  /// تفعيل SafeArea حول المحتوى
  final bool safeArea;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  /// أقصى اتساع للمحتوى (مثل AppBreakpoints.maxFormWidth)
  final double? maxWidth;

  /// حواشي المحتوى الخارجية
  final EdgeInsetsGeometry? contentPadding;

  /// تجنب صعود لوحة المفاتيح
  final bool? resizeToAvoidBottomInset;

  /// دالة مساعدة لحساب ارتفاع شريط الحالة + الـ AppBar بدقة لضبط بداية التمرير
  static double topBarHeight(BuildContext context) {
    return MediaQuery.paddingOf(context).top + kToolbarHeight;
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (appBar != null) return appBar;

    final hasTitle =
        appBarTitle != null ||
        appBarSubtitle != null ||
        appBarTitleWidget != null;
    final hasLeading =
        leading != null || showBackButton || onBackPressed != null;
    final hasActions = actions != null && actions!.isNotEmpty;

    if (!hasTitle && !hasLeading && !hasActions) {
      return null;
    }

    final colors = context.colors;

    // بناء زر الرجوع الموحد طبقاً لـ AGENTS.md
    Widget? leadingWidget = leading;
    if (leadingWidget == null && (showBackButton || onBackPressed != null)) {
      leadingWidget = Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: CustomButton.icon(
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: 'رجوع',
          iconSize: 18.r,
          dimension: 40.r,
          foregroundColor: colors.onSurface,
          backgroundColor: Colors.transparent,
          onPressed: onBackPressed ?? () => Get.back(),
        ),
      );
    }

    // بناء العنوان والعنوان الفرعي
    Widget? titleWidget = appBarTitleWidget;
    if (titleWidget == null && appBarTitle != null) {
      if (appBarSubtitle != null) {
        titleWidget = Column(
          crossAxisAlignment: (centerTitle ?? false)
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appBarTitle!,
              style: AppTypography.titleLarge.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              appBarSubtitle!,
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        );
      } else {
        titleWidget = Text(
          appBarTitle!,
          style: AppTypography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }

    // شريط الـ AppBar الانسيابي الخالي من أي خطوط قاطعة
    return AppBar(
      title: titleWidget,
      centerTitle: centerTitle ?? (appBarSubtitle == null),
      backgroundColor: appBarBg ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 60.w,
      leading: leadingWidget,
      flexibleSpace: enableGlassAppBar
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: (appBarBg ?? colors.surface).withValues(alpha: 0.15),
                ),
              ),
            )
          : null,
      actions: hasActions ? [...actions!, AppSpacing.hXs] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveGradient =
        backgroundGradient ??
        (useSurfaceMesh ? AppGradients.surfaceMesh(context) : null);

    final builtAppBar = _buildAppBar(context);

    // عندما يكون الهيدر شفافاً أو نستخدم التدرج الشبكي، يمتد المحتوى تلقائياً خلف الـ AppBar لمنع القص الحاد
    final effectiveExtend =
        extendBodyBehindAppBar ??
        (effectiveGradient != null &&
            (appBarBg == null || appBarBg == Colors.transparent));

    Widget content = body;

    if (contentPadding != null) {
      content = Padding(padding: contentPadding!, child: content);
    }

    if (maxWidth != null) {
      content = ResponsiveContentWrapper(
        maxWidth: maxWidth!,
        alignment: Alignment.topCenter,
        padding: EdgeInsets.zero,
        child: content,
      );
    }

    if (safeArea) {
      content = SafeArea(
        top: effectiveExtend && builtAppBar != null ? false : safeAreaTop,
        bottom: safeAreaBottom,
        child: content,
      );
    }

    final scaffold = Scaffold(
      backgroundColor: effectiveGradient != null
          ? Colors.transparent
          : (backgroundColor ?? colors.surface),
      appBar: builtAppBar,
      extendBodyBehindAppBar: effectiveExtend,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );

    // إذا وُجد تدرج شبكي، يُغلف الشاشة بالكامل من الحافة العليا للحافة السفلى
    if (effectiveGradient != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: effectiveGradient),
        child: scaffold,
      );
    }

    return scaffold;
  }
}
