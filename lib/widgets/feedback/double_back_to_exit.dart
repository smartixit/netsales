// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:netsales/core/constants/app_radius.dart';
// import 'package:netsales/core/constants/app_spacing.dart';

// /// ويدجت ذكية تعترض زر الرجوع (Back Button / Gesture) وتطلب من المستخدم
// /// النقر مرة أخرى خلال ثانيتين للخروج من التطبيق منعاً للخروج العرضي.
// class DoubleBackToExit extends StatefulWidget {
//   final Widget child;
//   final String message;
//   final Duration duration;

//   /// دالة اختيارية تُستدعى أولاً (مثلاً: العودة للتبويب الرئيسي قبل طلب الخروج).
//   /// إذا أعادت `true`، يتم تجاوز فحص الخروج.
//   final bool Function()? onWillHandlePop;

//   const DoubleBackToExit({
//     super.key,
//     required this.child,
//     this.message = 'انقر مرة أخرى للخروج من التطبيق',
//     this.duration = const Duration(seconds: 2),
//     this.onWillHandlePop,
//   });

//   @override
//   State<DoubleBackToExit> createState() => _DoubleBackToExitState();
// }

// class _DoubleBackToExitState extends State<DoubleBackToExit> {
//   DateTime? _lastBackPressTime;

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) return;

//         // إذا كان هناك معالج خاص (مثل التبديل للتبويب الأول)
//         if (widget.onWillHandlePop != null && widget.onWillHandlePop!()) {
//           return;
//         }

//         final now = DateTime.now();
//         if (_lastBackPressTime == null ||
//             now.difference(_lastBackPressTime!) > widget.duration) {
//           _lastBackPressTime = now;
//           HapticFeedback.lightImpact();
//           _showExitToast(context);
//         } else {
//           // نقرة ثانية خلال المدة المحددة -> خروج من التطبيق
//           SystemNavigator.pop();
//         }
//       },
//       child: widget.child,
//     );
//   }

//   void _showExitToast(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;

//     ScaffoldMessenger.of(context).removeCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.exit_to_app_rounded,
//               color: scheme.onInverseSurface,
//               size: 18.sp,
//             ),
//             SizedBox(width: AppSpacing.sm),
//             Flexible(
//               child: Text(
//                 widget.message,
//                 textAlign: TextAlign.center,
//                 style: theme.textTheme.labelMedium?.copyWith(
//                   color: scheme.onInverseSurface,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 12.sp,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppRadius.full),
//         ),
//         backgroundColor: scheme.inverseSurface.withValues(alpha: 0.93),
//         margin: EdgeInsets.symmetric(horizontal: 48.w, vertical: 24.h),
//         duration: widget.duration,
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//         elevation: 4,
//       ),
//     );
//   }
// }
