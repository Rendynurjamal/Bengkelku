part of '../home_page.dart';

/// Bagian UI: profile tab (memisah home_page.dart supaya tidak terlalu panjang).
extension _ProfileTab on _HomePageState {
  Widget profilePage() {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [surfaceAlt, surface],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: gold.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gold.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: gold.withValues(alpha: 0.12),
                    child: const Icon(Icons.person, size: 46, color: gold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Admin BengkelKu',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Pengelola BengkelKu',
                  style: TextStyle(color: textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _loyaltyCard(),
          const SizedBox(height: 22),
          _profileMenu(
            icon: Icons.car_crash_outlined,
            title: 'Mogok / Butuh Derek',
            onTap: openTowRequest,
            isDanger: true,
          ),
          _profileMenu(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            onTap: showAppSettings,
          ),
          _profileMenu(
            icon: Icons.help_outline,
            title: 'Bantuan',
            onTap: showHelp,
          ),
          _profileMenu(
            icon: Icons.chat_outlined,
            title: 'Hubungi Admin via WhatsApp',
            onTap: openWhatsApp,
          ),
          _profileMenu(
            icon: Icons.logout,
            title: 'Keluar',
            onTap: logout,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  /// Poin loyalty + level member (Bronze / Silver / Gold).
  Widget _loyaltyCard() {
    return ValueListenableBuilder<int>(
      valueListenable: LoyaltyData.points,
      builder: (context, points, _) {
        final level = LoyaltyData.level;
        final next = LoyaltyData.nextLevel;
        final Color levelColor = level.name == 'Gold'
            ? const Color(0xFFFFC107)
            : level.name == 'Silver'
                ? const Color(0xFFB0BEC5)
                : const Color(0xFFCD7F32);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: levelColor.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.workspace_premium, color: levelColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Member ${level.name}', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('$points poin', style: TextStyle(color: textSecondary, fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: LoyaltyData.progressToNext,
                  minHeight: 8,
                  backgroundColor: surfaceAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                next == null
                    ? 'Level tertinggi tercapai 🎉'
                    : '${next.minPoints - points} poin lagi menuju ${next.name}',
                style: TextStyle(color: textSecondary, fontSize: 11.5),
              ),
              const SizedBox(height: 2),
              Text('Setiap booking = +${LoyaltyData.basePointsPerBooking} poin, bonus 10 poin per Rp10.000.',
                  style: TextStyle(color: textSecondary, fontSize: 11)),
            ],
          ),
        );
      },
    );
  }

  // Pengaturan aplikasi: perubahan switch langsung terlihat dan aktif.
  void showAppSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: borderSubtle, borderRadius: BorderRadius.circular(8)))),
                const SizedBox(height: 20),
                Text('Pengaturan', style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Atur preferensi aplikasi BengkelKu.', style: TextStyle(color: textSecondary)),
                const SizedBox(height: 14),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.dark_mode_outlined, color: gold),
                  title: Text('Mode gelap', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('Matikan untuk memakai tampilan terang', style: TextStyle(color: textSecondary)),
                  value: AppColors.isDark,
                  activeColor: gold,
                  onChanged: (value) {
                    AppColors.setDarkMode(value);
                    setSheetState(() {});
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.notifications_active_outlined, color: gold),
                  title: Text('Notifikasi', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('Tampilkan pemberitahuan aplikasi', style: TextStyle(color: textSecondary)),
                  value: notificationsEnabled,
                  activeColor: gold,
                  onChanged: (value) {
                    setSheetState(() => notificationsEnabled = value);
                    if (mounted) _update(() {});
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.alarm_outlined, color: gold),
                  title: Text('Pengingat servis', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('Aktifkan pengingat perawatan kendaraan', style: TextStyle(color: textSecondary)),
                  value: serviceReminderEnabled,
                  activeColor: gold,
                  onChanged: (value) {
                    setSheetState(() => serviceReminderEnabled = value);
                    if (mounted) _update(() {});
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.view_agenda_outlined, color: gold),
                  title: Text('Tampilan ringkas', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('Preferensi untuk tampilan daftar layanan', style: TextStyle(color: textSecondary)),
                  value: compactServiceCards,
                  activeColor: gold,
                  onChanged: (value) {
                    setSheetState(() => compactServiceCards = value);
                    if (mounted) _update(() {});
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: background),
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Catatan: preferensi ini belum disimpan permanen setelah aplikasi ditutup.', style: TextStyle(color: textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bantuan berisi panduan penggunaan singkat yang bisa dibuka dari Profil.
  void showHelp() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pusat Bantuan', style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Panduan singkat menggunakan BengkelKu.', style: TextStyle(color: textSecondary)),
              const SizedBox(height: 16),
              const _HelpItem(icon: Icons.build_outlined, title: 'Memilih layanan', description: 'Buka tab Layanan, pilih jenis servis, lalu lihat detail dan harga sebelum melanjutkan.'),
              const _HelpItem(icon: Icons.calendar_month_outlined, title: 'Booking servis', description: 'Pilih layanan dan lengkapi informasi kendaraan serta jadwal yang tersedia.'),
              const _HelpItem(icon: Icons.history_outlined, title: 'Melihat riwayat', description: 'Buka tab Riwayat untuk memeriksa pesanan atau servis yang tercatat di aplikasi.'),
              const _HelpItem(icon: Icons.notifications_outlined, title: 'Notifikasi dan pengingat', description: 'Atur preferensi notifikasi dan pengingat servis melalui menu Pengaturan.'),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () { Navigator.pop(sheetContext); openWhatsApp(); }, child: const Text('Hubungi Admin via WhatsApp'))),
              const SizedBox(height: 6),
              SizedBox(width: double.infinity, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: background), onPressed: () => Navigator.pop(sheetContext), child: const Text('Tutup'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final Color accent = isDanger ? AppColors.danger : gold;

    return TapScale(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderSubtle),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDanger ? accent : textPrimary,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: textSecondary),
        ),
      ),
    );
  }
}
