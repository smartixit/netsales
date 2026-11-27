import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
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
  bool get hasHeaderAction;
  void onHeaderAction();
  bool get canTogglePartnerLink;
  bool get canDeletePartnerLink;
  bool get canViewPartnerWallet;
  bool get canViewRelationshipLifecycle;
  Future<void> togglePartnerLink(NetworkPosLinkEntity link);
  Future<void> deletePartnerLink(NetworkPosLinkEntity link);
  void openPosWalletStatement(NetworkPosLinkEntity link);
  void openRelationshipLifecycle(NetworkPosLinkEntity link);
  RxnInt get selectedScopeId;
  String get scopeFilterLabel;
  List<CustomSearchFilterOption<int?>> get scopeFilterOptions;
  void onScopeFilterChanged(int? id);
  int get totalPartnersCount;
  int get activePartnersCount;
  int get inactivePartnersCount;

  /// تلميح حقل البحث النصي
  List<CustomSearchFilterOption<String?>> buildFilterOptions();

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


}
