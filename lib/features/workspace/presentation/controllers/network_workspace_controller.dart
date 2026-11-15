import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/core/utils/greeting_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/domain/usecases/get_network_workspace_overview_use_case.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item.dart';
import 'package:netsales/widgets/charts/charting.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

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

  /// خيارات الفترات المعتمدة من الباكيند API
  static const List<ChartPeriodOption> periodOptions = [
    ChartPeriodOption(id: '7d', label: '7 أيام'),
    ChartPeriodOption(id: '30d', label: '30 يوماً'),
    ChartPeriodOption(id: '90d', label: '3 أشهر'),
    ChartPeriodOption(id: '12m', label: 'سنة'),
  ];

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
    final rawRoleKey = membership?.roleKey ??
        user?.role?.roleKey ??
        user?.generalRoleKey;
    final serverLabel = membership?.roleName ??
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

  /// عدد طلبات التغذية المعلقة
  int get pendingRequestsCount {
    final hasRequests =
        overview.value?.metrics.containsKey('requests') ?? false;
    if (!hasRequests) return 0;
    return int.tryParse(overview.value?.count('requests', 'pending') ?? '0') ??
        0;
  }

  /// قائمة طلبات التوريد المعلقة المحولة كـ ViewModels جاهزة للعرض
  List<WorkspaceTransactionItem> get recentPendingOrderItems {
    final pending = overview.value?.recentPendingRequests ?? const [];
    return pending.map((req) {
      final refShort = req.requestUuid.isNotEmpty
          ? req.requestUuid.split('-').first
          : '#${req.requestId}';
      final date = DateFormatter.tryParse(req.requestDate);
      final dateText = date != null ? DateFormatter.smart(date) : '';
      final subtitle = dateText.isNotEmpty
          ? '${req.saleTypeLabel} • $dateText'
          : req.saleTypeLabel;

      final statusPresentation = EnumPresentationRegistry.resolveRequestStatus(
        req.status,
        serverLabel: req.statusLabel,
      );

      return WorkspaceTransactionItem(
        title: req.posName,
        reference: refShort,
        subtitle: subtitle,
        formattedAmount:
            '${AmountFormatter.formatValue(req.requestTotalAmount)} ر.ي',
        statusPresentation: statusPresentation,
        initials: TextFormatter.avatarInitials(req.posName, maxChars: 2),
        actionLabel: 'اعتماد',
        onAction: () {
          Get.toNamed<void>(
            AppRoutes.voucherRequestDetails,
            arguments: req.requestId,
          );
        },
        onTap: () {
          Get.toNamed<void>(
            AppRoutes.voucherRequestDetails,
            arguments: req.requestId,
          );
        },
      );
    }).toList(growable: false);
  }

  /// تنسيق قيمة مبيعات الشبكة الجاهزة للعرض
  String formatNetworkSales(NetworkEntity network, bool isSelected) {
    if (!isSelected) return '••••';
    final salesMetric = overview.value?.metric('sales');
    final salesTotal = salesMetric?['total_amount'] ?? salesMetric?['total'];
    if (salesTotal is num) {
      return '${AmountFormatter.formatValue(salesTotal, decimalPlaces: 0)} YER';
    }
    return '0 YER';
  }

  /// تنسيق عدد نقاط بيع الشبكة الجاهز للعرض
  String formatNetworkPosCount(NetworkEntity network, bool isSelected) {
    if (!isSelected) return 'وكلاء معتمدين';
    final posMetric = overview.value?.metric('points_of_sale') ??
        overview.value?.metric('pos');
    final posTotal = posMetric?['total'];
    if (posTotal != null) {
      return '$posTotal نقطة بيع';
    }
    return 'وكلاء معتمدين';
  }

  /// ملخص السيولة المالية الجاهز للعرض
  ({
    String balance,
    bool hasWallet,
    bool isWalletActive,
    bool hasSales,
    double growthRate,
    String cashSales,
    String outstandingReceivables,
    String posCoverage,
  }) get liquiditySummary {
    final ov = overview.value;
    if (ov == null) {
      return (
        balance: '0.00',
        hasWallet: false,
        isWalletActive: false,
        hasSales: false,
        growthRate: 0.0,
        cashSales: '0.00',
        outstandingReceivables: '0.00',
        posCoverage: '0/0',
      );
    }
    final wallet = ov.metric('wallet');
    final sales = ov.metric('sales');
    final pos = ov.metric('points_of_sale');

    final hasWallet = wallet != null;
    final hasSales = sales != null;

    final balance = (wallet != null)
        ? AmountFormatter.format(ov.amount('wallet', 'balance'))
        : (sales != null
            ? AmountFormatter.format(ov.amount('sales', 'total_amount'))
            : '0.00');

    final isWalletActive = wallet?['is_active'] == true;
    final rawGrowth = sales?['growth_rate'];
    final double growthRate = (rawGrowth is num) ? rawGrowth.toDouble() : 0.0;

    final cashSales = sales != null
        ? AmountFormatter.format(ov.amount('sales', 'paid_amount'))
        : '0.00';

    final outstanding = sales != null
        ? AmountFormatter.format(ov.amount('sales', 'outstanding_amount'))
        : '0.00';

    final posTotal = pos != null ? ov.count('points_of_sale', 'total') : '0';
    final posActive = pos != null ? ov.count('points_of_sale', 'active') : '0';

    return (
      balance: balance,
      hasWallet: hasWallet,
      isWalletActive: isWalletActive,
      hasSales: hasSales,
      growthRate: growthRate,
      cashSales: cashSales,
      outstandingReceivables: outstanding,
      posCoverage: '$posActive/$posTotal',
    );
  }

  /// ملخص مؤشرات المبيعات السريع المرافق للمنحنى
  ({
    String totalSales,
    int invoiceCount,
    double growthRate,
  }) get salesVelocitySummary {
    final ov = overview.value;
    final sales = ov?.metric('sales');
    if (sales == null) {
      return (totalSales: '0.00', invoiceCount: 0, growthRate: 0.0);
    }

    final totalSales = sales['total_amount'] != null
        ? AmountFormatter.format(sales['total_amount'].toString())
        : '0.00';

    final invoiceCount = sales['invoice_count'] is num
        ? (sales['invoice_count'] as num).toInt()
        : int.tryParse(sales['invoice_count']?.toString() ?? '0') ?? 0;

    final rawGrowth = sales['growth_rate'];
    final double growthRate = (rawGrowth is num) ? rawGrowth.toDouble() : 0.0;

    return (
      totalSales: totalSales,
      invoiceCount: invoiceCount,
      growthRate: growthRate,
    );
  }

  /// تعريف مخطط وتيرة المبيعات الجاهز للعرض
  ChartDefinition get salesChartDefinition {
    final sales = overview.value?.metric('sales');
    final rawTrend = sales?['trend'];
    final List<dynamic> trendList = (rawTrend is List) ? rawTrend : const [];

    final points = <ChartDataPoint>[];
    for (int i = 0; i < trendList.length; i++) {
      final item = trendList[i];
      if (item is Map) {
        final date = item['date']?.toString() ?? '';
        final total = (item['total'] is num)
            ? (item['total'] as num).toDouble()
            : double.tryParse(item['total']?.toString() ?? '0') ?? 0.0;
        final label = _formatChartDate(date);
        points.add(ChartDataPoint(x: label, y: total));
      }
    }

    return ChartDefinition(
      family: ChartFamily.cartesian,
      type: ChartType.splineArea,
      series: [
        ChartSeries(
          id: 'sales_velocity',
          name: 'المبيعات',
          data: points,
          strokeWidth: 2.8,
          opacity: 0.22,
        ),
      ],
      options: const ChartOptions(
        showMarkers: true,
        showTooltip: true,
        enableTrackball: false,
        showMajorGridLines: false,
      ),
      state: points.isEmpty ? ChartState.empty : ChartState.data,
      stateMessage: points.isEmpty
          ? 'لا توجد فواتير مبيعات مسجلة في هذه الفترة'
          : null,
    );
  }

  /// قائمة بطاقات المؤشرات الستة الحيوية الجاهزة للعرض
  List<DashboardMetricData> get kpiMetrics {
    final ov = overview.value;
    if (ov == null) return const [];
    final metrics = ov.metrics;
    final items = <DashboardMetricData>[];

    // 1. نقاط البيع
    if (metrics.containsKey('points_of_sale')) {
      final total = ov.count('points_of_sale', 'total');
      final active = ov.count('points_of_sale', 'active');
      final inactive = ov.count('points_of_sale', 'inactive');
      items.add(
        DashboardMetricData(
          id: 'pos',
          title: 'نقاط البيع',
          value: total,
          unit: 'نقطة',
          icon: Icons.storefront_rounded,
          tone: DashboardMetricTone.primary,
          variant: DashboardMetricVariant.standard,
          description: 'نشطة $active · غير نشطة $inactive',
        ),
      );
    }

    // 2. طلبات التوريد
    if (metrics.containsKey('requests')) {
      final total = ov.count('requests', 'total');
      final pending = ov.count('requests', 'pending');
      items.add(
        DashboardMetricData(
          id: 'requests',
          title: 'طلبات التوريد',
          value: total,
          unit: 'طلب',
          icon: Icons.inbox_rounded,
          tone: DashboardMetricTone.warning,
          variant: DashboardMetricVariant.standard,
          description: 'بانتظار الاعتماد $pending',
        ),
      );
    }

    // 3. باقات الكتالوج
    if (metrics.containsKey('packages')) {
      final total = ov.count('packages', 'total');
      final active = ov.count('packages', 'active');
      items.add(
        DashboardMetricData(
          id: 'packages',
          title: 'باقات الكتالوج',
          value: total,
          unit: 'باقة',
          icon: Icons.widgets_rounded,
          tone: DashboardMetricTone.info,
          variant: DashboardMetricVariant.standard,
          description: 'باقات نشطة: $active',
        ),
      );
    }

    // 4. فواتير المبيعات
    if (metrics.containsKey('sales')) {
      final invoiceCount = ov.count('sales', 'invoice_count');
      final totalSalesAmount = AmountFormatter.format(
        ov.amount('sales', 'total_amount'),
      );
      items.add(
        DashboardMetricData(
          id: 'sales',
          title: 'فواتير المبيعات',
          value: totalSalesAmount,
          unit: 'ر.ي',
          icon: Icons.receipt_long_rounded,
          tone: DashboardMetricTone.success,
          variant: DashboardMetricVariant.standard,
          description: '$invoiceCount فاتورة معتمدة',
        ),
      );
    }

    // 5. مصروفات الشبكة
    if (metrics.containsKey('expenses')) {
      final expenseCount = ov.count('expenses', 'count');
      final totalExpensesAmount = AmountFormatter.format(
        ov.amount('expenses', 'total_amount'),
      );
      items.add(
        DashboardMetricData(
          id: 'expenses',
          title: 'مصروفات الشبكة',
          value: totalExpensesAmount,
          unit: 'ر.ي',
          icon: Icons.trending_down_rounded,
          tone: DashboardMetricTone.danger,
          variant: DashboardMetricVariant.standard,
          description: '$expenseCount سند موثق',
        ),
      );
    }

    // 6. محفظة الشبكة
    final wallet = metrics['wallet'];
    if (wallet is Map<String, dynamic>) {
      final balance = AmountFormatter.format(
        ov.amount('wallet', 'balance'),
      );
      final isActive = wallet['is_active'] == true;
      items.add(
        DashboardMetricData(
          id: 'wallet',
          title: 'رصيد المحفظة',
          value: balance,
          unit: 'ر.ي',
          icon: Icons.account_balance_wallet_rounded,
          tone: isActive
              ? DashboardMetricTone.primary
              : DashboardMetricTone.danger,
          variant: DashboardMetricVariant.status,
          statusLabel: isActive ? 'المحفظة نشطة' : 'المحفظة معطلة',
          description: isActive ? 'جاهزة للعمليات' : 'غير مفعلة',
        ),
      );
    }

    return items;
  }

  static String _formatChartDate(String rawDate) {
    if (rawDate.length >= 10) {
      final parts = rawDate.split('-');
      if (parts.length >= 3) return '${parts[2]}/${parts[1]}';
    }
    return rawDate;
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
