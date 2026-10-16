import 'package:flutter/material.dart';

import '../models/booking_data.dart';
import '../models/mechanic_data.dart';
import '../theme/app_colors.dart';
import 'mechanic_widgets.dart';

Widget _grabber() => Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: AppColors.borderSubtle,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

/// Form bintang + komentar setelah servis "Selesai".
/// Setelah dikirim, struk digital langsung ditampilkan.
Future<void> showReviewSheet(BuildContext context, BookingData booking) {
  final BuildContext outerContext = context;
  int stars = 0;
  final commentController = TextEditingController();
  final mechanic = MechanicData.byName(booking.mechanicName);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          const labels = ['Ketuk bintang untuk menilai', 'Kurang puas', 'Biasa saja', 'Cukup baik', 'Puas', 'Sangat puas!'];

          return Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              20,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _grabber(),
                  Row(
                    children: [
                      MechanicAvatar(mechanic: mechanic, radius: 26),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Servis selesai! 🎉',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${booking.serviceName} • ${booking.plateNumber}\nMontir: ${booking.mechanicName ?? '-'}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) {
                        final filled = i < stars;
                        return GestureDetector(
                          onTap: () => setSheetState(() => stars = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              filled ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: AppColors.gold,
                              size: 44,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      labels[stars],
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    maxLength: 200,
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar tentang servis & montir (opsional)',
                      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.surfaceAlt,
                      counterStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: stars == 0
                          ? null
                          : () {
                              booking.rating = stars;
                              booking.review = commentController.text.trim();
                              booking.reviewedAt = DateTime.now();
                              BookingData.notifyChanged();
                              Navigator.pop(sheetContext);
                              showReceiptSheet(outerContext, booking);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.surfaceAlt,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('KIRIM ULASAN & LIHAT STRUK',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text('Nanti saja', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Struk digital: rincian servis, montir, diskon, dan total.
Future<void> showReceiptSheet(BuildContext context, BookingData b) {
  final nomor = 'BK-${b.id.toString().padLeft(5, '0')}';
  final finished = b.statusChangedAt;
  final discount = b.discountAmount;
  final hasDiscount = b.discountPercent > 0;

  Widget row(String label, String value, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Divider(height: 1, color: AppColors.borderSubtle),
      );

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _grabber(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.receipt_long, color: AppColors.gold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Struk Digital',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text('BengkelKu • $nomor',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('LUNAS',
                        style: TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    row('Pemilik', b.ownerName),
                    row('Kendaraan', '${b.vehicleType} • ${b.plateNumber}'),
                    row('Jadwal', b.formattedSchedule),
                    row('Selesai', '${BookingData.formatDate(finished)} • ${finished.hour.toString().padLeft(2, '0')}:${finished.minute.toString().padLeft(2, '0')}'),
                    divider(),
                    row('Layanan', b.serviceName),
                    row('Montir', b.mechanicName ?? '-'),
                    row('Durasi', b.duration),
                    divider(),
                    row('Harga layanan', b.basePrice),
                    if (hasDiscount)
                      row(
                        b.discountLabel ?? 'Diskon',
                        b.discountPercent >= 1.0
                            ? 'GRATIS'
                            : '-${BookingData.formatRupiah(discount)}',
                        color: AppColors.success,
                      ),
                    divider(),
                    row('TOTAL', b.price, color: AppColors.gold, bold: true),
                    divider(),
                    row('Poin didapat', '+${b.pointsEarned} poin', color: AppColors.gold),
                    if (b.isReviewed)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Text('Ulasanmu',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            const Spacer(),
                            StarRow(rating: b.rating!.toDouble(), size: 16),
                          ],
                        ),
                      ),
                    if (b.isReviewed && (b.review ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('"${b.review}"',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                  fontStyle: FontStyle.italic)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text('Terima kasih sudah servis di BengkelKu 🙏',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
