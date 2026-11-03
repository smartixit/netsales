import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// تصنيفات الأخطاء التشغيلية لتقديم استجابة بصرية ملائمة (Error State Types)
enum ErrorStateType {
  /// خطأ عام في تدفق البيانات أو الواجهة
  general,

  /// انقطاع الاتصال بالإنترنت أو تعذر الوصول للخادم
  connection,

  /// خطأ داخلي في الخادم (500 / 502 / 503)
  server,

  /// انتهاء الجلسة أو نقص في صلاحيات الوصول (401 / 403)
  auth,

  /// العنصر أو المورد غير موجود (404)
  notFound,
}

/// أنماط عرض حالة الخطأ (Error State Layout Variants)
enum ErrorStateVariant {
  /// شاشة كاملة مع هالة ضوئية وشارة تصنيف وتفاصيل موسعة
  fullscreen,

  /// بطاقة مؤطرة ملائمة للتبويبات والأقسام المدمجة
  boxed,

  /// عرض مضغوط فائق الرشاقة للمساحات المحدودة
  compact,
}

/// ============================================================================
/// عنصر حالة الخطأ فائق الجودة والاحترافية (NetSales Premium CustomErrorState)
/// ============================================================================
/// يقدم واجهة استثنائية لمعالجة الأخطاء تمنح المستخدم الطمأنينة والوضوح الكامل:
///
/// 1. هالة محيطية متدرجة ملونة بحسب خطورة ونوع الخطأ (Ambient Status Glow).
/// 2. شارة تصنيف واضحة لكود الخطأ أو طبيعته لتسهيل الدعم الفني.
/// 3. زر إعادة محاولة رئيسي مصمم ومتحرك مع دعم خيار ثانوي (مثل الرجوع أو التواصل مع الدعم).
/// 4. تفاصيل تقنية اختيارية قابلة للطي والنسخ لدعم مهندسي التشغيل وخدمة العملاء.
/// 5. توافقية كاملة 100% مع كافة الاستدعاءات الحالية دون أي كسر برمجي.
class CustomErrorState extends StatefulWidget {
  const CustomErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.retryLabel = 'إعادة المحاولة',
    this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.type = ErrorStateType.general,
    this.variant = ErrorStateVariant.fullscreen,
    this.errorCode,
    this.technicalDetails,
    this.animationPath,
    this.icon,
    this.customAction,
    this.padding,
  });

  /// منشئ مخصص لأخطاء انقطاع الاتصال والشبكة (Network & Offline Error)
  factory CustomErrorState.connection({
    Key? key,
    String title = 'تعذر الاتصال بالشبكة',
    String subtitle =
        'يرجى التحقق من اتصالك بالإنترنت أو بيانات الهاتف ثم المحاولة مجدداً.',
    String retryLabel = 'إعادة فحص الاتصال',
    VoidCallback? onRetry,
    VoidCallback? onOpenSettings,
  }) {
    return CustomErrorState(
      key: key,
      title: title,
      subtitle: subtitle,
      retryLabel: retryLabel,
      onRetry: onRetry,
      secondaryActionLabel: onOpenSettings != null ? 'إعدادات الشبكة' : null,
      onSecondaryAction: onOpenSettings,
      secondaryActionIcon: Icons.settings_outlined,
      type: ErrorStateType.connection,
      errorCode: 'OFFLINE',
      icon: Icons.wifi_off_rounded,
    );
  }

  /// منشئ مخصص لأخطاء خادم المنصة (Internal Server 500 Error)
  factory CustomErrorState.server({
    Key? key,
    String title = 'الخدمة غير متاحة مؤقتاً',
    String subtitle =
        'حدث خطأ غير متوقع أثناء معالجة الطلب في الخادم. يجري العمل على حل المشكلة.',
    String retryLabel = 'إعادة المحاولة',
    VoidCallback? onRetry,
    String? technicalDetails,
    String? errorCode = 'ERR_500',
  }) {
    return CustomErrorState(
      key: key,
      title: title,
      subtitle: subtitle,
      retryLabel: retryLabel,
      onRetry: onRetry,
      type: ErrorStateType.server,
      errorCode: errorCode,
      technicalDetails: technicalDetails,
      icon: Icons.cloud_off_rounded,
    );
  }

  /// منشئ مخصص للأخطاء المدمجة داخل بطاقة أو قسم (Boxed Card Layout)
  const CustomErrorState.boxed({
    super.key,
    required this.title,
    this.subtitle,
    this.retryLabel = 'إعادة المحاولة',
    this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.type = ErrorStateType.general,
    this.errorCode,
    this.technicalDetails,
    this.animationPath,
    this.icon,
    this.customAction,
    this.padding,
  }) : variant = ErrorStateVariant.boxed;

  /// منشئ مخصص للحالات المصغرة (Compact Inline Layout)
  const CustomErrorState.compact({
    super.key,
    required this.title,
    this.subtitle,
    this.retryLabel = 'إعادة المحاولة',
    this.onRetry,
    this.icon,
    this.padding,
  })  : secondaryActionLabel = null,
        onSecondaryAction = null,
        secondaryActionIcon = null,
        type = ErrorStateType.general,
        errorCode = null,
        technicalDetails = null,
        animationPath = null,
        customAction = null,
        variant = ErrorStateVariant.compact;

  /// عنوان الخطأ البارز
  final String title;

  /// الوصف التوضيحي للخطأ
  final String? subtitle;

  /// نص زر إعادة المحاولة
  final String retryLabel;

  /// دالة إعادة المحاولة
  final VoidCallback? onRetry;

  /// نص الإجراء الثانوي
  final String? secondaryActionLabel;

  /// دالة الإجراء الثانوي
  final VoidCallback? onSecondaryAction;

  /// أيقونة الإجراء الثانوي
  final IconData? secondaryActionIcon;

  /// نوع وطبيعة الخطأ
  final ErrorStateType type;

  /// نمط العرض والتنسيق
  final ErrorStateVariant variant;

  /// رمز أو كود الخطأ البرمجي (مثل 404, 500, OFFLINE)
  final String? errorCode;

  /// تفاصيل استثنائية أو تتبع تقني للمطورين والدعم
  final String? technicalDetails;

  /// مسار ملف الأنيميشن Lottie المخصص
  final String? animationPath;

  /// أيقونة بديلة أو مرافقة
  final IconData? icon;

  /// عنصر إجراءات مخصص بالكامل
  final Widget? customAction;

  /// هوامش الحاوية
  final EdgeInsetsGeometry? padding;

  @override
  State<CustomErrorState> createState() => _CustomErrorStateState();
}

