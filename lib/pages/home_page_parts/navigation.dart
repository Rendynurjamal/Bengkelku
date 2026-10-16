part of '../home_page.dart';

/// Bagian UI: navigation (memisah home_page.dart supaya tidak terlalu panjang).
extension _Navigation on _HomePageState {
  Widget _bottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.build_outlined, 'activeIcon': Icons.build, 'label': 'Layanan'},
      {'icon': Icons.history_outlined, 'activeIcon': Icons.history, 'label': 'Riwayat'},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: borderSubtle)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, -6))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final bool active = selectedIndex == index;
            return InkWell(
              onTap: () => _update(() => selectedIndex = index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: active ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        active ? items[index]['activeIcon'] as IconData : items[index]['icon'] as IconData,
                        color: active ? gold : textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? gold : textSecondary),
                      child: Text(items[index]['label'] as String),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
