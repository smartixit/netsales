/// ملخص الفروقات بين طلب POS الأصلي والفاتورة النهائية كما أعاده Laravel.
class RequestModificationSummaryEntity {
  final bool hasModifications;
  final double originalTotal;
  final double approvedTotal;
  final int originalItemsCount;
  final int approvedItemsCount;

  const RequestModificationSummaryEntity({
    required this.hasModifications,
    required this.originalTotal,
    required this.approvedTotal,
    required this.originalItemsCount,
    required this.approvedItemsCount,
  });
}
