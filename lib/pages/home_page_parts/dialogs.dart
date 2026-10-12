part of '../home_page.dart';

/// Dialog & bottom sheet: daftar member, notifikasi, logout.
extension _HomeDialogs on _HomePageState {
  void _openMemberRegistration() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
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
                      color: borderSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.card_giftcard, color: gold),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Daftar Member Baru',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Isi data singkat, dapatkan voucher 10% otomatis untuk booking berikutnya.',
                  style: TextStyle(color: textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 20),
                _modalLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: textPrimary),
                  decoration: _modalFieldDecoration('Masukkan nama kamu', Icons.person_outline),
                ),
                const SizedBox(height: 14),
                _modalLabel('Nomor WhatsApp'),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: textPrimary),
                  decoration: _modalFieldDecoration('Contoh: 08123456789', Icons.phone_outlined),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final phone = phoneCtrl.text.trim();
                      if (name.isEmpty || phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lengkapi nama dan nomor WhatsApp dulu ya!'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context);

                      _update(() {
                        BookingData.pendingVoucherPercent = 0.10;
                        BookingData.pendingVoucherLabel = 'Voucher Member 10%';
                      });

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          title: const Row(
                            children: [
                              Icon(Icons.celebration, color: gold, size: 28),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Selamat Datang!',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
                                ),
                              ),
                            ],
                          ),
                          content: Text(
                            'Halo $name! Voucher diskon 10% sudah aktif dan akan otomatis dipakai di booking servis berikutnya.',
                            style: const TextStyle(color: textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _update(() => selectedIndex = 1);
                              },
                              child: const Text(
                                'PILIH LAYANAN',
                                style: TextStyle(color: gold, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('DAFTAR & DAPATKAN VOUCHER', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showNotification() {
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: borderSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.build_outlined, color: gold),
                ),
                title: const Text(
                  'Servis kendaraan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Kendaraan kamu sedang dalam proses servis.',
                  style: TextStyle(color: textSecondary),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Keluar Akun?',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Kamu akan keluar dari akun ini.',
            style: TextStyle(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  _fadeRoute(const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text(
                'Keluar',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
