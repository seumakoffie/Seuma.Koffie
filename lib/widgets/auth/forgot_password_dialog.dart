// lib/widgets/auth/forgot_password_dialog.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/auth_state.dart';

class ForgotPasswordDialog extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordDialog({super.key, this.initialEmail});

  static Future<void> show(BuildContext context, {String? initialEmail}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ForgotPasswordDialog(initialEmail: initialEmail),
    );
  }

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  int _step = 1; // 1: Email, 2: OTP On-Screen, 3: New Password

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  String _generatedOtp = '';
  bool _obscurePass = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailCtrl.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _generateNewOtp() {
    final random = Random();
    final code = (100000 + random.nextInt(900000)).toString();
    setState(() {
      _generatedOtp = code;
      _otpCtrl.clear();
      _errorMessage = null;
    });
  }

  void _handleStep1Submit() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Mohon masukkan alamat email yang valid.');
      return;
    }

    _generateNewOtp();
    setState(() {
      _step = 2;
      _errorMessage = null;
    });
  }

  void _handleStep2Submit() {
    final inputOtp = _otpCtrl.text.trim();
    if (inputOtp != _generatedOtp) {
      setState(() => _errorMessage = 'Kode OTP tidak sesuai. Periksa kode di atas.');
      return;
    }

    setState(() {
      _step = 3;
      _errorMessage = null;
    });
  }

  Future<void> _handleStep3Submit() async {
    final newPass = _newPassCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();

    if (newPass.length < 6) {
      setState(() => _errorMessage = 'Kata sandi minimal 6 karakter.');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Konfirmasi kata sandi tidak cocok.');
      return;
    }

    setState(() => _errorMessage = null);

    final auth = AuthManager.instance;
    final err = await auth.resetPasswordWithOnScreenOtp(
      email: _emailCtrl.text.trim(),
      newPassword: newPass,
    );

    if (!mounted) return;

    if (err != null) {
      setState(() => _errorMessage = err);
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Kata sandi berhasil diperbarui! Anda kini otomatis masuk.'),
            ],
          ),
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.espresso.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.lock_reset_rounded, color: AppColors.espresso, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Atur Ulang Sandi',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.espresso),
                        ),
                        Text(
                          'Langkah $_step dari 3',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 18),

            // Error Banner
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(fontSize: 12, color: Colors.red.shade900, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Step Content
            if (_step == 1) _buildStep1Email(),
            if (_step == 2) _buildStep2OnScreenOtp(),
            if (_step == 3) _buildStep3NewPassword(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Masukkan email yang terdaftar pada akun Seuma.Koffie Anda untuk verifikasi langsung di layar perangkat ini.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Alamat Email Terdaftar',
            prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 22),
        ElevatedButton(
          onPressed: _handleStep1Submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.espresso,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Lanjut ke Kode Verifikasi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
        ),
      ],
    );
  }

  Widget _buildStep2OnScreenOtp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Kode OTP keamanan telah dibuat langsung pada layar perangkat Anda (tanpa perlu membuka email):',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 14),

        // Prominent On-Screen OTP Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2C1609), Color(0xFF4A2511)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.gold, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'KODE VERIFIKASI PERANGKAT ANDA',
                    style: TextStyle(color: AppColors.gold, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SelectableText(
                _generatedOtp.split('').join('  '),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _otpCtrl.text = _generatedOtp;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode OTP otomatis terisi!'), duration: Duration(seconds: 1)),
                      );
                    },
                    icon: const Icon(Icons.flash_on_rounded, size: 14, color: Color(0xFFFFD54F)),
                    label: const Text('Isi Otomatis', style: TextStyle(color: Color(0xFFFFD54F), fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _generateNewOtp,
                    icon: const Icon(Icons.refresh_rounded, size: 14, color: Colors.white70),
                    label: const Text('Kode Baru', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // OTP Input Field
        TextField(
          controller: _otpCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 8),
          decoration: InputDecoration(
            counterText: '',
            hintText: '000000',
            hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kembali', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _handleStep2Submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.espresso,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Verifikasi OTP', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3NewPassword() {
    final auth = AuthManager.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Verifikasi OTP berhasil! Silakan masukkan kata sandi baru untuk akun Anda.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _newPassCtrl,
          obscureText: _obscurePass,
          decoration: InputDecoration(
            labelText: 'Kata Sandi Baru (Min. 6 Karakter)',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textMuted),
            suffixIcon: IconButton(
              icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 18),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmPassCtrl,
          obscureText: _obscurePass,
          decoration: InputDecoration(
            labelText: 'Konfirmasi Kata Sandi Baru',
            prefixIcon: const Icon(Icons.lock_reset_rounded, size: 18, color: AppColors.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: auth.isLoading ? null : _handleStep3Submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.caramel,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: auth.isLoading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Simpan Sandi & Masuk Otomatis', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
        ),
      ],
    );
  }
}
