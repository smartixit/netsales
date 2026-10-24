import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';

class CustomAppScaffold extends StatelessWidget {
  const CustomAppScaffold({
    super.key,
    this.backgroundColor,
    this.appBarTitle,
    this.appBarBg,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  final PreferredSizeWidget? appBar;
  final String? appBarTitle;
  final Color? appBarBg;
  final Color? backgroundColor;
  final Widget body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: backgroundColor ?? colors.background,
      appBar: appBarTitle != null
          ? AppBar(
              title: Text(appBarTitle!),
              backgroundColor: appBarBg ?? colors.surface,
            )
          : appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
