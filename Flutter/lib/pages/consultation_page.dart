import '../models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key});

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _chatHistory = [];
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

    final historyToSend = List<Map<String, String>>.from(_chatHistory);

    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true));
      _messages.add(ChatMessage.loading());
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/consultation'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': trimmed,
          'history': historyToSend,
          'context': _userContext,
        }),
      );

      final data = jsonDecode(response.body);
      final intent = data['intent'] ?? 'chat';

      if (intent == 'recommendation') {
        final List recipes = data['recipes'] ?? [];
        final String replyText =
            data['reply'] ?? 'Ini beberapa resep yang cocok!';

        _chatHistory.add({'role': 'user', 'content': trimmed});
        _chatHistory.add({'role': 'model', 'content': replyText});

        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(text: replyText, isUser: false));
          if (recipes.isNotEmpty) {
            _messages.add(ChatMessage.recipes(recipes));
          }
          _isLoading = false;
        });
      } else {
        final String botReply =
            data['reply'] ?? 'Maaf, aku tidak bisa menjawab itu.';

        _chatHistory.add({'role': 'user', 'content': trimmed});
        _chatHistory.add({'role': 'model', 'content': botReply});

        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(text: botReply, isUser: false));
          _isLoading = false;
        });
      }
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
    _textController.dispose();
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
                    Text(
                      'Ruang Konsultasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: context.colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.green500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ONLINE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.green500,
                            letterSpacing: 1,
                          ),
                        ),
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
                      child: Text(
                        'B',
                        style: TextStyle(
                          color: AppTheme.orange600,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
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
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: msg.isUser
                      ? _UserMessage(text: msg.text)
                      : _BotMessage(child: _buildBotContent(msg)),
                );
              },
            ),
          ),

          _buildQuickChips(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBotContent(ChatMessage msg) {
    if (msg.status == MessageStatus.loading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
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
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    if (msg.status == MessageStatus.error) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg.text,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      );
    }

    if (msg.status == MessageStatus.recipes && msg.recipes != null) {
      return _RecipeCards(recipes: msg.recipes!);
    }

    return Text(
      msg.text,
      style: const TextStyle(
          color: AppTheme.slate700,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.6),
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

  Widget _buildInputBar() {
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
          color: AppTheme.slate100.withOpacity(0.8),
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
                            color: AppTheme.orange500.withOpacity(0.3),
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
    );
  }
}

// ─────────────────────────────────────────
// Kartu Resep — ringkas + tombol detail
// ─────────────────────────────────────────

