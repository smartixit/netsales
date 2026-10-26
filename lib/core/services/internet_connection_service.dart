import 'dart:async';

import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class InternetConnectionService {
  InternetConnectionService._();

  static final InternetConnectionService instance = InternetConnectionService._();

  final InternetConnection _internet = InternetConnection();

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Stream<bool> get statusStream => _controller.stream;

  StreamSubscription<InternetStatus>? _internetSubscription;

  StreamSubscription<bool>? _stateSubscription;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// Initialize network monitoring
  Future<void> initialize() async {
    // Check initial status
    _isConnected = await _checkInternet();

    _controller.add(_isConnected);

    // Listen for internet changes
    _internetSubscription = _internet.onStatusChange.listen((status) {
      final connected = status == InternetStatus.connected;

      if (connected != _isConnected) {
        _isConnected = connected;

        _controller.add(connected);
      }
    });
  }

  /// Manual internet check
  Future<bool> hasInternet() async {
    final status = await _checkInternet();

    if (status != _isConnected) {
      _isConnected = status;

      _controller.add(status);
    }

    return status;
  }

  /// Real internet check
  Future<bool> _checkInternet() async {
    try {
      return await _internet.hasInternetAccess;
    } catch (_) {
      return false;
    }
  }

  void showInternetConnectionState() {
    _stateSubscription ??= InternetConnectionService.instance.statusStream.listen((
      connected,
    ) {
      if (Get.context == null) return;
      if (!connected) {
        CustomSnackbar.show(
          title: "لا يوجد اتصال بالإنترنت",
          message: "الرجاء التأكد من الاتصال بالإنترنت",
          type: SnackType.info,
        );
      } else {
        CustomSnackbar.show(
          title: "تم استعادة الاتصال بالإنترنت",
          message: "تم استعادة الاتصال بالإنترنت",
          type: SnackType.success,
        );
      }
    });
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _internetSubscription?.cancel();

    await _stateSubscription?.cancel();

    await _controller.close();
  }
}
