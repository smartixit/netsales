import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_event_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/activate_network_pos_agreement_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_agreement_draft_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_agreements_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_events_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/terminate_network_pos_agreement_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_network_pos_agreement_draft_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkPosLifecycleController extends GetxController {
  NetworkPosLifecycleController({
    required this.networkPosId,
    required this.getAgreementsUseCase,
    required this.getEventsUseCase,
    required this.createDraftUseCase,
    required this.updateDraftUseCase,
    required this.activateUseCase,
    required this.terminateUseCase,
  });

  final int networkPosId;
  final GetNetworkPosAgreementsUseCase getAgreementsUseCase;
  final GetNetworkPosEventsUseCase getEventsUseCase;
  final CreateNetworkPosAgreementDraftUseCase createDraftUseCase;
  final UpdateNetworkPosAgreementDraftUseCase updateDraftUseCase;
  final ActivateNetworkPosAgreementUseCase activateUseCase;
  final TerminateNetworkPosAgreementUseCase terminateUseCase;

  final agreements = <NetworkPosAgreementEntity>[].obs;
  final events = <NetworkPosEventEntity>[].obs;
  final isLoadingAgreements = true.obs;
  final isLoadingEvents = true.obs;
  final isLoadingMoreAgreements = false.obs;
  final isLoadingMoreEvents = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final eventsErrorMessage = RxnString();

  final titleController = TextEditingController();
  final referenceController = TextEditingController();
  final termsController = TextEditingController();
  final startsAtController = TextEditingController();
  final endsAtController = TextEditingController();

  String? _agreementsCursor;
  String? _eventsCursor;
  int _agreementsRevision = 0;
  int _eventsRevision = 0;

  bool get hasMoreAgreements => _agreementsCursor?.isNotEmpty == true;
  bool get hasMoreEvents => _eventsCursor?.isNotEmpty == true;

  @override
  void onInit() {
    super.onInit();
    loadAgreements();
    loadEvents();
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
    try {
      final result = await getAgreementsUseCase(
        networkPosId: networkPosId, cursor: _agreementsCursor, perPage: 15,
      );
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

  Future<void> loadMoreEvents() async {
    if (!hasMoreEvents || isLoadingMoreEvents.value) return;
    isLoadingMoreEvents.value = true;
    try {
      final result = await getEventsUseCase(
        networkPosId: networkPosId, cursor: _eventsCursor, perPage: 20,
      );
      events.addAll(result.items);
      _eventsCursor = result.nextCursor;
    } catch (error) {
      CustomSnackbar.show(title: 'خطأ', message: error.toString(), type: SnackType.error);
    } finally {
      isLoadingMoreEvents.value = false;
    }
  }

  void openDraftEditor({NetworkPosAgreementEntity? agreement}) {
    titleController.text = agreement?.title ?? '';
    referenceController.text = agreement?.reference ?? '';
    termsController.text = agreement?.terms ?? '';
    startsAtController.text = agreement?.startsAt ?? '';
    endsAtController.text = agreement?.endsAt ?? '';
    Get.dialog(CustomDialog.custom(
      title: agreement == null ? 'إنشاء مسودة اتفاقية' : 'تعديل مسودة الاتفاقية',
      confirmLabel: 'حفظ المسودة',
      cancelLabel: 'إلغاء',
      maxWidth: 640,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _agreementField(titleController, 'عنوان الاتفاقية'),
          _agreementField(referenceController, 'المرجع', required: false),
          _agreementField(termsController, 'الشروط والأحكام', lines: 5),
          _agreementField(startsAtController, 'بداية السريان (YYYY-MM-DD HH:mm:ss)', required: false),
          _agreementField(endsAtController, 'نهاية السريان (YYYY-MM-DD HH:mm:ss)', required: false),
        ],
      ),
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
    super.onClose();
  }
}
