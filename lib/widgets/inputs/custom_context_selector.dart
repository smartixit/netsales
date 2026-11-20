import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/inputs/custom_context_option.dart';
import 'package:netsales/widgets/inputs/custom_context_option_tile.dart';
import 'package:netsales/widgets/inputs/custom_context_selected_identity.dart';

/// مكون موحد مستقل لاختيار سياق الهوية والكيانات المتعددة (CustomContextSelector)
///
/// يدعم اختيار الكيان النشط (شبكة، نقطة بيع، فرع، عميل) بأسلوب الأكورديون الأنيق،
/// مع الحفاظ التام على التجاوب، وحالات التحميل والقراءة فقط، ودون أي منطق مخصص للميزات.
class CustomContextSelector extends StatelessWidget {
  const CustomContextSelector({
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
  final List<CustomContextOption> options;

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
                            border: Border.all(
                              color: accent.withValues(alpha: .28),
                            ),
                          ),
                          child: Icon(icon, color: accent, size: 20.r),
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AppSpacing.vXxs,
                              Text(
                                subtitle,
                                style: AppTypography.bodySmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 11.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isReadOnly && canExpand) ...[
                          AppSpacing.hXs,
                          CustomButton.outline(
                            text: isExpanded ? 'إخفاء' : 'تغيير',
                            icon: isExpanded
                                ? Icons.expand_less_rounded
                                : Icons.unfold_more_rounded,
                            size: AppButtonSize.small,
                            foregroundColor: accent,
                            borderColor: accent.withValues(alpha: .45),
                            onPressed: onToggle,
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.vSm,
                    CustomContextSelectedIdentity(
                      name: selectedName,
                      detail: selectedDetail,
                      initial: selectedInitial,
                      logoUrl: selectedLogoUrl,
                      accent: accent,
                      isExpanded: isExpanded,
                      canExpand: canExpand,
                      isReadOnly: isReadOnly,
                      readOnlyBadgeText: readOnlyBadgeText,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: duration,
              crossFadeState: (isExpanded && !isReadOnly)
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Divider(
                      height: 1,
                      color: colors.outlineVariant.withValues(alpha: .4),
                    ),
                    AppSpacing.vSm,
                    if (isLoading)
                      const CustomStateView.loading(
                        presentation: CustomStatePresentation.skeletonOnly,
                        skeleton: CustomStateSkeleton(
                          layout: CustomStateSkeletonLayout.list,
                          itemCount: 2,
                          cardHeight: 56,
                        ),
                      )
                    else if (emptyMessage != null)
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer.withValues(alpha: .4),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: .45),
                          ),
                        ),
                        child: Text(
                          emptyMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else ...[
                      for (final option in options)
                        CustomContextOptionTile(option: option, accent: accent),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
