class WorkspacePosPickerItemViewModel {
  const WorkspacePosPickerItemViewModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.subtitle,
    required this.isActive,
  });

  final int id;
  final String name;
  final String? logoUrl;
  final String subtitle;
  final bool isActive;
}