class _CustomErrorStateState extends State<CustomErrorState> {
  bool _isDetailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.variant == ErrorStateVariant.compact) {
      return _buildCompact(context);
    }

    final content = _buildFullContent(context);

    if (widget.variant == ErrorStateVariant.boxed) {
      return _buildBoxedWrapper(context, content);
    }

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: widget.padding ??
            EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
        child: content,
      ),
    );
  }

  /// بناء المحتوى الكامل للشاشة الرئيسية أو الصندوقية
  Widget _buildFullContent(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = _resolveThemeColor(colors);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 480.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. العنصر البصري المحاط بالهالة الضوئية للخطأ (Status Glow Halo)
          _buildGraphicWithHalo(context, isDark, themeColor),
          AppSpacing.vLg,

          // 2. شارة كود ونوع الخطأ (Status / Error Code Badge)
          _buildStatusBadge(context, themeColor),
          AppSpacing.vSm,

          // 3. العنوان الرئيسي للخطأ
          Text(
            widget.title,
            style: AppTypography.titleLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),

          // 4. الوصف التوضيحي المصقول
          if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              widget.subtitle!,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // 5. حزمة أزرار الإجراءات
          if (_hasActions) ...[
            AppSpacing.vLg,
            _buildActionButtons(context),
          ],

          // 6. صندوق التفاصيل التقنية القابل للطي (Diagnostics Accordion)
          if (widget.technicalDetails != null &&
              widget.technicalDetails!.isNotEmpty) ...[
            AppSpacing.vLg,
            _buildTechnicalDetailsSection(context, themeColor),
          ],
        ],
      ),
    );
  }

  /// بناء الرسم البصري مع الهالة الملونة المضيئة
  Widget _buildGraphicWithHalo(
    BuildContext context,
    bool isDark,
    Color themeColor,
  ) {
    final colors = context.colors;
    const size = 150.0;
    final haloColor = themeColor.withValues(alpha: isDark ? 0.14 : 0.09);
    final ringColor = themeColor.withValues(alpha: isDark ? 0.25 : 0.18);
    final effectiveAnim = widget.animationPath ??
        (widget.type == ErrorStateType.connection
            ? 'assets/animations/network.json'
            : 'assets/animations/error.json');

    return Center(
      child: SizedBox(
        width: size.w + 40.w,
        height: size.w + 40.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الهالة الضوئية التحذيرية
            Container(
              width: size.w + 40.w,
              height: size.w + 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    haloColor,
                    haloColor.withValues(alpha: 0.0),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // الحلقة الزجاجية الدائرية
            Container(
              width: size.w * 0.95,
              height: size.w * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceContainerLowest.withValues(alpha: 0.7),
                border: Border.all(color: ringColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withValues(alpha: 0.08),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // عرض ملف Lottie أو الأيقونة الفاخرة
            if (widget.icon != null && widget.animationPath == null)
              _buildFallbackIcon(context, size.w, themeColor)
            else
              SizedBox(
                width: size.w,
                height: size.w,
                child: Lottie.asset(
                  effectiveAnim,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallbackIcon(context, size.w, themeColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// أيقونة بديلة أنيقة في حال عدم توفر Lottie
  Widget _buildFallbackIcon(
    BuildContext context,
    double size,
    Color themeColor,
  ) {
    final activeIcon = widget.icon ?? _resolveDefaultIcon();

    return Container(
      width: size * 0.58,
      height: size * 0.58,
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: themeColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          activeIcon,
          size: size * 0.28,
          color: themeColor,
        ),
      ),
    );
  }

  /// بناء شارة نوع وكود الخطأ
  Widget _buildStatusBadge(BuildContext context, Color themeColor) {
    final label = widget.errorCode ?? _resolveDefaultTypeLabel();
    final badgeIcon = _resolveBadgeIcon();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 14.sp,
            color: themeColor,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTypography.badgeText.copyWith(
              color: themeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء حزمة أزرار الإجراءات
  Widget _buildActionButtons(BuildContext context) {
    if (widget.customAction != null) return widget.customAction!;

    final hasRetry = widget.onRetry != null;
    final hasSecondary = widget.secondaryActionLabel != null &&
        widget.onSecondaryAction != null;

    if (!hasRetry && !hasSecondary) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12.w,
      runSpacing: 8.h,
      children: [
        if (hasRetry)
          CustomButton.primary(
            text: widget.retryLabel,
            icon: Icons.refresh_rounded,
            onPressed: widget.onRetry!,
          ),
        if (hasSecondary)
          CustomButton.outline(
            text: widget.secondaryActionLabel!,
            icon: widget.secondaryActionIcon ?? Icons.arrow_forward_rounded,
            onPressed: widget.onSecondaryAction!,
          ),
      ],
    );
  }

  /// بناء قسم التفاصيل التقنية القابل للطي للمطورين والدعم
  Widget _buildTechnicalDetailsSection(
    BuildContext context,
    Color themeColor,
  ) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isDetailsExpanded = !_isDetailsExpanded),
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.terminal_rounded,
                    size: 18.sp,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'التفاصيل الفنية والدعم التقني',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isDetailsExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isDetailsExpanded) ...[
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: SelectableText(
                      widget.technicalDetails!,
                      style: AppTypography.badgeText.copyWith(
                        fontFamily: 'monospace',
                        color: colors.error,
                        height: 1.4,
                      ),
                    ),
                  ),
                  AppSpacing.vSm,
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: widget.technicalDetails!),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ تفاصيل الخطأ للحافظة'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(Icons.copy_rounded, size: 16.sp),
                      label: const Text('نسخ تفاصيل الخطأ'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// تغليف الحالة الصندوقية
  Widget _buildBoxedWrapper(BuildContext context, Widget content) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: widget.padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.error.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.error.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: content),
    );
  }

  /// بناء الحالة المضغوطة فائقة الرشاقة
  Widget _buildCompact(BuildContext context) {
    final colors = context.colors;
    final themeColor = _resolveThemeColor(colors);
    final activeIcon = widget.icon ?? _resolveDefaultIcon();

    return Center(
      child: Padding(
        padding: widget.padding ?? EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeColor.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                activeIcon,
                size: 20.sp,
                color: themeColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.title,
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                widget.subtitle!,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (widget.onRetry != null) ...[
              SizedBox(height: 8.h),
              CustomButton.text(
                text: widget.retryLabel,
                icon: Icons.refresh_rounded,
                onPressed: widget.onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _resolveThemeColor(AppColors colors) {
    return switch (widget.type) {
      ErrorStateType.connection => const Color(0xFFD97706), // Warm Amber
      ErrorStateType.server => colors.error,
      ErrorStateType.auth => const Color(0xFF6366F1), // Indigo
      ErrorStateType.notFound => colors.secondary,
      ErrorStateType.general => colors.error,
    };
  }

  IconData _resolveDefaultIcon() {
    return switch (widget.type) {
      ErrorStateType.connection => Icons.wifi_off_rounded,
      ErrorStateType.server => Icons.cloud_off_rounded,
      ErrorStateType.auth => Icons.lock_clock_rounded,
      ErrorStateType.notFound => Icons.search_off_rounded,
      ErrorStateType.general => Icons.error_outline_rounded,
    };
  }

  IconData _resolveBadgeIcon() {
    return switch (widget.type) {
      ErrorStateType.connection => Icons.signal_cellular_connected_no_internet_4_bar_rounded,
      ErrorStateType.server => Icons.dns_rounded,
      ErrorStateType.auth => Icons.security_rounded,
      ErrorStateType.notFound => Icons.help_outline_rounded,
      ErrorStateType.general => Icons.warning_amber_rounded,
    };
  }

  String _resolveDefaultTypeLabel() {
    return switch (widget.type) {
      ErrorStateType.connection => 'انقطاع الاتصال',
      ErrorStateType.server => 'خطأ في الخادم',
      ErrorStateType.auth => 'إذن الوصول أو الجلسة',
      ErrorStateType.notFound => 'غير موجود',
      ErrorStateType.general => 'خطأ في النظام',
    };
  }

  bool get _hasActions =>
      widget.onRetry != null ||
      (widget.secondaryActionLabel != null &&
          widget.onSecondaryAction != null) ||
      widget.customAction != null;
}
