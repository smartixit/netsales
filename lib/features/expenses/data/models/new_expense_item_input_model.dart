import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';

/// نموذج بيانات مدخل بند المصروف في طبقة البيانات (NewExpenseItemInputModel)
///
/// يرث من [NewExpenseItemInputEntity] ويتحمل حصرياً مسؤولية التحويل إلى JSON لطلبات الشبكة.
class NewExpenseItemInputModel extends NewExpenseItemInputEntity {
  const NewExpenseItemInputModel({
    required super.itemStatement,
    required super.itemAmount,
  });

  factory NewExpenseItemInputModel.fromEntity(NewExpenseItemInputEntity entity) {
    return NewExpenseItemInputModel(
      itemStatement: entity.itemStatement,
      itemAmount: entity.itemAmount,
    );
  }

  Map<String, dynamic> toJson() => {
    'item_statement': itemStatement,
    'item_amount': itemAmount,
  };
}
