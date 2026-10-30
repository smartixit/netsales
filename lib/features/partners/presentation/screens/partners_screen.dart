import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/widgets/network_pos_feed.dart';
import 'package:netsales/features/partners/presentation/widgets/networks_feed.dart';
import 'package:netsales/features/partners/presentation/widgets/partners_network_filter.dart';
import 'package:netsales/features/partners/presentation/widgets/partners_search_filter_bar.dart';
import 'package:netsales/features/partners/presentation/widgets/partners_segmented_header.dart';
import 'package:netsales/features/partners/presentation/widgets/pos_list_feed.dart';
import 'package:netsales/widgets/foundation/home_tab_shell.dart';

/// ============================================================================
/// شاشة الشركاء وشبكة التوزيع المجمعة (PartnersScreen)
/// ============================================================================
/// مجمّع تركيبي رشيق وعالمي (World-Class Lean Composite Assembler) لإدارة
/// مزودي الشبكات، نقاط البيع، وعقود الربط والتوزيع، خالٍ تماماً من التزاحم الرأسي
/// ومن دوال البناء المساعدة طبقاً لمعايير AGENTS.md.
class PartnersScreen extends GetView<PartnersController> {
  const PartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeTabShell.fixed(
      child: Column(
        children: [
          // 1. رأس التبويب القطاعي الموحد (الشبكات | الوكلاء | العقود)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: PartnersSegmentedHeader(controller: controller),
          ),
          AppSpacing.vXs,

          // 2. فلتر الشبكة المتكيف (يظهر تلقائياً لعقود الربط فقط)
          PartnersNetworkFilter(controller: controller),

          // 3. شريط البحث والتصفية المزدوج
          PartnersSearchFilterBar(controller: controller),
          AppSpacing.vXs,

          // 4. الحاوية التفاعلية لقوائم البيانات حسب التبويب النشط
          // وتتضمن بداخلها مؤشرات الـ KPI التمريرية لتوفير أقصى مساحة عرض
          Expanded(
            child: Obx(() {
              final tab = controller.activeSegmentIndex.value;
              if (tab == 0) {
                return NetworksFeed(controller: controller);
              } else if (tab == 1) {
                return PosListFeed(controller: controller);
              } else {
                return NetworkPosFeed(controller: controller);
              }
            }),
          ),
        ],
      ),
    );
  }
}
