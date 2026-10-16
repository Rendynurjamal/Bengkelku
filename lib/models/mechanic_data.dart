import 'booking_data.dart';

class Mechanic {
  final String name;
  final String specialty;
  final String experience;

  /// Foto montir. Taruh file di assets/images/ dengan nama ini; kalau file
  /// belum ada, aplikasi otomatis menampilkan avatar inisial.
  final String photoAsset;

  const Mechanic({
    required this.name,
    required this.specialty,
    required this.experience,
    required this.photoAsset,
  });

  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}

/// Ringkasan rating montir yang dihitung dari ulasan asli.
class MechanicRating {
  final double average;
  final int count;
  const MechanicRating(this.average, this.count);

  bool get hasReviews => count > 0;

  String get label => hasReviews
      ? '${average.toStringAsFixed(1)} ($count ulasan)'
      : 'Belum ada ulasan';
}

class MechanicData {
  static const List<Mechanic> mechanics = [
    Mechanic(
      name: 'Andi',
      specialty: 'Mesin & Transmisi',
      experience: '8 tahun',
      photoAsset: 'assets/images/montir_andi.jpg',
    ),
    Mechanic(
      name: 'Budi',
      specialty: 'Rem & Kelistrikan',
      experience: '6 tahun',
      photoAsset: 'assets/images/montir_budi.jpg',
    ),
    Mechanic(
      name: 'Rizky',
      specialty: 'Ganti Oli & Servis Rutin',
      experience: '4 tahun',
      photoAsset: 'assets/images/montir_rizky.jpg',
    ),
    Mechanic(
      name: 'Dimas',
      specialty: 'AC & Kelistrikan',
      experience: '5 tahun',
      photoAsset: 'assets/images/montir_dimas.jpg',
    ),
  ];

  static Mechanic? byName(String? name) {
    if (name == null) return null;
    for (final m in mechanics) {
      if (m.name == name) return m;
    }
    return null;
  }

  /// Rating rata-rata montir [name] dari semua ulasan yang pernah masuk.
  static MechanicRating ratingFor(String? name) {
    int total = 0;
    int count = 0;
    for (final b in BookingData.bookings) {
      if (b.mechanicName == name && b.rating != null) {
        total += b.rating!;
        count++;
      }
    }
    return MechanicRating(count == 0 ? 0 : total / count, count);
  }

  /// Booking lama tanpa montir (mis. dibuat sebelum ada pilihan montir)
  /// dibagi rata supaya tetap punya montir.
  static void refresh() {
    for (int i = 0; i < BookingData.bookings.length; i++) {
      final b = BookingData.bookings[i];
      b.mechanicName ??= mechanics[i % mechanics.length].name;
    }
  }

  static void assignBooking(BookingData booking) {
    final active = BookingData.bookings.where((b) => b.status != 'Selesai').toList();
    booking.mechanicName ??= mechanics[(active.length - 1).clamp(0, mechanics.length - 1).toInt()].name;
    refresh();
  }
}
