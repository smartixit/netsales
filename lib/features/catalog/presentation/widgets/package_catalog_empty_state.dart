import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';

/// عنصر الحالة الفارغة المخصص لكتالوج باقات الكروت
class PackageCatalogEmptyState extends GetView<PackageCatalogController> {
  const PackageCatalogEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasFilter = controller.searchQuery.value.isNotEmpty ||
          controller.statusFilter.value != null;

      return CustomEmptyState(
        icon: hasFilter
            ? Icons.search_off_rounded
            : Icons.wifi_tethering_off_rounded,
        title: hasFilter ? 'لا توجد نتائج مطابقة' : 'كتالوج الباقات فارغ',
        subtitle: hasFilter
            ? 'لم نجد أي باقة تطابق معايير البحث والفلترة المحددة.'
            : 'لم تقم بإضافة أي باقات كروت للشبكة بعد. يمكنك البدء بإنشاء أول باقة.',
        actionLabel: hasFilter ? 'إعادة ضبط الفلاتر' : 'إنشاء باقة الآن',
        onAction: () {
          if (hasFilter) {
            controller.searchController.clear();
            controller.setStatusFilter(null);
          } else {
            controller.initCreateForm();
            Get.toNamed<void>(AppRoutes.packageForm);
          }
        },
      );
    });
  }
}
