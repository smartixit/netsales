class ExpenseEntity {
  final int expenseId;
  final int networkId;
  final String expenseUuid;
  final double totalAmount;
  final String? expenseDate;
  final String? networkName;
  final String? createdByName;
  final List<ExpenseItemEntity> items;
  final List<ExpenseAttachmentEntity> attachments;

  const ExpenseEntity({
    required this.expenseId,
    required this.networkId,
    required this.expenseUuid,
    required this.totalAmount,
    this.expenseDate,
    this.networkName,
    this.createdByName,
    this.items = const [],
    this.attachments = const [],
  });
}

class ExpenseItemEntity {
  final int itemId;
  final String statement;
  final double amount;
  const ExpenseItemEntity({
    required this.itemId,
    required this.statement,
    required this.amount,
  });
}

class ExpenseAttachmentEntity {
  final int attachmentId;
  final String name;
  final String? mimeType;
  final int sizeBytes;
  final String? fileUrl;
  const ExpenseAttachmentEntity({
    required this.attachmentId,
    required this.name,
    this.mimeType,
    this.sizeBytes = 0,
    this.fileUrl,
  });
}
