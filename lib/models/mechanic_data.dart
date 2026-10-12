import 'booking_data.dart';

class MechanicData {
  static const List<String> mechanics = [
    'Andi',
    'Budi',
    'Rizky',
    'Dimas',
  ];

  static void refresh() {
    for (int i = 0; i < BookingData.bookings.length; i++) {
      final b = BookingData.bookings[i];
      b.mechanicName ??= mechanics[i % mechanics.length];
    }
  }

  static void assignBooking(BookingData booking) {
    final active = BookingData.bookings.where((b) => b.status != 'Selesai').toList();
    booking.mechanicName ??= mechanics[(active.length - 1).clamp(0, mechanics.length - 1).toInt()];
    refresh();
  }
}
