import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

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

  /// Show success dialog
  void _showSuccessDialog(String message) {
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
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Berhasil",
                    style: TextStyle(
                      color: Colors.green,
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
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  "Lanjut ke Login",
                  style: TextStyle(color: AppColors.premiumNavy),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _email.text.trim(),
            password: _password.text.trim(),
          );

      // Save to Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'email': _email.text.trim(),
              'username': _username.text.trim(),
              'role': 'user',
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      if (!mounted) return;
      _showSuccessDialog(
        "Registrasi berhasil!\n\nSilakan login dengan akun Anda.",
      );
    } on FirebaseAuthException catch (e) {
      String title = "Registrasi Gagal";
      String message = "Terjadi kesalahan saat mendaftar";

      if (e.code == 'email-already-in-use') {
        title = "Email Sudah Terdaftar";
        message =
            "Email ini sudah digunakan oleh akun lain.\n"
            "Silakan gunakan email yang berbeda atau login dengan akun tersebut.";
      } else if (e.code == 'invalid-email') {
        title = "Email Tidak Valid";
        message = "Format email yang Anda masukkan tidak valid.";
      } else if (e.code == 'weak-password') {
        title = "Password Terlalu Lemah";
        message =
            "Password harus memiliki minimal 6 karakter dan kombinasi yang kuat.";
      }

      if (!mounted) return;
      _showErrorDialog(title, message);
      debugPrint("REGISTER ERROR: ${e.code} - ${e.message}");
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog("Error", "Terjadi kesalahan: $e");
      debugPrint("REGISTER GENERAL ERROR: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGoogleRegister() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        if (!mounted) return;
        _showSuccessDialog("Registrasi Google Berhasil!\n\nSelamat datang!");
      } else {
        if (!mounted) return;
        _showErrorDialog(
          "Login Dibatalkan",
          "Anda membatalkan proses Google Sign-In.\n"
              "Silakan coba lagi jika ingin daftar dengan Google.",
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorDialog(
        "Google Sign-In Error",
        "Kode Error: ${e.code}\n\nPesan: ${e.message ?? 'Tidak ada pesan error'}",
      );
      debugPrint("GOOGLE REGISTER ERROR: ${e.code} - ${e.message}");
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(
        "Google Sign-In Gagal",
        "Terjadi kesalahan: $e\n\n"
            "Pastikan Anda memiliki koneksi internet dan Google Services terkonfigurasi dengan benar.",
      );
      debugPrint("GOOGLE REGISTER GENERAL ERROR: $e");
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
      appBar: AppBar(
        title: const Text("Daftar Akun"),
        backgroundColor: AppColors.premiumNavy,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ICON HEADER
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.goldMedium,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 48,
                    color: AppColors.premiumNavy,
                  ),
                ),
                const SizedBox(height: 20),

                // HEADER TEXT
                const Text(
                  "Buat Akun Baru",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.premiumNavy,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  "Daftar sekarang untuk memulai",
                  style: TextStyle(fontSize: 14, color: AppColors.grey),
                ),

                const SizedBox(height: 28),

                // USERNAME
                TextFormField(
                  controller: _username,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(
                      Icons.person,
                      color: AppColors.softNavy,
                    ),
                    labelStyle: const TextStyle(color: AppColors.softNavy),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.goldMedium,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Username wajib diisi";
                    }
                    if (value.length < 3) return "Minimal 3 karakter";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // EMAIL
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.softNavy,
                    ),
                    labelStyle: const TextStyle(color: AppColors.softNavy),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.goldMedium,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email wajib diisi";
                    }
                    if (!value.contains('@')) return "Email tidak valid";
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
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.softNavy,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.softNavy,
                      ),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                    ),
                    labelStyle: const TextStyle(color: AppColors.softNavy),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.goldMedium,
                        width: 2,
                      ),
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
                const SizedBox(height: 16),

                // CONFIRM PASSWORD
                TextFormField(
                  controller: _confirm,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: "Konfirmasi Password",
                    prefixIcon: const Icon(
                      Icons.lock_reset,
                      color: AppColors.softNavy,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.softNavy,
                      ),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                    ),
                    labelStyle: const TextStyle(color: AppColors.softNavy),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.goldMedium,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Konfirmasi password wajib diisi";
                    }
                    if (value != _password.text) {
                      return "Password tidak cocok";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // BUTTON DAFTAR
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onRegister,
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
                            : const Text("Daftar"),
                  ),
                ),

                const SizedBox(height: 16),

                // TOMBOL GOOGLE
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _onGoogleRegister,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text("Daftar dengan Google"),
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

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Sudah punya akun? Login",
                    style: TextStyle(color: AppColors.premiumNavy),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
