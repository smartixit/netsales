import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// أنماط العرض المتاحة للحالة الفارغة (Empty State Variants)
enum EmptyStateVariant {
  /// عرض كامل الشاشة مع توهج محيطي وأيقونة/أنيميشن كبيرة
  fullscreen,

  /// عرض داخل بطاقة مؤطرة ومظللة ملائمة للتبويبات والأقسام المدمجة
  boxed,

  /// عرض مضغوط فائق الرشاقة للمساحات المحدودة (القوائم السريعة والحاويات الصغيرة)
  compact,
}

/// ============================================================================
/// عنصر الحالة الفارغة فائق الجودة (NetSales Premium CustomEmptyState)
/// ============================================================================
/// يوفر تجربة بصرية راقية ومدروسة هندسياً عند عدم توفر بيانات، متوافقاً مع
/// المعيار الدائم لجودة الواجهات (Permanent Premium UI/UX Engineering Standard):
///
/// 1. هالة محيطية متدرجة (Ambient Glowing Halo) تحيط بالعنصر البصري لمنح عمق جمالي.
/// 2. شارة تصنيف ناعمة (Contextual Category Badge) لترسيخ الغرض التشغيلي للحالة.
/// 3. هرمية طباعية متقنة تفصل بدقة بين العنوان والوصف الإرشادي الواضح.
/// 4. أزرار إجراءات مدروسة (Primary & Secondary Actions) لتوجيه المستخدم للخطوة التالية.
/// 5. تكيف كامل مع السمتين الفاتحة والداكنة وكافة قياسات الشاشات والهواتف والأجهزة اللوحية.
class CustomEmptyState extends StatelessWidget {
  const CustomEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeIcon,
    this.animationPath = 'assets/animations/no_data.json',
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.customAction,
    this.variant = EmptyStateVariant.fullscreen,
    this.graphicSize,
    this.padding,
  }) : compact = (variant == EmptyStateVariant.compact);

  /// منشئ مخصص للحالات الفارغة المدمجة داخل بطاقات أو تبويبات (Boxed Container)
  const CustomEmptyState.boxed({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeIcon,
    this.animationPath = 'assets/animations/no_data.json',
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.customAction,
    this.graphicSize,
    this.padding,
  }) : variant = EmptyStateVariant.boxed,
       compact = false;

  /// منشئ مخصص للحالات المضغوطة جداً (قوائم منسدلة، أشرطة، أو بطاقات مصغرة)
  const CustomEmptyState.compact({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.padding,
  }) : badgeText = null,
       badgeIcon = null,
       animationPath = null,
       actionIcon = null,
       secondaryActionLabel = null,
       onSecondaryAction = null,
       secondaryActionIcon = null,
       customAction = null,
       graphicSize = null,
       variant = EmptyStateVariant.compact,
       compact = true;

  /// منشئ مخصص لنتائج البحث والتصفية الفارغة (Search & Filter Zero Results)
  factory CustomEmptyState.search({
    Key? key,
    required String query,
    VoidCallback? onClearSearch,
    String? subtitle,
  }) {
    return CustomEmptyState(
      key: key,
      badgeText: 'نتائج البحث',
      badgeIcon: Icons.search_rounded,
      icon: Icons.search_off_rounded,
      animationPath: null,
      title: 'لم يتم العثور على أي نتائج',
      subtitle:
          subtitle ??
          (query.isNotEmpty
              ? 'لم تتطابق نتائج البحث مع "$query". يرجى التحقق من صحة الكلمات أو إعادة التصفية.'
              : 'لم نتمكن من العثور على أي سجلات متطابقة مع معايير البحث الحالية.'),
      actionLabel: onClearSearch != null ? 'مسح البحث' : null,
      actionIcon: Icons.clear_rounded,
      onAction: onClearSearch,
    );
  }

  /// العنوان الرئيسي لحالة الفراغ
  final String title;

  /// النص التوضيحي المساعد
  final String? subtitle;

  /// شارة التصنيف العلوية (مثال: "المعاملات"، "الطلبات")
  final String? badgeText;

  /// أيقونة شارة التصنيف
  final IconData? badgeIcon;

  /// مسار ملف الأنيميشن Lottie المخصص
  final String? animationPath;

  /// أيقونة بديلة أو مرافقة للرسم التوضيحي
  final IconData? icon;

  /// لون مخصص للأيقونة
  final Color? iconColor;

  /// نص الإجراء الرئيسي
  final String? actionLabel;

  /// دالة الإجراء الرئيسي
  final VoidCallback? onAction;

  /// أيقونة الإجراء الرئيسي
  final IconData? actionIcon;

  /// نص الإجراء الثانوي
  final String? secondaryActionLabel;

  /// دالة الإجراء الثانوي
  final VoidCallback? onSecondaryAction;

  /// أيقونة الإجراء الثانوي
  final IconData? secondaryActionIcon;

  /// عنصر إجراءات مخصص بالكامل (في حال الحاجة لأزرار معقدة)
  final Widget? customAction;

  /// نمط عرض الحالة (شاشة كاملة، صندوقية، مضغوطة)
  final EmptyStateVariant variant;

  /// حجم العنصر الجرافيكي (عرضاً وارتفاعاً)
  final double? graphicSize;

  /// هوامش الحاوية الداخلية
  final EdgeInsetsGeometry? padding;

  /// حقل التوافقية السابقة
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (variant == EmptyStateVariant.compact || compact) {
      return _buildCompact(context);
    }

    final content = _buildFullContent(context);

    if (variant == EmptyStateVariant.boxed) {
      return _buildBoxedWrapper(context, content);
    }

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
        child: content,
      ),
    );
  }

  /// بناء المحتوى الرئيسي للشاشة الكاملة والصندوقية
  Widget _buildFullContent(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 480.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. العنصر البصري المحاط بالهالة الضوئية الملكية (Ambient Halo Graphic)
          _buildGraphicWithHalo(context, isDark),
          AppSpacing.vLg,

          // 2. شارة التصنيف الهندسية العلوية (Category Badge)
          if (badgeText != null && badgeText!.isNotEmpty) ...[
            _buildBadge(context),
            AppSpacing.vSm,
          ],

          // 3. العنوان الرئيسي المصقول بعناية
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),

          // 4. الوصف التوضيحي الإرشادي
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // 5. حزمة أزرار الإجراءات
          if (_hasActions) ...[AppSpacing.vLg, _buildActionButtons(context)],
        ],
      ),
    );
  }

  /// بناء الرسم البصري مع الهالة الضوئية وطبقات العمق
  Widget _buildGraphicWithHalo(BuildContext context, bool isDark) {
    final colors = context.colors;
    final size = graphicSize ?? 160.w;
    final haloColor = (iconColor ?? colors.primary).withValues(
      alpha: isDark ? 0.12 : 0.08,
    );
    final innerRingColor = (iconColor ?? colors.primary).withValues(
      alpha: isDark ? 0.20 : 0.14,
    );

    return Center(
      child: SizedBox(
        width: size + 40.w,
        height: size + 40.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الهالة الضوئية الخارجية المتلاشية
            Container(
              width: size + 40.w,
              height: size + 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [haloColor, haloColor.withValues(alpha: 0.0)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // الحلقة الزجاجية الدائرية المتوسطة
            Container(
              width: size * 0.95,
              height: size * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceContainerLowest.withValues(alpha: 0.6),
                border: Border.all(color: innerRingColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: (iconColor ?? colors.primary).withValues(
                      alpha: 0.06,
                    ),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // الرسم الأساسي: إما Lottie Animation أو أيقونة أيقونية فاخرة
            if (animationPath != null && animationPath!.isNotEmpty)
              SizedBox(
                width: size,
                height: size,
                child: Lottie.asset(
                  animationPath!,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallbackIcon(context, size),
                ),
              )
            else
              _buildFallbackIcon(context, size),
          ],
        ),
      ),
    );
  }

  /// أيقونة بديلة مصممة بعناية فائقة
  Widget _buildFallbackIcon(BuildContext context, double size) {
    final colors = context.colors;
    final activeIcon = icon ?? Icons.inbox_rounded;
    final effectiveColor = iconColor ?? colors.primary;

    return Container(
      width: size * 0.58,
      height: size * 0.58,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(activeIcon, size: size * 0.28, color: effectiveColor),
      ),
    );
  }

  /// بناء شارة التصنيف العلوية
  Widget _buildBadge(BuildContext context) {
    final colors = context.colors;
    final badgeColor = iconColor ?? colors.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeIcon != null) ...[
            Icon(badgeIcon, size: 14.sp, color: badgeColor),
            SizedBox(width: 5.w),
          ] else ...[
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
          ],
          Text(
            badgeText!,
            style: AppTypography.badgeText.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء أزرار الإجراءات المتدرجة
  Widget _buildActionButtons(BuildContext context) {
    if (customAction != null) return customAction!;

    final hasPrimary = actionLabel != null && onAction != null;
    final hasSecondary =
        secondaryActionLabel != null && onSecondaryAction != null;

    if (!hasPrimary && !hasSecondary) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12.w,
      runSpacing: 8.h,
      children: [
        if (hasPrimary)
          CustomButton.primary(
            text: actionLabel!,
            icon: actionIcon ?? Icons.add_rounded,
            onPressed: onAction!,
          ),
        if (hasSecondary)
          CustomButton.outline(
            text: secondaryActionLabel!,
            icon: secondaryActionIcon,
            onPressed: onSecondaryAction!,
          ),
      ],
    );
  }

  /// تغليف الحالة في بطاقة صندوقية مصقولة (Boxed Card Layout)
  Widget _buildBoxedWrapper(BuildContext context, Widget content) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: content),
    );
  }

  /// بناء الحالة المضغوطة فائقة الرشاقة (Compact Inline Variant)
  Widget _buildCompact(BuildContext context) {
    final colors = context.colors;
    final activeIcon = icon ?? Icons.inbox_outlined;
    final effectiveColor = iconColor ?? colors.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: padding ?? EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: effectiveColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(activeIcon, size: 20.sp, color: effectiveColor),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                subtitle!,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 8.h),
              CustomButton.text(
                text: actionLabel!,
                icon: actionIcon,
                onPressed: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasActions =>
      (actionLabel != null && onAction != null) ||
      (secondaryActionLabel != null && onSecondaryAction != null) ||
      customAction != null;
}
