import 'package:flutter/material.dart';
import 'package:netsales/core/enums/billing_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';

/// Presentation labels for server-defined Billing report fields and statuses.
class BillingReportLabels {
  BillingReportLabels._();

  static String resolve(
    BuildContext context,
    BillingReportsController controller,
    String key,
  ) {
    final english = controller.selectedLocale.value == 'en';
    if (key.startsWith('billing.status.')) {
      return status(
        key.substring('billing.status.'.length),
        english: english,
      );
    }
    if (key.startsWith('billing.report.column.') ||
        key.startsWith('billing.report.metric.')) {
      final id = key.substring(key.lastIndexOf('.') + 1);
      return english ? englishField(id) : arabic(id);
    }
    if (key == controller.selectedDefinition?['label'] && english) {
      return englishReport(controller.selectedType.value ?? '');
    }
    if (key == 'من تاريخ' && english) return 'From date';
    if (key == 'إلى تاريخ' && english) return 'To date';
    if (key == 'الحالة' && english) return 'Status';
    if (key == 'بحث' && english) return 'Search';
    return key;
  }

  static String status(String value, {bool english = false}) {
    return EnumPresentationRegistry.resolveBillingStatus(
      BillingStatus.fromWire(value),
      english: english,
    ).label;
  }

  static String englishReport(String type) => const {
        'subscriptions': 'Subscriptions',
        'trials': 'Trial usage',
        'trial_conversion': 'Trial conversion funnel',
        'renewals': 'Renewals',
        'plan_performance': 'Plan performance',
        'invoices': 'Invoices',
        'collections': 'Collections',
        'receivables': 'Accounts receivable',
        'usage': 'Usage',
        'dunning': 'Dunning',
        'refunds': 'Refunds',
        'revenue_recognition': 'Revenue recognition',
      }[type] ??
      type;

  static String field(String key, {required bool english}) =>
      english ? englishField(key) : arabic(key);

  static String englishField(String key) => const {
        'record_count': 'Record count',
        'active_subscriptions': 'Active subscriptions',
        'trialing_subscriptions': 'Trial subscriptions',
        'past_due_subscriptions': 'Past-due subscriptions',
        'canceled_subscriptions': 'Canceled subscriptions',
        'currency_code': 'Currency code',
        'invoice_number': 'Invoice number',
        'status': 'Status',
        'amount_minor': 'Amount (minor units)',
        'mrr_minor': 'Monthly recurring revenue',
        'arr_minor': 'Annual recurring revenue',
        'trial_eligible': 'Eligible trials',
        'trial_reserved': 'Reserved trials',
        'trial_started': 'Started trials',
        'trial_completed': 'Completed trials',
        'conversion_invoice_issued': 'Conversion invoices issued',
        'paid_conversion': 'Paid conversions',
      }[key] ??
      key.replaceAll('_', ' ');

  static String arabic(String key) => const {
        'record_count': 'عدد السجلات',
        'active_subscriptions': 'الاشتراكات النشطة',
        'trialing_subscriptions': 'الاشتراكات التجريبية',
        'past_due_subscriptions': 'اشتراكات متأخرة السداد',
        'canceled_subscriptions': 'الاشتراكات الملغاة',
        'currency_code': 'رمز العملة',
        'invoice_number': 'رقم الفاتورة',
        'status': 'الحالة',
        'amount_minor': 'المبلغ (وحدة صغرى)',
        'mrr_minor': 'الإيراد الشهري المتكرر',
        'arr_minor': 'الإيراد السنوي المتكرر',
        'trial_eligible': 'التجارب المؤهلة',
        'trial_reserved': 'التجارب المحجوزة',
        'trial_started': 'التجارب التي بدأت',
        'trial_completed': 'التجارب المكتملة',
        'conversion_invoice_issued': 'فواتير التحويل الصادرة',
        'paid_conversion': 'التحويلات المدفوعة',
      }[key] ??
      key.replaceAll('_', ' ');

  static String displayValue(String key, dynamic value) {
    if (value == null) return '—';
    final isAmount = key.endsWith('_minor') ||
        key == 'amount' ||
        key == 'mrr' ||
        key == 'arr' ||
        key.contains('revenue');
    if (isAmount &&
        (value is num || num.tryParse(value.toString()) != null)) {
      return AmountFormatter.format(value.toString());
    }
    return value.toString();
  }
}
