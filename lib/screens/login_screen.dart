import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscure = true; // hide password
  bool _isLoading = false; // show loading button

  /// Show error dialog with prominent styling
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error,
                    color: Colors.red.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "OK",
                  style: TextStyle(color: AppColors.premiumNavy),
                ),
              ),
            ],
          ),
    );
  }

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _email.text.trim(),
              password: _password.text.trim(),
            );

        if (!mounted) return;

        // Verify user exists in Firestore
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (!userDoc.exists) {
          if (!mounted) return;
          _showErrorDialog(
            "Akun Belum Terdaftar",
            "Email Anda terdaftar di Firebase Auth, tetapi belum ada data di database. "
                "Silakan daftar ulang atau hubungi administrator.",
          );
          // Sign out user since they don't have profile yet
          await FirebaseAuth.instance.signOut();
          return;
        }

        if (!mounted) return;

        // Cek apakah admin
        if (_email.text.trim() == "admin@test.com") {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } on FirebaseAuthException catch (e) {
        String title = "Login Gagal";
        String message = "Terjadi kesalahan saat login";

        if (e.code == 'user-not-found') {
          title = "Email Tidak Terdaftar";
          message =
              "Email ini belum pernah didaftarkan.\n"
              "Silakan klik 'Belum punya akun? Daftar' untuk membuat akun baru.";
        } else if (e.code == 'wrong-password') {
          title = "Password Salah";
          message =
              "Password yang Anda masukkan tidak sesuai.\n"
              "Silakan coba lagi.";
        } else if (e.code == 'invalid-email') {
          title = "Email Tidak Valid";
          message = "Format email yang Anda masukkan tidak valid.";
        } else if (e.code == 'too-many-requests') {
          title = "Terlalu Banyak Percobaan";
          message =
              "Anda telah mencoba login terlalu banyak kali.\n"
              "Silakan coba lagi nanti.";
        }

        if (!mounted) return;
        _showErrorDialog(title, message);
        debugPrint("LOGIN ERROR: ${e.code} - ${e.message}");
      } catch (e) {
        if (!mounted) return;
        _showErrorDialog("Error", "Terjadi kesalahan: $e");
        debugPrint("LOGIN GENERAL ERROR: $e");
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _onGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        if (!mounted) return;
        _showErrorDialog(
          "Login Dibatalkan",
          "Anda membatalkan proses Google Sign-In.\n"
              "Silakan coba lagi jika ingin login dengan Google.",
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorDialog(
        "Google Sign-In Error",
        "Kode Error: ${e.code}\n\nPesan: ${e.message ?? 'Tidak ada pesan error'}",
      );
      debugPrint("GOOGLE LOGIN ERROR: ${e.code} - ${e.message}");
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(
        "Google Sign-In Gagal",
        "Terjadi kesalahan: $e\n\n"
            "Pastikan Anda memiliki koneksi internet dan Google Services terkonfigurasi dengan benar.",
      );
      debugPrint("GOOGLE LOGIN GENERAL ERROR: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.premiumNavy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 60,
                  color: AppColors.goldMedium,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Selamat Datang",
                style: TextStyle(
                  color: AppColors.premiumNavy,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Masuk untuk melanjutkan",
                style: TextStyle(color: AppColors.grey, fontSize: 14),
              ),

              const SizedBox(height: 32),

              // FORM LOGIN
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // EMAIL
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email wajib diisi";
                        }
                        if (!value.contains('@')) {
                          return "Email tidak valid";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // PASSWORD
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscure = !_obscure);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password wajib diisi";
                        }
                        if (value.length < 6) {
                          return "Minimal 6 karakter";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // TOMBOL LOGIN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.premiumNavy,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                                : const Text("Masuk"),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TOMBOL GOOGLE
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _onGoogleLogin,
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text("Masuk dengan Google"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.premiumNavy,
                          side: const BorderSide(
                            color: AppColors.goldMedium,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // LINK REGISTER
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Belum punya akun? Daftar",
                        style: TextStyle(color: AppColors.premiumNavy),
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
  }
}
