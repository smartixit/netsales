import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/requests/presentation/views/network_procurement_orders_view.dart';
import 'package:netsales/features/requests/presentation/views/pos_procurement_orders_view.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// واجهة استعراض وإدارة طلبات التوريد الموحدة للمنصة (ProcurementOrdersScreen)
///
/// تعمل كواجهة موحدة وحيدة لكلا مساحتي العمل:
/// 1. مساحة نقطة البيع (POS Workspace): عبر [PosProcurementOrdersView].
/// 2. مساحة شبكة التوزيع (Network Workspace): عبر [NetworkProcurementOrdersView].
class ProcurementOrdersScreen extends StatelessWidget {
  const ProcurementOrdersScreen({
    super.key,
    this.embedded = false,
    this.isNetwork,
  });

  final bool embedded;
  final bool? isNetwork;

  @override
  Widget build(BuildContext context) {
    final isNetworkWorkspace = isNetwork ??
        (Get.isRegistered<WorkspaceService>() &&
            WorkspaceService.to.activeWorkspace == AppWorkspace.network);

    final view = isNetworkWorkspace
        ? NetworkProcurementOrdersView(embedded: embedded)
        : PosProcurementOrdersView(embedded: embedded);

    if (embedded) return view;

    return CustomAppScaffold(
      appBarTitle: isNetworkWorkspace
          ? 'طلبات التوريد الواردة'
          : 'طلبات التوريد',
      body: view,
    );
  }
}
