import 'package:flutter/material.dart';

/// Palet warna terpusat untuk seluruh aplikasi BengkelKu.
/// Mendukung mode gelap (dark charcoal + oranye) dan mode terang.
/// Warna tema (background, surface, teks, dll.) dibaca lewat getter sehingga
/// otomatis mengikuti mode yang dipilih di Pengaturan.
/// Nama `gold` / `goldSoft` sengaja dipertahankan supaya semua halaman
/// yang sudah memakainya otomatis ikut oranye.
class AppColors {
  AppColors._();

  /// Mode tampilan aktif. Ubah lewat [setDarkMode].
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  static bool get isDark => themeMode.value != ThemeMode.light;

  /// Ganti mode terang/gelap, lalu paksa seluruh layar menggambar ulang
  /// (banyak widget memakai warna yang dibaca saat build).
  static void setDarkMode(bool dark) {
    final next = dark ? ThemeMode.dark : ThemeMode.light;
    if (themeMode.value == next) return;
    themeMode.value = next;
    WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildAll());
    WidgetsBinding.instance.scheduleFrame();
  }

  static void _rebuildAll() {
    void visit(Element element) {
      element.markNeedsBuild();
      element.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
  }

  // --- Warna tetap (sama di kedua mode) ---
  static const Color gold = Color(0xFFF59E0B); // oranye utama
  static const Color goldSoft = Color(0xFFFBBF24); // oranye terang
  static const Color danger = Color(0xFFE07A6E);
  static const Color success = Color(0xFF7BC67E);

  // --- Warna mengikuti tema ---
  static Color get background =>
      isDark ? const Color(0xFF16181D) : const Color(0xFFF5F7FA);
  static Color get surface =>
      isDark ? const Color(0xFF1F2229) : const Color(0xFFFFFFFF);
  static Color get surfaceAlt =>
      isDark ? const Color(0xFF242831) : const Color(0xFFEDF0F4);
  static Color get textPrimary =>
      isDark ? const Color(0xFFF3F4F6) : const Color(0xFF16181D);
  static Color get textSecondary =>
      isDark ? const Color(0xFF9AA1AE) : const Color(0xFF5B6472);
  static Color get borderSubtle =>
      isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000);
}
