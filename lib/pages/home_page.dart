import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';
import 'service_page.dart';
import 'detail_service_page.dart';
import '../models/booking_data.dart';
import '../models/mechanic_data.dart';
import '../models/vehicle_data.dart';
import '../theme/app_colors.dart';
import '../widgets/tap_scale.dart';
import 'about_bengkel_page.dart';

part 'home_page_parts/home_tab.dart';
part 'home_page_parts/service_tab.dart';
part 'home_page_parts/history_tab.dart';
part 'home_page_parts/profile_tab.dart';
part 'home_page_parts/navigation.dart';
part 'home_page_parts/dialogs.dart';

// Alias warna supaya kode UI tetap ringkas (dipakai juga oleh file di home_page_parts/).
const Color background = AppColors.background;
const Color surface = AppColors.surface;
const Color surfaceAlt = AppColors.surfaceAlt;
const Color gold = AppColors.gold;
const Color goldSoft = AppColors.goldSoft;
const Color textPrimary = AppColors.textPrimary;
const Color textSecondary = AppColors.textSecondary;
const Color borderSubtle = AppColors.borderSubtle;

// ============================================================
// ROUTE TRANSISI HALUS (fade + slide)
// ============================================================

Route _fadeRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _HelpItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF14263A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x263D5570))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFFFFC21A)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Color(0xFFF3F4F6), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Color(0xFF9AA1AE), height: 1.35)),
        ])),
      ]),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Dipakai oleh file di home_page_parts/ (extension tidak boleh memanggil setState langsung).
  void _update(VoidCallback fn) => setState(fn);

  int selectedIndex = 0;

  // Preferensi Pengaturan aktif selama aplikasi berjalan.
  bool notificationsEnabled = true;
  bool serviceReminderEnabled = true;
  bool compactServiceCards = false;

  final bool hasNotification = true;

  // Rating montir (statis dulu, belum ada sistem review sungguhan)
  final double mechanicRating = 4.8;
  final int mechanicReviewCount = 128;

  // Kendaraan yang sedang dipilih di "garasi" (kunci: plat nomor)
  String? activePlate;

  // Filter riwayat per kendaraan (kunci: plat nomor, 'Semua' = semua)
  String historyPlateFilter = 'Semua';

  // Promo carousel
  int bannerIndex = 0;
  final PageController _bannerController = PageController();

  final List<Map<String, dynamic>> promos = [
    {
      'title': 'Diskon 20% Ganti Oli',
      'subtitle': 'Berlaku untuk semua jenis kendaraan bulan ini',
      'icon': Icons.local_offer_outlined,
      'serviceTitle': 'Ganti Oli',
      'discountPercent': 0.20,
    },
    {
      'title': 'Cek Rem Gratis',
      'subtitle': 'Booking servis mesin, cek sistem rem tanpa biaya tambahan',
      'icon': Icons.verified_outlined,
      'serviceTitle': 'Servis Rem',
      'discountPercent': 1.0,
    },
    {
      'title': 'Member Baru',
      'subtitle': 'Daftar sekarang dan dapatkan voucher servis pertama',
      'icon': Icons.card_giftcard_outlined,
      'serviceTitle': null,
      'discountPercent': 0.0,
    },
  ];

  void _openPromo(Map<String, dynamic> promo) {
    final serviceTitle = promo['serviceTitle'] as String?;
    final discountPercent = promo['discountPercent'] as double? ?? 0.0;
    final promoLabel = promo['title'] as String;

    if (serviceTitle == null) {
      _openMemberRegistration();
      return;
    }

    final service = services.firstWhere(
      (s) => s['title'] == serviceTitle,
      orElse: () => services.first,
    );

    Navigator.push(
      context,
      _fadeRoute(
        DetailServicePage(
          serviceName: service['title'] as String,
          description: service['description'] as String,
          price: service['price'] as String,
          duration: service['duration'] as String,
          icon: service['icon'] as IconData,
          discountPercent: discountPercent,
          promoLabel: promoLabel,
        ),
      ),
    );
  }

  // Search
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Keranjang servis (multi-select di tab Layanan)
  final Set<String> cartTitles = {};

  // Data layanan generik (dipakai untuk tampilan & pencarian di tab Layanan;
  // harga akhir tetap dihitung ulang sesuai jenis kendaraan saat booking,
  // lewat vehicle_data.dart)
  final List<Map<String, dynamic>> services = [
    {
      'icon': Icons.oil_barrel_outlined,
      'title': 'Ganti Oli',
      'description':
          'Penggantian oli kendaraan dengan oli berkualitas dan pemeriksaan kondisi mesin.',
      'price': 'Mulai Rp50.000',
      'duration': '30 - 45 menit',
    },
    {
      'icon': Icons.settings_outlined,
      'title': 'Servis Mesin',
      'description':
          'Pemeriksaan dan perbaikan komponen mesin kendaraan secara menyeluruh.',
      'price': 'Mulai Rp100.000',
      'duration': '1 - 2 jam',
    },
    {
      'icon': Icons.car_repair_outlined,
      'title': 'Servis Rem',
      'description':
          'Pemeriksaan kampas rem, minyak rem, dan sistem pengereman kendaraan.',
      'price': 'Mulai Rp75.000',
      'duration': '45 - 60 menit',
    },
    {
      'icon': Icons.bolt_outlined,
      'title': 'Kelistrikan',
      'description':
          'Pemeriksaan aki, lampu, kabel, dan sistem kelistrikan kendaraan.',
      'price': 'Mulai Rp80.000',
      'duration': '45 - 90 menit',
    },
    {
      'icon': Icons.ac_unit_outlined,
      'title': 'Servis AC',
      'description':
          'Pemeriksaan dan perawatan sistem pendingin (AC) kendaraan agar tetap dingin optimal.',
      'price': 'Mulai Rp150.000',
      'duration': '1 - 2 jam',
    },
    {
      'icon': Icons.settings_applications_outlined,
      'title': 'Servis Transmisi',
      'description':
          'Pemeriksaan dan perawatan sistem transmisi kendaraan untuk perpindahan gigi yang halus.',
      'price': 'Mulai Rp300.000',
      'duration': '2 - 4 jam',
    },
  ];

  List<Map<String, dynamic>> get filteredServices {
    if (searchQuery.trim().isEmpty) return services;
    final q = searchQuery.toLowerCase();
    return services
        .where((s) => (s['title'] as String).toLowerCase().contains(q))
        .toList();
  }

  // ============================================================
  // DATA TURUNAN DARI BookingData (bukan lagi data karangan)
  // ============================================================

  /// Daftar kendaraan unik (plat + jenis) yang pernah dibooking user.
  List<Map<String, String>> get garageVehicles {
    final Map<String, Map<String, String>> unique = {};
    for (final b in BookingData.bookings) {
      unique[b.plateNumber] = {
        'plate': b.plateNumber,
        'type': b.vehicleType,
      };
    }
    return unique.values.toList();
  }

  Map<String, String>? get activeVehicle {
    if (garageVehicles.isEmpty) return null;
    return garageVehicles.firstWhere(
      (v) => v['plate'] == activePlate,
      orElse: () => garageVehicles.first,
    );
  }

  /// Booking yang masih berjalan (belum "Selesai"), paling baru duluan.
  BookingData? get activeBooking {
    final active =
        BookingData.bookings.where((b) => b.status != 'Selesai').toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active.first;
  }

  /// Booking yang sudah selesai paling baru (untuk hitung reminder servis).
  BookingData? get latestCompletedBooking {
    final completed =
        BookingData.bookings.where((b) => b.status == 'Selesai').toList();
    if (completed.isEmpty) return null;
    completed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return completed.first;
  }

  int? get daysUntilNextService {
    final last = latestCompletedBooking;
    if (last == null) return null;
    final nextDue = last.createdAt.add(const Duration(days: 90));
    return nextDue.difference(DateTime.now()).inDays;
  }

  int _parsePrice(String price) {
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? 0 : int.parse(digits);
  }

  String _formatRupiah(int value) {
    final str = value.toString();
    final reversed = str.split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < reversed.length; i++) {
      buffer.write(reversed[i]);
      if ((i + 1) % 3 == 0 && i != reversed.length - 1) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join()}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Selesai':
        return AppColors.success;
      case 'Sedang Dikerjakan':
        return gold;
      default:
        return textSecondary; // Menunggu Antrian
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  // ============================================================
  // WHATSAPP ADMIN
  // ============================================================

  Future<void> openWhatsApp() async {
    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/6283840576034?text=Halo%20Admin%20BengkelKu%2C%20saya%20ingin%20bertanya%20tentang%20layanan%20bengkel.',
    );

    try {
      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
      );
    }
  }

  // ============================================================
  // GOOGLE MAPS
  // ============================================================

  Future<void> openMaps() async {
    final Uri mapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=FF9V%2BG3G%2C+Becok%2C+Kartoharjo%2C+Kabupaten+Magetan%2C+Jawa+Timur+63395',
    );

    try {
      await launchUrl(
        mapsUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
      );
    }
  }

  // ============================================================
  // BOOKING (SATU LAYANAN — DARI DETAIL)
  // ============================================================

  void openBooking() {
    Navigator.push(
      context,
      _fadeRoute(const ServicePage()),
    );
  }

  void openDetail(
    String serviceName,
    String description,
    String price,
    String duration,
    IconData icon,
  ) {
    Navigator.push(
      context,
      _fadeRoute(
        DetailServicePage(
          serviceName: serviceName,
          description: description,
          price: price,
          duration: duration,
          icon: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [homePage(), servicePage(), historyPage(), profilePage()];

    return Scaffold(
      backgroundColor: background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(key: ValueKey<int>(selectedIndex), child: pages[selectedIndex]),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }
}
