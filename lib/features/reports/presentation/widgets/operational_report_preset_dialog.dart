import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// Dialog flow for naming and persisting an operational report preset.
class OperationalReportPresetDialog {
  OperationalReportPresetDialog._();

  static Future<void> show({
    required Future<void> Function(String name) onSave,
  }) async {
    final nameController = TextEditingController();
    try {
      await CustomDialog.show(
        type: DialogType.custom,
        title: 'حفظ إعداد التقرير',
        maxWidth: 420,
        content: Padding(
          padding: const EdgeInsets.all(8),
          child: CustomTextField(
            controller: nameController,
            label: 'اسم الإعداد',
            hint: 'مثال: تقرير المبيعات الشهري',
            maxLength: 120,
            isRequired: true,
          ),
        ),
        confirmLabel: 'حفظ',
        cancelLabel: 'إلغاء',
        onConfirm: () {
          final name = nameController.text.trim();
          if (name.isEmpty) return;
          unawaited(onSave(name));
        },
      );
    } finally {
      nameController.dispose();
    }
  }
}
