import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Daftar path gambar terpusat. Taruh file foto di `assets/images/`.
/// Kalau file belum ada, [AppImage] otomatis menampilkan placeholder gradasi
/// + ikon, jadi aplikasi tidak error.
class AppImages {
  AppImages._();

  static const String hero = 'assets/images/hero.jpg';
  static const List<String> promos = [
    'assets/images/promo_oli.jpg',
    'assets/images/promo_rem.jpg',
    'assets/images/promo_member.jpg',
  ];
  static const List<String> gallery = [
    'assets/images/galeri_1.jpg',
    'assets/images/galeri_2.jpg',
    'assets/images/galeri_3.jpg',
    'assets/images/galeri_4.jpg',
    'assets/images/galeri_5.jpg',
    'assets/images/galeri_6.jpg',
  ];

  /// Pilih foto layanan berdasarkan judul layanan.
  static String forService(String title) {
    final t = title.toLowerCase();
    if (t.contains('oli')) return 'assets/images/svc_oli.jpg';
    if (t.contains('rem')) return 'assets/images/svc_rem.jpg';
    if (t.contains('listrik') || t.contains('aki')) return 'assets/images/svc_listrik.jpg';
    if (t.contains('ac')) return 'assets/images/svc_ac.jpg';
    if (t.contains('transmisi')) return 'assets/images/svc_transmisi.jpg';
    if (t.contains('mesin')) return 'assets/images/svc_mesin.jpg';
    return 'assets/images/svc_default.jpg';
  }
}

/// Gambar asset dengan fade-in dan fallback yang rapi.
class AppImage extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final IconData fallbackIcon;

  const AppImage(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.build_circle_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          asset,
          fit: fit,
          width: width,
          height: height,
          frameBuilder: (context, child, frame, sync) {
            if (sync) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (_, _, _) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2B303B), Color(0xFF1B1E25)],
              ),
            ),
            child: Center(
              child: Icon(fallbackIcon, color: AppColors.gold.withValues(alpha: 0.35), size: 34),
            ),
          ),
        ),
      ),
    );
  }
}
