/// ============================================================================
/// محرك حسابات الأوراق والكروت السيادي (VoucherSheetCalculator)
/// ============================================================================
/// أداة نقية ومعيارية مركزية مسؤولة عن حسابات التحويل المزدوج بين الأوراق (Sheets)
/// والكروت (Vouchers) وفق قواعد التوزيع المؤسسية وقص الأوراق لشبكات الاتصالات:
/// - عند كون عدد الكروت فردياً في الورقة (مثل 51)، يُحسب النصف بـ 26 كرت (Ceil).
/// - حساب مضاعفات وكسور الأوراق (نصف ورقة، ورقة، ورقة ونصف، إلخ).
/// - صياغة التوصيف النصي العربي الفصيح والدقيق لحجم الطلب.
class VoucherSheetCalculator {
  VoucherSheetCalculator._();

  /// حساب عدد كروت نصف الورقة بالتقريب للأعلى
  /// مثال: 51 -> 26 ، 50 -> 25 ، 24 -> 12
  static int halfSheetCards(int sheetSize) {
    if (sheetSize <= 0) return 0;
    return (sheetSize / 2.0).ceil();
  }

  /// حساب عدد كروت النصف الثاني المتبقي من الورقة
  /// مثال: 51 -> 25
  static int remainingHalfSheetCards(int sheetSize) {
    if (sheetSize <= 0) return 0;
    return sheetSize - halfSheetCards(sheetSize);
  }

  /// حساب إجمالي الكروت لعدد محدد من الأوراق (يدعم الأعداد الصحيحة والأنصاف والأرباع)
  /// مثال عند sheetSize = 51:
  /// - 0.5 ورقة -> 26 كرت
  /// - 1.0 ورقة -> 51 كرت
  /// - 1.5 ورقة -> 77 كرت (51 + 26)
  /// - 2.0 ورقة -> 102 كرت
  /// - 2.5 ورقة -> 128 كرت (102 + 26)
  static int cardsForSheets(double sheets, int sheetSize) {
    if (sheets <= 0 || sheetSize <= 0) return 0;

    final int fullSheets = sheets.floor();
    final double fraction = sheets - fullSheets;

    // حالة الأوراق الكاملة بدون كسور
    if (fraction < 0.001) {
      return fullSheets * sheetSize;
    }

    // حالة النصف ورقة الدقيقة (بين 0.45 و 0.55)
    if ((fraction - 0.5).abs() < 0.05) {
      return (fullSheets * sheetSize) + halfSheetCards(sheetSize);
    }

    // لأي كسور أخرى (مثل الربع أو الثلث) يتم التقريب للأعلى
    return (fullSheets * sheetSize) + (fraction * sheetSize).ceil();
  }

  /// فحص ما إذا كانت كمية كروت معينة تمثل نصف ورقة تحديداً
  static bool isHalfSheet(int cards, int sheetSize) {
    if (cards <= 0 || sheetSize <= 0) return false;
    return cards == halfSheetCards(sheetSize);
  }

  /// فحص ما إذا كانت الكمية تمثل عدداً صحيحاً من الأوراق أو أوراقاً وأنصافاً
  static SheetBreakdown breakdown(int cards, int sheetSize) {
    if (cards <= 0 || sheetSize <= 0) {
      return const SheetBreakdown(
        fullSheets: 0,
        hasHalfSheet: false,
        remainderCards: 0,
        totalCards: 0,
        sheetSize: 0,
      );
    }

    final int fullSheets = cards ~/ sheetSize;
    final int remainder = cards % sheetSize;
    final int half = halfSheetCards(sheetSize);

    if (remainder == 0) {
      return SheetBreakdown(
        fullSheets: fullSheets,
        hasHalfSheet: false,
        remainderCards: 0,
        totalCards: cards,
        sheetSize: sheetSize,
      );
    }

    if (remainder == half) {
      return SheetBreakdown(
        fullSheets: fullSheets,
        hasHalfSheet: true,
        remainderCards: 0,
        totalCards: cards,
        sheetSize: sheetSize,
      );
    }

    return SheetBreakdown(
      fullSheets: fullSheets,
      hasHalfSheet: false,
      remainderCards: remainder,
      totalCards: cards,
      sheetSize: sheetSize,
    );
  }

