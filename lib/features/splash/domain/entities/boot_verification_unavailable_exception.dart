/// Raised when a saved session cannot be verified due to network/server failure.
class BootVerificationUnavailableException implements Exception {
  const BootVerificationUnavailableException();

  @override
  String toString() => 'تعذر التحقق من جلسة المستخدم. تحقق من الاتصال ثم أعد المحاولة.';
}
