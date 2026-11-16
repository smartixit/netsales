class WorkspaceNetworkPickerItemViewModel {
  const WorkspaceNetworkPickerItemViewModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.initials,
    required this.subtitle,
    required this.isActive,
  });

  final int id;
  final String name;
  final String? logoUrl;
  final String initials;
  final String subtitle;
  final bool isActive;
}
