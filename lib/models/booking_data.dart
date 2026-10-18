import 'dart:async';

import 'package:flutter/foundation.dart';

import 'loyalty_data.dart';
import 'mechanic_data.dart';

class BookingData {
  final String ownerName;
  final String plateNumber;
  final String vehicleType;
  final String serviceName;
  final String price;
  final String duration;
  final DateTime createdAt;
  String status;
  String? mechanicName;

  /// ID unik booking (dipakai untuk nomor struk).
  final int id;

  /// Jadwal yang dipilih pengguna (tanggal + jam slot).
  final DateTime? scheduledAt;

  /// Harga sebelum diskon + info diskon (untuk struk).
  final String basePrice;
  final String? discountLabel;
  final double discountPercent;

  /// Ulasan setelah servis selesai (null = belum diulas).
  int? rating;
  String? review;
  DateTime? reviewedAt;

  /// Poin loyalty yang didapat dari booking ini.
  int pointsEarned;

  bool get isReviewed => rating != null;

  int? queuePosition;
  DateTime? estimatedStart;
  DateTime? estimatedFinish;

  /// Kapan status terakhir berubah (dipakai simulasi antrian live).
  DateTime statusChangedAt;

  BookingData({
    int? id,
    required this.ownerName,
    required this.plateNumber,
    required this.vehicleType,
    required this.serviceName,
    required this.price,
    required this.duration,
    DateTime? createdAt,
    this.status = 'Menunggu Antrian',
    this.mechanicName,
    this.scheduledAt,
    String? basePrice,
    this.discountLabel,
    this.discountPercent = 0,
    this.pointsEarned = 0,
    this.queuePosition,
    this.estimatedStart,
    this.estimatedFinish,
  }) : id = id ?? _nextId++,
       basePrice = basePrice ?? price,
       createdAt = createdAt ?? DateTime.now(),
       statusChangedAt = createdAt ?? DateTime.now();

  static int _nextId = 1;

  static final List<BookingData> bookings = [];

  /// Naik setiap kali data booking berubah. HomePage mendengarkan ini
  /// supaya antrian langsung ter-refresh tanpa perlu pindah tab dulu.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  /// Diisi halaman lain untuk meminta HomePage pindah tab
  /// (0 = Home, 1 = Layanan, 2 = Riwayat, 3 = Profil). HomePage me-reset ke null.
  static final ValueNotifier<int?> requestedTab = ValueNotifier<int?>(null);

  static void notifyChanged() => changes.value++;

  // ============================================================
  // PENYIMPANAN (dipakai AppStorage)
  // ============================================================

