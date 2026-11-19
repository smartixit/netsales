import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_context_option.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_context_option_tile.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_context_selected_identity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

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
    this.isReadOnly = false,
    this.readOnlyBadgeText = 'للقراءة فقط',
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
  final bool isReadOnly;
  final String readOnlyBadgeText;
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
              onTap: (!isReadOnly && canExpand) ? onToggle : null,
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
                        if (isReadOnly)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                              border: Border.all(
                                color: colors.outlineVariant.withValues(
                                  alpha: .4,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_rounded,
                                  size: 13.r,
                                  color: colors.onSurfaceVariant,
                                ),
                                AppSpacing.hXxs,
                                Text(
                                  readOnlyBadgeText,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (canExpand)
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: duration,
                            child: Container(
                              width: 32.r,
                              height: 32.r,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLow,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(
                                    alpha: .4,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20.r,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                    AppSpacing.vSm,
                    ProcurementContextSelectedIdentity(
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
            AnimatedCrossFade(
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: duration,
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: .35),
                    ),
                  ),
                ),
                child: isExpanded
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isLoading)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                child: CustomStateView.loading(
                                  presentation:
                                      CustomStatePresentation.skeletonOnly,
                                  skeleton: const CustomStateSkeleton(
                                    layout: CustomStateSkeletonLayout.list,
                                    itemCount: 2,
                                  ),
                                ),
                              )
                            else if (options.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                child: CustomStateView.empty(
                                  title: emptyMessage ?? 'لا توجد خيارات متاحة',
                                  presentation: CustomStatePresentation.compact,
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: options.length,
                                separatorBuilder: (_, _) => AppSpacing.vXs,
                                itemBuilder: (context, index) {
                                  final option = options[index];
                                  return ProcurementContextOptionTile(
                                    option: option,
                                    accent: accent,
                                  );
                                },
                              ),
                            AppSpacing.vSm,
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: CustomButton.text(
                                text: 'إغلاق القائمة',
                                icon: Icons.keyboard_arrow_up_rounded,
                                onPressed: onToggle,
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
