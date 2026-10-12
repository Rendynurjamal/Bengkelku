import 'package:flutter/material.dart';
import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const Color background = Color(0xFF06111F);
  static const Color gold = Color(0xFFFFC21A);
  static const Color textSecondary = Color(0xFFD0D6DE);

  final PageController _controller = PageController();
  int _index = 0;

  final List<Map<String, dynamic>> slides = [
    {
      'photo': 'photo-1486262715619-67b85e0b08d3',
      'icon': Icons.calendar_month_rounded,
      'eyebrow': 'BOOKING PRAKTIS',
      'title': 'Booking Tanpa Ribet',
      'desc': 'Pilih layanan servis yang kamu butuhkan dan atur jadwal kunjungan dalam hitungan detik.',
    },
    {
      'photo': 'photo-1632823471565-1ecdf5c7a3b8',
      'icon': Icons.history_rounded,
      'eyebrow': 'SEMUA TERCATAT',
      'title': 'Pantau Riwayat Servis',
      'desc': 'Lihat servis yang pernah dilakukan dan bantu jaga kendaraan tetap dalam kondisi prima.',
    },
    {
      'photo': 'photo-1487754180451-c456f719a1fc',
      'icon': Icons.support_agent_rounded,
      'eyebrow': 'SIAP MEMBANTU',
      'title': 'Chat Admin Langsung',
      'desc': 'Butuh bantuan memilih layanan? Hubungi admin BengkelKu dengan lebih mudah.',
    },
  ];

  void _finish() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final slide = slides[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/${slide['photo']}?auto=format&fit=crop&w=1400&q=85',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: background),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x66030A12), Color(0xAA06111F), Color(0xFF06111F)],
                        stops: [0, .45, 1],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 82, 28, 142),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: const Color(0xDD0D1B2A),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: gold.withValues(alpha: .8)),
                            ),
                            child: Icon(slide['icon'] as IconData, color: gold, size: 34),
                          ),
                          const SizedBox(height: 24),
                          Text(slide['eyebrow'] as String, style: const TextStyle(color: gold, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 11)),
                          const SizedBox(height: 10),
                          Text(slide['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 32, height: 1.1, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 14),
                          Text(slide['desc'] as String, style: const TextStyle(color: textSecondary, fontSize: 15, height: 1.6)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Lewati', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(slides.length, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 7,
                          height: 7,
                          decoration: BoxDecoration(color: active ? gold : Colors.white38, borderRadius: BorderRadius.circular(20)),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_index == slides.length - 1) {
                            _finish();
                          } else {
                            _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: Text(_index == slides.length - 1 ? 'Mulai Sekarang' : 'Lanjut', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
