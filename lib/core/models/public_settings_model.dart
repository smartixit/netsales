/// نموذج بيانات إعدادات النظام العامة (Public Settings Model)
///
/// مطابق لاستجابة GET /api/v1/system-settings/public في netsales_api.
class PublicSettingsModel {
  final String appName;
  final String appCompanyName;
  final String appSupportPhone;
  final String appSupportWhatsApp;
  final String appSupportEmail;
  final String defaultLocale;

  const PublicSettingsModel({
    required this.appName,
    required this.appCompanyName,
    required this.appSupportPhone,
    required this.appSupportWhatsApp,
    required this.appSupportEmail,
    this.defaultLocale = 'ar',
  });

  factory PublicSettingsModel.fromJson(Map<String, dynamic> json) {
    return PublicSettingsModel(
      appName: json['app_name']?.toString() ?? '',
      appCompanyName: json['app_company_name']?.toString() ?? '',
      appSupportPhone: json['app_support_phone']?.toString() ?? '',
      appSupportWhatsApp: json['app_support_whatsapp']?.toString() ?? '',
      appSupportEmail: json['app_support_email']?.toString() ?? '',
      defaultLocale: json['default_locale']?.toString() ?? 'ar',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'app_company_name': appCompanyName,
      'app_support_phone': appSupportPhone,
      'app_support_whatsapp': appSupportWhatsApp,
      'app_support_email': appSupportEmail,
      'default_locale': defaultLocale,
    };
  }
}