  /// توليد الصياغة النصية العربية البليغة والمطابقة بدقة للكمية
  /// أمثلة عند sheetSize = 51:
  /// - 26 -> "نصف ورقة"
  /// - 51 -> "ورقة واحدة"
  /// - 77 -> "ورقة ونصف"
  /// - 102 -> "ورقتان"
  /// - 128 -> "ورقتان ونصف"
  /// - 153 -> "3 ورقات"
  /// - 204 -> "4 ورقات"
  /// - 55 -> "ورقة واحدة و 4 كروت"
  static String describe(int cards, int sheetSize) {
    if (cards <= 0 || sheetSize <= 0) return '';

    final b = breakdown(cards, sheetSize);

    // إذا كانت نصف ورقة فقط
    if (b.fullSheets == 0 && b.hasHalfSheet) {
      return 'نصف ورقة';
    }

    // إذا كانت أوراقاً وأنصافاً متطابقة تماماً
    if (b.hasHalfSheet && b.remainderCards == 0) {
      return switch (b.fullSheets) {
        1 => 'ورقة ونصف',
        2 => 'ورقتان ونصف',
        >= 3 && <= 10 => '${b.fullSheets} ورقات ونصف',
        _ => '${b.fullSheets} ورقة ونصف',
      };
    }

    // إذا كانت أوراقاً كاملة بدون بواقي
    if (b.remainderCards == 0) {
      return switch (b.fullSheets) {
        1 => 'ورقة واحدة',
        2 => 'ورقتان',
        >= 3 && <= 10 => '${b.fullSheets} ورقات',
        _ => '${b.fullSheets} ورقة',
      };
    }

    // إذا كانت هناك كروت إضافية متبقية فوق الأوراق
    if (b.fullSheets > 0) {
      final sheetText = switch (b.fullSheets) {
        1 => 'ورقة واحدة',
        2 => 'ورقتان',
        >= 3 && <= 10 => '${b.fullSheets} ورقات',
        _ => '${b.fullSheets} ورقة',
      };
      return '$sheetText و ${b.remainderCards} كرت';
    }

    return '$cards كرت';
  }

  /// قائمة الرقائق السريعة الافتراضية المناسبة للباقة بناءً على سعتها
  static List<VoucherSheetPreset> getPresets(int sheetSize) {
    if (sheetSize <= 0) return const [];

    final half = halfSheetCards(sheetSize);

    return [
      VoucherSheetPreset(
        label: 'نصف ورقة ($half)',
        shortLabel: '½ ورقة',
        cards: half,
        sheets: 0.5,
      ),
      VoucherSheetPreset(
        label: 'ورقة ($sheetSize)',
        shortLabel: '1 ورقة',
        cards: sheetSize,
        sheets: 1.0,
      ),
      VoucherSheetPreset(
        label: 'ورقة ونصف (${sheetSize + half})',
        shortLabel: '1½ ورقة',
        cards: sheetSize + half,
        sheets: 1.5,
      ),
      VoucherSheetPreset(
        label: 'ورقتان (${sheetSize * 2})',
        shortLabel: '2 ورقة',
        cards: sheetSize * 2,
        sheets: 2.0,
      ),
      VoucherSheetPreset(
        label: '3 ورقات (${sheetSize * 3})',
        shortLabel: '3 ورقات',
        cards: sheetSize * 3,
        sheets: 3.0,
      ),
    ];
  }
}

/// ============================================================================
/// كائن تفكيك كمية الأوراق (SheetBreakdown)
/// ============================================================================
class SheetBreakdown {
  final int fullSheets;
  final bool hasHalfSheet;
  final int remainderCards;
  final int totalCards;
  final int sheetSize;

  const SheetBreakdown({
    required this.fullSheets,
    required this.hasHalfSheet,
    required this.remainderCards,
    required this.totalCards,
    required this.sheetSize,
  });

  /// الحساب الكلي العشري التقريبي لعدد الأوراق
  double get totalSheetsFraction {
    if (sheetSize <= 0) return 0.0;
    return totalCards / sheetSize;
  }

  /// هل الكمية مطابقة تماماً لمضاعفات الأوراق والأنصاف
  bool get isExactSheetOrHalf => remainderCards == 0;
}

/// ============================================================================
/// كائن كبسولة الورقة الجاهزة (VoucherSheetPreset)
/// ============================================================================
class VoucherSheetPreset {
  final String label;
  final String shortLabel;
  final int cards;
  final double sheets;

  const VoucherSheetPreset({
    required this.label,
    required this.shortLabel,
    required this.cards,
    required this.sheets,
  });
}
