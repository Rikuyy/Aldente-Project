import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 24, right: 24, bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ruang Konsultasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.slate800, letterSpacing: -0.5)),
                    Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: AppTheme.green500, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text('ONLINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.green500, letterSpacing: 1)),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.go('/app/profile'),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.orange100,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.orange200, width: 2),
                    ),
                    child: const Center(
                      child: Text('B', style: TextStyle(color: AppTheme.orange600, fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.slate100),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _BotMessage(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Halo Budi! 👋', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.slate900, letterSpacing: -0.3)),
                      SizedBox(height: 6),
                      Text('Hari ini kamu punya stok telur dan mie. Mau masak atau cari saran jajan?', style: TextStyle(color: AppTheme.slate600, fontSize: 13, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _UserMessage(text: 'Tolong cari resep dari bahan yang ada'),
                const SizedBox(height: 12),
                _BotMessage(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sip! Dengan bahan Telur dan Mie, kamu bisa bikin Mie Nyemek Telur Pedas.', style: TextStyle(color: AppTheme.slate600, fontSize: 13, height: 1.5)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.slate50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.slate100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.check_circle_rounded, color: AppTheme.green500, size: 16),
                                SizedBox(width: 6),
                                Text('Estimasi Biaya: Rp 0', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.slate800)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text('Karena semua bahan sudah ada di stokmu.', style: TextStyle(fontSize: 11, color: AppTheme.slate500, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.slate200, width: 2),
                              ),
                              child: const Text('Lihat Resep Lengkap', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.slate700)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 6, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: AppTheme.slate100.withOpacity(0.8),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppTheme.slate200, width: 2),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ketik pertanyaan...',
                        hintStyle: TextStyle(color: AppTheme.slate400, fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.orange500,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotMessage extends StatelessWidget {
  final Widget child;
  const _BotMessage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          border: Border.all(color: AppTheme.slate100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: child,
      ),
    );
  }
}

class _UserMessage extends StatelessWidget {
  final String text;
  const _UserMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEA580C), Color(0xFFDC4E0A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14, height: 1.5)),
      ),
    );
  }
}
