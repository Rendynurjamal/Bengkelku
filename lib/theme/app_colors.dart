import 'package:flutter/material.dart';

/// Palet warna terpusat untuk seluruh aplikasi BengkelKu.
/// Gaya baru: dark charcoal + oranye (mengikuti referensi AutoFixPro).
/// Nama `gold` / `goldSoft` sengaja dipertahankan supaya semua halaman
/// yang sudah memakainya otomatis ikut berubah jadi oranye.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF16181D);
  static const Color surface = Color(0xFF1F2229);
  static const Color surfaceAlt = Color(0xFF242831);
  static const Color gold = Color(0xFFF59E0B); // oranye utama
  static const Color goldSoft = Color(0xFFFBBF24); // oranye terang
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9AA1AE);
  static const Color borderSubtle = Color(0x1AFFFFFF); // putih 10%
  static const Color danger = Color(0xFFE07A6E);
  static const Color success = Color(0xFF7BC67E);
}
