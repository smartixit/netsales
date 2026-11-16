import 'package:get/get.dart';

/// Registers a lazy dependency once per GetX tag.
///
/// Feature bindings can be composed by multiple workspace shells and route
/// bindings. This helper prevents a later binding from replacing or
/// colliding with an already registered factory for the same scope.
void registerLazyIfAbsent<T>(
  T Function() builder, {
  String? tag,
  bool fenix = false,
}) {
  if (Get.isRegistered<T>(tag: tag)) return;
  Get.lazyPut<T>(builder, tag: tag, fenix: fenix);
}
