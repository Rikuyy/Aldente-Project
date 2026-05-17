import 'package:cookcase_plus/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key});

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _chatHistory = [];
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final Map<String, dynamic> _userContext = {
    'nama': 'Budi',
    'stokBahan': ['telur', 'mie', 'bawang merah', 'cabai'],
    'sisaBudget': 45000,
    'totalBudget': 150000,
  };

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final stok = (_userContext['stokBahan'] as List).join(', ');
    final persen =
        ((_userContext['sisaBudget'] / _userContext['totalBudget']) * 100)
            .toStringAsFixed(0);

    setState(() {
      _messages.add(ChatMessage(
        text: 'Halo ${_userContext['nama']}! 👋\n\n'
            'Stok kamu sekarang: $stok.\n'
            'Budget tersisa: Rp ${_userContext['sisaBudget']} ($persen%).\n\n'
            'Mau masak apa hari ini, atau perlu saran jajan?',
        isUser: false,
      ));
    });
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true));
      _messages.add(ChatMessage.loading());
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    _chatHistory.add({'role': 'user', 'text': trimmed});

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/consultation'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'message': trimmed,
          'history': _chatHistory.length > 1
              ? _chatHistory.sublist(0, _chatHistory.length - 1)
              : [],
          'context': _userContext,
        }),
      );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      final data = jsonDecode(response.body);
      final botReply = data['reply'] ?? 'Maaf, aku tidak bisa menjawab itu.';

      _chatHistory.add({'role': 'model', 'text': botReply});

      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(text: botReply, isUser: false));
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

  // Auto-scroll ke bawah setiap ada pesan baru
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
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
                    const Text('Ruang Konsultasi',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.slate800,
                            letterSpacing: -0.5)),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppTheme.green500, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text('ONLINE',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.green500,
                                letterSpacing: 1)),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.go('/app/profile'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.orange100,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.orange200, width: 2),
                    ),
                    child: const Center(
                      child: Text('B',
                          style: TextStyle(
                              color: AppTheme.orange600,
                              fontWeight: FontWeight.w900,
                              fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppTheme.slate100),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: msg.isUser
                      ? _UserMessage(text: msg.text)
                      : _BotMessage(
                          child: _buildBotContent(msg),
                        ),
                );
              },
            ),
          ),

          _buildQuickChips(),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildBotContent(ChatMessage msg) {
    if (msg.status == MessageStatus.loading) {
      return const Row(
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
      );
    }

    // Pesan error
    if (msg.status == MessageStatus.error) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg.text,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      msg.text,
      style: const TextStyle(
        color: AppTheme.slate700,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.6,
      ),
    );
  }

// ─────────────────────────────────────────
// Helper: Input bar
// ─────────────────────────────────────────
  Widget _buildInputBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 6, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: AppTheme.slate100.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppTheme.slate200, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _sendMessage,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Ketik pertanyaan...',
                  hintStyle: TextStyle(
                      color: AppTheme.slate400, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                ),
              ),
            ),
            // ✅ Tombol kirim — sekarang fungsional
            GestureDetector(
              onTap: () => _sendMessage(_textController.text),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isLoading ? AppTheme.slate300 : AppTheme.orange500,
                  shape: BoxShape.circle,
                  boxShadow: _isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: AppTheme.orange500.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
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
    );
  }

  Widget _buildQuickChips() {
    final chips = [
      {
        'label': '🍳 Lihat Rekomendasi Masak',
        'message':
            'Berikan rekomendasi masakan dari stok bahan yang aku punya sekarang',
        'color': AppTheme.orange50,
        'textColor': const Color(0xFF9A3412),
        'borderColor': AppTheme.orange200,
      },
      {
        'label': '💰 Cek Budget Hari Ini',
        'message':
            'Cek budget harian aku dan berikan saran apakah sebaiknya masak atau beli makan',
        'color': AppTheme.blue50,
        'textColor': AppTheme.blue700,
        'borderColor': AppTheme.blue100,
      },
      {
        'label': '📦 Info Stok Saya',
        'message':
            'Tampilkan stok bahan yang aku punya dan apa yang bisa dimasak dari bahan tersebut',
        'color': AppTheme.green50,
        'textColor': AppTheme.green600,
        'borderColor': const Color(0xFFBBF7D0),
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips.map((chip) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _QuickChip(
                label: chip['label'] as String,
                color: chip['color'] as Color,
                textColor: chip['textColor'] as Color,
                borderColor: chip['borderColor'] as Color,
                onTap: () => _sendMessage(chip['message'] as String),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
} // end _ConsultationPageState

class _BotMessage extends StatelessWidget {
  final Widget child;
  const _BotMessage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
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
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
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
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
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
          boxShadow: [
            BoxShadow(
                color: AppTheme.orange600.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.5)),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const _QuickChip({
    required this.label,
    required this.color,
    required this.textColor,
    required this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
      ),
    );
  }
}
