import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// العقد المعماري الموحد لمتحكمات استعراض وإدارة فواتير المبيعات والمشتريات (BaseInvoicesController)
///
/// يمثل نمط الاستراتيجية المؤسسي (Strategy Pattern) لإدارة شاشات الفواتير المشتركة بين مساحات العمل:
/// - يفصل الواجهة التصريحية تماماً عن المنطق التشغيلي الخاص بكل مساحة عمل.
/// - يضمن أن تكون الشاشة [InvoicesScreen] كوداً تصريحياً بحتاً (100% Declarative UI) بدون أي تفرعات شرطية.
abstract class BaseInvoicesController extends GetxController {
  /// عنوان الصفحة القيادي
  String get pageTitle;

  /// الوصف التوضيحي في ترويسة الصفحة
  String get pageSubtitle;

  /// أيقونة الترويسة الرئيسية
  IconData get pageIcon;

  /// الزر التفاعلي في ترويسة الصفحة (مثل زر إصدار فاتورة مباشرة للشبكة)
  Widget? get headerAction;

  /// تلميح حقل البحث النصي
  String get searchHint;

  /// قائمة الفواتير التفاعلية
  RxList<InvoiceEntity> get invoices;

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

  /// فلتر حالة السداد النشط (PAID, PARTIALLY_PAID, UNPAID, null = الكل)
  RxnString get paymentStatusFilter;

  /// فلتر نوع البيع النشط (CASH, CREDIT, null = الكل)
  RxnString get selectedSaleType;

  /// النص المستعلم عنه حالياً
  RxString get searchQuery;

  /// وحدة التحكم النصية بحقل البحث
  TextEditingController get searchController;

  /// معرف الفاتورة المفتوحة في الأكورديون حالياً
  RxnInt get expandedInvoiceId;

  /// إعادة تحديث البيانات والقائمة من البداية
  Future<void> loadInvoices({bool isRefresh = false});

  /// تحميل المزيد من الفواتير (Cursor Pagination)
  Future<void> loadMoreInvoices();

  /// تعيين فلتر حالة السداد
  void setPaymentStatusFilter(String? status);

  /// تغيير فلتر نوع البيع
  void onSaleTypeChanged(String? saleType);

  /// مسح كافة الفلاتر والبحث
  void resetFilters();

  /// تبديل فتح وإغلاق أكورديون بطاقة الفاتورة
  void toggleInvoiceExpansion(int invoiceId);

  /// الانتقال لشاشة تفاصيل الفاتورة
  void openInvoiceDetails(InvoiceEntity invoice);

  /// طباعة الفاتورة مباشرة
  Future<void> printInvoice(InvoiceEntity invoice);

  /// مشاركة الفاتورة
  Future<void> shareInvoice(InvoiceEntity invoice);

  /// بناء بطاقات المؤشرات الإحصائية لشريط الملخص
  List<CustomKpiCardData> buildKpiCards(BuildContext context);

  /// بناء خيارات التصفية لشيت البحث الموحد
  List<CustomSearchFilterOption<String?>> buildFilterOptions(
    BuildContext context,
  );

  /// بناء أي فلاتر إضافية خاصة بمساحة العمل
  Widget? buildExtraFilters(BuildContext context);

  /// بناء شريط أزرار الإجراءات الخاصة ببطاقة الفاتورة وفق سياق مساحة العمل
  Widget buildCardActions(BuildContext context, InvoiceEntity invoice);
}
