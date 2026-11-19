import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/presentation/views/network_pos_directory_view.dart';
import 'package:netsales/features/commercial/presentation/views/pos_linked_networks_view.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// واجهة استعراض وإدارة دليل الشركاء والعلاقات التجارية الموحدة للمنصة (CommercialDirectoryScreen)
///
/// تعمل كواجهة موحدة لكلا مساحتي العمل:
/// 1. مساحة شبكة التوزيع (Network Workspace): عبر [NetworkPosDirectoryView].
/// 2. مساحة نقطة البيع (POS Workspace): عبر [PosLinkedNetworksView].
class CommercialDirectoryScreen extends StatelessWidget {
  const CommercialDirectoryScreen({
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
        ? NetworkPosDirectoryView(embedded: embedded)
        : PosLinkedNetworksView(embedded: embedded);

    if (embedded) return view;

    return CustomAppScaffold(
      appBarTitle:
          isNetworkWorkspace ? 'دليل نقاط البيع والشركاء' : 'الشبكات المزودة',
      body: view,
    );
  }
}
