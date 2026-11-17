// lib/widgets/auth_dialog.dart
// Upgraded v5.0 Auth Modal: Anti-Fraud Warning, T&C Checkbox, Blockchain & E2EE Badges
import 'package:flutter/material.dart';
import '../state/auth_state.dart';
import '../theme/app_theme.dart';
import 'common/fraud_warning_box.dart';
import 'auth/terms_conditions_dialog.dart';
import 'auth/security_trust_strip.dart';

class AuthDialog extends StatefulWidget {
  final bool initialIsRegister;
  final String? reasonMessage;
  final VoidCallback? onAuthSuccess;

  const AuthDialog({
    super.key,
    this.initialIsRegister = false,
    this.reasonMessage,
    this.onAuthSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    bool isRegister = false,
    String? reasonMessage,
    VoidCallback? onAuthSuccess,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.90,
            ),
            child: AuthDialog(
              initialIsRegister: isRegister,
              reasonMessage: reasonMessage,
              onAuthSuccess: onAuthSuccess,
            ),
          ),
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (ctx) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight: MediaQuery.of(ctx).size.height * 0.90,
            ),
            child: Material(
              color: Colors.transparent,
              child: AuthDialog(
                initialIsRegister: isRegister,
                reasonMessage: reasonMessage,
                onAuthSuccess: onAuthSuccess,
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> with SingleTickerProviderStateMixin {
  late bool _isRegister;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  // Form Controllers
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailOrPhoneCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialIsRegister;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _emailOrPhoneCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final auth = AuthManager.instance;
    final email = _emailOrPhoneCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();

    if (!_isRegister && auth.isLockedOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🛑 Akses login ditangguhkan sementara (Anti-Brute Force). Silakan tunggu ${auth.remainingLockoutSeconds} detik.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

    if (_isRegister && !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Harap centang persetujuan Syarat & Ketentuan untuk melanjutkan pendaftaran.'),
          backgroundColor: AppColors.caramel,
        ),
      );
      return;
    }

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi seluruh kolom yang wajib.')),
      );
      return;
    }

    if (_isRegister && _nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi nama lengkap Anda.')),
      );
      return;
    }

    bool success = false;
    if (_isRegister) {
      success = await auth.register(
        name: _nameCtrl.text.trim(),
        email: email,
        phone: _phoneCtrl.text.trim().isEmpty ? '08123456789' : _phoneCtrl.text.trim(),
        password: pass,
      );
    } else {
      success = await auth.login(
        identifier: email,
        password: pass,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      widget.onAuthSuccess?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Text('☕', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isRegister
                      ? 'Selamat datang, ${auth.currentUser?.name}! Data Anda aman dengan enkripsi E2EE.'
                      : 'Selamat datang kembali, ${auth.currentUser?.name}!',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (!_isRegister) {
      if (auth.isLockedOut) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.security, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🛑 Akun ditangguhkan sementara (${auth.remainingLockoutSeconds} detik) karena ${auth.failedAttempts}x percobaan gagal. Dilindungi Cloudflare & Anti-Brute Force.',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        final remaining = 3 - auth.failedAttempts;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '⚠️ Password salah (min 4 karakter). Sisa percobaan sebelum lockout: ${remaining > 0 ? remaining : 1}x.',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    final success = await AuthManager.instance.loginWithGoogle();
    if (mounted && success) {
      Navigator.of(context).pop();
      widget.onAuthSuccess?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.espresso,
          behavior: SnackBarBehavior.floating,
          content: Text('Berhasil masuk sebagai ${AuthManager.instance.currentUser?.name}!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager.instance;

    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppColors.softShadow,
              border: Border.all(color: AppColors.caramel.withValues(alpha: 0.15)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Header Row with mascot & close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.creamLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.caramel.withValues(alpha: 0.2)),
                        ),
                        child: Center(
                          child: Text(
                            _isRegister ? '🌟' : '☕',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRegister ? 'BUAT AKUN MEMBER' : 'SELAMAT DATANG',
                            style: const TextStyle(
                              color: AppColors.caramel,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            _isRegister ? 'Daftar Seuma.Koffie' : 'Masuk ke Akunmu',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                  ),
                ],
              ),

              // Reason message if triggered by checkout attempt
              if (widget.reasonMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.caramel.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.caramel.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.caramel, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.reasonMessage!,
                          style: const TextStyle(
                            color: AppColors.espresso,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // INFO BOX WASPADA PENIPUAN
              const FraudWarningBox(compact: true),

              const SizedBox(height: 16),

              // Tab Switcher (Masuk / Daftar)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.caramel.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isRegister = false),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isRegister ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_isRegister
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: !_isRegister ? FontWeight.w800 : FontWeight.w600,
                                color: !_isRegister ? AppColors.caramel : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isRegister = true),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isRegister ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _isRegister
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Daftar Baru',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _isRegister ? FontWeight.w800 : FontWeight.w600,
                                color: _isRegister ? AppColors.caramel : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Form Inputs
              if (_isRegister) ...[
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap *',
                    labelStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.caramel, size: 18),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              TextField(
                controller: _emailOrPhoneCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: _isRegister ? 'Email *' : 'Email atau Nomor WhatsApp *',
                  labelStyle: const TextStyle(fontSize: 12),
                  prefixIcon: const Icon(Icons.mail_outline, color: AppColors.caramel, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              if (_isRegister) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor WhatsApp (untuk kurir antar kilat)',
                    labelStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.caramel, size: 18),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi *',
                  labelStyle: const TextStyle(fontSize: 12),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.caramel, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              // CHECKBOX SYARAT & KETENTUAN (Khusus Pendaftaran Akun)
              if (_isRegister) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: AppColors.caramel,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Saya menyetujui ',
                            style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w500),
                          ),
                          GestureDetector(
                            onTap: () => TermsConditionsDialog.show(context),
                            child: const Text(
                              'Syarat & Ketentuan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.caramel,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Text(
                            ' serta Kebijakan Privasi Seuma.Koffie.',
                            style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // Anti-Brute Force Lockout & Warning Banner
              if (!_isRegister && auth.isLockedOut) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade300, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lock_clock, color: Colors.red.shade800, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AKSES DIKUNCI (ANTI-BRUTE FORCE)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.red.shade900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Terlalu banyak percobaan gagal (${auth.failedAttempts}x). Harap tunggu ${auth.remainingLockoutSeconds} detik sebelum mencoba lagi.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.red.shade800,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ] else if (!_isRegister && auth.failedAttempts > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.orange.shade800, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Percobaan gagal: ${auth.failedAttempts}/3 kali. Akun akan terkunci jika salah 3 kali berturut-turut.',
                          style: TextStyle(fontSize: 11, color: Colors.orange.shade900, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              const SizedBox(height: 4),

              // Submit Button
              ElevatedButton(
                onPressed: (auth.isLoading || (!_isRegister && auth.isLockedOut) || (_isRegister && !_agreedToTerms))
                    ? (_isRegister && !_agreedToTerms
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚠️ Harap centang persetujuan Syarat & Ketentuan terlebih dahulu.'),
                                backgroundColor: AppColors.caramel,
                              ),
                            );
                          }
                        : null)
                    : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ((_isRegister && !_agreedToTerms) || (!_isRegister && auth.isLockedOut))
                      ? const Color(0xFFBCAAA4)
                      : AppColors.caramel,
                  foregroundColor: Colors.white,
                  elevation: ((_isRegister && !_agreedToTerms) || (!_isRegister && auth.isLockedOut)) ? 1 : 4,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _isRegister
                            ? 'Daftar Akun & Lanjut Belanja'
                            : (auth.isLockedOut
                                ? 'Terkunci (${auth.remainingLockoutSeconds}s)'
                                : 'Masuk Sekarang'),
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
              ),

              const SizedBox(height: 16),

              // Social Login
              OutlinedButton.icon(
                onPressed: (auth.isLoading || (!_isRegister && auth.isLockedOut)) ? null : _handleGoogleLogin,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.25)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'G',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4285F4),
                      fontSize: 13,
                    ),
                  ),
                ),
                label: const Text(
                  'Lanjut Cepat dengan Google',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ),

              const SizedBox(height: 16),

              // BANNER KEAMANAN BLOCKCHAIN & END-TO-END ENCRYPTION
              const SecurityTrustStrip(compact: true),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
