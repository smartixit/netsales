import 'dart:async';

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
import 'package:netsales/core/utils/greeting_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/domain/usecases/get_network_workspace_overview_use_case.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item_view_model.dart';
import 'package:netsales/features/workspace/presentation/mappers/network_workspace_transaction_mapper.dart';
import 'package:netsales/features/workspace/presentation/mappers/network_workspace_dashboard_mapper.dart';
import 'package:netsales/features/workspace/presentation/mappers/network_provider_card_mapper.dart';
import 'package:netsales/features/workspace/presentation/models/network_provider_card_view_model.dart';
import 'package:netsales/features/workspace/presentation/models/network_workspace_dashboard_view_model.dart';

class NetworkWorkspaceController extends GetxController {
  NetworkWorkspaceController({
    required this.getMyNetworksUseCase,
    required this.getOverviewUseCase,
  });

  final GetMyNetworksUseCase getMyNetworksUseCase;
  final GetNetworkWorkspaceOverviewUseCase getOverviewUseCase;

  final RxInt selectedNavIndex = 0.obs;
  final networks = <NetworkEntity>[].obs;
  final RxnInt selectedNetworkId = RxnInt();
  final Rxn<NetworkWorkspaceOverviewEntity> overview =
      Rxn<NetworkWorkspaceOverviewEntity>();
  final isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final selectedPeriod = '30d'.obs;
  int _revision = 0;

  NetworkEntity? get selectedNetwork => networks.firstWhereOrNull(
    (network) => network.networkId == selectedNetworkId.value,
  );

  /// اسم الشبكة النشطة المعروضة
  String get activeNetworkName =>
      overview.value?.networkName ??
      selectedNetwork?.networkName ??
      'الشبكة المصرحة';


  /// اسم المستخدم من الجلسة
  String get userName {
    final name = SessionService.to.currentUser?.userFullName.trim() ?? '';
    return name.isEmpty ? 'المستخدم' : name;
  }

  /// كائن العرض الدلالي للدور الوظيفي لمزود الشبكة
  EnumPresentation get rolePresentation {
    final user = SessionService.to.currentUser;
    final membership = user?.workspaceMemberships.firstWhereOrNull(
      (m) => m.scope == RoleScope.network,
    );
    final rawRoleKey =
        membership?.roleKey ?? user?.role?.roleKey ?? user?.generalRoleKey;
    final serverLabel =
        membership?.roleName ??
        user?.role?.roleName ??
        user?.role?.roleKeyLabel;
    final typedRoleKey = RoleKey.fromWire(rawRoleKey);
    final presentation = EnumPresentationRegistry.resolveRoleKey(
      typedRoleKey,
      serverLabel: serverLabel,
    );
    if (presentation.isKnown) {
      return presentation;
    }
    return EnumPresentationRegistry.resolveRoleScope(
      RoleScope.network,
      serverLabel: serverLabel,
    );
  }

  /// رتبة أو صفة المستخدم المستخرجة ديناميكياً من Enum الأدوار وسجل العرض
  String get userRole => rolePresentation.label;

  /// تحية الوقت المركزية الموحدة
  String get welcomeGreeting => GreetingFormatter.greeting();

  /// تاريخ اليوم المنسق وفق المعايير
  String get todayFormatted => DateFormatter.fullDate(DateTime.now());

  /// رابط صورة المستخدم
  String? get userProfileLogo => SessionService.to.currentUser?.userProfileLogo;

  NetworkWorkspaceDashboardViewModel get dashboardViewModel =>
      NetworkWorkspaceDashboardMapper.map(overview.value);

  int get pendingRequestsCount => dashboardViewModel.pendingRequestsCount;

  List<NetworkProviderCardViewModel> get providerCards =>
      NetworkProviderCardMapper.map(
        networks: networks,
        selectedNetworkId: selectedNetworkId.value,
        overview: overview.value,
      );

  void openPackagesCatalog() =>
      Get.toNamed<void>(AppRoutes.voucherPackagesCatalog);

  void openWholesaleInvoices() =>
      Get.toNamed<void>(AppRoutes.wholesaleInvoices);

  void openRepaymentCollection() =>
      Get.toNamed<void>(AppRoutes.repaymentCollection);

  void openNetworkWalletStatement() =>
      Get.toNamed<void>(AppRoutes.networkWalletStatement);

  List<WorkspaceTransactionItemViewModel> get recentPendingOrderItems {
    return NetworkWorkspaceTransactionMapper.mapPendingRequests(
      overview.value?.recentPendingRequests ?? const [],
      onOpenRequest: (requestId) {
        Get.toNamed<void>(
          AppRoutes.voucherRequestDetails,
          arguments: requestId,
        );
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(_initializeWorkspace());
  }

  Future<void> _initializeWorkspace() async {
    if (WorkspaceService.to.activeWorkspace != AppWorkspace.network) {
      await WorkspaceService.to.setActiveWorkspace(AppWorkspace.network);
    }
    await loadWorkspace();
  }

  @override
  void onClose() {
    _revision++;
    super.onClose();
  }

  String get userInitials => TextFormatter.avatarInitials(userName, maxChars: 2);

  void openCreateSaleInvoice() =>
      Get.toNamed<void>(AppRoutes.networkCreateSaleInvoice);

  void onNavItemSelected(int index) => selectedNavIndex.value = index;

  Future<void> loadWorkspace() async {
    final revision = ++_revision;
    isLoading.value = true;
    errorMessage.value = null;
    overview.value = null;
    try {
      final result = await getMyNetworksUseCase();
      if (revision != _revision) return;
      networks.assignAll(result);

      final networkIds = result.map((n) => n.networkId).toList(growable: false);
      final resolvedId = WorkspaceService.to.resolveActiveNetworkId(networkIds);

      selectedNetworkId.value = resolvedId;
      if (resolvedId != null) {
        await WorkspaceService.to.saveActiveNetworkId(resolvedId);
      } else {
        await WorkspaceService.to.clearActiveNetworkId();
      }

      await loadOverview(revision: revision);
    } catch (error) {
      if (revision != _revision) return;
      errorMessage.value = error is AppException
          ? error.message
          : 'تعذر تحميل مساحة عمل الشبكة.';
    } finally {
      if (revision == _revision) isLoading.value = false;
    }
  }

  Future<void> loadOverview({int? revision}) async {
    final requestRevision = revision ?? ++_revision;
    final networkId = selectedNetworkId.value;
    if (networkId == null) {
      overview.value = null;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await getOverviewUseCase(
        networkId,
        period: selectedPeriod.value,
      );
      if (requestRevision != _revision) return;
      if (result.networkId != networkId) {
        throw const FormatException(
          'أعاد الخادم ملخص شبكة غير الشبكة المحددة.',
        );
      }
      overview.value = result;
    } catch (error) {
      if (requestRevision != _revision) return;
      overview.value = null;
      errorMessage.value = error is AppException
          ? error.message
          : error is FormatException
          ? error.message
          : 'تعذر جلب مؤشرات الشبكة.';
    } finally {
      if (requestRevision == _revision) isLoading.value = false;
    }
  }

  Future<void> selectNetwork(int? networkId) async {
    if (networkId == null || networkId == selectedNetworkId.value) return;
    selectedNetworkId.value = networkId;
    await WorkspaceService.to.saveActiveNetworkId(networkId);
    overview.value = null;
    await loadOverview();
  }

  Future<void> selectPeriod(String period) async {
    if (selectedPeriod.value == period) return;
    selectedPeriod.value = period;
    overview.value = null;
    await loadOverview();
  }

}
