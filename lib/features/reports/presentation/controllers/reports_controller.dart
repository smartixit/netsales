import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/services/share_service.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/reports/domain/entities/report_network_option.dart';
import 'package:netsales/features/reports/domain/entities/report_type.dart';
import 'package:netsales/features/reports/domain/usecases/get_report_use_case.dart';
import 'package:netsales/features/reports/domain/usecases/request_report_export_use_case.dart';
import 'package:netsales/features/reports/domain/usecases/get_report_export_status_use_case.dart';
import 'package:netsales/features/reports/domain/usecases/download_report_export_use_case.dart';

class ReportsController extends GetxController {
  ReportsController(this.getReport, this.getMyNetworks, this.getPosNetworks, this.requestExport, this.getExportStatus, this.downloadExport);
  final GetReportUseCase getReport;
  final GetMyNetworksUseCase getMyNetworks;
  final GetPosNetworksListUseCase getPosNetworks;
  final RequestReportExportUseCase requestExport;
  final GetReportExportStatusUseCase getExportStatus;
  final DownloadReportExportUseCase downloadExport;

  final types = ReportType.values.obs;
  final selectedType = ReportType.sales.obs;
  final networks = <ReportNetworkOption>[].obs;
  final selectedNetworkId = RxnInt();
  final rows = <Map<String, dynamic>>[].obs;
  final loading = false.obs;
  final loadingMore = false.obs;
  final isResolvingContext = false.obs;
  final isExporting = false.obs;
  final exportStatusMessage = RxnString();
  final error = RxnString();
  final nextCursor = RxnString();
  String? fromDate;
  String? toDate;
  int _requestSequence = 0;

  bool get hasMore => nextCursor.value != null && nextCursor.value!.isNotEmpty;
  bool get canView => PermissionService.to.can(selectedType.value.permission);
  bool get isPosWorkspace =>
      WorkspaceService.to.activeWorkspace == AppWorkspace.pos;

  @override
  void onInit() {
    super.onInit();
    resolveNetworks();
  }

  Future<void> resolveNetworks() async {
    isResolvingContext.value = true;
    error.value = null;
    try {
      final options = <ReportNetworkOption>[];
      if (isPosWorkspace) {
        final posId = WorkspaceService.to.savedActivePosId;
        if (posId == null) {
          error.value = 'اختر نقطة البيع النشطة أولاً من مساحة العمل.';
          return;
        }
        final links = await getPosNetworks(posId, perPage: 100);
        for (final link in links.items) {
          final network = link.network;
          if (link.status && network != null) {
            options.add(ReportNetworkOption(
              networkId: link.networkId,
              name: network.networkName,
            ));
          }
        }
      } else {
        final result = await getMyNetworks();
        for (final network in result) {
          options.add(ReportNetworkOption(
            networkId: network.networkId,
            name: network.networkName,
          ));
        }
      }
      networks.assignAll(options);
      final savedId = WorkspaceService.to.savedActiveNetworkId;
      if (savedId != null && options.any((item) => item.networkId == savedId)) {
        selectedNetworkId.value = savedId;
      } else if (options.length == 1) {
        selectedNetworkId.value = options.single.networkId;
      } else {
        selectedNetworkId.value = null;
      }
      if (selectedNetworkId.value != null) {
        await load(refresh: true);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isResolvingContext.value = false;
    }
  }

  void selectNetwork(int? id) {
    if (id == null || selectedNetworkId.value == id) return;
    selectedNetworkId.value = id;
    load(refresh: true);
  }

  void selectType(ReportType type) {
    if (selectedType.value == type) return;
    selectedType.value = type;
    load(refresh: true);
  }

  Future<void> load({bool refresh = false}) async {
    final networkId = selectedNetworkId.value;
    if (networkId == null) return;
    if (!canView) {
      rows.clear();
      error.value = 'لا تملك صلاحية عرض هذا التقرير.';
      return;
    }
    if (refresh) {
      loading.value = true;
      nextCursor.value = null;
      error.value = null;
    } else {
      if (loading.value || loadingMore.value || !hasMore) return;
      loadingMore.value = true;
    }
    final sequence = ++_requestSequence;
    try {
      final page = await getReport(
        type: selectedType.value,
        networkId: networkId,
        posId: isPosWorkspace ? WorkspaceService.to.savedActivePosId : null,
        fromDate: fromDate,
        toDate: toDate,
        cursor: refresh ? null : nextCursor.value,
        perPage: 25,
      );
      if (sequence != _requestSequence) return;
      if (refresh) rows.clear();
      rows.addAll(page.rows);
      nextCursor.value = page.nextCursor;
    } catch (e) {
      if (sequence == _requestSequence) error.value = e.toString();
    } finally {
      if (sequence == _requestSequence) {
        loading.value = false;
        loadingMore.value = false;
      }
    }
  }

  @override
  void onClose() {
    _requestSequence++;
    super.onClose();
  }
}
