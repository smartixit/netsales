part of 'custom_state_view.dart';
extension on CustomStateView {
Widget _buildStateView(BuildContext context) {
    final colors = context.colors;
    final accent = accentColor ?? _resolveAccent(colors);

    if (presentation == CustomStatePresentation.skeletonOnly) {
      return _buildSkeleton(context);
    }

    if (presentation == CustomStatePresentation.banner) {
      return _buildBanner(context, accent);
    }

    if (presentation == CustomStatePresentation.compact) {
      return _buildCompact(context, accent);
    }

    final content = _buildContent(context, accent);
    if (presentation == CustomStatePresentation.fullscreen) {
      return Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: padding ?? EdgeInsets.all(AppSpacing.xl),
          child: content,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: accent.withValues(alpha: .22)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .045),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Center(child: content),
    );
  }

  Color _resolveAccent(AppColors colors) {
    return switch (kind) {
      CustomStateKind.loading => colors.primary,
      CustomStateKind.empty => colors.secondary,
      CustomStateKind.error => colors.error,
      CustomStateKind.offline => colors.warning,
      CustomStateKind.pricingExpired => colors.tertiary,
      CustomStateKind.notFound => colors.secondary,
    };
  }

  String _defaultBadge() {
    return switch (kind) {
      CustomStateKind.loading => 'جارٍ التحميل',
      CustomStateKind.empty => 'لا توجد بيانات',
      CustomStateKind.error => 'حدث خطأ',
      CustomStateKind.offline => 'OFFLINE',
      CustomStateKind.pricingExpired => 'PRICING EXPIRED',
      CustomStateKind.notFound => 'غير موجود',
    };
  }

  IconData _defaultIcon() {
    return switch (kind) {
      CustomStateKind.loading => Icons.hourglass_top_rounded,
      CustomStateKind.empty => Icons.inbox_rounded,
      CustomStateKind.error => Icons.error_outline_rounded,
      CustomStateKind.offline => Icons.wifi_off_rounded,
      CustomStateKind.pricingExpired => Icons.timer_off_rounded,
      CustomStateKind.notFound => Icons.search_off_rounded,
    };
  }

  Widget _buildCompact(BuildContext context, Color accent) {
    final colors = context.colors;
    return Padding(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .10),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: .25)),
          ),
          child: Center(
            child: kind == CustomStateKind.loading
                ? SizedBox.square(dimension: 18.r, child: CircularProgressIndicator(strokeWidth: 2, color: accent))
                : Icon(icon ?? _defaultIcon(), color: accent, size: 20.r),
          ),
        ),
        AppSpacing.vXs,
        Text(title, textAlign: TextAlign.center, style: AppTypography.labelLarge.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800)),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          AppSpacing.vXxs,
          Text(subtitle!, textAlign: TextAlign.center, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant, height: 1.4)),
        ],
        if (kind == CustomStateKind.loading && showLoadingSkeleton) ...[
          AppSpacing.vSm,
          CustomStateSkeletonView(recipe: skeleton ?? const CustomStateSkeleton(), builder: skeletonBuilder),
        ],
        if (_hasActions) ...[AppSpacing.vXs, _buildActions(context)],
      ]),
    );
  }

  Widget _buildBanner(BuildContext context, Color accent) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accent.withValues(alpha: .20)),
      ),
      child: Row(children: [
        Icon(icon ?? _defaultIcon(), size: 17.r, color: accent),
        AppSpacing.hXs,
        Expanded(
          child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800)),
        ),
        if (onAction != null)
          CustomButton.text(text: actionLabel ?? 'إعادة المحاولة', size: AppButtonSize.small, onPressed: onAction),
      ]),
    );
  }

  bool get _hasActions =>
      customAction != null ||
      (actionLabel != null && onAction != null) ||
      (secondaryActionLabel != null && onSecondaryAction != null);



}
