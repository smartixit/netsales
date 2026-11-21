import 'package:netsales/core/presentation/enums/semantic_tone.dart';

/// حالة دعوة ربط نقطة البيع بالشبكة (Linking Challenge Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\LinkingChallengeStatus)
enum LinkingChallengeStatus {
  pending('PENDING'),
  consumed('CONSUMED'),
  expired('EXPIRED'),
  revoked('REVOKED'),
  unknown('UNKNOWN');

  final String wireValue;
  const LinkingChallengeStatus(this.wireValue);

  static LinkingChallengeStatus fromWire(String? raw) {
    if (raw == null) return LinkingChallengeStatus.unknown;
    for (final status in LinkingChallengeStatus.values) {
      if (status.wireValue == raw) return status;
    }
    return LinkingChallengeStatus.unknown;
  }

  bool get isPending => this == LinkingChallengeStatus.pending;
  bool get isConsumed => this == LinkingChallengeStatus.consumed;
  bool get isExpired => this == LinkingChallengeStatus.expired;
  bool get isRevoked => this == LinkingChallengeStatus.revoked;
  bool get isKnown => this != LinkingChallengeStatus.unknown;

  String get label {
    switch (this) {
      case LinkingChallengeStatus.pending:
        return 'بانتظار المسح';
      case LinkingChallengeStatus.consumed:
        return 'تم الارتباط';
      case LinkingChallengeStatus.expired:
        return 'منتهية الصلاحية';
      case LinkingChallengeStatus.revoked:
        return 'ملغاة';
      case LinkingChallengeStatus.unknown:
        return 'غير محدد';
    }
  }

  SemanticTone get tone {
    switch (this) {
      case LinkingChallengeStatus.pending:
        return SemanticTone.primary;
      case LinkingChallengeStatus.consumed:
        return SemanticTone.success;
      case LinkingChallengeStatus.expired:
        return SemanticTone.warning;
      case LinkingChallengeStatus.revoked:
        return SemanticTone.danger;
      case LinkingChallengeStatus.unknown:
        return SemanticTone.neutral;
    }
  }
}
