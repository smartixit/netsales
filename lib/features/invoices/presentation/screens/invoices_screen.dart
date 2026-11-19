import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/invoices/presentation/views/network_wholesale_invoices_view.dart';
import 'package:netsales/features/invoices/presentation/views/pos_purchase_invoices_view.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// واجهة استعراض وإدارة الفواتير الموحدة للمنصة (InvoicesScreen)
///
/// تعمل كواجهة موحدة لكلا مساحتي العمل:
/// 1. مساحة شبكة التوزيع (Network Workspace): عبر [NetworkWholesaleInvoicesView].
/// 2. مساحة نقطة البيع (POS Workspace): عبر [PosPurchaseInvoicesView].
class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({
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
        ? NetworkWholesaleInvoicesView(embedded: embedded)
        : PosPurchaseInvoicesView(embedded: embedded);

    if (embedded) return view;

    return CustomAppScaffold(
      appBarTitle: isNetworkWorkspace
          ? 'فواتير مبيعات الجملة'
          : 'فواتير المشتريات',
      body: view,
    );
  }
}
