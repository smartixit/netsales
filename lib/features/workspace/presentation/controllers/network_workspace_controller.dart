import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/core/utils/greeting_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/domain/usecases/get_network_workspace_overview_use_case.dart';
import 'package:netsales/features/workspace/presentation/mappers/network_workspace_dashboard_mapper.dart';
import 'package:netsales/features/workspace/presentation/mappers/network_workspace_transaction_mapper.dart';
import 'package:netsales/features/workspace/presentation/models/network_workspace_dashboard_view_model.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item_view_model.dart';

class NetworkWorkspaceController extends GetxController {
  NetworkWorkspaceController({
    required this.getMyNetworksUseCase,
    required this.getOverviewUseCase,
  });

  final GetMyNetworksUseCase getMyNetworksUseCase;
  final GetNetworkWorkspaceOverviewUseCase getOverviewUseCase;

  final RxInt selectedNavIndex = 0.obs;
  final RxInt selectedMobileNavIndex = 0.obs;
  final RxList<NetworkEntity> networks = <NetworkEntity>[].obs;
  final RxnInt selectedNetworkId = RxnInt();
  final Rxn<NetworkWorkspaceOverviewEntity> overview =
      Rxn<NetworkWorkspaceOverviewEntity>();
  final RxBool isLoadingNetworks = false.obs;
  final RxBool isLoadingOverview = false.obs;
  final RxnString networksError = RxnString();
  final RxnString overviewError = RxnString();
  final RxString selectedPeriod = '30d'.obs;

  int _revision = 0;

  NetworkEntity? get selectedNetwork => networks.firstWhereOrNull(
    (network) => network.networkId == selectedNetworkId.value,
  );

  String get activeNetworkName => selectedNetwork?.networkName ?? '';

  String get userName {
    final name = SessionService.to.currentUser?.userFullName.trim() ?? '';
    return name.isEmpty ? 'المستخدم' : name;
  }

  EnumPresentation get rolePresentation {
    final user = SessionService.to.currentUser;
    final activeNetworkId = selectedNetworkId.value;
    final membership = user?.workspaceMemberships.firstWhereOrNull(
      (item) =>
          item.scope == RoleScope.network &&
          activeNetworkId != null &&
          item.tenantId == activeNetworkId,
    );
    final rawRoleKey =
        membership?.roleKey ?? user?.role?.roleKey ?? user?.generalRoleKey;
    final serverLabel =
        membership?.roleName ??
        user?.role?.roleName ??
        user?.role?.roleKeyLabel;
    final presentation = EnumPresentationRegistry.resolveRoleKey(
      RoleKey.fromWire(rawRoleKey),
      serverLabel: serverLabel,
    );
    if (presentation.isKnown) return presentation;
    return EnumPresentationRegistry.resolveRoleScope(
      RoleScope.network,
      serverLabel: serverLabel,
    );
  }

  String get userRole => rolePresentation.label;
  String get welcomeGreeting => GreetingFormatter.greeting();
  String get todayFormatted => DateFormatter.fullDate(DateTime.now());
  String? get userProfileLogo => SessionService.to.currentUser?.userProfileLogo;
  String get userInitials => TextFormatter.avatarInitials(userName);

  NetworkWorkspaceDashboardViewModel get dashboardViewModel =>
      NetworkWorkspaceDashboardMapper.map(overview.value);

  int? get pendingRequestsCount => dashboardViewModel.pendingRequestsCount;

  List<WorkspaceTransactionItemViewModel> get recentPendingOrderItems =>
      NetworkWorkspaceTransactionMapper.mapPendingRequests(
        overview.value?.recentPendingRequests ?? const [],
        onOpenRequest: (requestId) => Get.toNamed<void>(
          AppRoutes.voucherRequestDetails,
          arguments: requestId,
        ),
      );

  @override
  void onInit() {
    super.onInit();
    unawaited(_initializeWorkspace());
  }

  Future<void> _initializeWorkspace() async {
    try {
      if (WorkspaceService.to.activeWorkspace != AppWorkspace.network) {
        await WorkspaceService.to.setActiveWorkspace(AppWorkspace.network);
      }
    } catch (error) {
      // Workspace selection is a local navigation preference. A storage
      // failure must not prevent loading the server-authorized network scope.
      log(
        '⚠️ [NetworkWorkspaceController] Could not persist active workspace preference: $error',
      );
    }
    await loadWorkspace();
  }

