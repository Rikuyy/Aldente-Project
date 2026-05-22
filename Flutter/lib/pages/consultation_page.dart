import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Column(
        children: [
          Container(
            color: context.colors.cardBackground,
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
                    Text('Ruang Konsultasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5)),
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
           Divider(height: 1, color: context.colors.border),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _BotMessage(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('Halo Budi!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.slate900, letterSpacing: -0.3)),
                          SizedBox(width: 4),
                          Icon(Icons.waving_hand, size: 14, color: AppTheme.slate900),
                        ],
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13, height: 1.5),
                          children: const [
                            TextSpan(text: 'Hari ini kamu punya stok '),
                            TextSpan(text: 'telur', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.orange600, backgroundColor: Color(0xFFFFF7ED))),
                            TextSpan(text: ' dan '),
                            TextSpan(text: 'mie', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.orange600, backgroundColor: Color(0xFFFFF7ED))),
                            TextSpan(text: '. Mau masak atau cari saran jajan?'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.blue50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.blue100),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.article_outlined, color: AppTheme.blue500, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Berdasarkan budget sisa (30%), saya sarankan kamu Masak saja hari ini untuk berhemat.',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF), height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13, height: 1.5),
                          children: [
                            const TextSpan(text: 'Sip! Dengan bahan '),
                            TextSpan(text: 'Telur', style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                            const TextSpan(text: ' dan '),
                            TextSpan(text: 'Mie', style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                            const TextSpan(text: ', kamu bisa bikin '),
                            const TextSpan(text: 'Mie Nyemek Telur Pedas', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.orange600)),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppTheme.green500, size: 16),
                                const SizedBox(width: 6),
                                Text('Estimasi Biaya: Rp 0', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: context.colors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Karena semua bahan sudah ada di stokmu.', style: TextStyle(fontSize: 11, color: context.colors.surface, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: context.colors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: context.colors.border, width: 2),
                              ),
                              child: Text('Lihat Resep Lengkap', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: context.colors.textPrimary)),
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
            color: context.colors.cardBackground,
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
            child: const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickChip(label: 'Lihat Rekomendasi Masak', color: AppTheme.orange50, textColor: Color(0xFF9A3412), borderColor: AppTheme.orange200),
                  SizedBox(width: 8),
                  _QuickChip(label: 'Cek Budget Hari Ini', color: AppTheme.blue50, textColor: AppTheme.blue700, borderColor: AppTheme.blue100),
                  SizedBox(width: 8),
                  _QuickChip(label: 'Tambah Stok', color: AppTheme.green50, textColor: AppTheme.green600, borderColor: Color(0xFFBBF7D0)),
                ],
              ),
            ),
          ),

          Container(
            color: context.colors.cardBackground,
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 6, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: context.colors.border.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: context.colors.border, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ketik pertanyaan...',
                        hintStyle: TextStyle(color: context.colors.textHint, fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.orange500,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppTheme.orange500.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Icon(Icons.send_rounded, color: context.colors.cardBackground, size: 18),
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
          color: context.colors.cardBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          border: Border.all(color: context.colors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
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
          boxShadow: [BoxShadow(color: AppTheme.orange600.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Text(text, style: TextStyle(color: context.colors.cardBackground, fontWeight: FontWeight.w500, fontSize: 14, height: 1.5)),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Color borderColor;
  const _QuickChip({required this.label, required this.color, required this.textColor, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
    );
  }
}