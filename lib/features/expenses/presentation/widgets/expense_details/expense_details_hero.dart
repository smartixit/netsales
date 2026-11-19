import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// الترويسة القيادية لصفحة تفاصيل المصروف التشغيلي (Expense Details Hero)
class ExpenseDetailsHero extends StatelessWidget {
  const ExpenseDetailsHero({super.key, required this.expense});

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colors.error.withValues(alpha: 0.10),
            colors.surface,
            colors.surface,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border.all(
          color: colors.error.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.error.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة سند الصرف
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      colors.error,
                      colors.error.withValues(alpha: .85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: colors.error.withValues(alpha: 0.40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.error.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              AppSpacing.hSm,

              // عنوان وسند الصرف
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'سند صرف مصروفات تشغيلية',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppSpacing.vXxs,
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              expense.displayReference,
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.hXs,
                        CustomInteractiveBounce(
                          onTap: () {
                            UrlLauncherService.copyToClipboard(
                              expense.displayReference,
                              confirmationMessage: 'تم نسخ رقم المصروف',
                            );
                            CustomSnackbar.show(
                              title: 'تم النسخ',
                              message:
                                  'تم نسخ المعرّف ${expense.displayReference} إلى الحافظة',
                              type: SnackType.info,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: colors.outlineVariant.withValues(
                                  alpha: .4,
                                ),
                                width: 0.5,
                              ),
                            ),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 12.r,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // شارة المصروف
              const CustomStatusBadge(
                label: 'مصروف تشغيلي',
                tone: SemanticTone.danger,
                icon: Icons.payments_outlined,
              ),
            ],
          ),
          AppSpacing.vMd,

          // سكة الإجمالي المالي الكلي للسند
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: colors.error.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'إجمالي المبلغ المصروف',
                      style: AppTypography.caption.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.vXxs,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            expense.formattedTotalAmount,
                            style: AppTypography.headlineSmall.copyWith(
                              color: colors.error,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          AppSpacing.hXxs,
                          Text(
                            'ر.ي',
                            style: AppTypography.caption.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'التاريخ المعتمد',
                      style: AppTypography.caption.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.vXxs,
                    Text(
                      expense.formattedExpenseDate,
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
