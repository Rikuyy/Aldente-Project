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
  int _botMessageCount = 0; // counter pesan bot

  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  // CTA muncul setiap kelipatan 2 pesan bot
  bool _shouldShowCTA(int botCount) => botCount % 2 == 0;

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
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

      _botMessageCount++;
      final showCTA = _shouldShowCTA(_botMessageCount);

      setState(() {
        _messages.removeLast(); // hapus loading
        _messages.add({
          'role': 'model',
          'text': botReply,
          'showCTA': showCTA,
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
            child: const Column(
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
          ),
          const Divider(height: 1, color: AppTheme.slate100),

          // Chat area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

                // Loading bubble
                if (msg['role'] == 'loading') {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16),
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

                final isBot = msg['role'] == 'model';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ChatBubble(
                    isBot: isBot,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(
                            color: isBot ? AppTheme.slate700 : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                          ),
                        ),
                        if (isBot && (msg['showCTA'] ?? false)) ...[
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
              padding:
                  const EdgeInsets.only(left: 20, right: 6, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: AppTheme.slate100.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppTheme.slate200, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pertanyaanmu di sini...',
                        hintStyle: TextStyle(
                          color: AppTheme.slate400,
                          fontWeight: FontWeight.w500,
                        ),
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
          color: isBot ? Colors.white : null,
          gradient: isBot
              ? null
              : const LinearGradient(
                  colors: [Color(0xFFEA580C), Color(0xFFDC4E0A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: isBot
              ? const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
          border: isBot ? Border.all(color: AppTheme.slate100) : null,
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
