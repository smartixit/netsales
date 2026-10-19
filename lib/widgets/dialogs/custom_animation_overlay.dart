import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/sound_service.dart';

enum AnimationOverlayType { success, error, warning, info, network, loading }

class CustomAnimationOverlay {
  CustomAnimationOverlay._();

  static PageRouteBuilder<void>? _route;

  /// Queue واحدة لجميع عمليات الـ Overlay.
  static Future<void> _operationQueue = Future.value();

  static bool get isShowing => _route != null;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  static Future<void> show({
    required AnimationOverlayType type,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? autoHideAfter,
    bool force = false,
  }) {
    return _enqueue(() async {
      await _showOrReplace(
        type: type,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        autoHideAfter: autoHideAfter,
        force: force,
      );
    });
  }

  static Future<void> hide() {
    return _enqueue(() async {
      await _hideNow();
    });
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  /// يعرض Loading ويكتمل Future بعد بدء الـ Route فعلياً.
  ///
  /// لا ينتظر انتهاء Loading.
  static Future<void> showLoading({String? message, bool force = false}) {
    return show(
      type: AnimationOverlayType.loading,
      message: message,
      force: force,
    );
  }

  // ---------------------------------------------------------------------------
  // Success
  // ---------------------------------------------------------------------------

  /// يعرض Success وينتظر دورة Success كاملة:
  ///
  /// show
  ///   ↓
  /// دخول Route
  ///   ↓
  /// مدة العرض
  ///   ↓
  /// hide
  ///   ↓
  /// اكتمال إزالة Route
  ///
  /// لذلك:
  ///
  /// await showSuccess();
  ///
  /// يعني فعلياً أن Success انتهى بالكامل.
  static Future<void> showSuccess({
    String? message,
    Duration autoHide = const Duration(milliseconds: 1400),
    bool force = false,
  }) {
    return _enqueue(() async {
      await _showOrReplace(
        type: AnimationOverlayType.success,
        message: message,
        force: force,
      );

      // انتظر مدة Success فعلياً.
      await Future<void>.delayed(autoHide);

      // أزل Success مباشرة داخل نفس Queue operation.
      //
      // لا نستعمل hide() هنا لأن hide() تضيف عملية جديدة
      // إلى نفس Queue، وهذا سيؤدي إلى انتظار العملية لنفسها.
      await _hideNow();
    });
  }

  // ---------------------------------------------------------------------------
  // Error
  // ---------------------------------------------------------------------------

  /// يعرض Error ولا ينتظر المستخدم.
  ///
  /// الـ Error يبقى ظاهراً حتى:
  /// - يضغط المستخدم على الـ Overlay إذا كان مسموحاً.
  /// - أو يتم استدعاء hide() من الخارج.
  static Future<void> showError({
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    bool force = false,
  }) {
    return show(
      type: AnimationOverlayType.error,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      force: force,
    );
  }

  // ---------------------------------------------------------------------------
  // Warning
  // ---------------------------------------------------------------------------

  static Future<void> showWarning({
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    bool force = false,
  }) {
    return show(
      type: AnimationOverlayType.warning,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      force: force,
    );
  }

  // ---------------------------------------------------------------------------
  // Info
  // ---------------------------------------------------------------------------

  static Future<void> showInfo({
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    bool force = false,
  }) {
    return show(
      type: AnimationOverlayType.info,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      force: force,
    );
  }

  // ---------------------------------------------------------------------------
  // Network
  // ---------------------------------------------------------------------------

  static Future<void> showNetworkError({
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    bool force = false,
  }) {
    return show(
      type: AnimationOverlayType.network,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      force: force,
    );
  }

  // ---------------------------------------------------------------------------
  // Queue
  // ---------------------------------------------------------------------------

  static Future<void> _enqueue(Future<void> Function() operation) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return Future.value();
    }
    final completer = Completer<void>();

    _operationQueue = _operationQueue.then((_) async {
      try {
        await operation();

        if (!completer.isCompleted) {
          completer.complete();
        }
      } catch (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      }
    });

