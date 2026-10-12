part of '../home_page.dart';

/// Bagian UI: service tab (memisah home_page.dart supaya tidak terlalu panjang).
extension _ServiceTab on _HomePageState {
  Widget servicePage() {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        title: const Text('Layanan Bengkel', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
            children: [
              _searchBar(),
              const SizedBox(height: 10),
              const Text('Harga final menyesuaikan jenis kendaraan saat konfirmasi', style: TextStyle(color: textSecondary, fontSize: 11)),
              const SizedBox(height: 12),
              if (filteredServices.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderSubtle)),
                  child: const Column(
                    children: [
                      Icon(Icons.search_off, color: textSecondary, size: 30),
                      SizedBox(height: 10),
                      Text('Layanan tidak ditemukan', style: TextStyle(color: textSecondary)),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    for (int i = 0; i < filteredServices.length; i++) ...[
                      _selectableServiceCard(
                        icon: filteredServices[i]['icon'] as IconData,
                        title: filteredServices[i]['title'] as String,
                        description: filteredServices[i]['description'] as String,
                        price: filteredServices[i]['price'] as String,
                        onOpenDetail: () => openDetail(
                          filteredServices[i]['title'] as String,
                          filteredServices[i]['description'] as String,
                          filteredServices[i]['price'] as String,
                          filteredServices[i]['duration'] as String,
                          filteredServices[i]['icon'] as IconData,
                        ),
                      ),
                      if (i != filteredServices.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
            ],
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _cartSummaryBar()),
        ],
      ),
    );
  }

