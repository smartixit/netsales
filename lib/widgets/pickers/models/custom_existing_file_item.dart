/// نموذج بيانات مجرد لعرض مرفق موجود مسبقاً على الخادم داخل [CustomFilePicker]
/// دون ربط المكوّن المشترك بأي كيان خاص بميزة معينة (Domain-Agnostic).
class CustomExistingFileItem {
  const CustomExistingFileItem({
    required this.id,
    required this.name,
    required this.url,
    this.isImage = false,
    this.isPdf = false,
    this.sizeLabel,
  });

  final int id;
  final String name;
  final String url;
  final bool isImage;
  final bool isPdf;
  final String? sizeLabel;
}
