import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// العقد المعماري الموحد لمتحكمات استعراض وإدارة دليل الشركاء التجاريين (BaseCommercialDirectoryController)
///
/// يمثل نمط الاستراتيجية المؤسسي (Strategy Pattern) لإدارة شاشات الشركاء المشتركة بين مساحات العمل:
/// - يفصل الواجهة التصريحية تماماً عن المنطق التشغيلي الخاص بكل مساحة عمل.
/// - يضمن أن تكون الشاشة [CommercialDirectoryScreen] كوداً تصريحياً بحتاً (100% Declarative UI) بدون أي تفرعات شرطية.
abstract class BaseCommercialDirectoryController extends GetxController {
  /// عنوان الصفحة القيادي
  String get pageTitle;

  /// الوصف التوضيحي في ترويسة الصفحة
  String get pageSubtitle;

  /// أيقونة الترويسة الرئيسية
  IconData get pageIcon;

  /// الزر التفاعلي في ترويسة الصفحة (مثل زر دعوة نقطة بيع أو ربط مزود)
  Widget? get headerAction;

  /// تلميح حقل البحث النصي
  String get searchHint;

  /// هل العرض من منظور مساحة الشبكة
  bool get isNetworkView;

  /// قائمة روابط الشركاء التفاعلية
  RxList<NetworkPosLinkEntity> get links;

  /// حالة التحميل الأولي
  RxBool get isLoading;

  /// رسالة الخطأ الأولي إن وجدت
  RxnString get errorMessage;

  /// هل تتوفر صفحات إضافية للترقيم
  bool get hasMore;

  /// حالة تحميل الصفحة الإضافية
  RxBool get isLoadingMore;

  /// خطأ تحميل الصفحة الإضافية إن وجد
  RxnString get loadMoreError;

  /// فلتر الحالة المعتمد النشط (null = الكل)
  RxnString get statusFilter;

  /// النص المستعلم عنه حالياً
  RxString get searchQuery;

  /// وحدة التحكم النصية بحقل البحث
  TextEditingController get searchController;

  /// معرف الرابط المفتوح في الأكورديون حالياً
  RxnInt get expandedLinkId;

  /// إعادة تحديث البيانات والقائمة من البداية
  Future<void> refreshDirectory();

  /// تحميل المزيد من السجلات (Cursor Pagination)
  Future<void> loadMoreLinks();

  /// تعيين فلتر الحالة
  void setStatusFilter(String? status);

  /// مسح كافة الفلاتر والبحث
  void resetFilters();

  /// تبديل فتح وإغلاق أكورديون بطاقة الشريك
  void toggleAccordion(int linkId);

  /// فتح الشيت التعريفي لبيانات الشريك
  void openPartnerDetails(NetworkPosLinkEntity link);

  /// بناء بطاقات المؤشرات الإحصائية لشريط الملخص
  List<CustomKpiCardData> buildKpiCards(BuildContext context);

  /// بناء خيارات التصفية لشيت البحث الموحد
  List<CustomSearchFilterOption<String?>> buildFilterOptions(
    BuildContext context,
  );

  /// بناء أي فلاتر إضافية خاصة بمساحة العمل
  Widget? buildExtraFilters(BuildContext context);

  /// بناء شريط أزرار الإجراءات الخاصة ببطاقة الشريك وفق سياق مساحة العمل
  Widget buildCardActions(BuildContext context, NetworkPosLinkEntity link);
}
