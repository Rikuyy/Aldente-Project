import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

class GuestModePage extends StatefulWidget {
  const GuestModePage({super.key});

  @override
  State<GuestModePage> createState() => _GuestModePageState();
}

class _GuestModePageState extends State<GuestModePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  int _botMessageCount = 0;

  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'model',
      'text':
          'Halo! Saya asisten CookCase+ kamu. Ada yang bisa saya bantu untuk rencana makan hari ini?',
      'showCTA': false,
      'isWelcome': true,
    });
  }

  bool _shouldShowCTA(int botCount) => botCount % 2 == 0 && botCount > 0;
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  int _botMessageCount = 0; // counter pesan bot

  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  // CTA muncul setiap kelipatan 2 pesan bot
  bool _shouldShowCTA(int botCount) => botCount % 2 == 0;

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _messages.add({'role': 'loading'});
      _messages.add({'role': 'loading', 'text': ''});
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // History tanpa pesan loading terakhir
    final history = _messages
        .where((m) => m['role'] == 'user' || m['role'] == 'model')
        .map((m) => {'role': m['role'], 'text': m['text']})
        .toList();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/consultation'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': userMessage,
          'history':
              history.length > 1 ? history.sublist(0, history.length - 1) : [],
          'context': {
            'nama': 'Tamu',
            'stokBahan': [],
            'sisaBudget': 15000,
            'totalBudget': 15000,
          },
        }),
      );

      final data = jsonDecode(response.body);
      final botReply = data['reply'] ?? 'Maaf, aku tidak bisa menjawab itu.';
      final List<dynamic>? recommendations = data['recommendations'];

      _botMessageCount++;
      final showCTA = _shouldShowCTA(_botMessageCount);

      setState(() {
        _messages.removeLast();
        _messages.removeLast(); // hapus loading
        _messages.add({
          'role': 'model',
          'text': botReply,
          'showCTA': showCTA,
          'recommendations': recommendations,
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({
          'role': 'model',
          'text': 'Waduh, ada gangguan koneksi nih. Coba lagi ya! 🙏',
          'showCTA': false,
        });
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Column(
        children: [
          // HEADER
          Container(
            color: context.colors.cardBackground,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 24,
              right: 24,
              bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'CookCase+',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.slate800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.auto_awesome,
                            color: AppTheme.orange500, size: 20),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ruang Konsultasi Cerdas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.slate500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => context.push('/sign_in'),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: AppTheme.orange600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: () => context.push('/sign_up'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.orange500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                      'CookCash',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: context.colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.auto_awesome, color: AppTheme.orange500, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ruang Konsultasi Cerdas',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colors.surface,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.border),

          // CHAT AREA
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final role = msg['role'] as String;

                // Loading bubble
                if (role == 'loading') {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: _ChatBubble(
                      isBot: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.orange500,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'ChefBot sedang mengetik...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.slate400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // User bubble
                if (role == 'user') {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF97316), Color(0xFFEA580C)],
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
                              color: AppTheme.orange600.withValues(alpha: 51),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          msg['text'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            fontSize: 14,
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                _ChatBubble(
                  isBot: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Halo!',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.slate900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Saya asisten CookCash kamu. Ada yang bisa saya bantu untuk rencana makan hari ini?',
                        style: TextStyle(color: context.colors.textPrimary, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                          color: AppTheme.orange600.withValues(alpha: 51),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Rekomendasi menu untuk makan siang dengan budget 15 ribu',
                      style: TextStyle(color: context.colors.cardBackground, fontWeight: FontWeight.w500, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _ChatBubble(
                  isBot: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tentu! Dengan budget Rp15.000, kamu bisa mempertimbangkan menu berikut:',
                        style: TextStyle(color: context.colors.textPrimary, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      const _MenuOption(icon: Icons.restaurant, title: 'Nasi Telur Pontianak + Es Teh', subtitle: '(Masak di kos)'),
                      const SizedBox(height: 6),
                      const _MenuOption(icon: Icons.ramen_dining, title: 'Mie Dok-Dok Ala Warkop'),
                      const SizedBox(height: 6),
                      const _MenuOption(icon: Icons.rice_bowl, title: 'Beli Nasi Warteg', subtitle: '(Sayur 2 macem, Telur, dan Tempe Orek)'),
                      const SizedBox(height: 16),
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
                                      color: AppTheme.orange600.withValues(alpha: 76.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Yuk, Login!',
                                      style: TextStyle(
                                        color: context.colors.cardBackground,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.arrow_forward, color: context.colors.cardBackground, size: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Bot bubble
                final bool showRecommendations =
                    msg['recommendations'] != null &&
                        (msg['recommendations'] as List).isNotEmpty;
                final bool showCTA = msg['showCTA'] == true;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ChatBubble(
                    isBot: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: const TextStyle(
                            color: AppTheme.slate700,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                        if (showRecommendations) ...[
                          const SizedBox(height: 12),
                          ...(msg['recommendations'] as List)
                              .map<Widget>((rec) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _MenuOption(
                                icon: Icons.restaurant,
                                title: rec['nama'] ?? rec.toString(),
                                subtitle: rec['deskripsi'] ?? '',
                              ),
                            );
                          }),
                        ],
                        if (showCTA) ...[
                          const SizedBox(height: 16),
                          _buildLoginCTA(context),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // INPUT AREA
          Container(
            color: context.colors.cardBackground,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.slate100.withValues(alpha: 0.8),
                color: context.colors.border,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Ketik pertanyaanmu di sini...',
                        hintStyle: TextStyle(
                          color: AppTheme.slate400,
                          fontWeight: FontWeight.w500,
                        ),
                        hintStyle: TextStyle(color: context.colors.textHint, fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            _isLoading ? AppTheme.slate300 : AppTheme.orange500,
                        shape: BoxShape.circle,
                        boxShadow: _isLoading
                            ? []
                            : [
                                BoxShadow(
                                  color:
                                      AppTheme.orange500.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Icon(
                        _isLoading
                            ? Icons.hourglass_empty_rounded
                            : Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const Icon(Icons.send_rounded, color: AppTheme.orange500, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCTA(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/sign_in'),
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
                    color: AppTheme.orange600.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: isBot
                  ? Colors.black.withValues(alpha: 0.04)
                  : AppTheme.orange600.withValues(alpha: 0.2),
              blurRadius: isBot ? 10 : 12,
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
  final IconData icon;
  final String title;
  final String? subtitle;
  const _MenuOption({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.slate600),
        Icon(icon, size: 16, color: context.colors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppTheme.slate800,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.slate500,
                  ),
                ),
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.colors.textPrimary)),
              if (subtitle != null)
                Text(subtitle!, style:  TextStyle(fontSize: 12, color: context.colors.surface)),
            ],
          ),
        ),
      ],
    );
  }
}
