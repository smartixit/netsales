import 'dart:math';

/// ============================================================================
/// مساعد توليد مفاتيح عدم التكرار الموحدة (Idempotency Key Helper)
/// ============================================================================
/// يولد مفاتيح فريدة ومحصنة ضد التصادم تلتزم بأعلى معايير الأنظمة المالية:
/// - بادئة مجال صريحة (Domain Prefix: sale, wallet, sub, voucher, exp).
/// - ختم زمني دقيق بالمللي ثانية لترتيب وسهولة تتبع العمليات.
/// - سلسلة عشوائية آمنة سيبرانياً تمنع التخمين والتصادم (Cryptographically Secure Random).
abstract final class IdempotencyHelper {
  IdempotencyHelper._();

  static final Random _secureRandom = Random.secure();

  /// توليد مفتاح فريد عام بصيغة: prefix-timestamp-randomHex
  static String generate([String prefix = 'req']) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomHex = List.generate(
      16,
      (_) => _secureRandom.nextInt(16).toRadixString(16),
    ).join();

    final cleanPrefix = prefix
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]'), '');

    return '${cleanPrefix.isEmpty ? "req" : cleanPrefix}-$timestamp-$randomHex';
  }

  /// مفتاح لعمليات إصدار وتأكيد فواتير بيع الكروت
  static String forSaleInvoice([int? posId]) =>
      generate(posId != null ? 'sale-pos$posId' : 'sale');

  /// مفتاح لعمليات شحن وتعديل أرصدة المحافظ
  static String forWalletTransaction([String? walletType]) =>
      generate(walletType != null ? 'wallet-$walletType' : 'wallet');

  /// مفتاح لطلبات كروت الإنترنت
  static String forVoucherRequest([int? networkId]) =>
      generate(networkId != null ? 'vouch-net$networkId' : 'vouch');

  /// مفتاح لاشتراكات وتجديد باقات مزودي الشبكات
  static String forSubscription([int? planId]) =>
      generate(planId != null ? 'sub-plan$planId' : 'sub');

  /// مفتاح لسندات المصروفات المالية
  static String forExpense([int? categoryId]) =>
      generate(categoryId != null ? 'exp-cat$categoryId' : 'exp');

  /// مفتاح للعمليات المجمعة الحساسة (Batch Operations)
  static String forBatchOperation(String operation) =>
      generate('batch-$operation');
}
