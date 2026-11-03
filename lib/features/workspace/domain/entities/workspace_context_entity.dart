import 'package:netsales/core/enums/app_workspace.dart';

/// الكيان الدوميني لسياق مساحة العمل النشطة
class WorkspaceContextEntity {
  final AppWorkspace workspace;
  final int? tenantId;
  final String? tenantName;
  final String? roleKey;
  final List<String> permissions;

  const WorkspaceContextEntity({
    required this.workspace,
    this.tenantId,
    this.tenantName,
    this.roleKey,
    this.permissions = const [],
  });

  bool get isNetwork => workspace == AppWorkspace.network;
  bool get isPos => workspace == AppWorkspace.pos;
  bool get isUnsupported => workspace == AppWorkspace.unsupported;

  WorkspaceContextEntity copyWith({
    AppWorkspace? workspace,
    int? tenantId,
    String? tenantName,
    String? roleKey,
    List<String>? permissions,
  }) {
    return WorkspaceContextEntity(
      workspace: workspace ?? this.workspace,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      roleKey: roleKey ?? this.roleKey,
      permissions: permissions ?? this.permissions,
    );
  }
}