  static String? _iso(DateTime? d) => d?.toIso8601String();
  static DateTime? _parse(Object? v) =>
      v is String ? DateTime.tryParse(v) : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerName': ownerName,
        'plateNumber': plateNumber,
        'vehicleType': vehicleType,
        'serviceName': serviceName,
        'price': price,
        'duration': duration,
        'createdAt': _iso(createdAt),
        'status': status,
        'mechanicName': mechanicName,
        'scheduledAt': _iso(scheduledAt),
        'basePrice': basePrice,
        'discountLabel': discountLabel,
        'discountPercent': discountPercent,
        'rating': rating,
        'review': review,
        'reviewedAt': _iso(reviewedAt),
        'pointsEarned': pointsEarned,
        'statusChangedAt': _iso(statusChangedAt),
      };

  static BookingData fromJson(Map<String, dynamic> j) {
    final b = BookingData(
      id: j['id'] as int?,
      ownerName: j['ownerName'] as String? ?? '',
      plateNumber: j['plateNumber'] as String? ?? '',
      vehicleType: j['vehicleType'] as String? ?? '',
      serviceName: j['serviceName'] as String? ?? '',
      price: j['price'] as String? ?? '',
      duration: j['duration'] as String? ?? '',
      createdAt: _parse(j['createdAt']),
      status: j['status'] as String? ?? 'Menunggu Antrian',
      mechanicName: j['mechanicName'] as String?,
      scheduledAt: _parse(j['scheduledAt']),
      basePrice: j['basePrice'] as String?,
      discountLabel: j['discountLabel'] as String?,
      discountPercent: (j['discountPercent'] as num?)?.toDouble() ?? 0,
      pointsEarned: j['pointsEarned'] as int? ?? 0,
    );
    b.rating = j['rating'] as int?;
    b.review = j['review'] as String?;
    b.reviewedAt = _parse(j['reviewedAt']);
    b.statusChangedAt = _parse(j['statusChangedAt']) ?? b.createdAt;
    return b;
  }

  /// Ganti seluruh daftar booking dengan data tersimpan.
  static void restore(List<BookingData> saved) {
    bookings
      ..clear()
      ..addAll(saved);
    for (final b in saved) {
      if (b.id >= _nextId) _nextId = b.id + 1;
    }
    _recomputeQueue();
    notifyChanged();
  }

  // ============================================================
  // ANTRIAN LIVE (MODE DEMO)
  // Status maju otomatis: Menunggu -> Sedang Dikerjakan -> Selesai.
  // Waktu dipercepat supaya enak dipresentasikan. Set demoMode = false
  // kalau mau mematikan simulasi.
  // ============================================================
  static const bool demoMode = true;
  static const int demoWaitSeconds = 8; // jeda sebelum mulai dikerjakan
  static const int demoWorkSeconds = 45; // lama pengerjaan

  /// Naik tiap detik; dipakai kartu antrian untuk update progress & hitung mundur.
  static final ValueNotifier<int> tick = ValueNotifier<int>(0);

  /// Diisi saat sebuah servis selesai; HomePage menampilkan notifikasi lalu me-reset.
  static final ValueNotifier<BookingData?> justCompleted =
      ValueNotifier<BookingData?>(null);

  static Timer? _ticker;

  static void startTicker() {
    if (!demoMode) return;
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _advance());
  }

  static void stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// Booking yang belum selesai, urut dari yang paling lama (giliran paling depan).
  static List<BookingData> get _activeQueue {
    final list = bookings.where((b) => b.status != 'Selesai').toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  static void _advance() {
    final queue = _activeQueue;
    if (queue.isEmpty) return;

    final now = DateTime.now();
    final head = queue.first;
    final elapsed = now.difference(head.statusChangedAt).inSeconds;
    bool changed = false;
    BookingData? finished;

    if (head.status == 'Menunggu Antrian' && elapsed >= demoWaitSeconds) {
      head.status = 'Sedang Dikerjakan';
      head.statusChangedAt = now;
      changed = true;
    } else if (head.status == 'Sedang Dikerjakan' && elapsed >= demoWorkSeconds) {
      head.status = 'Selesai';
      head.statusChangedAt = now;
      finished = head;
      changed = true;
      // Antrian berikutnya mulai menghitung jeda dari sekarang.
      if (queue.length > 1) queue[1].statusChangedAt = now;
    }

    _recomputeQueue();
    if (changed) notifyChanged();
    if (finished != null) justCompleted.value = finished;
    tick.value++;
  }

  /// Hitung ulang posisi antrian + estimasi mulai/selesai untuk semua booking aktif.
  static void _recomputeQueue() {
    final queue = _activeQueue;
    DateTime? cursor;
    for (int i = 0; i < queue.length; i++) {
      final b = queue[i];
      final DateTime start;
      if (b.status == 'Sedang Dikerjakan') {
        start = b.statusChangedAt;
      } else {
        final base = i == 0 ? b.statusChangedAt : cursor!;
        start = base.add(const Duration(seconds: demoWaitSeconds));
      }
      final finish = start.add(const Duration(seconds: demoWorkSeconds));
      b.queuePosition = i + 1;
      b.estimatedStart = start;
      b.estimatedFinish = finish;
      cursor = finish;
    }
  }

  static String formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// 0.0 - 1.0, progres pengerjaan saat status "Sedang Dikerjakan".
  double get workProgress {
    if (status == 'Selesai') return 1.0;
    if (status != 'Sedang Dikerjakan') return 0.0;
    final sec = DateTime.now().difference(statusChangedAt).inSeconds;
    return (sec / demoWorkSeconds).clamp(0.0, 1.0).toDouble();
  }

  int get secondsToFinish {
    final f = estimatedFinish;
    if (f == null) return 0;
    final s = f.difference(DateTime.now()).inSeconds;
    return s < 0 ? 0 : s;
  }

  int get secondsToStart {
    final st = estimatedStart;
    if (st == null) return 0;
    final s = st.difference(DateTime.now()).inSeconds;
    return s < 0 ? 0 : s;
  }
  static double pendingVoucherPercent = 0;
  static String? pendingVoucherLabel;

  static BookingData save({
    required String owner,
    required String plate,
    required String vehicle,
    required String service,
    required String servicePrice,
    required String serviceDuration,
    String? mechanicName,
    DateTime? scheduledAt,
    String? basePrice,
    String? discountLabel,
    double discountPercent = 0,
  }) {
    final now = DateTime.now();
    final activeCount = bookings.where((b) => b.status != 'Selesai').length;
    final booking = BookingData(
      ownerName: owner,
      plateNumber: plate,
      vehicleType: vehicle,
      serviceName: service,
      price: servicePrice,
      duration: serviceDuration,
      createdAt: now,
      mechanicName: mechanicName,
      scheduledAt: scheduledAt,
      basePrice: basePrice,
      discountLabel: discountLabel,
      discountPercent: discountPercent,
      queuePosition: activeCount + 1,
      estimatedStart: now.add(Duration(minutes: 30 * activeCount)),
    );
    booking.estimatedFinish = booking.estimatedStart!.add(_durationToEstimate(serviceDuration));
    bookings.insert(0, booking);
    // Poin loyalty naik setiap kali booking dibuat.
    booking.pointsEarned = LoyaltyData.award(booking.price);
    if (demoMode) _recomputeQueue();
    notifyChanged();
    return booking;
  }

  static Duration _durationToEstimate(String value) {
    final m = RegExp(r'(\d+)').firstMatch(value);
    final n = m == null ? 60 : int.tryParse(m.group(1)!) ?? 60;
    return Duration(minutes: n);
  }

  static void clearVoucher() {
    pendingVoucherPercent = 0;
    pendingVoucherLabel = null;
  }

  String get formattedEstimatedStart =>
      estimatedStart == null ? '-' : _formatTime(estimatedStart!);

  String get formattedEstimatedFinish =>
      estimatedFinish == null ? '-' : _formatTime(estimatedFinish!);

  static String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  // ============================================================
  // JADWAL & SLOT JAM
  // ============================================================

  static const List<String> slotTimes = [
    '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00',
  ];

  /// Gabungkan tanggal + slot "HH:mm" jadi DateTime.
  static DateTime slotDateTime(DateTime date, String slot) {
    final parts = slot.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Slot sudah lewat (hari ini, jam sudah berlalu / kurang dari 30 menit lagi).
  static bool isSlotPast(DateTime date, String slot) {
    final limit = DateTime.now().add(const Duration(minutes: 30));
    return slotDateTime(date, slot).isBefore(limit);
  }

  /// Slot penuh? Penuh kalau lewat, sudah diisi booking lain untuk montir itu,
  /// atau (simulasi bengkel ramai) jatah montir itu di jam tsb sudah terisi
  /// pelanggan lain. Slot "ramai" ditentukan deterministik dari tanggal+jam+montir
  /// supaya selalu konsisten, bukan acak tiap dibuka.
  static bool isSlotTaken(DateTime date, String slot, String? mechanic) {
    if (isSlotPast(date, slot)) return true;

    final target = slotDateTime(date, slot);
    final mechanics = MechanicData.mechanics.map((m) => m.name).toList();

    bool bookedBy(String name) => bookings.any(
          (b) =>
              b.scheduledAt != null &&
              b.mechanicName == name &&
              b.scheduledAt!.isAtSameMomentAs(target),
        );

    bool busySeed(String name) {
      final idx = mechanics.indexOf(name);
      final hour = target.hour;
      final seed = date.day * 31 + date.month * 17 + hour * 13 + idx * 7;
      return seed % 5 == 0;
    }

    if (mechanic != null) return bookedBy(mechanic) || busySeed(mechanic);
    // Belum pilih montir: penuh kalau semua montir tidak tersedia.
    return mechanics.every((m) => bookedBy(m) || busySeed(m));
  }

  /// Slot mulai [start] dan [count]-1 slot sesudahnya (berurutan) semuanya kosong?
  static bool isRangeFree(
    DateTime date,
    String start,
    int count,
    String? mechanic,
  ) {
    final i = slotTimes.indexOf(start);
    if (i < 0 || i + count > slotTimes.length) return false;
    for (int k = 0; k < count; k++) {
      if (isSlotTaken(date, slotTimes[i + k], mechanic)) return false;
    }
    return true;
  }

  static String formatDate(DateTime d) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String get formattedSchedule {
    final s = scheduledAt;
    if (s == null) return '-';
    return '${formatDate(s)} • ${_formatTime(s)}';
  }

  // ============================================================
  // HARGA (untuk struk)
  // ============================================================

  static int parseRupiah(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? 0 : int.parse(digits);
  }

  static String formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp$buffer';
  }

  /// Nilai diskon dalam rupiah (0 kalau harga tidak bisa dihitung).
  int get discountAmount {
    if (discountPercent <= 0) return 0;
    final base = parseRupiah(basePrice);
    if (discountPercent >= 1.0) return base;
    return (base * discountPercent).round();
  }
}
