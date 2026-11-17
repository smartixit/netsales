part of 'custom_state_view.dart';
extension on CustomStateView {
  Widget _buildContent(BuildContext context, Color accent) {
    final colors = context.colors;
    final size = (graphicSize ?? 104).r;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 480.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeroGraphic(context, accent, size),
          AppSpacing.vMd,
          _buildBadge(context, accent),
          AppSpacing.vSm,
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            AppSpacing.vXs,
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.55,
              ),
            ),
          ],
          if (kind == CustomStateKind.loading && showLoadingSkeleton) ...[
            AppSpacing.vMd,
            CustomStateSkeletonView(recipe: skeleton ?? const CustomStateSkeleton(), builder: skeletonBuilder),
          ],
          if (_hasActions) ...[
            AppSpacing.vMd,
            _buildActions(context),
          ],
          if (technicalDetails != null && technicalDetails!.isNotEmpty) ...[
            AppSpacing.vMd,
            _buildTechnicalDetails(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroGraphic(BuildContext context, Color accent, double size) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size + 34.r,
      height: size + 34.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size + 34.r,
            height: size + 34.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: isDark ? .20 : .12),
                  accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          Container(
            width: size * .88,
            height: size * .88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surfaceContainerLow.withValues(alpha: .9),
              border: Border.all(color: accent.withValues(alpha: .28), width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: .10),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          if (kind == CustomStateKind.loading)
            SizedBox(
              width: size * .62,
              height: size * .62,
              child: CircularProgressIndicator(
                strokeWidth: 3.r,
                color: accent,
                backgroundColor: accent.withValues(alpha: .12),
              ),
            ),
          if (kind != CustomStateKind.loading)
            Container(
              width: size * .58,
              height: size * .58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: .12),
                border: Border.all(color: accent.withValues(alpha: .28)),
              ),
              child: Icon(icon ?? _defaultIcon(), color: accent, size: size * .28),
            ),
          if (kind == CustomStateKind.loading)
            Icon(icon ?? _defaultIcon(), color: accent, size: size * .24),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, Color accent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: accent.withValues(alpha: .24)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon ?? _defaultIcon(), size: 13.r, color: accent),
        AppSpacing.hXxs,
        Text(
          badgeLabel ?? _defaultBadge(),
          style: AppTypography.badgeText.copyWith(color: accent, fontWeight: FontWeight.w800),
        ),
      ]),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (customAction != null) return customAction!;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        if (actionLabel != null && onAction != null)
          CustomButton.primary(
            text: actionLabel!,
            icon: actionIcon ?? Icons.refresh_rounded,
            onPressed: onAction!,
            size: AppButtonSize.small,
          ),
        if (secondaryActionLabel != null && onSecondaryAction != null)
          CustomButton.outline(
            text: secondaryActionLabel!,
            icon: secondaryActionIcon,
            onPressed: onSecondaryAction!,
            size: AppButtonSize.small,
          ),
      ],
    );
  }

  Widget _buildTechnicalDetails(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .36)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          title: Text(
            'التفاصيل الفنية والدعم التقني',
            style: AppTypography.labelMedium.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: Icon(Icons.terminal_rounded, color: colors.onSurfaceVariant),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectableText(
                    technicalDetails!,
                    style: AppTypography.bodySmall.copyWith(color: colors.error, height: 1.4),
                  ),
                  AppSpacing.vSm,
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: CustomButton.text(
                      text: 'نسخ تفاصيل الخطأ',
                      icon: Icons.copy_rounded,
                      size: AppButtonSize.small,
                      onPressed: () async {
                        await UrlLauncherService.copyToClipboard(technicalDetails!);
                        CustomToast.show(message: 'تم نسخ تفاصيل الخطأ للحافظة', icon: Icons.copy_rounded);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
