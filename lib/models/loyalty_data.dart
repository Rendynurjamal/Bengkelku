import 'package:flutter/foundation.dart';

/// Level member berdasarkan total poin.
class LoyaltyLevel {
  final String name;
  final int minPoints;
  const LoyaltyLevel(this.name, this.minPoints);
}

/// Poin loyalty & level member. Poin naik setiap kali pengguna booking.
class LoyaltyData {
  LoyaltyData._();

  static const List<LoyaltyLevel> levels = [
    LoyaltyLevel('Bronze', 0),
    LoyaltyLevel('Silver', 300),
    LoyaltyLevel('Gold', 800),
  ];

  /// Poin dasar per booking + bonus 10 poin tiap Rp10.000 yang dibayar.
  static const int basePointsPerBooking = 100;

  static final ValueNotifier<int> points = ValueNotifier<int>(0);

  /// Tambah poin untuk sebuah booking dengan harga akhir [finalPrice]
  /// (mis. "Rp80.000" atau "GRATIS"). Mengembalikan poin yang didapat.
  static int award(String finalPrice) {
    final digits = finalPrice.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = digits.isEmpty ? 0 : int.parse(digits);
    final earned = basePointsPerBooking + (amount ~/ 10000) * 10;
    points.value += earned;
    return earned;
  }

  static LoyaltyLevel get level {
    LoyaltyLevel current = levels.first;
    for (final l in levels) {
      if (points.value >= l.minPoints) current = l;
    }
    return current;
  }

  /// Level berikutnya, atau null kalau sudah level tertinggi.
  static LoyaltyLevel? get nextLevel {
    final i = levels.indexOf(level);
    return i + 1 < levels.length ? levels[i + 1] : null;
  }

  /// 0.0 - 1.0 progres menuju level berikutnya.
  static double get progressToNext {
    final next = nextLevel;
    if (next == null) return 1.0;
    final cur = level;
    final span = next.minPoints - cur.minPoints;
    return ((points.value - cur.minPoints) / span).clamp(0.0, 1.0).toDouble();
  }
}
