/// Operational workspaces available in the NetSales mobile application.
enum AppWorkspace { network, pos }

extension AppWorkspaceExtension on AppWorkspace {
  bool get isNetwork => this == AppWorkspace.network;
  bool get isPos => this == AppWorkspace.pos;

  String get labelAr {
    switch (this) {
      case AppWorkspace.network:
        return 'مساحة عمل مزود الشبكة';
      case AppWorkspace.pos:
        return 'مساحة عمل نقطة البيع';
    }
  }

  String get labelEn {
    switch (this) {
      case AppWorkspace.network:
        return 'Network Workspace';
      case AppWorkspace.pos:
        return 'POS Workspace';
    }
  }
}
