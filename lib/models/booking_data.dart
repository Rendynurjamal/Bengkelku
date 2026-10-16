import 'dart:async';

import 'package:flutter/foundation.dart';

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
  int? queuePosition;
  DateTime? estimatedStart;
  DateTime? estimatedFinish;

  /// Kapan status terakhir berubah (dipakai simulasi antrian live).
  DateTime statusChangedAt;

  BookingData({
    required this.ownerName,
    required this.plateNumber,
    required this.vehicleType,
    required this.serviceName,
    required this.price,
    required this.duration,
    DateTime? createdAt,
    this.status = 'Menunggu Antrian',
    this.mechanicName,
    this.queuePosition,
    this.estimatedStart,
    this.estimatedFinish,
  }) : createdAt = createdAt ?? DateTime.now(),
       statusChangedAt = createdAt ?? DateTime.now();

  static final List<BookingData> bookings = [];

  /// Naik setiap kali data booking berubah. HomePage mendengarkan ini
  /// supaya antrian langsung ter-refresh tanpa perlu pindah tab dulu.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  /// Diisi halaman lain untuk meminta HomePage pindah tab
  /// (0 = Home, 1 = Layanan, 2 = Riwayat, 3 = Profil). HomePage me-reset ke null.
  static final ValueNotifier<int?> requestedTab = ValueNotifier<int?>(null);

  static void notifyChanged() => changes.value++;

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
      queuePosition: activeCount + 1,
      estimatedStart: now.add(Duration(minutes: 30 * activeCount)),
    );
    booking.estimatedFinish = booking.estimatedStart!.add(_durationToEstimate(serviceDuration));
    bookings.insert(0, booking);
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
}
