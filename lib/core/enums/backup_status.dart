/// حالة النسخة الاحتياطية (Backup Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\BackupStatus)
enum BackupStatus {
  queued('QUEUED'),
  running('RUNNING'),
  success('SUCCESS'),
  failed('FAILED'),
  unknown('UNKNOWN');

  final String wireValue;
  const BackupStatus(this.wireValue);

  static BackupStatus fromWire(String? raw) {
    if (raw == null) return BackupStatus.unknown;
    for (final status in BackupStatus.values) {
      if (status.wireValue == raw) return status;
    }
    return BackupStatus.unknown;
  }

  bool get isKnown => this != BackupStatus.unknown;
}

