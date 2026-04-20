import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class GuestModePage extends StatelessWidget {
  const GuestModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 24,
              right: 24,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'CookCase+',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.slate800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.auto_awesome, color: AppTheme.orange500, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ruang Konsultasi Cerdas',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.slate500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.slate100),

          // Chat area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Bot message 1
                _ChatBubble(
                  isBot: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Halo!',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.slate900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Saya asisten CookCase+ kamu. Ada yang bisa saya bantu untuk rencana makan hari ini?',
                        style: TextStyle(color: AppTheme.slate800, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // User message
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), AppTheme.orange600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.orange600.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Rekomendasi menu untuk makan siang dengan budget 15 ribu',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bot reply with CTA
                _ChatBubble(
                  isBot: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tentu! Dengan budget Rp15.000, kamu bisa mempertimbangkan menu berikut:',
                        style: TextStyle(color: AppTheme.slate700, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      _MenuOption(emoji: '🍳', title: 'Nasi Telur Pontianak + Es Teh', subtitle: '(Masak di kos)'),
                      const SizedBox(height: 6),
                      _MenuOption(emoji: '🍜', title: 'Mie Dok-Dok Ala Warkop'),
                      const SizedBox(height: 6),
                      _MenuOption(emoji: '🍛', title: 'Beli Nasi Warteg', subtitle: '(Sayur 2 macem, Telur, dan Tempe Orek)'),
                      const SizedBox(height: 16),

                      // CTA Card
                      GestureDetector(
                        onTap: () => context.go('/onboarding'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.orange50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.orange200, width: 2),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Butuh rekomendasi lebih akurat?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF431407),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Dapatkan rencana makan yang disesuaikan dengan isi kulkas dan seleramu.',
                                style: TextStyle(
                                  color: Color(0xFF9A3412),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.orange600,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.orange600.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'Yuk, Login!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Input area
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.slate100,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppTheme.slate200),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ketik pertanyaanmu di sini...',
                        hintStyle: TextStyle(color: AppTheme.slate400, fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.send_rounded, color: AppTheme.orange500, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isBot;
  final Widget child;
  const _ChatBubble({required this.isBot, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: AppTheme.slate100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  const _MenuOption({required this.emoji, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.slate800)),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppTheme.slate500)),
            ],
          ),
        ),
      ],
    );
  }
}
