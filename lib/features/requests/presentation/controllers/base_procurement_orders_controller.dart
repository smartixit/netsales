import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// العقد المعماري الموحد لمتحكمات استعراض وإدارة طلبات التوريد (BaseProcurementOrdersController)
///
/// يمثل نمط الاستراتيجية المؤسسي (Strategy Pattern) لإدارة شاشات المعاملات المشتركة بين مساحات العمل:
/// - يفصل الواجهة التصريحية تماماً عن المنطق التشغيلي الخاص بكل مساحة عمل.
/// - يضمن أن تكون الشاشة [ProcurementOrdersScreen] كوداً تصريحياً بحتاً (100% Declarative UI) بدون أي تفرعات شرطية.
abstract class BaseProcurementOrdersController extends GetxController {
  /// عنوان الصفحة القيادي
  String get pageTitle;

  /// الوصف التوضيحي في ترويسة الصفحة
  String get pageSubtitle;

  /// أيقونة الترويسة الرئيسية
  IconData get pageIcon;

  /// الزر التفاعلي في ترويسة الصفحة (إن وجد، مثل زر إنشاء طلب جديد)
  Widget? get headerAction;

  /// تلميح حقل البحث النصي
  String get searchHint;

  /// قائمة طلبات التوريد التفاعلية
  RxList<RequestEntity> get requests;

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

  /// الفلتر النشط للحالة (null = الكل)
  RxnString get statusFilter;

  /// النص المستعلم عنه حالياً
  RxString get searchQuery;

  /// وحدة التحكم النصية بحقل البحث
  TextEditingController get searchController;

  /// معرف الطلب المفتوح في الأكورديون حالياً
  RxnInt get expandedRequestId;

  /// إعادة تحديث البيانات والقائمة
  Future<void> refreshOrders();

  /// تحميل المزيد من الطلبات (Cursor Pagination)
  Future<void> loadMoreRequests();

  /// تعيين فلتر الحالة المعتمدة
  void setStatusFilter(String? status);

  /// مسح كافة الفلاتر والبحث
  void resetFilters();

  /// تبديل فتح وإغلاق أكورديون بطاقة الطلب
  void toggleAccordion(int requestId);

  /// الانتقال لشاشة تفاصيل الطلب
  void openRequestDetails(RequestEntity request);

  /// فتح الفاتورة المعتمدة المرتبطة بالطلب
  void openInvoice(int invoiceId);

  /// بناء بطاقات المؤشرات الإحصائية لشريط الملخص
  List<CustomKpiCardData> buildKpiCards(BuildContext context);

  /// بناء خيارات التصفية لشيت البحث الموحد
  List<CustomSearchFilterOption<String?>> buildFilterOptions(
    BuildContext context,
  );

  /// بناء أي فلاتر إضافية خاصة بمساحة العمل (مثل قائمة اختيار الشبكات)
  Widget? buildExtraFilters(BuildContext context);

  /// بناء شريط أزرار الإجراءات الخاصة ببطاقة الطلب وفق سياق مساحة العمل
  Widget buildCardActions(BuildContext context, RequestEntity request);
}
