import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// بطاقة الترويسة القيادية لطلبات التوريد (Orders Command Hero - Executive Edition)
///
/// تجسد نفس العمق البصري والتدرج اللوني الزمردي الغني [0xFF087F68, 0xFF075B55, 0xFF123F49]
/// مع الحواف الذهبية الدافئة والدوائر الهندسية الخافتة المستلهمة من شاشة إنشاء الطلب الجديد.
class ProcurementOrdersHero extends StatelessWidget {
  const ProcurementOrdersHero({
    super.key,
    this.onCreate,
    this.canCreate = false,
    this.embedded = false,
    this.title,
    this.subtitle,
  });

  final VoidCallback? onCreate;
  final bool canCreate;
  final bool embedded;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF087F68), Color(0xFF075B55), Color(0xFF123F49)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFFFD98A).withValues(alpha: .32),
          width: 1.2,
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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. الدائرة الهندسية الشفافة في الزاوية العلوية
          PositionedDirectional(
            end: -18.r,
            top: -28.r,
            child: Container(
              width: 112.r,
              height: 112.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .055),
              ),
            ),
          ),

          // 2. الحلقة الهندسية الشفافة في الزاوية السفلية
          PositionedDirectional(
            end: 40.r,
            bottom: -48.r,
            child: Container(
              width: 90.r,
              height: 90.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .08),
                  width: 16.r,
                ),
              ),
            ),
          ),

          // 3. المحتوى الداخلي للترويسة
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // أيقونة الترويسة الذهبية الفخمة ذات الإطار الزجاجي
                    Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(17.r),
                        border: Border.all(
                          color: const Color(0xFFFFE7B0).withValues(alpha: .38),
                        ),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
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
                            title ?? 'طلبات التوريد',
                            style: AppTypography.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          AppSpacing.vXs,
                          Text(
                            subtitle ?? 'متابعة وإدارة طلبات كروت الشبكات، حالات الاعتماد، وتفاصيل الكميات فورياً.',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: .88),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (canCreate) ...[
                  AppSpacing.vMd,
                  Row(
                    children: [
                      const Spacer(),
                      CustomButton.primary(
                        text: 'طلب توريد جديد +',
                        icon: Icons.add_shopping_cart_rounded,
                        shape: AppButtonShape.pill,
                        size: AppButtonSize.small,
                        onPressed: onCreate,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
