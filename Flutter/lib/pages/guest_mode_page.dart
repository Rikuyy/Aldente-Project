<<<<<<< HEAD
import 'dart:convert'; // ← tambahkan import ini
=======
import 'dart:convert';
>>>>>>> 3dce3ded2007c2340c53492b0ffca3ec2144b212
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class GuestModePage extends StatefulWidget {
  const GuestModePage({super.key});

  @override
  State<GuestModePage> createState() => _GuestModePageState();
}

class _GuestModePageState extends State<GuestModePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  int _botMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text:
          'Halo! Saya asisten CookCash kamu. Ada yang bisa saya bantu untuk rencana makan hari ini?',
      isUser: false,
    ));
  }

  bool _shouldShowCTA() => _botMessageCount > 0 && _botMessageCount % 2 == 0;

  Future<void> _sendMessage(String text) async {
    final userMessage = text.trim();
    if (userMessage.isEmpty || _isLoading) return;

    final historyToSend = _messages
        .where((m) => m.status != MessageStatus.loading)
        .map((m) => {'role': m.isUser ? 'user' : 'model', 'text': m.text})
        .toList();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _messages.add(ChatMessage.loading());
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/consultation'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': userMessage,
          'history': historyToSend,
          'context': {
            'nama': 'Cookmate',
            'stokBahan': [],
            'sisaBudget': 0,
            'totalBudget': 0,
          },
        }),
      );

      final data = jsonDecode(response.body);
      final botReply = data['reply'] ?? 'Maaf, aku tidak bisa menjawab itu.';

      _botMessageCount++;
      final showCTA = _shouldShowCTA();

      setState(() {
        _messages.removeLast(); // hapus loading
        _messages.add(ChatMessage(text: botReply, isUser: false));
        if (showCTA) {
          _messages.add(ChatMessage(
            text: 'Butuh rekomendasi lebih akurat? Yuk login!',
            isUser: false,
          ));
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(
          text: 'Waduh, ada gangguan koneksi nih. Coba lagi ya! 🙏',
          isUser: false,
          status: MessageStatus.error,
        ));
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
          // Header
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
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'CookCash',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: context.colors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.auto_awesome,
                            color: AppTheme.orange500, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ruang Konsultasi Cerdas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textSecondary,
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
                            fontWeight: FontWeight.bold),
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
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Daftar',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.slate100),

          // Chat area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

                if (msg.status == MessageStatus.loading) {
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
                                strokeWidth: 2, color: AppTheme.orange500),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'ChefBot sedang mengetik...',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.slate400,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final isBot = !msg.isUser;
                final isCTA = isBot &&
                    msg.text.contains('Butuh rekomendasi lebih akurat?');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ChatBubble(
                    isBot: isBot,
                    child: msg.isUser
                        ? Text(
                            msg.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              fontSize: 14,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: const TextStyle(
                                  color: AppTheme.slate700,
                                  height: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                              if (isCTA) ...[
                                const SizedBox(height: 12),
                                _buildLoginCTA(context),
                              ],
                            ],
                          ),
                  ),
                );
              },
            ),
          ),

          // Input bar
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
                color: AppTheme.slate100.withOpacity(0.8),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppTheme.slate200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(_messageController.text),
                      decoration: const InputDecoration(
                        hintText: 'Ketik pertanyaanmu di sini...',
                        hintStyle: TextStyle(
                            color: AppTheme.slate400,
                            fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => _sendMessage(_messageController.text),
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
                                    color: AppTheme.orange500.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
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
                  fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Dapatkan rencana makan yang disesuaikan dengan isi kulkas dan seleramu.',
              style: TextStyle(
                  color: Color(0xFF9A3412),
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
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
                      offset: const Offset(0, 3))
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Yuk, Login!',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
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
          color: isBot ? context.colors.cardBackground : AppTheme.orange500,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: isBot ? Border.all(color: context.colors.border) : null,
          boxShadow: [
            BoxShadow(
              color: isBot
                  ? Colors.black.withOpacity(0.04)
                  : AppTheme.orange600.withOpacity(0.2),
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
