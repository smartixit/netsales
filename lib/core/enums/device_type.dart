/// نوع الجهاز المقترن بحساب المستخدم (Device Type)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\DeviceType)
enum DeviceType {
  android('ANDROID'),
  ios('IOS'),
  web('WEB'),
  windows('WINDOWS'),
  linux('LINUX'),
  mac('MAC'),
  unknown('UNKNOWN');

  final String wireValue;
  const DeviceType(this.wireValue);

  static DeviceType fromWire(String? raw) {
    if (raw == null) return DeviceType.unknown;
    for (final type in DeviceType.values) {
      if (type.wireValue == raw) return type;
    }
    return DeviceType.unknown;
  }

  bool get isKnown => this != DeviceType.unknown;
}

