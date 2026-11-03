/// ============================================================================
/// بيئات ومساحات العمل التشغيلية المعتمدة لنظام NetSales (App Workspace)
/// ============================================================================
/// يقتصر تطبيق الهاتف حصراً على مساحتي عمل تشغيليتين:
/// 1. مساحة مزود الشبكة (NETWORK Workspace)
/// 2. مساحة نقطة البيع (POS Workspace)
/// مع حظر حسابات إدارة المنصة العامة (SUPER_ADMIN / PLATFORM) وتوجيهها لتطبيق Windows المكتبي.
enum AppWorkspace {
  /// مساحة عمل مزود شبكة الإنترنت (Internet Network Provider)
  network,

  /// مساحة عمل نقطة البيع والوكيل المعتمد (Point of Sale / Agent)
  pos,

  /// حساب إدارة المنصة العامة (غير مدعوم بتطبيق الهاتف ومخصص لحواسيب Windows)
  unsupported,
}

extension AppWorkspaceExtension on AppWorkspace {
  bool get isNetwork => this == AppWorkspace.network;
  bool get isPos => this == AppWorkspace.pos;
  bool get isUnsupported => this == AppWorkspace.unsupported;

  String get labelAr {
    switch (this) {
      case AppWorkspace.network:
        return 'مساحة عمل مزود الشبكة';
      case AppWorkspace.pos:
        return 'مساحة عمل نقطة البيع';
      case AppWorkspace.unsupported:
        return 'إدارة المنصة العامة';
    }
  }

  String get labelEn {
    switch (this) {
      case AppWorkspace.network:
        return 'Network Workspace';
      case AppWorkspace.pos:
        return 'POS Workspace';
      case AppWorkspace.unsupported:
        return 'Platform Administration';
    }
  }
}
