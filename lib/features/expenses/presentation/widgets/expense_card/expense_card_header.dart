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

/// ترويسة بطاقة المصروف التشغيلي (Expense Card Header)
class ExpenseCardHeader extends StatelessWidget {
  const ExpenseCardHeader({
    super.key,
    required this.expense,
  });

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .30),
        border: Border(
          bottom: BorderSide(
            color: colors.primary.withValues(alpha: .08),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // أيقونة سند الصرف
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      colors.error,
                      colors.error.withValues(alpha: .85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: colors.error.withValues(alpha: .40),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.error.withValues(alpha: .25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 22.r,
                ),
              ),
              AppSpacing.hSm,

              // المعرف والشبكة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              expense.displayReference,
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
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
                    AppSpacing.vXxs,
                    Text(
                      expense.displayNetworkName,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // شارة نوع المصروف
              const CustomStatusBadge(
                label: 'مصروف تشغيلي',
                tone: SemanticTone.danger,
                icon: Icons.payments_outlined,
                isCompact: true,
              ),
            ],
          ),
          AppSpacing.vSm,

          // شريط التاريخ والمسؤول
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12.r,
                    color: colors.onSurfaceVariant.withValues(alpha: .7),
                  ),
                  AppSpacing.hXs,
                  Text(
                    expense.formattedExpenseDate,
                    style: AppTypography.caption.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 12.r,
                    color: colors.onSurfaceVariant.withValues(alpha: .7),
                  ),
                  AppSpacing.hXs,
                  Text(
                    expense.displayCreatorName,
                    style: AppTypography.caption.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
