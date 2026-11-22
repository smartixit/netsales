import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';

/// واجهة مشتركة للمتحكمات التي تدعم فلترة قيود دفاتر الأستاذ المالية
abstract interface class WalletFilterController {
  Rxn<WalletOperationType> get selectedOperationType;
  void setOperationFilter(WalletOperationType? type);
  TextEditingController get searchController;
  void onSearchChanged(String query);
}