  Widget _selectableServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required String price,
    required VoidCallback onOpenDetail,
  }) {
    final bool selected = cartTitles.contains(title);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? gold.withValues(alpha: 0.08) : surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? gold.withValues(alpha: 0.5) : borderSubtle),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _update(() {
                if (selected) {
                  cartTitles.remove(title);
                } else {
                  cartTitles.add(title);
                }
              });
            },
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? gold : Colors.transparent,
                border: Border.all(color: selected ? gold : textSecondary, width: 1.5),
              ),
              child: selected ? const Icon(Icons.check, size: 15, color: background) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TapScale(
              onTap: onOpenDetail,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(color: gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 3),
                        Text(price, style: const TextStyle(color: goldSoft, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: gold, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartSummaryBar() {
    final total = services.where((s) => cartTitles.contains(s['title'])).fold<int>(0, (sum, s) => sum + _parsePrice(s['price'] as String));
    final bool voucherActive = BookingData.pendingVoucherPercent > 0;
    final int discountedTotal = voucherActive ? (total * (1 - BookingData.pendingVoucherPercent)).round() : total;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      offset: cartTitles.isEmpty ? const Offset(0, 1.3) : Offset.zero,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: surfaceAlt,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: gold.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, -6))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucherActive
                        ? '${cartTitles.length} layanan • ${BookingData.pendingVoucherLabel} aktif 🎉'
                        : '${cartTitles.length} layanan dipilih (estimasi)',
                    style: const TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  if (voucherActive) ...[
                    Row(
                      children: [
                        Text(
                          _formatRupiah(total),
                          style: const TextStyle(color: textSecondary, fontSize: 12, decoration: TextDecoration.lineThrough),
                        ),
                        const SizedBox(width: 6),
                        Text(_formatRupiah(discountedTotal), style: const TextStyle(color: goldSoft, fontWeight: FontWeight.bold, fontSize: 17)),
                      ],
                    ),
                  ] else
                    Text(_formatRupiah(total), style: const TextStyle(color: goldSoft, fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _openCartCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: background,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Booking Semua', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openCartCheckout() {
    final ownerController = TextEditingController();
    final plateController = TextEditingController();
    String? checkoutVehicleType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(color: borderSubtle, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const Text('Konfirmasi Booking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
                    const SizedBox(height: 6),
                    Text('${cartTitles.length} layanan dipilih — nggak perlu pilih servis lagi', style: const TextStyle(color: textSecondary, fontSize: 12)),
                    const SizedBox(height: 18),
                    _modalLabel('Nama Pemilik'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: ownerController,
                      style: const TextStyle(color: textPrimary),
                      decoration: _modalFieldDecoration('Masukkan nama pemilik', Icons.person_outline),
                    ),
                    const SizedBox(height: 14),
                    _modalLabel('Nomor Polisi'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: plateController,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(color: textPrimary),
                      decoration: _modalFieldDecoration('Contoh: L 1234 AB', Icons.confirmation_number_outlined),
                    ),
                    const SizedBox(height: 14),
                    _modalLabel('Jenis Kendaraan'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: checkoutVehicleType,
                      dropdownColor: surfaceAlt,
                      style: const TextStyle(color: textPrimary),
                      decoration: _modalFieldDecoration('Pilih jenis kendaraan', Icons.directions_car_outlined),
                      items: vehicleList.map((v) => DropdownMenuItem(value: v.name, child: Text('${v.icon} ${v.name}'))).toList(),
                      onChanged: (value) => setModalState(() => checkoutVehicleType = value),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: surfaceAlt, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: cartTitles
                            .map((t) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: gold, size: 14),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(t, style: const TextStyle(color: textSecondary, fontSize: 13))),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          final owner = ownerController.text.trim();
                          final plate = plateController.text.trim().toUpperCase();
                          if (owner.isEmpty || plate.isEmpty || checkoutVehicleType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lengkapi semua data terlebih dahulu!'), backgroundColor: Colors.redAccent),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          _submitCartBooking(owner, plate, checkoutVehicleType!);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: const Text('KONFIRMASI BOOKING', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _submitCartBooking(String owner, String plate, String vehicleType) {
    final vehicle = vehicleList.firstWhere(
      (v) => v.name == vehicleType,
      orElse: () => vehicleList.first,
    );

    final bool voucherActive = BookingData.pendingVoucherPercent > 0;
    final String voucherLabel = BookingData.pendingVoucherLabel ?? 'Voucher';

    for (final title in cartTitles) {
      ServiceData? match;
      for (final s in vehicle.services) {
        if (s.name.toLowerCase() == title.toLowerCase()) {
          match = s;
          break;
        }
      }
      match ??= () {
        for (final s in vehicle.services) {
          if (s.name.toLowerCase().contains(title.toLowerCase().split(' ').first)) {
            return s;
          }
        }
        return null;
      }();

      final fallback = services.firstWhere(
        (s) => s['title'] == title,
        orElse: () => {'price': 'Harga menyesuaikan', 'duration': 'Menyesuaikan'},
      );

      String finalPrice = match?.price ?? fallback['price'] as String;
      final finalDuration = match?.duration ?? fallback['duration'] as String;

      if (voucherActive) {
        final discounted = (_parsePrice(finalPrice) * (1 - BookingData.pendingVoucherPercent)).round();
        finalPrice = _formatRupiah(discounted);
      }

      final newBooking = BookingData.save(
        owner: owner,
        plate: plate,
        vehicle: vehicleType,
        service: title,
        servicePrice: finalPrice,
        serviceDuration: finalDuration,
      );

      MechanicData.assignBooking(newBooking);
    }

    if (voucherActive) {
      BookingData.clearVoucher();
    }

    _update(() {
      cartTitles.clear();
      activePlate = plate;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: gold, size: 30),
              SizedBox(width: 10),
              Expanded(child: Text('Booking Berhasil', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$owner ($plate) berhasil booking. Cek statusnya di tab Riwayat.',
                style: const TextStyle(color: textSecondary),
              ),
              if (voucherActive) ...[
                const SizedBox(height: 8),
                Text(
                  '🎉 $voucherLabel diterapkan ke semua layanan!',
                  style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _update(() => selectedIndex = 2);
              },
              child: const Text('LIHAT RIWAYAT', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _modalLabel(String text) {
    return Text(text, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13));
  }

  InputDecoration _modalFieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textSecondary),
      prefixIcon: Icon(icon, color: gold),
      filled: true,
      fillColor: surfaceAlt,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: gold, width: 1.5)),
    );
  }
}
