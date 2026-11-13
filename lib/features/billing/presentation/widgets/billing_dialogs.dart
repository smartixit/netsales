import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:get/get.dart';
import 'package:netsales/core/services/file_picker_service.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_file_picker.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// تدفقات حوارات الفوترة المعتمدة. جميع النوافذ تمر عبر CustomDialog،
/// ومدخلات الملفات تمر عبر CustomFilePicker وخدمة الملفات المركزية.
class BillingDialogs {
  BillingDialogs._();

  static Future<void> editAccount(
    BillingController controller,
    Map<String, dynamic> account,
  ) async {
    final legal = TextEditingController(text: account['legal_name']?.toString() ?? '');
    final email = TextEditingController(text: account['billing_email']?.toString() ?? '');
    final tax = TextEditingController(text: account['tax_number']?.toString() ?? '');
    final address = TextEditingController(text: account['billing_address']?.toString() ?? '');
    final terms = TextEditingController(text: account['payment_terms_days']?.toString() ?? '0');
    try {
      final accepted = await CustomDialog.show(
        type: DialogType.custom,
        title: 'تعديل حساب الفوترة',
        maxWidth: 560,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: legal, label: 'الاسم القانوني', isRequired: true),
              CustomTextField(controller: email, label: 'البريد المحاسبي', keyboardType: TextInputType.emailAddress, isRequired: false),
              CustomTextField(controller: tax, label: 'الرقم الضريبي', isRequired: false),
              CustomTextField(controller: address, label: 'عنوان الفوترة', maxLines: 2, isRequired: false),
              CustomTextField(controller: terms, label: 'أيام السداد', keyboardType: TextInputType.number, isRequired: true),
            ],
          ),
        ),
        confirmLabel: 'حفظ',
        cancelLabel: 'إلغاء',
      );
      if (accepted == true && legal.text.trim().isNotEmpty) {
        await controller.updateAccount({
          'legal_name': legal.text.trim(),
          'billing_email': email.text.trim().isEmpty ? null : email.text.trim(),
          'tax_number': tax.text.trim().isEmpty ? null : tax.text.trim(),
          'billing_address': address.text.trim().isEmpty ? null : address.text.trim(),
          'payment_terms_days': int.tryParse(terms.text.trim()) ?? 0,
        });
      }
    } finally {
      legal.dispose();
      email.dispose();
      tax.dispose();
      address.dispose();
      terms.dispose();
    }
  }

  static Future<void> addContact(BillingController controller) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    try {
      final accepted = await CustomDialog.show(
        type: DialogType.custom,
        title: 'إضافة جهة اتصال',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: name, label: 'الاسم', isRequired: true),
            CustomTextField(controller: email, label: 'البريد الإلكتروني', keyboardType: TextInputType.emailAddress, isRequired: false),
            CustomTextField(controller: phone, label: 'رقم الهاتف', keyboardType: TextInputType.phone, isRequired: false),
          ],
        ),
        confirmLabel: 'إضافة',
        cancelLabel: 'إلغاء',
      );
      if (accepted == true && name.text.trim().isNotEmpty) {
        await controller.createContact({
          'name': name.text.trim(),
          'email': email.text.trim().isEmpty ? null : email.text.trim(),
          'phone': phone.text.trim().isEmpty ? null : phone.text.trim(),
          'is_primary': false,
          'receives_invoices': true,
        });
      }
    } finally {
      name.dispose();
      email.dispose();
      phone.dispose();
    }
  }

  static Future<void> editContact(
    BillingController controller,
    Map<String, dynamic> contact,
  ) async {
    final name = TextEditingController(text: contact['name']?.toString() ?? '');
    final email = TextEditingController(text: contact['email']?.toString() ?? '');
    final phone = TextEditingController(text: contact['phone']?.toString() ?? '');
    try {
      final accepted = await CustomDialog.show(
        type: DialogType.custom,
        title: 'تعديل جهة الاتصال',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: name, label: 'الاسم', isRequired: true),
            CustomTextField(controller: email, label: 'البريد الإلكتروني', keyboardType: TextInputType.emailAddress, isRequired: false),
            CustomTextField(controller: phone, label: 'رقم الهاتف', keyboardType: TextInputType.phone, isRequired: false),
          ],
        ),
        confirmLabel: 'حفظ',
        cancelLabel: 'إلغاء',
      );
      final id = (contact['contact_id'] as num?)?.toInt();
      if (accepted == true && id != null && name.text.trim().isNotEmpty) {
        await controller.updateContact(id, {
          'name': name.text.trim(),
          'email': email.text.trim().isEmpty ? null : email.text.trim(),
          'phone': phone.text.trim().isEmpty ? null : phone.text.trim(),
        });
      }
    } finally {
      name.dispose();
      email.dispose();
      phone.dispose();
    }
  }

  static Future<void> deleteContact(BillingController controller, int id) async {
    final accepted = await CustomDialog.show(
      type: DialogType.danger,
      title: 'حذف جهة الاتصال',
      message: 'هل تريد حذف جهة الاتصال المحددة؟',
      confirmLabel: 'حذف',
      cancelLabel: 'إلغاء',
    );
    if (accepted == true) await controller.deleteContact(id);
  }

  static Future<void> payInvoice(
    BillingController controller,
    Map<String, dynamic> invoice,
  ) async {
    final invoiceId = (invoice['invoice_id'] as num?)?.toInt();
    final remaining = int.tryParse(invoice['remaining_minor']?.toString() ?? '0') ?? 0;
    if (invoiceId == null || remaining <= 0 || controller.paymentMethods.isEmpty) return;

    final amount = TextEditingController(text: remaining.toString());
    final reference = TextEditingController();
    controller.paymentProof.value = null;
    try {
      final accepted = await CustomDialog.show(
        type: DialogType.custom,
        title: 'تسجيل دفعة على الفاتورة',
        maxWidth: 560,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('المبلغ المتبقي: $remaining وحدة صغرى'),
              ),
              Obx(() => CustomDropdown<int>(
                items: controller.paymentMethods.map((method) => DropdownItem<int>(
                  value: (method['payment_method_id'] as num).toInt(),
                  child: Text(method['name']?.toString() ?? method['code']?.toString() ?? 'وسيلة دفع'),
                )).toList(),
                rxValue: controller.selectedPaymentMethodId,
                onChanged: (id) => controller.selectedPaymentMethodId.value = id,
                label: 'وسيلة الدفع',
                hint: 'اختر وسيلة الدفع',
              )),
              CustomTextField(controller: amount, label: 'المبلغ بالوحدة الصغرى', keyboardType: TextInputType.number),
              CustomTextField(controller: reference, label: 'مرجع التحويل', isRequired: false),
              const SizedBox(height: 8),
              Obx(() => CustomFilePicker.single(
                initialFile: controller.paymentProof.value,
                onFileChanged: (file) => controller.paymentProof.value = file,
                preset: FileTypePreset.custom,
                allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
                maxFileSizeBytes: 5 * 1024 * 1024,
                label: 'إثبات الدفع',
                hint: 'PDF أو JPG أو PNG، بحد أقصى 5MB',
                displayMode: FilePickerDisplayMode.button,
              )),
              const SizedBox(height: 8),
              const Text('سيُسجل الطلب بانتظار مراجعة المنصة. لن يتفعل الاشتراك قبل اعتماد الدفع.'),
            ],
          ),
        ),
        confirmLabel: 'إرسال طلب الدفع',
        cancelLabel: 'إلغاء',
      );
      final amountMinor = int.tryParse(amount.text.trim());
      final methodId = controller.selectedPaymentMethodId.value;
      if (accepted == true && amountMinor != null && amountMinor > 0 &&
          amountMinor <= remaining && methodId != null) {
        await controller.recordPayment(
          invoiceId,
          methodId,
          amountMinor,
          reference.text.trim().isEmpty ? null : reference.text.trim(),
          controller.paymentProof.value?.path,
        );
      }
    } finally {
      controller.paymentProof.value = null;
      amount.dispose();
      reference.dispose();
    }
  }

  static Future<void> subscriptionDetails(
    BillingController controller,
    int id,
  ) async {
    await controller.loadSubscriptionDetails(id);
    final detail = controller.subscriptionDetails.value;
    if (detail == null) return;
    final trial = detail['trial_redemption'];
    await CustomDialog.show(
      type: DialogType.info,
      title: 'تفاصيل الاشتراك',
      confirmLabel: 'إغلاق',
      maxWidth: 600,
      content: Obx(() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الحالة: ${detail['status_label']?.toString() ?? detail['status']?.toString() ?? '—'}'),
            Text('بداية الفترة: ${detail['current_period_start']?.toString() ?? '—'}'),
            Text('نهاية الفترة: ${detail['current_period_end']?.toString() ?? '—'}'),
            if (trial is Map<String, dynamic>) ...[
              const SizedBox(height: 8),
              const Text('الفترة التجريبية', style: AppTypography.titleSmall),
              Text('الحالة: ${trial['status']?.toString() ?? '—'}'),
              Text('تاريخ البدء: ${trial['started_at']?.toString() ?? '—'}'),
              Text('تاريخ الانتهاء: ${trial['completed_at']?.toString() ?? '—'}'),
            ],
            const SizedBox(height: 10),
            const Text('الاستخدام المسجل', style: TextStyle(fontWeight: FontWeight.w700)),
            ...controller.usageRows.map((row) => Text(
              '${row['meter'] is Map<String, dynamic> ? row['meter']['name']?.toString() ?? 'عداد' : 'عداد'}: ${row['quantity']?.toString() ?? '0'}',
            )),
            CustomCursorLoadMore(
              hasMore: controller.usagePage.hasMore,
              isLoading: controller.usagePage.isLoadingMore.value,
              error: controller.usagePage.loadMoreError.value,
              onPressed: controller.loadMoreUsage,
              label: 'تحميل المزيد من سجلات الاستخدام',
            ),
            const SizedBox(height: 10),
            const Text('سجل الأحداث', style: TextStyle(fontWeight: FontWeight.w700)),
            ...controller.eventRows.map((row) => Text(
              '${row['event_type']?.toString() ?? 'حدث'} — ${row['occurred_at']?.toString() ?? ''}',
            )),
            CustomCursorLoadMore(
              hasMore: controller.eventsPage.hasMore,
              isLoading: controller.eventsPage.isLoadingMore.value,
              error: controller.eventsPage.loadMoreError.value,
              onPressed: controller.loadMoreEvents,
              label: 'تحميل المزيد من الأحداث',
            ),
          ],
        ),
      )),
    );
  }

  static Future<void> purchase(BillingController controller, int priceId) async {
    final eligibility = await controller.checkTrial(priceId);
    if (eligibility == null) return;
    final ready = eligibility['purchase_ready'] == true;
    final trial = eligibility['trial'];
    final trialEligible = trial is Map<String, dynamic> && trial['eligible'] == true;
    final blockers = (eligibility['purchase_blockers'] as List<dynamic>? ?? const <dynamic>[]).join('، ');
    final accepted = await CustomDialog.show(
      type: ready ? DialogType.confirmation : DialogType.warning,
      title: 'تأكيد الاشتراك',
      message: !ready
          ? 'لا يمكن الشراء حالياً: $blockers'
          : (trialEligible
              ? 'السعر مؤهل لفترة تجريبية وفق سياسة المنصة.'
              : 'سيُنشأ طلب الاشتراك والفاتورة وفق شروط الخطة.') +
              ' لن تُفعّل الاستحقاقات قبل اعتماد الدفع.',
      confirmLabel: ready ? 'متابعة' : 'فهمت',
      cancelLabel: 'رجوع',
    );
    if (accepted == true && ready) await controller.purchase(priceId);
  }

  static Future<void> cancelSubscription(BillingController controller, int id) async {
    final accepted = await CustomDialog.show(
      type: DialogType.danger,
      title: 'إلغاء الاشتراك',
      message: 'اختر توقيت الإلغاء. الإلغاء الفوري ينهي الاستحقاقات وفق سياسة الخادم ولا يمكن التراجع عنه من هذه الشاشة.',
      confirmLabel: 'إلغاء فوري',
      cancelLabel: 'رجوع',
      secondaryActionLabel: 'نهاية الفترة',
      onConfirm: () => controller.cancel(id, atPeriodEnd: false),
      onSecondaryAction: () {
        Get.back(result: true);
        controller.cancel(id, atPeriodEnd: true);
      },
    );
    // إجراء الإلغاء الفوري يتم في onConfirm بعد إغلاق الحوار.
    if (accepted == true) return;
  }
}
