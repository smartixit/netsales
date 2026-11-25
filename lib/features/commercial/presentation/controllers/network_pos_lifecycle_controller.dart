import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_event_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_pos_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_network_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_package_pos_discounts_for_pos_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/create_package_pos_discount_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/update_package_pos_discount_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_pos_discount_status_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_pos_discount_use_case.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/commercial/domain/usecases/activate_network_pos_agreement_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_agreement_draft_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_agreements_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_events_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_trashed_network_pos_links_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/restore_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/terminate_network_pos_agreement_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_network_pos_agreement_draft_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkPosLifecycleController extends GetxController {
  NetworkPosLifecycleController({
    required this.networkPosId,
    required this.networkId,
    required this.posId,
    required this.getNetworkPackagesUseCase,
    required this.getPackagePosDiscountsUseCase,
    required this.createPackagePosDiscountUseCase,
    required this.updatePackagePosDiscountUseCase,
    required this.togglePackagePosDiscountStatusUseCase,
    required this.deletePackagePosDiscountUseCase,
    required this.entityId,
    required this.isNetworkScope,
    required this.getTrashedLinksUseCase,
    required this.restoreLinkUseCase,
    required this.getAgreementsUseCase,
    required this.getEventsUseCase,
    required this.createDraftUseCase,
    required this.updateDraftUseCase,
    required this.activateUseCase,
    required this.terminateUseCase,
  });

  final int networkPosId;
  final int networkId;
  final int posId;
  final GetNetworkPackagesUseCase getNetworkPackagesUseCase;
  final GetPackagePosDiscountsForPosUseCase getPackagePosDiscountsUseCase;
  final CreatePackagePosDiscountUseCase createPackagePosDiscountUseCase;
  final UpdatePackagePosDiscountUseCase updatePackagePosDiscountUseCase;
  final TogglePackagePosDiscountStatusUseCase togglePackagePosDiscountStatusUseCase;
  final DeletePackagePosDiscountUseCase deletePackagePosDiscountUseCase;
  final int entityId;
  final bool isNetworkScope;
  final GetTrashedNetworkPosLinksUseCase getTrashedLinksUseCase;
  final RestoreNetworkPosLinkUseCase restoreLinkUseCase;
  final GetNetworkPosAgreementsUseCase getAgreementsUseCase;
  final GetNetworkPosEventsUseCase getEventsUseCase;
  final CreateNetworkPosAgreementDraftUseCase createDraftUseCase;
  final UpdateNetworkPosAgreementDraftUseCase updateDraftUseCase;
  final ActivateNetworkPosAgreementUseCase activateUseCase;
  final TerminateNetworkPosAgreementUseCase terminateUseCase;

  final agreements = <NetworkPosAgreementEntity>[].obs;
  final events = <NetworkPosEventEntity>[].obs;
  final archivedLinks = <NetworkPosLinkEntity>[].obs;
  final packages = <PackageEntity>[].obs;
  final packageDiscounts = <PackagePosDiscountEntity>[].obs;
  final selectedPackageId = RxnInt();
  final isLoadingAgreements = true.obs;
  final isLoadingEvents = true.obs;
  final isLoadingArchive = true.obs;
  final isLoadingDiscounts = true.obs;
  final isLoadingPackages = true.obs;
  final isSavingDiscount = false.obs;
  final isLoadingMoreAgreements = false.obs;
  final isLoadingMoreEvents = false.obs;
  final isLoadingMoreArchive = false.obs;
  final isLoadingMoreDiscounts = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final eventsErrorMessage = RxnString();
  final archiveErrorMessage = RxnString();
  final discountsErrorMessage = RxnString();
  final packagesErrorMessage = RxnString();

  final titleController = TextEditingController();
  final referenceController = TextEditingController();
  final termsController = TextEditingController();
  final startsAtController = TextEditingController();
  final endsAtController = TextEditingController();
  final discountCashController = TextEditingController();
  final discountCreditController = TextEditingController();
  final discountStartController = TextEditingController();
  final discountEndController = TextEditingController();

  String? _agreementsCursor;
  String? _eventsCursor;
  String? _archiveCursor;
  String? _discountsCursor;
  int _agreementsRevision = 0;
  int _eventsRevision = 0;
  int _archiveRevision = 0;
  int _discountsRevision = 0;
  int _discountsRevision = 0;

  bool get canViewAgreements => PermissionService.to.can(
    isNetworkScope ? AppPermissions.networkViewPosAgreements : AppPermissions.posViewNetworkAgreements,
  );
  bool get canViewEvents => PermissionService.to.can(
    isNetworkScope ? AppPermissions.networkViewPosLinkEvents : AppPermissions.posViewNetworkLinkEvents,
  );
  bool get canManageAgreements => PermissionService.to.can(
    isNetworkScope ? AppPermissions.networkManagePosAgreements : AppPermissions.posManageNetworkAgreements,
  );
  bool get canRestoreLinks => PermissionService.to.can(
    isNetworkScope ? AppPermissions.networkRestorePosLink : AppPermissions.posRestoreNetworkLink,
  );
  bool get canViewCatalog => PermissionService.to.can(AppPermissions.voucherPackageDiscountsView);
  bool get canCreateDiscount => PermissionService.to.can(AppPermissions.voucherPackageDiscountsCreate);
  bool get canEditDiscount => PermissionService.to.can(AppPermissions.voucherPackageDiscountsEdit);
  bool get canToggleDiscount => PermissionService.to.can(AppPermissions.voucherPackageDiscountsToggleStatus);
  bool get canDeleteDiscount => PermissionService.to.can(AppPermissions.voucherPackageDiscountsDelete);
  bool get canManageDiscounts => canCreateDiscount || canEditDiscount || canToggleDiscount || canDeleteDiscount;
  bool get canViewArchive => PermissionService.to.can(
    isNetworkScope ? AppPermissions.networksView : AppPermissions.posView,
  );

  bool get hasMoreAgreements => _agreementsCursor?.isNotEmpty == true;
  bool get hasMoreEvents => _eventsCursor?.isNotEmpty == true;
  bool get hasMoreArchive => _archiveCursor?.isNotEmpty == true;

  @override
  void onInit() {
    super.onInit();
    if (canViewAgreements) loadAgreements();
    if (canViewEvents) loadEvents();
    if (canViewArchive) loadArchivedLinks();
    if (canViewCatalog) {
      loadPackages();
      loadPackageDiscounts();
    }
  }

  Future<void> loadAgreements({bool refresh = false}) async {
    final revision = ++_agreementsRevision;
    if (refresh) {
      _agreementsCursor = null;
      agreements.clear();
    }
    isLoadingAgreements.value = agreements.isEmpty;
    errorMessage.value = null;
    try {
      final result = await getAgreementsUseCase(networkPosId: networkPosId, perPage: 15);
      if (revision != _agreementsRevision) return;
      agreements.assignAll(result.items);
      _agreementsCursor = result.nextCursor;
    } catch (error) {
      if (revision == _agreementsRevision) errorMessage.value = error.toString();
    } finally {
      if (revision == _agreementsRevision) isLoadingAgreements.value = false;
    }
  }

  Future<void> loadMoreAgreements() async {
    if (!hasMoreAgreements || isLoadingMoreAgreements.value) return;
    isLoadingMoreAgreements.value = true;
    final revision = _agreementsRevision;
    final cursor = _agreementsCursor;
    try {
      final result = await getAgreementsUseCase(
        networkPosId: networkPosId, cursor: cursor, perPage: 15,
      );
      if (revision != _agreementsRevision) return;
      agreements.addAll(result.items);
      _agreementsCursor = result.nextCursor;
    } catch (error) {
      CustomSnackbar.show(title: 'خطأ', message: error.toString(), type: SnackType.error);
    } finally {
      isLoadingMoreAgreements.value = false;
    }
  }

  Future<void> loadEvents({bool refresh = false}) async {
    final revision = ++_eventsRevision;
    if (refresh) {
      _eventsCursor = null;
      events.clear();
    }
    isLoadingEvents.value = events.isEmpty;
    eventsErrorMessage.value = null;
    try {
      final result = await getEventsUseCase(networkPosId: networkPosId, perPage: 20);
      if (revision != _eventsRevision) return;
      events.assignAll(result.items);
      _eventsCursor = result.nextCursor;
    } catch (error) {
      if (revision == _eventsRevision) eventsErrorMessage.value = error.toString();
    } finally {
      if (revision == _eventsRevision) isLoadingEvents.value = false;
    }
  }

  Future<void> loadPackages() async {
    isLoadingPackages.value = true;
    packagesErrorMessage.value = null;
    try {
      final result = await getNetworkPackagesUseCase(networkId, status: true, perPage: 50);
      packages.assignAll(result.items);
    } catch (error) {
      packagesErrorMessage.value = error.toString();
    } finally {
      isLoadingPackages.value = false;
    }
  }

  Future<void> loadPackageDiscounts({bool refresh = false}) async {
    final revision = ++_discountsRevision;
    if (networkId <= 0 || posId <= 0) {
      discountsErrorMessage.value = 'بيانات نطاق العلاقة غير مكتملة.';
      isLoadingDiscounts.value = false;
      return;
    }
    if (refresh) {
      _discountsCursor = null;
      packageDiscounts.clear();
    }
    isLoadingDiscounts.value = packageDiscounts.isEmpty;
    discountsErrorMessage.value = null;
    try {
      final result = await getPackagePosDiscountsUseCase(
        networkId: networkId,
        posId: posId,
        perPage: 15,
      );
      if (revision != _discountsRevision) return;
      packageDiscounts.assignAll(result.items);
      _discountsCursor = result.nextCursor;
    } catch (error) {
      if (revision == _discountsRevision) discountsErrorMessage.value = error.toString();
    } finally {
      if (revision == _discountsRevision) isLoadingDiscounts.value = false;
    }
  }

  bool get hasMorePackageDiscounts => _discountsCursor?.isNotEmpty == true;

  Future<void> loadMorePackageDiscounts() async {
    if (!hasMorePackageDiscounts || isLoadingMoreDiscounts.value) return;
    isLoadingMoreDiscounts.value = true;
    final revision = _discountsRevision;
    final cursor = _discountsCursor;
    try {
      final result = await getPackagePosDiscountsUseCase(
        networkId: networkId,
        posId: posId,
        cursor: cursor,
        perPage: 15,
      );
      if (revision == _discountsRevision) {
        packageDiscounts.addAll(result.items);
        _discountsCursor = result.nextCursor;
      }
    } catch (error) {
      if (revision == _discountsRevision) {
        CustomSnackbar.show(title: 'خطأ', message: error.toString(), type: SnackType.error);
      }
    } finally {
      isLoadingMoreDiscounts.value = false;
    }
  }

  String packageNameFor(int? packageId) {
    for (final package in packages) {
      if (package.packageId == packageId) return package.packageName;
    }
    return packageId == null ? 'باقة غير محددة' : 'باقة #$packageId';
  }

  void openDiscountEditor({PackagePosDiscountEntity? discount}) {
    if (discount == null && !canCreateDiscount) return;
    if (discount == null && packages.isEmpty) {
      CustomSnackbar.show(title: 'لا توجد باقات', message: 'لا توجد باقات نشطة في الشبكة لتخصيص خصم عليها.', type: SnackType.warning);
      return;
    }
    if (discount != null && !canEditDiscount) return;
    selectedPackageId.value = discount?.packageId;
    discountCashController.text = discount?.discountCash.toString() ?? '';
    discountCreditController.text = discount?.discountCredit.toString() ?? '';
    discountStartController.text = discount?.startDate?.toIso8601String() ?? '';
    discountEndController.text = discount?.endDate?.toIso8601String() ?? '';
    Get.dialog(CustomDialog(
      type: DialogType.custom,
      title: discount == null ? 'تخصيص خصم للباقة' : 'تعديل خصم نقطة البيع',
      confirmLabel: 'حفظ الخصم',
      cancelLabel: 'إلغاء',
      maxWidth: 620,
      autoCloseOnConfirm: false,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (discount == null)
              CustomDropdown<int>(
                label: 'الباقة',
                hint: 'اختر الباقة',
                rxValue: selectedPackageId,
                items: packages.map((item) => DropdownItem<int>(
                  value: item.packageId,
                  child: Text(item.packageName),
                )).toList(growable: false),
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: Text('الباقة: ${packageNameFor(discount.packageId)}'),
              ),
            _agreementField(discountCashController, 'نسبة الخصم النقدي %'),
            _agreementField(discountCreditController, 'نسبة الخصم الآجل %'),
            _agreementField(discountStartController, 'بداية السريان (اختياري)', required: false),
            _agreementField(discountEndController, 'نهاية السريان (اختياري)', required: false),
          ],
        ),
      ),
      onConfirm: () => saveDiscount(discount: discount),
    ));
  }

  Future<void> saveDiscount({PackagePosDiscountEntity? discount}) async {
    if (isSavingDiscount.value ||
        (discount == null && !canCreateDiscount) ||
        (discount != null && !canEditDiscount)) return;
    final cash = double.tryParse(AmountFormatter.clean(discountCashController.text));
    final credit = double.tryParse(AmountFormatter.clean(discountCreditController.text));
    if (cash == null || credit == null || cash < 0 || cash > 100 || credit < 0 || credit > 100) {
      CustomSnackbar.show(title: 'بيانات غير صحيحة', message: 'أدخل نسب خصم رقمية بين 0 و100.', type: SnackType.warning);
      return;
    }
    if (discount == null && selectedPackageId.value == null) {
      CustomSnackbar.show(title: 'اختر الباقة', message: 'يجب تحديد الباقة قبل حفظ الخصم.', type: SnackType.warning);
      return;
    }
    isSavingDiscount.value = true;
    try {
      final payload = <String, dynamic>{
        'discount_cash': cash,
        'discount_credit': credit,
        'discount_start_date': discountStartController.text.trim().isEmpty ? null : discountStartController.text.trim(),
        'discount_end_date': discountEndController.text.trim().isEmpty ? null : discountEndController.text.trim(),
      };
      if (discount == null) {
        payload.addAll({
          'network_id': networkId,
          'pos_id': posId,
          'package_id': selectedPackageId.value,
          'status': true,
        });
        await createPackagePosDiscountUseCase(payload);
      } else {
        await updatePackagePosDiscountUseCase(discount.discountId, payload);
      }
      Get.back();
      await loadPackageDiscounts(refresh: true);
      await loadEvents(refresh: true);
      CustomSnackbar.show(title: 'نجاح', message: 'تم حفظ خصم الباقة.', type: SnackType.success);
    } catch (error) {
      CustomSnackbar.show(title: 'تعذر الحفظ', message: error.toString(), type: SnackType.error);
    } finally {
      isSavingDiscount.value = false;
    }
  }

  Future<void> toggleDiscount(PackagePosDiscountEntity discount) async {
    if (!canToggleDiscount || isSavingDiscount.value) return;
    isSavingDiscount.value = true;
    try {
      await togglePackagePosDiscountStatusUseCase(discount.discountId);
      await loadPackageDiscounts(refresh: true);
      await loadEvents(refresh: true);
      CustomSnackbar.show(title: 'نجاح', message: 'تم تحديث حالة الخصم.', type: SnackType.success);
    } catch (error) {
      CustomSnackbar.show(title: 'خطأ', message: error.toString(), type: SnackType.error);
    } finally {
      isSavingDiscount.value = false;
    }
  }

  Future<void> deleteDiscount(PackagePosDiscountEntity discount) async {
    if (!canDeleteDiscount || isSavingDiscount.value) return;
    final confirmed = await CustomDialog.confirmation(
      title: 'حذف الخصم',
      message: 'سيتم حذف الخصم المخصص لهذه الباقة من العلاقة. لن يتم حذف الباقة أو بيانات نقطة البيع.',
      confirmLabel: 'حذف الخصم',
      onConfirm: () {},
    ).showDialog();
    if (confirmed != true) return;
    isSavingDiscount.value = true;
    try {
      await deletePackagePosDiscountUseCase(discount.discountId);
      await loadPackageDiscounts(refresh: true);
      await loadEvents(refresh: true);
      CustomSnackbar.show(title: 'نجاح', message: 'تم حذف الخصم.', type: SnackType.success);
    } catch (error) {
      CustomSnackbar.show(title: 'خطأ', message: error.toString(), type: SnackType.error);
    } finally {
      isSavingDiscount.value = false;
    }
  }

  Future<void> loadArchivedLinks({bool refresh = false}) async {
    final revision = ++_archiveRevision;
    if (refresh) {
      _archiveCursor = null;
      archivedLinks.clear();
    }
    isLoadingArchive.value = archivedLinks.isEmpty;
    archiveErrorMessage.value = null;
    try {
      final result = await getTrashedLinksUseCase(
        entityId: entityId,
        isNetwork: isNetworkScope,
        perPage: 15,
      );
      if (revision != _archiveRevision) return;
      archivedLinks.assignAll(result.items);
      _archiveCursor = result.nextCursor;
    } catch (error) {
      if (revision == _archiveRevision) archiveErrorMessage.value = error.toString();
    } finally {
      if (revision == _archiveRevision) isLoadingArchive.value = false;
    }
  }

  Future<void> loadMoreArchivedLinks() async {
    if (_archiveCursor == null || _archiveCursor!.isEmpty || isLoadingMoreArchive.value) return;
    isLoadingMoreArchive.value = true;
    final revision = _archiveRevision;
    final cursor = _archiveCursor;
    try {
      final result = await getTrashedLinksUseCase(
        entityId: entityId,
        isNetwork: isNetworkScope,
        cursor: cursor,
        perPage: 15,
      );
      if (revision != _archiveRevision) return;
      archivedLinks.addAll(result.items);
      _archiveCursor = result.nextCursor;
    } catch (error) {
      CustomSnackbar.show(title: 'خطأ', message: error.toString(), type: SnackType.error);
    } finally {
      isLoadingMoreArchive.value = false;
    }
  }

  Future<void> restoreLink(NetworkPosLinkEntity link) async {
    if (!canRestoreLinks) return;
    isSaving.value = true;
    try {
      await restoreLinkUseCase(link.networkPosId);
      archivedLinks.removeWhere((item) => item.networkPosId == link.networkPosId);
      await loadEvents(refresh: true);
      CustomSnackbar.show(title: 'نجاح', message: 'تمت استعادة العلاقة التجارية.', type: SnackType.success);
    } catch (error) {
      CustomSnackbar.show(title: 'تعذر الاستعادة', message: error.toString(), type: SnackType.error);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> loadMoreEvents() async {
    if (!hasMoreEvents || isLoadingMoreEvents.value) return;
    isLoadingMoreEvents.value = true;
    final revision = _eventsRevision;
    final cursor = _eventsCursor;
    try {
      final result = await getEventsUseCase(
        networkPosId: networkPosId, cursor: cursor, perPage: 20,
      );
      if (revision != _eventsRevision) return;
      events.addAll(result.items);
      _eventsCursor = result.nextCursor;
    } catch (error) {
      CustomSnackbar.show(title: 'خطأ', message: error.toString(), type: SnackType.error);
    } finally {
      isLoadingMoreEvents.value = false;
    }
  }

  void openDraftEditor({NetworkPosAgreementEntity? agreement}) {
    if (!canManageAgreements) return;
    titleController.text = agreement?.title ?? '';
    referenceController.text = agreement?.reference ?? '';
    termsController.text = agreement?.terms ?? '';
    startsAtController.text = agreement?.startsAt ?? '';
    endsAtController.text = agreement?.endsAt ?? '';
    Get.dialog(CustomDialog(
      type: DialogType.custom,
      title: agreement == null ? 'إنشاء مسودة اتفاقية' : 'تعديل مسودة الاتفاقية',
      confirmLabel: 'حفظ المسودة',
      cancelLabel: 'إلغاء',
      maxWidth: 640,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          _agreementField(titleController, 'عنوان الاتفاقية'),
          _agreementField(referenceController, 'المرجع', required: false),
          _agreementField(termsController, 'الشروط والأحكام', lines: 5),
          _agreementField(startsAtController, 'بداية السريان (YYYY-MM-DD HH:mm:ss)', required: false),
            _agreementField(endsAtController, 'نهاية السريان (YYYY-MM-DD HH:mm:ss)', required: false),
          ],
        ),
      ),
      autoCloseOnConfirm: false,
      onConfirm: () => saveDraft(agreement: agreement),
    ));
  }

  Widget _agreementField(TextEditingController fieldController, String label, {
    bool required = true,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: CustomTextField(
      controller: fieldController,
      label: label,
      maxLines: lines,
      isRequired: required,
    ),
  );

  Future<void> saveDraft({NetworkPosAgreementEntity? agreement}) async {
    if (isSaving.value || !canManageAgreements) return;
    final title = titleController.text.trim();
    final terms = termsController.text.trim();
    if (title.isEmpty || terms.isEmpty) {
      CustomSnackbar.show(title: 'بيانات ناقصة', message: 'عنوان الاتفاقية والشروط حقول إلزامية.', type: SnackType.warning);
      return;
    }
    isSaving.value = true;
    try {
      final payload = <String, dynamic>{
        'title': title,
        'reference': referenceController.text.trim().isEmpty ? null : referenceController.text.trim(),
        'terms': terms,
        'starts_at': startsAtController.text.trim().isEmpty ? null : startsAtController.text.trim(),
        'ends_at': endsAtController.text.trim().isEmpty ? null : endsAtController.text.trim(),
      };
      if (agreement == null) {
        await createDraftUseCase(networkPosId: networkPosId, payload: payload);
      } else {
        await updateDraftUseCase(
          networkPosId: networkPosId, agreementId: agreement.agreementId, payload: payload,
        );
      }
      Get.back();
      await loadAgreements(refresh: true);
      await loadEvents(refresh: true);
      CustomSnackbar.show(title: 'نجاح', message: 'تم حفظ مسودة الاتفاقية.', type: SnackType.success);
    } catch (error) {
      CustomSnackbar.show(title: 'خطأ', message: error.toString(), type: SnackType.error);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> activate(NetworkPosAgreementEntity agreement) async {
    if (!canManageAgreements) return;
    final confirmed = await CustomDialog.confirmation(
      title: 'اعتماد الاتفاقية',
      message: 'سيتم اعتماد الإصدار ${agreement.version} كاتفاقية نشطة للعلاقة. لا يمكن تعديل الإصدار بعد اعتماده.',
      confirmLabel: 'اعتماد الاتفاقية',
      onConfirm: () {},
    ).showDialog();
    if (confirmed != true) return;
    await _runAgreementAction(
      () => activateUseCase(networkPosId: networkPosId, agreementId: agreement.agreementId),
      'تم اعتماد الاتفاقية.',
    );
  }

  Future<void> terminate(NetworkPosAgreementEntity agreement) async {
    if (!canManageAgreements) return;
    final confirmed = await CustomDialog.confirmation(
      title: 'إنهاء الاتفاقية',
      message: 'سيتم إنهاء الاتفاقية النشطة. لن تُحذف بياناتها أو سجل اعتمادها.',
      confirmLabel: 'إنهاء الاتفاقية',
      onConfirm: () {},
    ).showDialog();
    if (confirmed != true) return;
    await _runAgreementAction(
      () => terminateUseCase(networkPosId: networkPosId, agreementId: agreement.agreementId),
      'تم إنهاء الاتفاقية.',
    );
  }

  Future<void> _runAgreementAction(
    Future<NetworkPosAgreementEntity> Function() action,
    String success,
  ) async {
    if (isSaving.value || !canManageAgreements) return;
    isSaving.value = true;
    try {
      await action();
      await loadAgreements(refresh: true);
      await loadEvents(refresh: true);
      CustomSnackbar.show(title: 'نجاح', message: success, type: SnackType.success);
    } catch (error) {
      CustomSnackbar.show(title: 'خطأ', message: error.toString(), type: SnackType.error);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    referenceController.dispose();
    termsController.dispose();
    startsAtController.dispose();
    endsAtController.dispose();
    discountCashController.dispose();
    discountCreditController.dispose();
    discountStartController.dispose();
    discountEndController.dispose();
    super.onClose();
  }
}
