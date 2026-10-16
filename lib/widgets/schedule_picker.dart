import 'package:flutter/material.dart';

import '../models/booking_data.dart';
import '../models/mechanic_data.dart';
import '../theme/app_colors.dart';
import 'mechanic_widgets.dart';

/// Pilihan jadwal pengguna: montir + tanggal + jam mulai.
class ScheduleSelection {
  final String? mechanic;
  final DateTime? date;
  final String? slot;

  const ScheduleSelection({this.mechanic, this.date, this.slot});

  bool get isComplete => mechanic != null && date != null && slot != null;

  DateTime? get scheduledAt =>
      (date != null && slot != null) ? BookingData.slotDateTime(date!, slot!) : null;
}

/// Bagian form booking: pilih montir, pilih tanggal, pilih jam.
/// Slot yang penuh/lewat tampil abu-abu dan tidak bisa dipilih.
class SchedulePicker extends StatefulWidget {
  final ValueChanged<ScheduleSelection> onChanged;

  /// Banyaknya slot berurutan yang dibutuhkan (mis. booking beberapa layanan sekaligus).
  final int slotsNeeded;

  /// true = tampilan terang (halaman Booking Servis), false = ikut tema aplikasi.
  final bool light;

  const SchedulePicker({
    super.key,
    required this.onChanged,
    this.slotsNeeded = 1,
    this.light = false,
  });

  @override
  State<SchedulePicker> createState() => _SchedulePickerState();
}

class _SchedulePickerState extends State<SchedulePicker> {
  String? _mechanic;
  DateTime? _date;
  String? _slot;

  late final List<DateTime> _days;

  Color get _text => widget.light ? const Color(0xFF16181D) : AppColors.textPrimary;
  Color get _textSub => widget.light ? Colors.black54 : AppColors.textSecondary;
  Color get _tile => widget.light ? const Color(0xFFF5F3EF) : AppColors.surfaceAlt;
  Color get _line => widget.light ? const Color(0x1F000000) : AppColors.borderSubtle;
  Color get _disabledBg =>
      widget.light ? const Color(0xFFE3E3E3) : AppColors.background.withValues(alpha: 0.6);
  Color get _disabledText => widget.light ? Colors.black26 : AppColors.textSecondary.withValues(alpha: 0.45);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _days = List.generate(7, (i) => today.add(Duration(days: i)));
  }

  void _emit() => widget.onChanged(
        ScheduleSelection(mechanic: _mechanic, date: _date, slot: _slot),
      );

  bool _slotFree(String slot) {
    if (_date == null || _mechanic == null) return false;
    return BookingData.isRangeFree(_date!, slot, widget.slotsNeeded, _mechanic);
  }

  void _revalidateSlot() {
    if (_slot != null && !_slotFree(_slot!)) _slot = null;
  }

  Widget _label(String text, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(text,
              style: TextStyle(color: _text, fontWeight: FontWeight.bold, fontSize: 14)),
          if (hint != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(hint, style: TextStyle(color: _textSub, fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = AppColors.gold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------- MONTIR ----------------
        _label('Pilih Montir'),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: MechanicData.mechanics.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final m = MechanicData.mechanics[i];
              final selected = _mechanic == m.name;
              final rating = MechanicData.ratingFor(m.name);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _mechanic = m.name;
                    _revalidateSlot();
                  });
                  _emit();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 148,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected ? gold.withValues(alpha: 0.14) : _tile,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? gold : _line,
                      width: selected ? 1.6 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MechanicAvatar(mechanic: m, radius: 22),
                          const Spacer(),
                          if (selected) Icon(Icons.check_circle, color: gold, size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(m.name,
                          style: TextStyle(
                              color: _text, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(
                        m.specialty,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _textSub, fontSize: 11, height: 1.2),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.star, color: gold, size: 14),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              rating.hasReviews
                                  ? '${rating.average.toStringAsFixed(1)} (${rating.count})'
                                  : 'Baru',
                              style: TextStyle(
                                  color: _textSub,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // ---------------- TANGGAL ----------------
        _label('Pilih Tanggal'),
        SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final d = _days[i];
              final selected = _date != null &&
                  _date!.year == d.year &&
                  _date!.month == d.month &&
                  _date!.day == d.day;
              const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _date = d;
                    _revalidateSlot();
                  });
                  _emit();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 58,
                  decoration: BoxDecoration(
                    color: selected ? gold : _tile,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? gold : _line),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        i == 0 ? 'Hari ini' : dayNames[d.weekday - 1],
                        style: TextStyle(
                          color: selected ? Colors.white : _textSub,
                          fontSize: i == 0 ? 9.5 : 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          color: selected ? Colors.white : _text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // ---------------- JAM ----------------
        _label(
          'Pilih Jam',
          hint: widget.slotsNeeded > 1
              ? 'Butuh ${widget.slotsNeeded} slot berurutan'
              : null,
        ),
        if (_mechanic == null || _date == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _tile,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Pilih montir dan tanggal dulu untuk melihat jam yang tersedia.',
              style: TextStyle(color: _textSub, fontSize: 12.5),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BookingData.slotTimes.map((slot) {
              final free = _slotFree(slot);
              final selected = _slot == slot;

              return GestureDetector(
                onTap: free
                    ? () {
                        setState(() => _slot = slot);
                        _emit();
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 76,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !free ? _disabledBg : (selected ? gold : _tile),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: !free ? Colors.transparent : (selected ? gold : _line),
                    ),
                  ),
                  child: Text(
                    slot,
                    style: TextStyle(
                      color: !free
                          ? _disabledText
                          : (selected ? Colors.white : _text),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      decoration: !free ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            _legend(gold, 'Dipilih'),
            const SizedBox(width: 14),
            _legend(_tile, 'Tersedia', border: _line),
            const SizedBox(width: 14),
            _legend(_disabledBg, 'Penuh'),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color color, String text, {Color? border}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border == null ? null : Border.all(color: border),
          ),
        ),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: _textSub, fontSize: 11)),
      ],
    );
  }
}
