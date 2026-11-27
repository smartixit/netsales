import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// العقد المعماري الموحد لمتحكمات استعراض وإدارة عضويات مساحة العمل (BaseMembershipsController)
///
/// يمثل نمط الاستراتيجية المؤسسي (Strategy Pattern) لإدارة شاشات العضويات المشتركة بين مساحات العمل:
/// - يفصل الواجهة التصريحية تماماً عن المنطق التشغيلي الخاص بكل مساحة عمل.
/// - يضمن أن تكون الشاشة [MembershipsScreen] كوداً تصريحياً بحتاً (100% Declarative UI) بدون أي تفرعات شرطية.
abstract class BaseMembershipsController extends GetxController {
  /// عنوان الصفحة القيادي
  String get pageTitle;

  /// الوصف التوضيحي في ترويسة الصفحة
  String get pageSubtitle;

  /// أيقونة الترويسة الرئيسية
  IconData get pageIcon;

  /// الزر التفاعلي في ترويسة الصفحة (زر إضافة عضو جديد)
  bool get canAddMember;
  bool get canChangeMemberRole;
  bool get canChangeMemberStatus;
  bool get canRemoveMember;
  int get totalMembersCount;
  int get activeMembersCount;
  int get suspendedMembersCount;
  int get invitedMembersCount;

  /// تلميح حقل البحث النصي
  String get searchHint;

  /// هل العرض من منظور مساحة الشبكة
  bool get isNetworkView;

  /// قائمة أعضاء مساحة العمل التفاعلية
  RxList<WorkspaceMemberEntity> get members;

  /// حالة التحميل الأولي
  RxBool get isLoading;

  /// رسالة الخطأ الأولي إن وجدت
  RxnString get errorMessage;

  /// الفلتر النشط للحالة (null = الكل)
  RxnString get statusFilter;

  /// النص المستعلم عنه حالياً
  RxString get searchQuery;

  /// وحدة التحكم النصية بحقل البحث
  TextEditingController get searchController;

  /// معرف العضو المفتوح في الأكورديون حالياً
  RxnInt get expandedMemberId;

  RxList<MembershipRoleEntity> get assignableRoles;

  Future<void> addMember({
    required String phoneNumber,
    required int roleId,
    String? status,
  });

  Future<void> changeMemberRole(
    WorkspaceMemberEntity member,
    int roleId,
    String? reason,
  );

  Future<void> changeMemberStatus(
    WorkspaceMemberEntity member,
    String status,
    String? reason,
  );

  Future<void> removeMember(
    WorkspaceMemberEntity member,
    String? reason,
  );

  /// إعادة تحديث البيانات والقائمة من البداية
  Future<void> refreshMembers();

  /// تعيين فلتر الحالة المعتمدة
  void setStatusFilter(String? status);

  /// مسح كافة الفلاتر والبحث
  void resetFilters();

  /// تبديل فتح وإغلاق أكورديون بطاقة العضو
  void toggleAccordion(int memberId);


  /// خيارات تصفية العضويات المعروضة في شريط البحث الموحد.
  List<CustomSearchFilterOption<String?>> buildFilterOptions();

}
