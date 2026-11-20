import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/pos_status.dart';
import 'package:netsales/core/utils/date_formatter.dart';

/// كيان نقطة البيع التجارية (POS Entity)
class PosEntity extends Equatable {
  const PosEntity({
    required this.posId,
    required this.ownerId,
    required this.posUuid,
    required this.posName,
    required this.posPhoneNumber,
    this.posEmail,
    this.posAddress,
    this.governorateId,
    this.directorateId,
    this.governorateName,
    this.directorateName,
    this.status,
    this.statusLabel,
    this.ownerName,
    this.posProfileLogoUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int posId;
  final int ownerId;
  final String posUuid;
  final String posName;
  final String posPhoneNumber;
  final String? posEmail;
  final String? posAddress;
  final int? governorateId;
  final int? directorateId;
  final String? governorateName;
  final String? directorateName;
  final String? status;
  final String? statusLabel;
  final String? ownerName;
  final String? posProfileLogoUrl;
  final String? createdAt;
  final String? updatedAt;

  /// مرجع نقطة البيع الأصلي للعرض والنسخ (UUID المعتمد أو المعرف الرقمي)
  String get displayReference {
    if (posUuid.trim().isNotEmpty) {
      return posUuid.trim();
    }
    return '#$posId';
  }

  /// الاسم المنسق للعرض
  String get displayName =>
      posName.trim().isNotEmpty ? posName.trim() : 'نقطة بيع #$posId';

  /// هاتف التواصل المنسق
  String get displayPhone => posPhoneNumber.trim().isNotEmpty
      ? posPhoneNumber.trim()
      : 'غير متوفر';

  /// اسم المسؤول أو المالك المنسق
  String get displayOwnerName =>
      ownerName != null && ownerName!.trim().isNotEmpty
          ? ownerName!.trim()
          : 'غير محدد';

  /// العنوان والموقع الجغرافي المنسق
  String get displayLocation {
    final segments = <String>[
      if (governorateName != null && governorateName!.trim().isNotEmpty)
        governorateName!.trim(),
      if (directorateName != null && directorateName!.trim().isNotEmpty)
        directorateName!.trim(),
    ];
    final area = segments.join(' - ');
    final addr = posAddress?.trim();
    if (area.isNotEmpty && addr != null && addr.isNotEmpty) {
      return '$area ($addr)';
    }
    if (area.isNotEmpty) return area;
    if (addr != null && addr.isNotEmpty) return addr;
    log(directorateName.toString());
    log(governorateName.toString());
    log(addr.toString());
    log(area.toString());
    return 'غير محدد';
  }

  /// تاريخ الإنشاء المحول
  DateTime? get parsedCreatedAt => DateTime.tryParse(createdAt ?? '');

  /// صيغة تاريخ الإنشاء المنسقة
  String get formattedCreatedAt => parsedCreatedAt != null
      ? DateFormatter.date(parsedCreatedAt!)
      : (createdAt ?? 'غير متوفر');

  PosStatus get typedStatus => PosStatus.fromWire(status);
  bool get isActive => typedStatus == PosStatus.active;

  @override
  List<Object?> get props => [
        posId,
        ownerId,
        posUuid,
        posName,
        posPhoneNumber,
        posEmail,
        posAddress,
        governorateId,
        directorateId,
        governorateName,
        directorateName,
        status,
        statusLabel,
        ownerName,
        posProfileLogoUrl,
        createdAt,
        updatedAt,
      ];
}
