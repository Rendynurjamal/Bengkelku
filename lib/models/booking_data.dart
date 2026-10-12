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
  }) : createdAt = createdAt ?? DateTime.now();

  static final List<BookingData> bookings = [];
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