    return completer.future;
  }

  // ---------------------------------------------------------------------------
  // Show / Replace
  // ---------------------------------------------------------------------------

  static Future<void> _showOrReplace({
    required AnimationOverlayType type,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? autoHideAfter,
    bool force = false,
  }) async {
    final existingRoute = _route;

    if (existingRoute != null) {
      if (!force && type == AnimationOverlayType.loading) {
        return;
      }

      await _hideNow();
    }

    await _waitForSafeNavigator(force: force);

    final context = Get.overlayContext ?? Get.context;

    if (context == null || !context.mounted) {
      log(
        '⚠️ Cannot show animation overlay: '
        'no valid BuildContext is available.',
      );
      return;
    }

    final PageRouteBuilder<void> route = _createRoute(
      type: type,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      autoHideAfter: autoHideAfter,
    );

    _route = route;

    if (type == AnimationOverlayType.success) {
      SoundService.instance.playSound(usageType: AndroidUsageType.alarm);
    }

    final navigator = Navigator.of(context, rootNavigator: true);

    if (!navigator.mounted) {
      _route = null;
      log(
        '⚠️ Cannot show animation overlay: '
        'Navigator is not mounted.',
      );
      return;
    }

    // بدء إدخال الـ Route.
    unawaited(navigator.push<void>(route));

    // ننتظر حتى تكتمل عملية دخول Route
    // بدلاً من الاعتماد على Future.delayed(Duration.zero)
    // لمعرفة أن Transition انتهى.
    await _waitForRouteEntrance(route);

    // هذه الخاصية أصبحت غير مستخدمة مع Success،
    // لأن showSuccess يدير دورة Success كاملة بنفسه.
    //
    // تبقى هنا لدعم show() العام إذا استُخدمت مستقبلاً.
    if (autoHideAfter != null) {
      _scheduleAutoHide(route: route, duration: autoHideAfter);
    }
  }

  // ---------------------------------------------------------------------------
  // Route Entrance
  // ---------------------------------------------------------------------------

  /// ينتظر اكتمال transition الخاص بدخول Route.
  static Future<void> _waitForRouteEntrance(PageRoute<void> route) async {
    final animation = route.animation;

    if (animation == null) {
      return;
    }

    if (animation.status == AnimationStatus.completed) {
      return;
    }

    final completer = Completer<void>();

    void listener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        animation.removeStatusListener(listener);

        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    }

    animation.addStatusListener(listener);

    // قد يكون الـ animation اكتمل بين الفحص السابق
    // وبين إضافة الـ listener.
    if (animation.status == AnimationStatus.completed) {
      animation.removeStatusListener(listener);

      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    await completer.future;
  }
  // ---------------------------------------------------------------------------
  // Auto Hide
  // ---------------------------------------------------------------------------

  static void _scheduleAutoHide({
    required Route<void> route,
    required Duration duration,
  }) {
    Future<void>.delayed(duration, () async {
      if (!identical(_route, route)) {
        return;
      }

      await hide();
    });
  }

  // ---------------------------------------------------------------------------
  // Hide
  // ---------------------------------------------------------------------------

  static Future<void> _hideNow() async {
    final route = _route;

    if (route == null) {
      return;
    }

    // نفصل المرجع فوراً حتى لا تعتبر عمليات أخرى
    // أن هذا الـ Route ما زال هو الـ Active Overlay.
    _route = null;

    if (!_isNavigatorSafe()) {
      await _afterNextFrame(() {});
    }

    final context = Get.overlayContext ?? Get.context;

    if (context == null || !context.mounted) {
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);

    if (!navigator.mounted) {
      return;
    }

    try {
      if (route.isCurrent) {
        // pop ثم ننتظر Future الخاصة بالـ Route.
        //
        // هذا الـ Future يكتمل عند إزالة Route فعلياً.
        navigator.pop();

        await route.popped;
      } else {
        // Route ليست الحالية.
        //
        // نزيلها مباشرة ثم نعطي Flutter فرصة لمعالجة
        // تغيير الـ Navigator.
        navigator.removeRoute(route);

        await Future<void>.delayed(Duration.zero);
      }
    } catch (error) {
      // إذا كانت Route قد أزيلت بالفعل،
      // فلا يوجد شيء آخر يجب إزالته.
      //
      // لا نعيد رمي الخطأ هنا لأن الهدف من hide هو
      // ضمان انتهاء حالة الـ Overlay.
    }
  }

  // ---------------------------------------------------------------------------
  // Navigator Safety
  // ---------------------------------------------------------------------------

  static Future<void> _waitForSafeNavigator({required bool force}) async {
    if (force) {
      await _afterNextFrame(() {});
      return;
    }

    final scheduler = SchedulerBinding.instance;

    final busy =
        scheduler.hasScheduledFrame ||
        (scheduler.schedulerPhase != SchedulerPhase.idle &&
            scheduler.schedulerPhase != SchedulerPhase.postFrameCallbacks);

    if (busy) {
      await _afterNextFrame(() {});
    }
  }

  static bool _isNavigatorSafe() {
    final phase = SchedulerBinding.instance.schedulerPhase;

    return phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks;
  }

  // ---------------------------------------------------------------------------
  // Next Frame
  // ---------------------------------------------------------------------------

  static Future<void> _afterNextFrame(FutureOr<void> Function() action) {
    final completer = Completer<void>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await action();

        if (!completer.isCompleted) {
          completer.complete();
        }
      } catch (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      }
    });

    return completer.future;
  }

  // ---------------------------------------------------------------------------
  // Route
  // ---------------------------------------------------------------------------

  static PageRouteBuilder<void> _createRoute({
    required AnimationOverlayType type,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? autoHideAfter,
  }) {
    final cleanMessage =
        (type == AnimationOverlayType.error ||
                type == AnimationOverlayType.warning ||
                type == AnimationOverlayType.network) &&
            message != null
        ? AppException.sanitizeMessage(message)
        : message;

    final animationPath = _getAnimationPath(type);

    final defaultMessage = _getDefaultMessage(type);

    return PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      maintainState: true,

      transitionDuration: AppMotion.page,

      reverseTransitionDuration: AppMotion.slow,

      transitionsBuilder: (_, animation, __, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: AppMotion.springy,
          reverseCurve: AppMotion.standard,
        );

        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curve),
            child: child,
          ),
        );
      },

      pageBuilder: (context, _, __) {
        final isAction = actionLabel != null && onAction != null;

        final allowBackToClose =
            (type == AnimationOverlayType.error ||
                type == AnimationOverlayType.warning ||
                type == AnimationOverlayType.info ||
                type == AnimationOverlayType.network) &&
            autoHideAfter == null;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && allowBackToClose) {
              unawaited(hide());
            }
          },
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      if (type != AnimationOverlayType.loading) {
                        unawaited(hide());
                      }
                    },
                    child: Container(
                      color: context.colors.scrim.withValues(alpha: 0.45),
                    ),
                  ),
                ),

                Center(
                  child: RepaintBoundary(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                        vertical: AppSpacing.xxl,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.dialog),
                        boxShadow: AppElevation.level5(context),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: AppSpacing.section,
                            height: AppSpacing.section,
                            child: Lottie.asset(
                              animationPath,
                              repeat:
                                  type == AnimationOverlayType.loading ||
                                  type == AnimationOverlayType.network,
                            ),
                          ),

                          if (defaultMessage.isNotEmpty) AppSpacing.vSm,

                          if (defaultMessage.isNotEmpty)
                            Text(
                              cleanMessage ?? defaultMessage,
                              textAlign: TextAlign.center,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colors.onSurface,
                              ),
                            ),

                          if (isAction) ...[
                            AppSpacing.vLg,

                            CustomButton.primary(
                              text: actionLabel,
                              onPressed: () async {
                                await hide();
                                onAction();
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Assets
  // ---------------------------------------------------------------------------

  static String _getAnimationPath(AnimationOverlayType type) {
    switch (type) {
      case AnimationOverlayType.success:
        return 'assets/animations/success.json';

      case AnimationOverlayType.error:
        return 'assets/animations/error.json';

      case AnimationOverlayType.warning:
        return 'assets/animations/warning.json';

      case AnimationOverlayType.info:
        return 'assets/animations/info.json';

      case AnimationOverlayType.network:
        return 'assets/animations/network.json';

      case AnimationOverlayType.loading:
        return 'assets/animations/loading.json';
    }
  }

  static String _getDefaultMessage(AnimationOverlayType type) {
    switch (type) {
      case AnimationOverlayType.success:
        return 'تمت العملية بنجاح';

      case AnimationOverlayType.error:
        return 'حدث خطأ ما';

      case AnimationOverlayType.warning:
        return 'هل أنت متأكد؟';

      case AnimationOverlayType.info:
        return '';

      case AnimationOverlayType.network:
        return 'لا يوجد اتصال بالإنترنت';

      case AnimationOverlayType.loading:
        return '';
    }
  }
}