class _RecipeCards extends StatelessWidget {
  final List recipes;
  const _RecipeCards({required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(recipes.length, (i) {
        final recipe = recipes[i];
        final title = recipe['title'] ?? '-';
        final category = recipe['category'] ?? '';
        final score = (recipe['score'] ?? 0.0) as num;
        final persen = (score * 100).toStringAsFixed(0);
        final totalIngredients = recipe['total_ingredients'] ?? 0;
        final totalSteps = recipe['total_steps'] ?? 0;
        final loves = recipe['loves'] ?? 0;

        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.orange200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Info kiri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.slate700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Baris info: kategori · bahan · steps · loves
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (category.isNotEmpty)
                          _InfoChip(
                              icon: Icons.label_outline,
                              label: category,
                              color: AppTheme.orange100,
                              textColor: AppTheme.orange600),
                        _InfoChip(
                            icon: Icons.kitchen_outlined,
                            label: '$totalIngredients bahan',
                            color: AppTheme.slate100,
                            textColor: AppTheme.slate700),
                        _InfoChip(
                            icon: Icons.format_list_numbered_rounded,
                            label: '$totalSteps langkah',
                            color: AppTheme.slate100,
                            textColor: AppTheme.slate700),
                        _InfoChip(
                            icon: Icons.favorite_rounded,
                            label: '$loves',
                            color: const Color(0xFFFFE4E6),
                            textColor: const Color(0xFFE11D48)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Kanan: badge % cocok + tombol detail
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.orange500,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$persen%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showRecipeDetail(context, recipe),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.orange50,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.orange200),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 18,
                        color: AppTheme.orange600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showRecipeDetail(BuildContext context, Map recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecipeDetailSheet(recipe: recipe),
    );
  }
}

// ─────────────────────────────────────────
// Info chip kecil di kartu
// ─────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  const _InfoChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Bottom Sheet — Detail Resep Lengkap
// ─────────────────────────────────────────

class _RecipeDetailSheet extends StatelessWidget {
  final Map recipe;
  const _RecipeDetailSheet({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final title = recipe['title'] ?? '-';
    final category = recipe['category'] ?? '';
    final score = (recipe['score'] ?? 0.0) as num;
    final loves = recipe['loves'] ?? 0;
    final persen = (score * 100).toStringAsFixed(0);
    final ingredients = recipe['ingredients'] ?? '';

    // Steps: bisa List atau String
    final dynamic rawSteps = recipe['steps'];
    List<String> stepsList = [];
    if (rawSteps is List) {
      stepsList = rawSteps.map((s) => s.toString()).toList();
    } else if (rawSteps is String && rawSteps.isNotEmpty) {
      stepsList = rawSteps
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.slate200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  children: [
                    // ── Header ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.slate700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  if (category.isNotEmpty)
                                    _InfoChip(
                                        icon: Icons.label_outline,
                                        label: category,
                                        color: AppTheme.orange100,
                                        textColor: AppTheme.orange600),
                                  _InfoChip(
                                      icon: Icons.favorite_rounded,
                                      label: '$loves disukai',
                                      color: const Color(0xFFFFE4E6),
                                      textColor: const Color(0xFFE11D48)),
                                  _InfoChip(
                                      icon: Icons.auto_awesome_rounded,
                                      label: '$persen% cocok',
                                      color: AppTheme.orange50,
                                      textColor: AppTheme.orange600),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const _SectionTitle(
                        icon: Icons.kitchen_outlined, label: 'Bahan-bahan'),
                    const SizedBox(height: 10),

                    // ── Bahan ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.orange50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.orange200),
                      ),
                      child: _buildIngredientsList(ingredients.toString()),
                    ),

                    const SizedBox(height: 24),
                    _SectionTitle(
                      icon: Icons.format_list_numbered_rounded,
                      label: 'Langkah Memasak (${stepsList.length})',
                    ),
                    const SizedBox(height: 10),

                    // ── Steps ──
                    if (stepsList.isEmpty)
                      const Text(
                        'Langkah memasak tidak tersedia.',
                        style:
                            TextStyle(color: AppTheme.slate400, fontSize: 13),
                      )
                    else
                      ...List.generate(stepsList.length, (i) {
                        // Bersihkan prefix "1)" atau "1." yang sudah ada
                        final raw = stepsList[i];
                        final cleaned = raw
                            .replaceFirst(RegExp(r'^\d+[\)\.]\s*'), '')
                            .trim();
                        return _StepTile(
                            number: i + 1,
                            text: cleaned.isEmpty ? raw : cleaned);
                      }),

                    const SizedBox(height: 32),

                    // ── Tombol Tutup ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        label: const Text(
                          'Tutup',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.orange500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIngredientsList(String raw) {
    // Pisahkan bahan berdasarkan koma, tampilkan tiap bahan sebagai baris
    final items =
        raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.orange500,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.slate700,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────
// Step tile bernomor
// ─────────────────────────────────────────

class _StepTile extends StatelessWidget {
  final int number;
  final String text;
  const _StepTile({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor langkah
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.orange500,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Teks langkah
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.slate100.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.slate700,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Section title
// ─────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.orange500),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.slate700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Widget pendukung
// ─────────────────────────────────────────

class _BotMessage extends StatelessWidget {
  final Widget child;
  const _BotMessage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          border: Border.all(color: context.colors.border),
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
              color: AppTheme.orange600.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: context.colors.cardBackground,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;
  const _QuickChip({
    required this.label,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
