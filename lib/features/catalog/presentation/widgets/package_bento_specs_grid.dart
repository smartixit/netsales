import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_bento_pod.dart';

/// شبكة مكعبات المواصفات الفنية التفاعلية بنمط Bento (Package Bento Specs Grid)
///
/// بديل عصري فاخر للقوائم المسطحة؛ يعتمد حصرياً على لوحة ألوان النظام المركزية [AppColors]
class PackageBentoSpecsGrid extends StatelessWidget {
  const PackageBentoSpecsGrid({super.key, required this.package});

  final PackageEntity package;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.widgets_outlined, size: 20.r, color: colors.primary),
            SizedBox(width: AppSpacing.xs),
            Text(
              'المواصفات الفنية المعتمدة للباقة',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),

        // شبكة Bento المكونة من 4 مكعبات
        Row(
          children: [
            // مكعب 1: سعة البيانات (لون السماء المعتمد مركزياً)
            Expanded(
              child: PackageBentoPod(
                icon: Icons.data_usage_rounded,
                iconColor: colors.skyAccent,
                title: 'سعة البيانات',
                value: package.balanceParts.displayText,
                subtitle: 'رصيد الحزمة الرقمي',
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            // مكعب 2: فترة الصلاحية (اللون البنفسجي المعتمد مركزياً)
            Expanded(
              child: PackageBentoPod(
                icon: Icons.event_available_rounded,
                iconColor: colors.purpleAccent,
                title: 'فترة الصلاحية',
                value: package.validityDisplay,
                subtitle: 'صلاحية الكرت للعميل',
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.sm),

        Row(
          children: [
            // مكعب 3: وقت الاتصال (لون الكهرمان المعتمد مركزياً)
            Expanded(
              child: PackageBentoPod(
                icon: Icons.timer_rounded,
                iconColor: colors.amberAccent,
                title: 'وقت الاستخدام',
                value: package.uptimeDisplay,
                subtitle: 'أقصى مدة اتصال بالشبكة',
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            // مكعب 4: سعة الحزمة وتكلفة الكرت الواحد (لون هوية المنصة الأساسي)
            Expanded(
              child: PackageBentoPod(
                icon: Icons.style_rounded,
                iconColor: colors.primary,
                title: 'الحزمة والكرت',
                value: '${package.packageVoucherCount} كرت',
                subtitle:
                    'فئة الكرت: ${AmountFormatter.formatValue(package.unitVoucherPrice)} ر.ي',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
