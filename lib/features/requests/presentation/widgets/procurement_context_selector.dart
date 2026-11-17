import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';

/// Shared presentation for the supplier Network and destination POS selectors.
class ProcurementContextSelector extends StatelessWidget {
  const ProcurementContextSelector({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.selectedName,
    required this.selectedDetail,
    required this.selectedLogoUrl,
    required this.selectedInitial,
    required this.isExpanded,
    required this.canExpand,
    required this.onToggle,
    required this.options,
    this.isLoading = false,
    this.emptyMessage,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String selectedName;
  final String selectedDetail;
  final String? selectedLogoUrl;
  final String selectedInitial;
  final bool isExpanded;
  final bool canExpand;
  final bool isLoading;
  final String? emptyMessage;
  final VoidCallback onToggle;
  final List<ProcurementContextOption> options;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = AppMotion.disabled(context)
        ? Duration.zero
        : const Duration(milliseconds: 260);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isExpanded
              ? accent.withValues(alpha: .55)
              : colors.outlineVariant.withValues(alpha: .48),
          width: isExpanded ? 1.35 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: isExpanded ? .075 : .045),
            blurRadius: isExpanded ? 22 : 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: canExpand ? onToggle : null,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: .11),
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                          child: Icon(icon, color: accent, size: 19.r),
                        ),
                        AppSpacing.hSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTypography.titleSmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                subtitle,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canExpand) ...[
                          CustomButton.text(
                            text: isExpanded ? 'إغلاق' : 'تغيير',
                            icon: isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.swap_horiz_rounded,
                            size: AppButtonSize.small,
                            onPressed: onToggle,
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? .5 : 0,
                            duration: duration,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: accent,
                              size: 20.r,
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.vSm,
                    if (isLoading)
                      const CustomStateView.loading(
                        presentation: CustomStatePresentation.skeletonOnly,
                        skeleton: CustomStateSkeleton(
                          layout: CustomStateSkeletonLayout.text,
                          lineCount: 2,
                          showCardSurface: false,
                        ),
                      )
                    else if (emptyMessage != null)
                      Text(
                        emptyMessage!,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.error,
                        ),
                      )
                    else
                      _SelectedIdentity(
                        name: selectedName,
                        detail: selectedDetail,
                        logoUrl: selectedLogoUrl,
                        initial: selectedInitial,
                        accent: accent,
                      ),
                  ],
                ),
              ),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: duration,
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: isExpanded && options.length > 1
                    ? Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Column(
                          children: [
                            Divider(
                              height: AppSpacing.sm,
                              color: colors.outlineVariant.withValues(alpha: .5),
                            ),
                            ...options.map(
                              (option) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: AppSpacing.xs,
                                ),
                                child: _ContextOptionTile(
                                  option: option,
                                  accent: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity, height: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProcurementContextOption {
  const ProcurementContextOption({
    required this.id,
    required this.name,
    required this.detail,
    required this.logoUrl,
    required this.initial,
    required this.selected,
    required this.onTap,
  });

  final int id;
  final String name;
  final String detail;
  final String? logoUrl;
  final String initial;
  final bool selected;
  final VoidCallback onTap;
}

class _SelectedIdentity extends StatelessWidget {
  const _SelectedIdentity({
    required this.name,
    required this.detail,
    required this.logoUrl,
    required this.initial,
    required this.accent,
  });

  final String name;
  final String detail;
  final String? logoUrl;
  final String initial;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            accent.withValues(alpha: .12),
            colors.primary.withValues(alpha: .045),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accent.withValues(alpha: .30)),
      ),
      child: Row(
        children: [
          CustomCachedImage.logo(
            url: logoUrl,
            size: 48.r,
            borderRadius: 14.r,
            fallbackText: initial,
            fallbackTextStyle: AppTypography.titleMedium.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_rounded, color: accent, size: 21.r),
        ],
      ),
    );
  }
}

class _ContextOptionTile extends StatelessWidget {
  const _ContextOptionTile({required this.option, required this.accent});

  final ProcurementContextOption option;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: option.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: option.selected
                ? accent.withValues(alpha: .105)
                : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: option.selected
                  ? accent.withValues(alpha: .62)
                  : colors.outlineVariant.withValues(alpha: .34),
              width: option.selected ? 1.35 : 1,
            ),
          ),
          child: Row(
            children: [
              CustomCachedImage.logo(
                url: option.logoUrl,
                size: 38.r,
                borderRadius: 11.r,
                fallbackText: option.initial,
              ),
              AppSpacing.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      option.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (option.selected)
                Icon(Icons.check_circle_rounded, color: accent, size: 20.r),
            ],
          ),
        ),
      ),
    );
  }
}
