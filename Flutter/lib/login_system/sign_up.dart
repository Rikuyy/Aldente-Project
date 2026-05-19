import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_services.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = '/sign_up';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscureText1 = true;
  bool _obscureText2 = true;

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await _authService.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Pendaftaran berhasil! Silakan masuk menggunakan akun Anda."),
          backgroundColor: Colors.green,
        ),
      );

      // URUTAN REVISI: Sesuai alur baru, setelah mendaftar lempar dulu ke Login Screen
      context.go('/sign_in');
    } else {
      String errMsg = "Registrasi Gagal";
      if (response['errors'] != null && response['errors']['email'] != null) {
        errMsg = "Email ini sudah terdaftar di sistem";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white, title: const Text("Daftar Akun")),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Daftar Akun Baru",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Lengkapi data diri Anda secara benar di bawah ini",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Username
                        TextFormField(
                          controller: _usernameController,
                          validator: (val) => (val == null || val.isEmpty)
                              ? "Nama pengguna tidak boleh kosong"
                              : null,
                          decoration: InputDecoration(
                            labelText: "Nama Pengguna",
                            hintText: "Masukkan nama pengguna",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: authOutlineInputBorder,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Email tidak boleh kosong";
                            final emailRegex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value))
                              return "Format email tidak valid";
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "Masukkan alamat email",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: authOutlineInputBorder,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText1,
                          validator: (val) => (val == null || val.length < 6)
                              ? "Kata sandi minimal 6 karakter"
                              : null,
                          decoration: InputDecoration(
                            labelText: "Kata Sandi",
                            hintText: "Masukkan kata sandi",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscureText1
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFFFF7643)),
                              onPressed: () => setState(
                                  () => _obscureText1 = !_obscureText1),
                            ),
                            border: authOutlineInputBorder,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureText2,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return "Konfirmasi kata sandi wajib diisi";
                            if (val != _passwordController.text)
                              return "Kata sandi tidak cocok";
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Konfirmasi Kata Sandi",
                            hintText: "Ulangi masukkan kata sandi",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscureText2
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFFFF7643)),
                              onPressed: () => setState(
                                  () => _obscureText2 = !_obscureText2),
                            ),
                            border: authOutlineInputBorder,
                          ),
                        ),
                        const SizedBox(height: 40),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFFF7643),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text("Daftar"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);
