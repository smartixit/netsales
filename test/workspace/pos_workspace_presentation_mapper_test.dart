import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_active_supply_order_mapper.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_network_package_mapper.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_wallet_summary_mapper.dart';

void main() {
  group('POS workspace presentation mappers', () {
    test('maps package pricing and specification labels for display', () {
      const package = PackageEntity(
        packageId: 5,
        networkId: 2,
        packageName: 'باقة 10 جيجا',
        packageBalance: 10,
        packageUptime: 30,
        packageValidity: 7,
        packageVoucherCount: 20,
        packageVoucherPrice: 500,
        packageDefaultCashDiscount: 10,
        packageDefaultCreditDiscount: 5,
        cashDiscountAmount: 50,
        creditDiscountAmount: 25,
        effectiveCashPrice: 450,
        effectiveCreditPrice: 475,
        status: true,
      );

      final result = PosNetworkPackageMapper.map([package]);

      expect(result, hasLength(1));
      expect(result.single.packageId, 5);
      expect(result.single.name, 'باقة 10 جيجا');
      expect(result.single.discountLabel, '10%');
      expect(result.single.supplyPrice, contains('450'));
      expect(result.single.retailPrice, contains('500'));
      expect(result.single.specifications, isNotEmpty);
    });

    test('maps wallet amounts and credit labels for display', () {
      const wallet = PosWalletEntity(
        walletId: 1,
        networkId: 2,
        posId: 3,
        walletBalance: 1250,
        creditLimit: null,
        availableOverdraftCapacity: 500,
        isOverdrawn: true,
      );

      final result = PosWalletSummaryMapper.map(wallet);

      expect(result, isNotNull);
      expect(result!.isOverdrawn, isTrue);
      expect(result.formattedBalance, contains('1,250'));
      expect(result.creditLimitLabel, 'بدون تسهيلات');
      expect(result.availableOverdraftLabel, contains('500'));
    });

    test('maps active request progress without UI-side status interpretation', () {
      const request = RequestEntity(
        requestId: 41,
        networkId: 3,
        posId: 7,
        requestUuid: 'request-12345678',
        requestTotalAmount: 1250,
        statusRaw: 'PROCESSING',
        statusLabel: 'قيد المعالجة',
      );

      final result = PosActiveSupplyOrderMapper.map([request]);

      expect(result, isNotNull);
      expect(result!.reference, 'request-');
      expect(result.isReviewComplete, isTrue);
      expect(result.isDeliveryActive, isTrue);
      expect(result.isDeliveryComplete, isFalse);
    });

    test('returns no active order for terminal request statuses', () {
      const request = RequestEntity(
        requestId: 42,
        networkId: 3,
        posId: 7,
        requestTotalAmount: 0,
        statusRaw: 'REJECTED',
      );

      expect(PosActiveSupplyOrderMapper.map([request]), isNull);
    });
  });
}
