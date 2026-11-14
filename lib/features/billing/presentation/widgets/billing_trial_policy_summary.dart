import 'package:flutter/material.dart';
import 'package:netsales/core/enums/billing_status.dart';
import 'package:netsales/core/enums/billing_trial_entitlement_mode.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

class BillingTrialPolicySummary extends StatelessWidget {
  const BillingTrialPolicySummary({
    required this.trial,
    this.showAdjustments = true,
    this.title = 'سياسة الفترة التجريبية',
    super.key,
  });

  final Map<String, dynamic> trial;
  final bool showAdjustments;
  final String title;

  @override
  Widget build(BuildContext context) {
    final status = trial['status']?.toString();
    final mode = BillingTrialEntitlementMode.fromWire(
      trial['entitlement_mode']?.toString(),
    );
    final modePresentation =
        EnumPresentationRegistry.resolveBillingTrialEntitlementMode(mode);
    final awaitingApproval = trial['requires_manual_approval'] == true &&
        status == 'PENDING_APPROVAL';
    final awaitingActivation = trial['awaiting_first_activation'] == true;
    final adjustments = trial['adjustments'] is List
        ? (trial['adjustments'] as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false)
        : const <Map<String, dynamic>>[];
    final allowedFeatures = trial['allowed_features'] is List
        ? (trial['allowed_features'] as List)
            .map((item) => item.toString())
            .toList(growable: false)
        : const <String>[];

    return CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          if (status != null) BillingStatusBadge(status: status),
          const SizedBox(height: 8),
          CustomStatusBadge.fromPresentation(modePresentation),
          if (awaitingApproval)
            _notice(
              context,
              'طلب التجربة بانتظار موافقة المنصة؛ لا تُمنح المزايا التجريبية قبل الموافقة.',
              Icons.hourglass_top_rounded,
            ),
          if (awaitingActivation)
            _notice(
              context,
              'التجربة محجوزة ومعتمدة، ويبدأ عدادها عند أول تفعيل تشغيلي.',
              Icons.play_circle_outline_rounded,
            ),
          _detail('مدة التجربة', _durationLabel()),
          _detail('بداية التجربة', _startTriggerLabel()),
          _detail('نطاق استخدام التجربة', _scopeLabel()),
          _detail('أهلية التجربة', _eligibilityLabel()),
          _detail(
            'الموافقة اليدوية',
            trial['requires_manual_approval'] == true ? 'مطلوبة' : 'غير مطلوبة',
          ),
          _detail('السلوك عند الانتهاء', _endBehaviorLabel()),
          _detail('تاريخ البدء', _dateTimeLabel(trial['start'])),
          _detail('تاريخ الانتهاء', _dateTimeLabel(trial['end'])),
          _detail('الوقت المتبقي', _remainingLabel()),
          if (mode == BillingTrialEntitlementMode.restricted) ...[
            const SizedBox(height: 8),
            Text('المزايا المسموحة خلال التجربة', style: AppTypography.titleSmall),
            if (allowedFeatures.isEmpty)
              const Text('لم يحدد الخادم مزايا مقيدة بالاسم.')
            else
              ...allowedFeatures.map(
                (feature) => CustomInfoListTile(
                  minHeight: 34,
                  padding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline_rounded),
                  title: Text(feature),
                ),
              ),
          ],
          if (showAdjustments && adjustments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('سجل تعديلات التجربة', style: AppTypography.titleSmall),
            ...adjustments.map(_adjustmentTile),
          ],
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 142,
              child: Text(label, style: AppTypography.bodySmall),
            ),
            Expanded(child: Text(value, style: AppTypography.bodyMedium)),
          ],
        ),
      );

  Widget _notice(BuildContext context, String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomSurfaceCard(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Widget _adjustmentTile(Map<String, dynamic> adjustment) {
    final previous = _dateTimeLabel(adjustment['previous_trial_end']);
    final next = _dateTimeLabel(adjustment['new_trial_end']);
    final reason = adjustment['reason']?.toString();
    return CustomInfoListTile(
      padding: EdgeInsets.zero,
      title: Text(_adjustmentTypeLabel(adjustment['adjustment_type']?.toString())),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('نهاية التجربة السابقة: $previous'),
          Text('نهاية التجربة الجديدة: $next'),
          if (reason != null && reason.isNotEmpty) Text('السبب: $reason'),
          Text('تاريخ التعديل: ${_dateTimeLabel(adjustment['occurred_at'])}'),
        ],
      ),
    );
  }

  String _durationLabel() {
    final value = (trial['duration_value'] as num?)?.toInt();
    final unit = trial['duration_unit']?.toString().toUpperCase();
    if (value == null || unit == null) return 'غير محددة';
    final label = switch (unit) {
      'HOUR' || 'HOURS' => 'ساعة',
      'DAY' || 'DAYS' => 'يوم',
      'WEEK' || 'WEEKS' => 'أسبوع',
      'MONTH' || 'MONTHS' => 'شهر',
      _ => unit,
    };
    return '$value $label';
  }

  String _startTriggerLabel() =>
      switch (trial['start_trigger']?.toString().toUpperCase()) {
        'PURCHASE' => 'عند إتمام الشراء',
        'FIRST_ACTIVATION' => 'عند أول تفعيل تشغيلي',
        _ => 'حسب سياسة الخادم',
      };

  String _scopeLabel() =>
      switch (trial['redemption_scope']?.toString().toUpperCase()) {
        'NETWORK' => 'مرة واحدة للشبكة',
        'BILLING_ACCOUNT' => 'مرة واحدة لحساب الفوترة',
        'PRODUCT' => 'مرة واحدة لكل منتج',
        _ => 'حسب سياسة الخادم',
      };

  String _eligibilityLabel() =>
      switch (trial['eligibility_mode']?.toString().toUpperCase()) {
        'ALL' => 'جميع الحسابات المؤهلة',
        'NEW_NETWORK' => 'الشبكات الجديدة فقط',
        'NEW_BILLING_ACCOUNT' => 'حسابات الفوترة الجديدة فقط',
        _ => 'وفق تحقق الخادم',
      };

  String _endBehaviorLabel() =>
      switch (trial['end_behavior']?.toString().toUpperCase()) {
        'CREATE_INVOICE' => 'إصدار فاتورة للدورة المدفوعة',
        'EXPIRE' => 'إنهاء الاشتراك دون تحويل مدفوع',
        _ => 'حسب سياسة الخادم',
      };

  String _remainingLabel() {
    final end = DateTime.tryParse(trial['end_at']?.toString() ?? '');
    final now = DateTime.tryParse(trial['server_now']?.toString() ?? '');
    if (end == null || now == null) return 'غير متاح من الخادم';
    final difference = end.difference(now);
    if (difference.isNegative || difference.inSeconds == 0) {
      return 'انتهت المدة حسب وقت الخادم';
    }
    final days = difference.inDays;
    final hours = difference.inHours.remainder(24);
    if (days > 0) return '$days يوم و$hours ساعة';
    final minutes = difference.inMinutes.remainder(60);
    if (hours > 0) return '$hours ساعة و$minutes دقيقة';
    return '$minutes دقيقة';
  }

  String _dateTimeLabel(dynamic value) {
    if (value == null || value.toString().isEmpty) return '—';
    return value.toString().replaceFirst('T', ' ');
  }

  String _adjustmentTypeLabel(String? value) =>
      switch (value?.toUpperCase()) {
        'EXTEND' => 'تمديد مدة التجربة',
        'SHORTEN' => 'تقليص مدة التجربة',
        'TERMINATE' => 'إنهاء التجربة',
        _ => value ?? 'تعديل',
      };
}
