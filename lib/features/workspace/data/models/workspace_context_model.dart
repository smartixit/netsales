import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/workspace/domain/entities/workspace_context_entity.dart';

/// نموذج سياق مساحة العمل لنقل وتخزين البيانات
class WorkspaceContextModel extends WorkspaceContextEntity {
  const WorkspaceContextModel({
    required super.workspace,
    super.tenantId,
    super.tenantName,
    super.roleKey,
    super.permissions,
  });

  factory WorkspaceContextModel.fromJson(Map<String, dynamic> json) {
    final workspaceName = json['workspace']?.toString() ?? 'network';
    final workspace = AppWorkspace.values.firstWhere(
      (w) => w.name == workspaceName,
      orElse: () => AppWorkspace.network,
    );

    return WorkspaceContextModel(
      workspace: workspace,
      tenantId: json['tenant_id'] as int?,
      tenantName: json['tenant_name']?.toString(),
      roleKey: json['role_key']?.toString(),
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workspace': workspace.name,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'role_key': roleKey,
      'permissions': permissions,
    };
  }
}
