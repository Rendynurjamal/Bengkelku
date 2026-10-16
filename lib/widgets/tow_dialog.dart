import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';

/// Nomor WhatsApp admin/derek BengkelKu (format internasional tanpa +).
const String kTowWhatsAppNumber = '6283840576034';

/// Bottom sheet "Mogok / Butuh Derek": pilih/isi plat nomor, lalu buka
/// WhatsApp dengan pesan yang sudah terisi plat nomor kendaraan.
Future<void> showTowSheet(
  BuildContext context, {
  required List<String> knownPlates,
  String? initialPlate,
}) {
  final controller = TextEditingController(
    text: initialPlate ?? (knownPlates.isNotEmpty ? knownPlates.first : ''),
  );

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
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: AppColors.borderSubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.car_crash_outlined, color: AppColors.danger),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Mogok / Butuh Derek',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih atau isi plat nomor kendaraanmu. Pesan darurat akan terisi otomatis dan dikirim lewat WhatsApp ke admin.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
                  ),
                  if (knownPlates.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: knownPlates.map((plate) {
                        final active = controller.text.trim().toUpperCase() == plate;
                        return ChoiceChip(
                          label: Text(plate),
                          selected: active,
                          selectedColor: AppColors.gold.withValues(alpha: 0.25),
                          labelStyle: TextStyle(
                            color: active ? AppColors.gold : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => setSheetState(() => controller.text = plate),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) => setSheetState(() {}),
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Contoh: L 1234 AB',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.confirmation_number_outlined, color: AppColors.gold),
                      filled: true,
                      fillColor: AppColors.surfaceAlt,
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
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text('KIRIM VIA WHATSAPP',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        final plate = controller.text.trim().toUpperCase();
                        if (plate.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Isi plat nomor dulu ya.')),
                          );
                          return;
                        }
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(sheetContext);
                        final text = 'DARURAT! Halo Admin BengkelKu, kendaraan saya mogok dan butuh derek. '
                            'Plat nomor: $plate. Mohon segera dibantu.';
                        final uri = Uri.parse(
                          'https://wa.me/$kTowWhatsAppNumber?text=${Uri.encodeComponent(text)}',
                        );
                        try {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } catch (_) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
                          );
                        }
                      },
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
