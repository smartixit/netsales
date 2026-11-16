import 'package:get/get.dart';

/// Registers a lazy dependency once per GetX registration key.
///
/// A fenix registration can have no live instance while its factory is still
/// available. Checking both states prevents a binding from replacing or
/// duplicating a factory that GetX can already recreate.
void registerLazyIfAbsent<T>(
  T Function() builder, {
  String? tag,
  bool fenix = false,
}) {
  if (Get.isRegistered<T>(tag: tag) || Get.isPrepared<T>(tag: tag)) {
    return;
  }

  Get.lazyPut<T>(builder, tag: tag, fenix: fenix);
}
