part of '../home_page.dart';

/// Bagian UI: history tab (memisah home_page.dart supaya tidak terlalu panjang).
extension _HistoryTab on _HomePageState {
  Widget historyPage() {
    MechanicData.refresh();

    final allBookings = BookingData.bookings;
    final garage = garageVehicles;

    final displayedBookings = historyPlateFilter == 'Semua'
        ? allBookings
        : allBookings
            .where((b) => b.plateNumber == historyPlateFilter)
            .toList();

    final sortedBookings = List<BookingData>.from(displayedBookings)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        title: const Text(
          'Riwayat Servis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          if (garage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: garage.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final String key =
                        index == 0 ? 'Semua' : garage[index - 1]['plate']!;
                    final String label = index == 0
                        ? 'Semua'
                        : '${garage[index - 1]['type']} • ${garage[index - 1]['plate']}';
                    final active = key == historyPlateFilter;

                    return TapScale(
                      onTap: () {
                        _update(() {
                          historyPlateFilter = key;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: active ? gold.withValues(alpha: 0.15) : surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color:
                                active ? gold.withValues(alpha: 0.5) : borderSubtle,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: active ? goldSoft : textSecondary,
                            fontWeight:
                                active ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          Expanded(
            child: allBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: gold.withValues(alpha: 0.25)),
                          ),
                          child: const Icon(
                            Icons.history,
                            size: 46,
                            color: gold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Belum Ada Riwayat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Riwayat booking kamu akan muncul di sini.',
                          style: TextStyle(color: textSecondary),
                        ),
                      ],
                    ),
                  )
                : sortedBookings.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada riwayat untuk kendaraan ini',
                          style: TextStyle(color: textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sortedBookings.length,
                        itemBuilder: (context, index) {
                          final booking = sortedBookings[index];

                          return TapScale(
                            onTap: () => showBookingDetail(booking),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderSubtle),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: gold.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.build_outlined,
                                    color: gold,
                                  ),
                                ),
                                title: Text(
                                  booking.serviceName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${booking.vehicleType} • ${booking.plateNumber}',
                                  style:
                                      const TextStyle(color: textSecondary),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(booking.status)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    booking.status,
                                    style: TextStyle(
                                      color: _statusColor(booking.status),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void showBookingDetail(BookingData booking) {
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nota Servis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _notaRow('Pemilik', booking.ownerName),
                    _notaRow('No. Polisi', booking.plateNumber),
                    _notaRow('Kendaraan', booking.vehicleType),
                    _notaRow('Layanan', booking.serviceName),
                    _notaRow('Harga', booking.price),
                    _notaRow('Estimasi Durasi', booking.duration),
                    _notaRow(
                      'Status',
                      booking.status,
                      valueColor: _statusColor(booking.status),
                    ),
                    if (booking.mechanicName != null)
                      _notaRow('Montir', booking.mechanicName!),
                    if (booking.status == 'Menunggu Antrian' &&
                        booking.queuePosition != null)
                      _notaRow(
                        'Posisi Antrian',
                        '#${booking.queuePosition}',
                      ),
                    if (booking.estimatedStart != null)
                      _notaRow(
                        'Estimasi Mulai',
                        booking.formattedEstimatedStart,
                      ),
                    if (booking.estimatedFinish != null)
                      _notaRow(
                        'Estimasi Selesai',
                        booking.formattedEstimatedFinish,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _notaRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
