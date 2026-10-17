import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppRadius {
  AppRadius._();

  /// No radius (0)
  static double get none => 0.r;

  /// Extra small radius (4) - Tags, chips, small badges
  static double get xs => 4.r;

  /// Small radius (8) - Small buttons, inputs, checkboxes
  static double get sm => 8.r;

  /// Medium radius (12) - Cards, dialogs, menus
  static double get md => 12.r;

  /// Large radius (16) - Large cards, sheets, containers
  static double get lg => 16.r;

  /// Extra large radius (20) - Modals, bottom sheets
  static double get xl => 20.r;

  /// Double extra large radius (24) - Bottom sheets, drawers
  static double get xxl => 24.r;

  /// Triple extra large radius (28) - Large dialogs
  static double get xxxl => 28.r;

  /// Full radius (999) - Pills, avatars, circular buttons
  static double get full => 999.r;

  /// Button radius
  static double get button => 16.r;

  /// Input radius
  static double get input => 12.r;

  /// Card radius
  static double get card => 16.r;

  /// Dialog radius
  static double get dialog => 24.r;

  /// Bottom sheet radius
  static double get bottomSheet => 24.r;

  /// Chip radius
  static double get chip => 8.r;

  /// Avatar radius
  static double get avatar => 999.r;

  /// Snackbar radius
  static double get snackbar => 12.r;

  /// Tooltip radius
  static double get tooltip => 8.r;

  /// Border radius shortcuts
  static BorderRadius get noneRadius => BorderRadius.circular(none);
  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get xxlRadius => BorderRadius.circular(xxl);
  static BorderRadius get fullRadius => BorderRadius.circular(full);

  /// Top-only radius
  static BorderRadius get topLg =>
      BorderRadius.vertical(top: Radius.circular(lg));
  static BorderRadius get topXl =>
      BorderRadius.vertical(top: Radius.circular(xl));
  static BorderRadius get topXxl =>
      BorderRadius.vertical(top: Radius.circular(xxl));

  /// Bottom-only radius
  static BorderRadius get bottomLg =>
      BorderRadius.vertical(bottom: Radius.circular(lg));
  static BorderRadius get bottomXl =>
      BorderRadius.vertical(bottom: Radius.circular(xl));

  /// Left-only radius
  static BorderRadius get leftLg =>
      BorderRadius.horizontal(left: Radius.circular(lg));

  /// Right-only radius
  static BorderRadius get rightLg =>
      BorderRadius.horizontal(right: Radius.circular(lg));
}
