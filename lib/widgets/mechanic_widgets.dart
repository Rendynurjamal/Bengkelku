import 'package:flutter/material.dart';

import '../models/mechanic_data.dart';
import '../theme/app_colors.dart';

/// Foto montir. Kalau file foto belum ada di assets, tampil avatar inisial.
class MechanicAvatar extends StatelessWidget {
  final Mechanic? mechanic;
  final double radius;

  const MechanicAvatar({super.key, required this.mechanic, this.radius = 26});

  @override
  Widget build(BuildContext context) {
    final m = mechanic;
    final size = radius * 2;

    Widget fallback() => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.goldSoft, AppColors.gold],
            ),
          ),
          child: m == null
              ? Icon(Icons.engineering_outlined,
                  color: Colors.white, size: radius)
              : Text(
                  m.initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.95,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );

    if (m == null) return fallback();

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          m.photoAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback(),
        ),
      ),
    );
  }
}

/// Deretan bintang (mendukung setengah bintang).
class StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const StarRow({super.key, required this.rating, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final IconData icon;
        if (rating >= i + 1) {
          icon = Icons.star;
        } else if (rating >= i + 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, color: AppColors.gold, size: size);
      }),
    );
  }
}
