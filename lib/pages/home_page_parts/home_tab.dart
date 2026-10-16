part of '../home_page.dart';

/// Bagian UI: home tab (memisah home_page.dart supaya tidak terlalu panjang).
extension _HomeTab on _HomePageState {
  Widget homePage() {
    MechanicData.refresh();
    final reminder = _reminderSection();

    return Scaffold(
      backgroundColor: background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openWhatsApp,
        backgroundColor: gold,
        foregroundColor: background,
        icon: const Icon(Icons.chat),
        label: const Text('Chat Admin', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: gold,
          backgroundColor: surface,
          onRefresh: () async {
            MechanicData.refresh();
            _update(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(text: 'Bengkel', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary)),
                              TextSpan(text: 'Ku', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: gold)),
                            ]),
                          ),
                          const SizedBox(height: 4),
                          Text('Solusi servis kendaraan kamu', style: TextStyle(color: textSecondary)),
                        ],
                      ),
                    ),
                    TapScale(
                      onTap: showNotification,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: surface, shape: BoxShape.circle, border: Border.all(color: borderSubtle)),
                            padding: const EdgeInsets.all(10),
                            child: const Icon(Icons.notifications_none, color: gold, size: 22),
                          ),
                          if (hasNotification)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: surface, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    height: 155,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1600&q=90',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: surfaceAlt,
                            child: const Icon(Icons.directions_car_filled, color: gold, size: 56),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                background.withValues(alpha: 0.88),
                                background.withValues(alpha: 0.45),
                                background.withValues(alpha: 0.08),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 230,
                              child: Text(
                                'Servis lebih mudah, kendaraan lebih siap.',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _searchBar(),
                const SizedBox(height: 20),
                _promoCarousel(),
                const SizedBox(height: 22),

                _towCard(),
                const SizedBox(height: 22),
                _sectionTitle('Menu Utama'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _menuCard(icon: Icons.calendar_month_outlined, title: 'Booking', onTap: openBooking)),
                    const SizedBox(width: 12),
                    Expanded(child: _menuCard(icon: Icons.build_outlined, title: 'Layanan', onTap: () => _update(() => selectedIndex = 1))),
                    const SizedBox(width: 12),
                    Expanded(child: _menuCard(icon: Icons.history, title: 'Riwayat', onTap: () => _update(() => selectedIndex = 2))),
                    const SizedBox(width: 12),
                    Expanded(child: _menuCard(icon: Icons.person_outline, title: 'Profil', onTap: () => _update(() => selectedIndex = 3))),
                  ],
                ),

                const SizedBox(height: 26),
                _sectionTitle('Layanan Populer'),
                const SizedBox(height: 14),
                if (filteredServices.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderSubtle)),
                    child: Column(
                      children: [
                        Icon(Icons.search_off, color: textSecondary, size: 30),
                        SizedBox(height: 10),
                        Text('Layanan tidak ditemukan', style: TextStyle(color: textSecondary)),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 258,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 4, right: 4),
                      itemCount: filteredServices.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, i) {
                        final service = filteredServices[i];
                        final title = service['title'] as String;
                        final description = service['description'] as String;
                        final price = service['price'] as String;
                        final icon = service['icon'] as IconData;
                        return _popularServiceCard(
                          icon: icon,
                          title: title,
                          description: description,
                          price: price,
                          onTap: () => openDetail(
                            title,
                            description,
                            price,
                            service['duration'] as String,
                            icon,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 26),
                _sectionTitle('Lokasi & Rating'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _ratingBadgeCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _contactCard(icon: Icons.location_on_outlined, title: 'Map', value: 'Lokasi Bengkel', onTap: openMaps)),
                  ],
                ),

                const SizedBox(height: 26),
                _sectionTitle('Kendaraan Aktif'),
                const SizedBox(height: 12),
                _garageSection(),

                if (reminder != null) ...[
                  const SizedBox(height: 22),
                  reminder,
                ],

                const SizedBox(height: 22),
                _sectionTitle('Status Servis'),
                const SizedBox(height: 12),
                _activeServiceSection(),

                const SizedBox(height: 26),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [surfaceAlt, surface]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: gold.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: gold),
                          SizedBox(width: 10),
                          Text('Informasi Bengkel', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'BengkelKu siap membantu kebutuhan servis kendaraan kamu dengan pelayanan yang nyaman dan terpercaya.',
                        style: TextStyle(color: textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _reminderSection() {
    final days = daysUntilNextService;
    if (days == null) return null;

    final bool overdue = days < 0;
    final bool urgent = days <= 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Servis Berikutnya'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: urgent ? gold.withValues(alpha: 0.5) : borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.event_repeat_outlined, color: gold, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Servis Berikutnya', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      overdue
                          ? 'Sudah lewat ${days.abs()} hari dari jadwal — yuk servis lagi'
                          : 'Sekitar $days hari lagi (± 3 bulan dari servis terakhir)',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (urgent || overdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: gold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    overdue ? 'Terlambat' : 'Segera',
                    style: const TextStyle(color: goldSoft, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _activeServiceSection() {
    final booking = activeBooking;

    if (booking == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderSubtle),
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, color: gold, size: 32),
            const SizedBox(height: 10),
            Text(
              'Tidak ada servis yang sedang berjalan',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Booking layanan untuk mulai proses servis.',
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(color: gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.build_circle_outlined, color: gold, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.status, style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text('${booking.serviceName} • ${booking.vehicleType} (${booking.plateNumber})', style: TextStyle(color: textSecondary)),
                        const SizedBox(height: 4),
                        Text('${booking.duration} • ${booking.price}', style: const TextStyle(color: goldSoft, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _serviceTimeline(booking.status),
              const SizedBox(height: 16),
              ValueListenableBuilder<int>(
                valueListenable: BookingData.tick,
                builder: (context, tickValue, child) => _queueLiveInfo(booking),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _sectionTitle('Montir Bertugas'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: gold.withValues(alpha: 0.4))),
                child: MechanicAvatar(mechanic: MechanicData.byName(booking.mechanicName), radius: 25),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.mechanicName ?? 'Menunggu penugasan', style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(MechanicData.byName(booking.mechanicName)?.specialty ?? 'Teknisi BengkelKu', style: TextStyle(color: textSecondary)),
                    const SizedBox(height: 6),
                    Builder(builder: (context) {
                      final rating = MechanicData.ratingFor(booking.mechanicName);
                      return Row(
                        children: [
                          StarRow(rating: rating.average),
                          const SizedBox(width: 6),
                          Text(rating.label, style: TextStyle(color: textSecondary, fontSize: 11)),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const Icon(Icons.verified_outlined, color: gold),
            ],
          ),
        ),
      ],
    );
  }

  /// Tombol darurat: mogok / butuh derek -> WhatsApp dengan plat nomor terisi.
  Widget _towCard() {
    return TapScale(
      onTap: openTowRequest,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.car_crash_outlined, color: AppColors.danger),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mogok / Butuh Derek', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Kirim lokasi darurat ke admin via WhatsApp', style: TextStyle(color: textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.danger),
          ],
        ),
      ),
    );
  }

  /// Info antrian live: progress bar + hitung mundur (update tiap detik).
  Widget _queueLiveInfo(BookingData booking) {
    if (booking.status == 'Sedang Dikerjakan') {
      final progress = booking.workProgress;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sedang dikerjakan ${booking.mechanicName ?? 'montir'}',
                style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: surfaceAlt,
              valueColor: const AlwaysStoppedAnimation<Color>(gold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sisa waktu ${BookingData.formatCountdown(booking.secondsToFinish)} • selesai ±${booking.formattedEstimatedFinish}',
            style: TextStyle(color: textSecondary, fontSize: 11),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_outlined, color: gold, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Antrean ke-${booking.queuePosition ?? '-'}',
                  style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Giliran dimulai dalam ${BookingData.formatCountdown(booking.secondsToStart)} • ±${booking.formattedEstimatedStart}',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceTimeline(String status) {
    const stages = ['Menunggu', 'Dikerjakan', 'Selesai'];
    final int currentStage = status == 'Selesai'
        ? 2
        : status == 'Sedang Dikerjakan'
            ? 1
            : 0;

    return Row(
      children: List.generate(stages.length, (index) {
        final bool done = index < currentStage;
        final bool active = index == currentStage;
        final bool isLast = index == stages.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: index == 0
                        ? const SizedBox()
                        : Container(height: 2, color: (done || active) ? gold.withValues(alpha: 0.6) : borderSubtle),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? gold : surface,
                      border: Border.all(color: (done || active) ? gold : borderSubtle, width: 2),
                    ),
                    child: done
                        ? Icon(Icons.check, size: 13, color: background)
                        : active
                            ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: gold, shape: BoxShape.circle))
                            : null,
                  ),
                  Expanded(
                    child: isLast
                        ? const SizedBox()
                        : Container(height: 2, color: done ? gold.withValues(alpha: 0.6) : borderSubtle),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                stages[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: active ? goldSoft : (done ? textPrimary : textSecondary),
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _garageSection() {
    final garage = garageVehicles;

    if (garage.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderSubtle),
        ),
        child: Column(
          children: [
            const Icon(Icons.directions_car_outlined, color: gold, size: 34),
            const SizedBox(height: 10),
            Text(
              'Belum ada kendaraan terdaftar',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Kendaraan otomatis terdaftar setelah kamu booking servis pertama.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TapScale(
              onTap: openBooking,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Booking Sekarang',
                  style: TextStyle(color: background, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    }

    activePlate ??= garage.first['plate'];
    final active = activeVehicle!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: garage.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final v = garage[index];
              final bool isActive = v['plate'] == activePlate;
              return TapScale(
                onTap: () => _update(() => activePlate = v['plate']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? gold.withValues(alpha: 0.15) : surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? gold.withValues(alpha: 0.5) : borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car_filled_outlined, size: 16, color: isActive ? gold : textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        v['type']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? goldSoft : textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [surfaceAlt, surface],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gold.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.directions_car_outlined, color: gold, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(active['type']!, style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(active['plate']!, style: TextStyle(color: textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _promoCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: promos.length,
            onPageChanged: (index) => _update(() => bannerIndex = index),
            itemBuilder: (context, index) {
              final promo = promos[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: TapScale(
                  onTap: () => _openPromo(promo),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          [
                            'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?auto=format&fit=crop&w=1400&q=90',
                            'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?auto=format&fit=crop&w=1400&q=90',
                            'https://images.unsplash.com/photo-1635073908681-8b4e5f3c6e75?auto=format&fit=crop&w=1400&q=90',
                          ][index % 3],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: surfaceAlt,
                            child: Icon(promo['icon'] as IconData, color: gold, size: 54),
                          ),
                        ),
                        // overlay gelap supaya teks tetap terbaca di atas foto
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [background.withValues(alpha: 0.92), background.withValues(alpha: 0.55), background.withValues(alpha: 0.1)],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: gold.withValues(alpha: 0.25)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: borderSubtle),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: gold, shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text('PROMO', style: TextStyle(color: textPrimary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 210,
                                child: Text(
                                  promo['title'] as String,
                                  style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w800, height: 1.15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 220,
                                child: Text(
                                  promo['subtitle'] as String,
                                  style: const TextStyle(color: Color(0xFFC3C8D2), fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(10)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Klaim Sekarang', style: TextStyle(color: Color(0xFF1A1200), fontSize: 12, fontWeight: FontWeight.w700)),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, color: Color(0xFF1A1200), size: 14),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(promos.length, (index) {
            final bool active = index == bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? gold : borderSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderSubtle),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) => _update(() => searchQuery = value),
        style: TextStyle(color: textPrimary),
        cursorColor: gold,
        decoration: InputDecoration(
          hintText: 'Cari layanan servis...',
          hintStyle: TextStyle(color: textSecondary),
          prefixIcon: const Icon(Icons.search, color: gold),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: textSecondary, size: 18),
                  onPressed: () {
                    _update(() {
                      searchController.clear();
                      searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _ratingBadgeCard() {
    return TapScale(
      onTap: () {
        Navigator.push(
          context,
          _fadeRoute(const AboutBengkelPage()),
        );
      },
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: gold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bengkel Resmi',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (i) => const Padding(
                padding: EdgeInsets.only(right: 1),
                child: Icon(Icons.star, color: gold, size: 13),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '4.9 (350+ ulasan)',
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderSubtle)),
        child: Column(
          children: [
            Icon(icon, color: gold, size: 25),
            const SizedBox(height: 9),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _popularServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required String price,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 208,
      child: TapScale(
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gold.withValues(alpha: 0.20)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 14, offset: const Offset(0, 7)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 126,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _servicePhoto(title),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: surfaceAlt,
                        child: Icon(icon, color: gold, size: 44),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, surface.withValues(alpha: 0.92)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
                        child: Icon(icon, color: Color(0xFF17120A), size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 8, 13, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textSecondary, fontSize: 12, height: 1.25)),
                      ),
                      Row(
                        children: [
                          Expanded(child: Text(price, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w800))),
                          const Icon(Icons.arrow_forward_rounded, color: gold, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _servicePhoto(String title) {
    switch (title) {
      case 'Ganti Oli':
        return 'https://images.unsplash.com/photo-1635784063382-9f2b7e7c6e4c?auto=format&fit=crop&w=1200&q=85';
      case 'Servis Rem':
        return 'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?auto=format&fit=crop&w=1200&q=85';
      case 'Servis AC':
        return 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?auto=format&fit=crop&w=1200&q=85';
      case 'Servis Mesin':
        return 'https://images.unsplash.com/photo-1486754735734-325b5831c3ad?auto=format&fit=crop&w=1200&q=85';
      case 'Kelistrikan':
        return 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=85';
      default:
        return 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?auto=format&fit=crop&w=1200&q=85';
    }
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
