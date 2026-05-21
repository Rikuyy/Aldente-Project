import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_services.dart';

class OtpScreen extends StatefulWidget {
  static const String routeName = '/otp';
  final String? email;

  const OtpScreen({super.key, this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pin1Controller = TextEditingController();
  final _pin2Controller = TextEditingController();
  final _pin3Controller = TextEditingController();
  final _pin4Controller = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isResending = false;

  void _handleVerifyOtp() async {
    String otpCode = _pin1Controller.text +
        _pin2Controller.text +
        _pin3Controller.text +
        _pin4Controller.text;

    if (otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan lengkapi 4 digit kode OTP Anda")),
      );
      return;
    }

    setState(() => _isLoading = true);
    String targetEmail = widget.email ?? "user@gmail.com";

    final response = await _authService.verifyOtp(targetEmail, otpCode);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("OTP Berhasil Diverifikasi! Silakan buat sandi baru."),
            backgroundColor: Colors.green),
      );
      context.push('/reset_password', extra: targetEmail);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(response['message'] ?? "Kode OTP salah atau tidak cocok"),
            backgroundColor: Colors.red),
      );
    }
  }

  void _handleResendOtp() async {
    setState(() => _isResending = true);
    String targetEmail = widget.email ?? "user@gmail.com";

    final response = await _authService.forgotPassword(targetEmail);

    setState(() => _isResending = false);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Kode OTP baru yang fresh telah dikirim ke Gmail Anda!"),
            backgroundColor: Colors.green),
      );
      _pin1Controller.clear();
      _pin2Controller.clear();
      _pin3Controller.clear();
      _pin4Controller.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message'] ?? "Gagal mengirim ulang OTP"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white, title: const Text("Verifikasi OTP")),
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
                    "Verifikasi Kode OTP",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kami telah mengirim kode ke alamat email ${widget.email ?? 'Anda'}.\nKode ini hanya berlaku selama 5 menit.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Form(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildOtpBox(context, _pin1Controller,
                                first: true, last: false),
                            _buildOtpBox(context, _pin2Controller,
                                first: false, last: false),
                            _buildOtpBox(context, _pin3Controller,
                                first: false, last: false),
                            _buildOtpBox(context, _pin4Controller,
                                first: false, last: true),
                          ],
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleVerifyOtp,
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
                              : const Text("Verifikasi"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  _isResending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Color(0xFFFF7643), strokeWidth: 2))
                      : TextButton(
                          onPressed: _handleResendOtp,
                          child: const Text("Kirim Ulang Kode OTP",
                              style: TextStyle(
                                  color: Color(0xFFFF7643),
                                  fontWeight: FontWeight.bold)),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context, TextEditingController controller,
      {required bool first, required bool last}) {
    return SizedBox(
      height: 64,
      width: 64,
      child: TextFormField(
        controller: controller,
        onChanged: (pin) {
          if (pin.isNotEmpty && !last) FocusScope.of(context).nextFocus();
          if (pin.isEmpty && !first) FocusScope.of(context).previousFocus();
        },
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: "0",
          hintStyle: const TextStyle(color: Color(0xFFD8D8D8)),
          border: authOutlineInputBorder,
          enabledBorder: authOutlineInputBorder,
          focusedBorder: authOutlineInputBorder.copyWith(
            borderSide: const BorderSide(color: Color(0xFFFF7643), width: 2),
          ),
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(12)),
);
