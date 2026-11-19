import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';

class ProcurementNewOrderHeroCard extends StatelessWidget {
  const ProcurementNewOrderHeroCard({
    super.key,
    required this.isEditMode,
    this.requestId,
  });

  final bool isEditMode;
  final int? requestId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF087F68), Color(0xFF075B55), Color(0xFF123F49)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: const Color(0xFFFFD98A).withValues(alpha: .32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF087F68).withValues(alpha: .23),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -18,
            top: -28,
            child: Container(
              width: 112.r,
              height: 112.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .055),
              ),
            ),
          ),
          PositionedDirectional(
            end: 40,
            bottom: -48,
            child: Container(
              width: 90.r,
              height: 90.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .08),
                  width: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(17.r),
                    border: Border.all(
                      color: const Color(0xFFFFE7B0).withValues(alpha: .38),
                    ),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: const Color(0xFFFFE7B0),
                    size: 27.r,
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditMode ? 'تحديث طلب التوريد' : 'مساحة طلب التوريد',
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      AppSpacing.vXs,
                      Text(
                        isEditMode
                            ? 'مراجعة تفاصيل الطلب #${requestId ?? ''} وتعديل الكميات قبل حفظ التغييرات.'
                            : 'اختر الشبكة ونقطة البيع، ثم كوّن طلبك مباشرة من الباقات والأسعار المتاحة.',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: .88),
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