  @override
  void onClose() {
    _revision++;
    super.onClose();
  }

  void openPackagesCatalog() =>
      Get.toNamed<void>(AppRoutes.voucherPackagesCatalog);

  void openCreateSaleInvoice() =>
      Get.toNamed<void>(AppRoutes.networkCreateSaleInvoice);

  void onNavItemSelected(int index) {
    if (index < 0) return;
    selectedNavIndex.value = index;
    if (index < 4) selectedMobileNavIndex.value = index;
  }

  void openProfile() => onNavItemSelected(3);
  void openWholesaleInvoices() => onNavItemSelected(4);
  void openOperatingExpenses() => onNavItemSelected(5);
  void openPlatformBilling() => onNavItemSelected(6);
  void openBillingReports() => onNavItemSelected(7);
  void openTeamManagement() => onNavItemSelected(8);
  void openOperationalReports() => onNavItemSelected(9);

  Future<void> loadWorkspace() async {
    final revision = ++_revision;
    isLoadingNetworks.value = true;
    networksError.value = null;
    overviewError.value = null;
    isLoadingOverview.value = false;
    networks.clear();
    overview.value = null;
    selectedNetworkId.value = null;

    try {
      final result = await getMyNetworksUseCase();
      if (revision != _revision || isClosed) return;

      networks.assignAll(result);
      final ids = result
          .map((network) => network.networkId)
          .toList(growable: false);
      final selectedId = WorkspaceService.to.resolveWorkspaceActiveNetworkId(
        ids,
      );
      selectedNetworkId.value = selectedId;
      WorkspaceService.to.bindActiveMembership(RoleScope.network, selectedId);

      if (selectedId == null) {
        await WorkspaceService.to.clearActiveNetworkId();
        return;
      }

      await WorkspaceService.to.saveActiveNetworkId(selectedId);
      await loadOverview(revision: revision);
    } catch (error) {
      if (revision != _revision || isClosed) return;
      networks.clear();
      selectedNetworkId.value = null;
      WorkspaceService.to.bindActiveMembership(RoleScope.network, null);
      overview.value = null;
      networksError.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل الشبكات المصرح بها.',
      );
    } finally {
      if (revision == _revision && !isClosed) {
        isLoadingNetworks.value = false;
      }
    }
  }

  Future<void> loadOverview({int? revision}) async {
    final requestRevision = revision ?? ++_revision;
    final networkId = selectedNetworkId.value;
    if (networkId == null) {
      overview.value = null;
      overviewError.value = null;
      isLoadingOverview.value = false;
      return;
    }

    isLoadingOverview.value = true;
    overviewError.value = null;
    overview.value = null;
    try {
      final result = await getOverviewUseCase(
        networkId,
        period: selectedPeriod.value,
      );
      if (requestRevision != _revision || isClosed) return;
      if (result.networkId != networkId) {
        throw const FormatException(
          'أعاد الخادم ملخص شبكة لا تطابق الشبكة المحددة.',
        );
      }
      overview.value = result;
    } catch (error) {
      if (requestRevision != _revision || isClosed) return;
      overview.value = null;
      overviewError.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل مؤشرات الشبكة المحددة.',
      );
    } finally {
      if (requestRevision == _revision && !isClosed) {
        isLoadingOverview.value = false;
      }
    }
  }

  Future<void> selectNetwork(int? networkId) async {
    if (networkId == null || networkId == selectedNetworkId.value) return;
    final isAuthorized = networks.any(
      (network) => network.networkId == networkId,
    );
    if (!isAuthorized) return;

    final revision = ++_revision;
    selectedNetworkId.value = networkId;
    WorkspaceService.to.bindActiveMembership(RoleScope.network, networkId);
    overview.value = null;
    overviewError.value = null;
    isLoadingOverview.value = true;
    await WorkspaceService.to.saveActiveNetworkId(networkId);
    await loadOverview(revision: revision);
  }

  Future<void> selectPeriod(String period) async {
    if (selectedPeriod.value == period) return;
    selectedPeriod.value = period;
    await loadOverview();
  }

  Future<void> retryNetworks() => loadWorkspace();

  Future<void> retryOverview() => loadOverview();
}
