import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_services.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await _authService.resetPassword(
      widget.email,
      _passwordController.text.trim(),
      _confirmPasswordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Kata sandi berhasil diperbarui! Silakan masuk kembali."),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/sign_in');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(response['message'] ?? "Gagal mengatur ulang kata sandi"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Atur Ulang Sandi"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  const Text(
                    "Kata Sandi Baru",
                    style: TextStyle(
                        fontSize: 28,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Silakan buat kata sandi baru untuk akun:\n${widget.email}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Masukkan kata sandi baru Anda";
                      }
                      if (value.length < 6) {
                        return "Kata sandi minimal harus terdiri dari 6 karakter";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Kata Sandi Baru",
                      hintText: "Masukkan kata sandi baru",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon:
                          Icon(Icons.lock_outline, color: Color(0xFF757575)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Silakan konfirmasi kata sandi Anda";
                      }
                      if (value != _passwordController.text) {
                        return "Konfirmasi kata sandi tidak cocok";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Konfirmasi Kata Sandi",
                      hintText: "Ketik ulang kata sandi baru",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon:
                          Icon(Icons.lock_reset, color: Color(0xFF757575)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFF7643),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Simpan Sandi Baru"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
