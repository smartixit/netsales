import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/membership/presentation/views/network_members_view.dart';
import 'package:netsales/features/membership/presentation/views/pos_members_view.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// الشاشة الرئيسية الحاضنة لإدارة أعضاء وفريق المنشأة (MembershipScreen)
///
/// تعمل كحاضنة موحدة للشاشات المستقلة والواجهات المضمنة (مطابقة لنمط CommercialDirectoryScreen و InvoicesScreen):
/// 1. مساحة شبكة التوزيع (Network Workspace): عبر [NetworkMembersView].
/// 2. مساحة نقطة البيع (POS Workspace): عبر [PosMembersView].
class MembershipScreen extends StatelessWidget {
  const MembershipScreen({
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
        ? NetworkMembersView(embedded: embedded)
        : PosMembersView(embedded: embedded);

    if (embedded) return view;

    return CustomAppScaffold(
      appBarTitle:
          isNetworkWorkspace ? 'فريق عمل الشبكة' : 'فريق عمل نقطة البيع',
      body: view,
    );
  }
}
