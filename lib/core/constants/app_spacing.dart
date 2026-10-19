import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  AppSpacing._();

  /// Zero spacing
  static double get zero => 0.w;

  /// Micro spacing (2)
  static double get xxs => 2.w;

  /// Extra small spacing (4)
  static double get xs => 4.w;

  /// Small spacing (8)
  static double get sm => 8.w;

  /// Medium spacing (12)
  static double get md => 12.w;

  /// Large spacing (16)
  static double get lg => 16.w;

  /// Extra large spacing (20)
  static double get xl => 20.w;

  /// Double extra large spacing (24)
  static double get xxl => 24.w;

  /// Triple extra large spacing (32)
  static double get xxxl => 32.w;

  /// Huge spacing (40)
  static double get huge => 40.w;

  /// Giant spacing (48)
  static double get giant => 48.w;

  /// Section spacing (56)
  static double get section => 56.w;

  /// Large section spacing (64)
  static double get sectionLg => 64.w;

  /// Extra large section spacing (80)
  static double get sectionXl => 80.w;

  /// Screen padding horizontal
  static double get screenPadding => 24.w;

  /// Card padding
  static double get cardPadding => 16.w;

  /// Button padding horizontal
  static double get buttonPaddingH => 24.w;

  /// Button padding vertical
  static double get buttonPaddingV => 14.h;

  /// Input padding
  static double get inputPadding => 16.w;

  /// List item spacing
  static double get listItemSpacing => 12.w;

  /// Grid spacing
  static double get gridSpacing => 16.w;

  /// Dialog padding
  static double get dialogPadding => 24.w;

  /// Bottom sheet padding
  static double get bottomSheetPadding => 24.w;

  /// App bar height
  static double get appBarHeight => 56.h;

  /// Bottom nav height
  static double get bottomNavHeight => 80.h;

  /// Status bar height
  static double get statusBarHeight => 24.h;

  /// Horizontal spacing shortcuts
  static SizedBox get hXxs => SizedBox(width: xxs);
  static SizedBox get hXs => SizedBox(width: xs);
  static SizedBox get hSm => SizedBox(width: sm);
  static SizedBox get hMd => SizedBox(width: md);
  static SizedBox get hLg => SizedBox(width: lg);
  static SizedBox get hXl => SizedBox(width: xl);
  static SizedBox get hXxl => SizedBox(width: xxl);

  /// Vertical spacing shortcuts
  static SizedBox get vXxs => SizedBox(height: xxs);
  static SizedBox get vXs => SizedBox(height: xs);
  static SizedBox get vSm => SizedBox(height: sm);
  static SizedBox get vMd => SizedBox(height: md);
  static SizedBox get vLg => SizedBox(height: lg);
  static SizedBox get vXl => SizedBox(height: xl);
  static SizedBox get vXxl => SizedBox(height: xxl);
  static SizedBox get vHuge => SizedBox(height: huge);
  static SizedBox get vGiant => SizedBox(height: giant);
}
