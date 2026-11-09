import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/backup_status.dart';
import 'package:netsales/core/enums/device_type.dart';
import 'package:netsales/core/enums/invoice_payment_status.dart';
import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/core/enums/notification_type.dart';
import 'package:netsales/core/enums/provider_subscription_status.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/enums/user_device_status.dart';
import 'package:netsales/core/enums/user_status.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/enums/network_status.dart';
import 'package:netsales/core/enums/pos_status.dart';

void main() {
  group('Cross-Repository Enum Contract Parity Tests', () {
    test('NetworkStatus parses exact canonical wire values', () {
      expect(NetworkStatus.fromWire('ACTIVE'), NetworkStatus.active);
      expect(NetworkStatus.fromWire('INACTIVE'), NetworkStatus.inactive);
      expect(NetworkStatus.fromWire('PENDING'), NetworkStatus.pending);
      expect(NetworkStatus.fromWire('REJECTED'), NetworkStatus.rejected);
      expect(NetworkStatus.fromWire('BANNED'), NetworkStatus.banned);

      // Unknown & null handling
      expect(NetworkStatus.fromWire(null), NetworkStatus.unknown);
      expect(
        NetworkStatus.fromWire('UNKNOWN_FUTURE_VAL'),
        NetworkStatus.unknown,
      );
      expect(
        NetworkStatus.fromWire('active'),
        NetworkStatus.unknown,
      ); // Exact casing enforced

      expect(NetworkStatus.active.isKnown, isTrue);
      expect(NetworkStatus.unknown.isKnown, isFalse);
    });

    test('PosStatus parses exact canonical wire values', () {
      expect(PosStatus.fromWire('ACTIVE'), PosStatus.active);
      expect(PosStatus.fromWire('INACTIVE'), PosStatus.inactive);
      expect(PosStatus.fromWire('PENDING'), PosStatus.pending);
      expect(PosStatus.fromWire('REJECTED'), PosStatus.rejected);
      expect(PosStatus.fromWire('BANNED'), PosStatus.banned);

      expect(PosStatus.fromWire(null), PosStatus.unknown);
      expect(PosStatus.fromWire('pending'), PosStatus.unknown);
      expect(PosStatus.unknown.isKnown, isFalse);
    });

    test('UserStatus and UserDeviceStatus parse exact wire values', () {
      expect(UserStatus.fromWire('ACTIVE'), UserStatus.active);
      expect(UserStatus.fromWire('PENDING'), UserStatus.pending);
      expect(UserStatus.fromWire('INACTIVE'), UserStatus.inactive);
      expect(UserStatus.fromWire('BANNED'), UserStatus.banned);
      expect(UserStatus.fromWire('OTHER'), UserStatus.unknown);

      expect(UserDeviceStatus.fromWire('ACTIVE'), UserDeviceStatus.active);
      expect(UserDeviceStatus.fromWire('INACTIVE'), UserDeviceStatus.inactive);
      expect(UserDeviceStatus.fromWire('PENDING'), UserDeviceStatus.pending);
      expect(UserDeviceStatus.fromWire('BANNED'), UserDeviceStatus.banned);
      expect(UserDeviceStatus.fromWire('REJECTED'), UserDeviceStatus.unknown);
    });

    test('DeviceType parses exact wire values without alert tone', () {
      expect(DeviceType.fromWire('ANDROID'), DeviceType.android);
      expect(DeviceType.fromWire('IOS'), DeviceType.ios);
      expect(DeviceType.fromWire('WEB'), DeviceType.web);
      expect(DeviceType.fromWire('WINDOWS'), DeviceType.windows);
      expect(DeviceType.fromWire('LINUX'), DeviceType.linux);
      expect(DeviceType.fromWire('MAC'), DeviceType.mac);
      expect(DeviceType.fromWire('UNKNOWN'), DeviceType.unknown);
      expect(DeviceType.fromWire('android'), DeviceType.unknown);

      final presentation = EnumPresentationRegistry.resolveDeviceType(
        DeviceType.android,
      );
      expect(presentation.tone, SemanticTone.neutral);
      expect(presentation.isKnown, isTrue);
    });

    test('RoleKey and RoleScope parse exact wire values', () {
      expect(RoleKey.fromWire('SUPER_ADMIN'), RoleKey.superAdmin);
      expect(RoleKey.fromWire('NETWORK_OWNER'), RoleKey.networkOwner);
      expect(RoleKey.fromWire('NETWORK_USER'), RoleKey.networkUser);
      expect(RoleKey.fromWire('POS_AGENT'), RoleKey.posAgent);
      expect(RoleKey.fromWire('POS_USER'), RoleKey.posUser);
      expect(RoleKey.fromWire('SUPPORT_AGENT'), RoleKey.supportAgent);
      expect(RoleKey.fromWire('ACCOUNTANT'), RoleKey.accountant);
      expect(RoleKey.fromWire('NETWORK_ACCOUNTANT'), RoleKey.networkAccountant);
      expect(RoleKey.fromWire('POS_ACCOUNTANT'), RoleKey.posAccountant);
      expect(RoleKey.fromWire('OTHER'), RoleKey.unknown);

      expect(RoleScope.fromWire('PLATFORM'), RoleScope.platform);
      expect(RoleScope.fromWire('NETWORK'), RoleScope.network);
      expect(RoleScope.fromWire('POS'), RoleScope.pos);
      expect(RoleScope.fromWire('OTHER'), RoleScope.unknown);
    });

    test('SaleType, RequestStatus, and InvoicePaymentStatus parse exact wire values', () {
      expect(SaleType.fromWire('CASH'), SaleType.cash);
      expect(SaleType.fromWire('CREDIT'), SaleType.credit);
      expect(SaleType.fromWire('cash'), SaleType.unknown);

      expect(RequestStatus.fromWire('PENDING'), RequestStatus.pending);
      expect(RequestStatus.fromWire('APPROVED'), RequestStatus.approved);
      expect(RequestStatus.fromWire('REJECTED'), RequestStatus.rejected);
      expect(RequestStatus.fromWire('CANCELLED'), RequestStatus.cancelled);
      expect(RequestStatus.fromWire(null), RequestStatus.unknown);

      expect(InvoicePaymentStatus.fromWire('PAID'), InvoicePaymentStatus.paid);
      expect(
        InvoicePaymentStatus.fromWire('PARTIALLY_PAID'),
        InvoicePaymentStatus.partiallyPaid,
      );
      expect(
        InvoicePaymentStatus.fromWire('UNPAID'),
        InvoicePaymentStatus.unpaid,
      );
      expect(InvoicePaymentStatus.fromWire(null), InvoicePaymentStatus.unknown);
    });

    test('WalletOperationType, ProviderSubscriptionStatus, and BackupStatus parse exact wire values', () {
      expect(
        WalletOperationType.fromWire('DEPOSIT'),
        WalletOperationType.deposit,
      );
      expect(
        WalletOperationType.fromWire('WITHDRAW'),
        WalletOperationType.withdraw,
      );
      expect(
        WalletOperationType.fromWire('deposit'),
        WalletOperationType.unknown,
      );

      expect(
        ProviderSubscriptionStatus.fromWire('ACTIVE'),
        ProviderSubscriptionStatus.active,
      );
      expect(
        ProviderSubscriptionStatus.fromWire('QUEUED'),
        ProviderSubscriptionStatus.queued,
      );
      expect(
        ProviderSubscriptionStatus.fromWire('EXPIRED'),
        ProviderSubscriptionStatus.expired,
      );
      expect(
        ProviderSubscriptionStatus.fromWire('CANCELLED'),
        ProviderSubscriptionStatus.cancelled,
      );
      expect(
        ProviderSubscriptionStatus.fromWire('SUSPENDED'),
        ProviderSubscriptionStatus.suspended,
      );

      expect(BackupStatus.fromWire('QUEUED'), BackupStatus.queued);
      expect(BackupStatus.fromWire('RUNNING'), BackupStatus.running);
      expect(BackupStatus.fromWire('SUCCESS'), BackupStatus.success);
      expect(BackupStatus.fromWire('FAILED'), BackupStatus.failed);
      expect(BackupStatus.fromWire('failed'), BackupStatus.unknown);
    });

    test('NotificationType safe wire parsing preserves unknown state without generalInfo hiding', () {
      expect(
        NotificationType.fromWire('SALE_INVOICE_CREATED'),
        NotificationType.saleInvoiceCreated,
      );
      expect(
        NotificationType.fromWire('GENERAL_INFO'),
        NotificationType.generalInfo,
      );

      // Crucial invariant: unknown string does NOT return generalInfo
      final unknown = NotificationType.fromWire(
        'NEW_BACKEND_EVENT_NOT_IN_CLIENT',
      );
      expect(unknown, NotificationType.unknown);
      expect(unknown.isKnown, isFalse);
    });
  });

  group('EnumPresentationRegistry Semantic Mapping & Precedence Tests', () {
    test('Server label takes precedence over fallback when provided', () {
      final withServer = EnumPresentationRegistry.resolveNetworkStatus(
        NetworkStatus.active,
        serverLabel: 'شبكة مفعلة ونشطة',
      );
      expect(withServer.label, 'شبكة مفعلة ونشطة');
      expect(withServer.tone, SemanticTone.success);

      final fallback = EnumPresentationRegistry.resolveNetworkStatus(
        NetworkStatus.active,
        serverLabel: null,
      );
      expect(fallback.label, 'مفعّل');
      expect(fallback.tone, SemanticTone.success);
    });

    test('Status values map to accurate semantic tones', () {
      // Success
      expect(
        EnumPresentationRegistry.resolveNetworkStatus(NetworkStatus.active)
            .tone,
        SemanticTone.success,
      );
      expect(
        EnumPresentationRegistry.resolvePosStatus(PosStatus.active).tone,
        SemanticTone.success,
      );
      expect(
        EnumPresentationRegistry.resolveRequestStatus(RequestStatus.approved)
            .tone,
        SemanticTone.success,
      );
      expect(
        EnumPresentationRegistry.resolveInvoicePaymentStatus(
          InvoicePaymentStatus.paid,
        ).tone,
        SemanticTone.success,
      );
      expect(
        EnumPresentationRegistry.resolveBackupStatus(BackupStatus.success).tone,
        SemanticTone.success,
      );

      // Warning
      expect(
        EnumPresentationRegistry.resolveNetworkStatus(NetworkStatus.pending)
            .tone,
        SemanticTone.warning,
      );
      expect(
        EnumPresentationRegistry.resolveRequestStatus(RequestStatus.pending)
            .tone,
        SemanticTone.warning,
      );
      expect(
        EnumPresentationRegistry.resolveInvoicePaymentStatus(
          InvoicePaymentStatus.partiallyPaid,
        ).tone,
        SemanticTone.warning,
      );
      expect(
        EnumPresentationRegistry.resolveBackupStatus(BackupStatus.running).tone,
        SemanticTone.warning,
      );

      // Danger
      expect(
        EnumPresentationRegistry.resolveNetworkStatus(NetworkStatus.rejected)
            .tone,
        SemanticTone.danger,
      );
      expect(
        EnumPresentationRegistry.resolveNetworkStatus(NetworkStatus.banned)
            .tone,
        SemanticTone.danger,
      );
      expect(
        EnumPresentationRegistry.resolveRequestStatus(RequestStatus.rejected)
            .tone,
        SemanticTone.danger,
      );
      expect(
        EnumPresentationRegistry.resolveInvoicePaymentStatus(
          InvoicePaymentStatus.unpaid,
        ).tone,
        SemanticTone.danger,
      );
      expect(
        EnumPresentationRegistry.resolveBackupStatus(BackupStatus.failed).tone,
        SemanticTone.danger,
      );

      // Neutral
      expect(
        EnumPresentationRegistry.resolveNetworkStatus(NetworkStatus.inactive)
            .tone,
        SemanticTone.neutral,
      );
      expect(
        EnumPresentationRegistry.resolveRequestStatus(RequestStatus.cancelled)
            .tone,
        SemanticTone.neutral,
      );
      expect(
        EnumPresentationRegistry.resolveDeviceType(DeviceType.android).tone,
        SemanticTone.neutral,
      );
      expect(
        EnumPresentationRegistry.resolveRoleKey(RoleKey.networkOwner).tone,
        SemanticTone.neutral,
      );

      // Unknown fallback
      expect(
        EnumPresentationRegistry.resolveNetworkStatus(NetworkStatus.unknown)
            .tone,
        SemanticTone.neutral,
      );
      expect(
        EnumPresentationRegistry.resolveNetworkStatus(NetworkStatus.unknown)
            .isKnown,
        isFalse,
      );
    });

    test(
      'Network–POS boolean link status resolves correctly without fake enum',
      () {
        final activeLink = EnumPresentationRegistry.resolveLinkStatus(true);
        expect(activeLink.tone, SemanticTone.success);
        expect(activeLink.label, 'نشط');

        final inactiveLink = EnumPresentationRegistry.resolveLinkStatus(false);
        expect(inactiveLink.tone, SemanticTone.neutral);
        expect(inactiveLink.label, 'معطل');
      },
    );

    test(
      'LinkingChallengeStatus parses exact wire values and presentation',
      () {
        expect(
          LinkingChallengeStatus.fromWire('PENDING'),
          LinkingChallengeStatus.pending,
        );
        expect(
          LinkingChallengeStatus.fromWire('CONSUMED'),
          LinkingChallengeStatus.consumed,
        );
        expect(
          LinkingChallengeStatus.fromWire('EXPIRED'),
          LinkingChallengeStatus.expired,
        );
        expect(
          LinkingChallengeStatus.fromWire('REVOKED'),
          LinkingChallengeStatus.revoked,
        );
        expect(
          LinkingChallengeStatus.fromWire('pending'),
          LinkingChallengeStatus.unknown,
        );
        expect(
          LinkingChallengeStatus.fromWire(null),
          LinkingChallengeStatus.unknown,
        );

        expect(LinkingChallengeStatus.pending.isPending, isTrue);
        expect(LinkingChallengeStatus.consumed.isConsumed, isTrue);
        expect(LinkingChallengeStatus.expired.isExpired, isTrue);
        expect(LinkingChallengeStatus.revoked.isRevoked, isTrue);

        final presPending =
            EnumPresentationRegistry.resolveLinkingChallengeStatus(
              LinkingChallengeStatus.pending,
            );
        expect(presPending.tone, SemanticTone.warning);
        expect(presPending.label, 'قيد الانتظار');

        final presConsumed =
            EnumPresentationRegistry.resolveLinkingChallengeStatus(
              LinkingChallengeStatus.consumed,
            );
        expect(presConsumed.tone, SemanticTone.success);
        expect(presConsumed.label, 'مكتمل');

        final presRevoked =
            EnumPresentationRegistry.resolveLinkingChallengeStatus(
              LinkingChallengeStatus.revoked,
            );
        expect(presRevoked.tone, SemanticTone.danger);
        expect(presRevoked.label, 'ملغي');
      },
    );

    test(
      'LinkingChallengeStatus parses exact wire values and presentation',
      () {
        expect(
          LinkingChallengeStatus.fromWire('PENDING'),
          LinkingChallengeStatus.pending,
        );
        expect(
          LinkingChallengeStatus.fromWire('CONSUMED'),
          LinkingChallengeStatus.consumed,
        );
        expect(
          LinkingChallengeStatus.fromWire('EXPIRED'),
          LinkingChallengeStatus.expired,
        );
        expect(
          LinkingChallengeStatus.fromWire('REVOKED'),
          LinkingChallengeStatus.revoked,
        );
        expect(
          LinkingChallengeStatus.fromWire('pending'),
          LinkingChallengeStatus.unknown,
        );
        expect(
          LinkingChallengeStatus.fromWire(null),
          LinkingChallengeStatus.unknown,
        );

        expect(LinkingChallengeStatus.pending.isPending, isTrue);
        expect(LinkingChallengeStatus.consumed.isConsumed, isTrue);
        expect(LinkingChallengeStatus.expired.isExpired, isTrue);
        expect(LinkingChallengeStatus.revoked.isRevoked, isTrue);

        final presPending =
            EnumPresentationRegistry.resolveLinkingChallengeStatus(
              LinkingChallengeStatus.pending,
            );
        expect(presPending.tone, SemanticTone.warning);
        expect(presPending.label, 'قيد الانتظار');

        final presConsumed =
            EnumPresentationRegistry.resolveLinkingChallengeStatus(
              LinkingChallengeStatus.consumed,
            );
        expect(presConsumed.tone, SemanticTone.success);
        expect(presConsumed.label, 'مكتمل');

        final presRevoked =
            EnumPresentationRegistry.resolveLinkingChallengeStatus(
              LinkingChallengeStatus.revoked,
            );
        expect(presRevoked.tone, SemanticTone.danger);
        expect(presRevoked.label, 'ملغي');
      },
    );
  });
}
