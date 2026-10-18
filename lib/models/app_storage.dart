import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import 'booking_data.dart';
import 'loyalty_data.dart';

/// Menyimpan data aplikasi (booking, ulasan, poin loyalty, mode gelap)
/// ke penyimpanan perangkat / browser supaya tidak hilang saat aplikasi
/// ditutup atau halaman web di-refresh.
class AppStorage {
  AppStorage._();

  static const _kBookings = 'bookings_v1';
  static const _kPoints = 'loyalty_points_v1';
  static const _kDark = 'dark_mode_v1';

  static SharedPreferences? _prefs;

  /// Panggil sekali sebelum runApp: memuat data tersimpan lalu mulai
  /// menyimpan otomatis setiap ada perubahan.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;

      final dark = prefs.getBool(_kDark);
      if (dark != null) {
        AppColors.themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
      }

      LoyaltyData.restore(prefs.getInt(_kPoints) ?? 0);

      final raw = prefs.getString(_kBookings);
      if (raw != null && raw.isNotEmpty) {
        final list = (jsonDecode(raw) as List)
            .map((e) => BookingData.fromJson(e as Map<String, dynamic>))
            .toList();
        BookingData.restore(list);
      }
    } catch (_) {
      // Data rusak / penyimpanan tidak tersedia: mulai dari kosong.
    }

    BookingData.changes.addListener(_saveBookings);
    LoyaltyData.points.addListener(_savePoints);
    AppColors.themeMode.addListener(_saveTheme);
  }

  static void _saveBookings() {
    final json = jsonEncode(BookingData.bookings.map((b) => b.toJson()).toList());
    _prefs?.setString(_kBookings, json);
  }

  static void _savePoints() => _prefs?.setInt(_kPoints, LoyaltyData.points.value);

  static void _saveTheme() => _prefs?.setBool(_kDark, AppColors.isDark);
}
