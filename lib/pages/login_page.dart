import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_page.dart' show HomePage;

/// Halaman login BengkelKu.
/// Tidak mengubah halaman Home atau fitur pada halaman lain.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  void _showForgotPassword() {
    final controller = TextEditingController(text: _emailController.text.trim());
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Lupa Password?'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email terdaftar'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showMessage('Pemulihan password perlu dihubungkan ke layanan akun.');
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _showRegister() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Buat Akun BengkelKu'),
        content: const Text('Pendaftaran akun belum terhubung ke server. Untuk sekarang, isi nama dan password di halaman login untuk mencoba tampilan aplikasi.'),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Mengerti'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?auto=format&fit=crop&w=1800&q=85',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF07111E)),
            loadingBuilder: (context, child, progress) => child,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xB8000914), Color(0xF506111F), Color(0xFF06111F)],
                stops: [0, .43, 1],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 460 : 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 78,
                        height: 78,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: .13),
                          border: Border.all(color: AppColors.gold.withValues(alpha: .6)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.car_repair_rounded, color: AppColors.gold, size: 43),
                      ),
                      const SizedBox(height: 18),
                      const Text('BengkelKu', textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -.7)),
                      const SizedBox(height: 8),
                      Text('Rawat kendaraan, tanpa khawatir.', textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xF20A1726),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: .10)),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 28, offset: Offset(0, 12))],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Selamat Datang!', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Masuk untuk melanjutkan ke akun Anda', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              const SizedBox(height: 22),
                              _field(controller: _nameController, label: 'Nama pengguna', icon: Icons.person_outline_rounded,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama pengguna wajib diisi' : null),
                              const SizedBox(height: 13),
                              _field(controller: _emailController, label: 'Email atau nomor HP', icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Email atau nomor HP wajib diisi' : null),
                              const SizedBox(height: 13),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _hidePassword,
                                validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                                style: const TextStyle(color: Colors.white),
                                decoration: _decoration('Password', Icons.lock_outline_rounded).copyWith(
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                                    icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textSecondary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(children: [
                                SizedBox(width: 22, height: 22, child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                  activeColor: AppColors.gold,
                                  checkColor: Colors.black,
                                  side: BorderSide(color: AppColors.textSecondary),
                                )),
                                const SizedBox(width: 7),
                                Expanded(child: Text('Ingat saya', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                                TextButton(onPressed: _showForgotPassword, child: const Text('Lupa password?', style: TextStyle(color: AppColors.gold, fontSize: 12))),
                              ]),
                              const SizedBox(height: 12),
                              SizedBox(height: 50, child: FilledButton(
                                onPressed: _login,
                                style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                                child: const Text('Masuk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              )),
                              const SizedBox(height: 18),
                              Row(children: [Expanded(child: Divider(color: Color(0x334B6075))), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('atau masuk dengan', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))), Expanded(child: Divider(color: Color(0x334B6075)))]),
                              const SizedBox(height: 16),
                              SizedBox(height: 48, child: OutlinedButton.icon(
                                onPressed: () => _showMessage('Login Google belum aktif. Hubungkan Firebase/Google Sign-In terlebih dahulu.'),
                                icon: const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 22, fontWeight: FontWeight.w900)),
                                label: const Text('Masuk dengan Google', style: TextStyle(color: Color(0xFF17212D), fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide.none,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                              )),
                              const SizedBox(height: 18),
                              Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
                                Text('Belum punya akun? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                TextButton(onPressed: _showRegister, style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                  child: const Text('Daftar', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text('Dengan masuk, Anda dapat mengelola layanan dan jadwal servis kendaraan.', textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF778393), fontSize: 11, height: 1.5)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({required TextEditingController controller, required String label, required IconData icon,
    String? Function(String?)? validator, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label, icon),
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
    prefixIcon: Icon(icon, color: AppColors.gold, size: 21),
    filled: true,
    fillColor: const Color(0xFF132235),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0x334B6075))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: AppColors.gold, width: 1.4)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Colors.redAccent)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Colors.redAccent)),
  );
}
