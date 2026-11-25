import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/auth/domain/usecases/get_directorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/get_governorates_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_network_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkFormController extends GetxController {
  NetworkFormController({
    required this.getGovernorates,
    required this.getDirectorates,
    required this.createNetwork,
    required this.updateNetwork,
    required this.getNetworkDetails,
  });

  final GetGovernoratesUseCase getGovernorates;
  final GetDirectoratesUseCase getDirectorates;
  final CreateNetworkUseCase createNetwork;
  final UpdateNetworkUseCase updateNetwork;
  final GetNetworkDetailsUseCase getNetworkDetails;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final logo = ValueNotifier<File?>(null);
  final governorates = <GovernorateEntity>[].obs;
  final directorates = <DirectorateEntity>[].obs;
  final selectedGovernorate = Rxn<GovernorateEntity>();
  final selectedDirectorate = Rxn<DirectorateEntity>();
  final isLoading = false.obs;
  final isLoadingGovernorates = false.obs;
  final isLoadingDirectorates = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  int? networkId;
  int _directorateRevision = 0;

  bool get isEditing => networkId != null;

  @override
  void onInit() {
    super.onInit();
    final rawId = Get.parameters['id'];
    networkId = rawId == null ? null : int.tryParse(rawId);
    if (rawId != null && (networkId == null || networkId! <= 0)) {
      errorMessage.value = 'معرّف الشبكة غير صالح.';
      return;
    }
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadGovernorates();
    if (isClosed) return;
    final id = networkId;
    if (id == null) return;
    isLoading.value = true;
    try {
      final argument = Get.arguments;
      final entity = argument is NetworkEntity
          ? argument
          : await getNetworkDetails(id);
      if (isClosed) return;
      nameController.text = entity.networkName;
      addressController.text = entity.networkAddress ?? '';
      final governorate = governorates.firstWhereOrNull(
        (item) => item.governorateId == entity.governorateId,
      );
      selectedGovernorate.value = governorate;
      if (governorate != null) {
        await _loadDirectorates(governorate.governorateId);
        selectedDirectorate.value = directorates.firstWhereOrNull(
          (item) => item.directorateId == entity.directorateId,
        );
      }
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(error);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> _loadGovernorates() async {
    isLoadingGovernorates.value = true;
    try {
      final result = await getGovernorates.execute();
      if (isClosed) return;
      governorates.assignAll(result);
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(error);
    } finally {
      if (!isClosed) isLoadingGovernorates.value = false;
    }
  }

  Future<void> onGovernorateChanged(GovernorateEntity? value) async {
    selectedGovernorate.value = value;
    selectedDirectorate.value = null;
    directorates.clear();
    if (value != null) await _loadDirectorates(value.governorateId);
  }

  Future<void> _loadDirectorates(int governorateId) async {
    final revision = ++_directorateRevision;
    isLoadingDirectorates.value = true;
    try {
      final result = await getDirectorates.execute(governorateId);
      if (isClosed || revision != _directorateRevision) return;
      directorates.assignAll(result);
    } catch (error) {
      if (!isClosed && revision == _directorateRevision) {
        errorMessage.value = AppException.sanitizeMessage(error);
      }
    } finally {
      if (!isClosed && revision == _directorateRevision) {
        isLoadingDirectorates.value = false;
      }
    }
  }

  Future<void> save() async {
    if (isSaving.value || !(formKey.currentState?.validate() ?? false)) return;
    final governorate = selectedGovernorate.value;
    final directorate = selectedDirectorate.value;
    if (governorate == null || directorate == null) return;

    isSaving.value = true;
    try {
      final payload = <String, dynamic>{
        'network_name': nameController.text.trim(),
        'governorate_id': governorate.governorateId,
        'directorate_id': directorate.directorateId,
        'network_address': addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        if (logo.value != null) '_network_logo_path': logo.value!.path,
      };
      if (isEditing) {
        await updateNetwork(networkId: networkId!, payload: payload);
      } else {
        await createNetwork(payload);
      }
      CustomSnackbar.show(
        type: SnackType.success,
        title: isEditing ? 'تم تحديث الشبكة' : 'تم إنشاء الشبكة',
        message: isEditing ? 'حُدثت بيانات الشبكة بنجاح.' : 'أُنشئت الشبكة بنجاح.',
      );
      Get.back(result: true);
    } catch (error) {
      CustomSnackbar.show(
        type: SnackType.error,
        title: 'تعذر حفظ الشبكة',
        message: AppException.sanitizeMessage(error),
      );
    } finally {
      if (!isClosed) isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    logo.dispose();
    super.onClose();
  }
}
