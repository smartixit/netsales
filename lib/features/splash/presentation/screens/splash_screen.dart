import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/features/splash/presentation/widgets/splash_body_content.dart';
import 'package:netsales/features/splash/presentation/widgets/splash_circle_vector.dart';

/// شاشة الإقلاع الرئيسية للنظام (Splash Screen)
/// واجهة عرض نقية (Lean View) خالية من أي منطق أعمال وتلتزم بنظام التصميم الموحد.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF003B32),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient(context),
          ),
          child: SafeArea(
            child: Stack(
              children: [const SplashCircleVector(), const SplashBodyContent()],
            ),
          ),
        ),
      ),
    );
  }
}
