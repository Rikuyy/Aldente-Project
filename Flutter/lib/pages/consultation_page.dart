import '../models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'dart:convert';

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
  bool _isLoadingUser = true;

  // Data user — diisi dari API
  String _nama = 'Cookmate';
  String _inisial = 'C';
  num _sisaBudget = 0;
  num _totalBudget = 0;
  num _overBudget = 0;
  bool _isOverBudget = false;

  @override
  void initState() {
    super.initState();
    _userContext(); // nama method tetap sesuai milikmu
  }

  // Fetch data user login dari API
  Future<void> _userContext() async {
    try {
      final userData = await ApiService.get('/me');
      final budgetData = await ApiService.get('/budget/balance');
      if (!mounted) return;
      setState(() {
        _nama = userData['Username'] ?? userData['name'] ?? 'Cookmate';
        _totalBudget =
            budgetData['total_budget'] ?? userData['Budget_Bulanan'] ?? 0;
        _sisaBudget = budgetData['sisa_budget'] ?? 0;
        _overBudget = budgetData['over_budget'] ?? 0;
        _isOverBudget = budgetData['is_over_budget'] ?? false;
        _inisial = _nama.isNotEmpty ? _nama[0].toUpperCase() : 'C';
        _isLoadingUser = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingUser = false);
    }
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final budgetInfo = _isOverBudget
        ? '⚠️ Budget bulan ini sudah terlampaui Rp $_overBudget dari Rp $_totalBudget.'
        : 'Sisa budget bulan ini: Rp $_sisaBudget dari Rp $_totalBudget.';
    setState(() {
      _messages.add(ChatMessage(
        text: 'Halo $_nama! 👋\n\n'
            '$budgetInfo\n\n'
            'Mau masak apa hari ini, atau perlu saran hemat?',
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
      final token = await ApiService.getToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/consultation'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': trimmed,
          'history': historyToSend,
          'context': {
            'sisaBudget': _sisaBudget,
            'totalBudget': _totalBudget,
          },
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
        _messages.add(const ChatMessage(
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

  // Dipanggil saat user konfirmasi ganti jadwal dari _GantiJadwalSheet.
  // Data pengganti diteruskan ke TodoPage lewat Navigator.pop result.
  void _handleGantiJadwal(Map<String, dynamic> result) {
    // Pop ConsultationPage sambil membawa data pengganti ke TodoPage.
    // Karena TodoPage membuka halaman ini via Navigator.push (bukan go_router),
    // Navigator.of(context).pop(result) sudah cukup untuk mengembalikan data.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
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
                    child: Center(
                      child: _isLoadingUser
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.orange500,
                              ),
                            )
                          : Text(
                              _inisial,
                              style: const TextStyle(
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
      return const Row(
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
      return _RecipeCards(
        recipes: msg.recipes!,
        onGantiJadwal: _handleGantiJadwal,
      );
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
// Kartu Resep — ringkas + tombol detail + ganti jadwal
// ─────────────────────────────────────────

class _RecipeCards extends StatelessWidget {
  final List recipes;
  final void Function(Map<String, dynamic> result)? onGantiJadwal;
  const _RecipeCards({required this.recipes, this.onGantiJadwal});

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
              // Kanan: badge % cocok + tombol detail + ganti jadwal
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
                  const SizedBox(height: 8),
                  // ── Tombol Ganti Jadwal ──
                  GestureDetector(
                    onTap: () => _showGantiJadwalSheet(context, recipe),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        size: 18,
                        color: Color(0xFF1D4ED8),
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

  void _showGantiJadwalSheet(BuildContext context, Map recipe) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GantiJadwalSheet(recipe: recipe),
    );
    if (result != null && context.mounted) {
      onGantiJadwal?.call(result);
    }
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

// ─────────────────────────────────────────
// Bottom Sheet — Ganti Jadwal Makan
// ─────────────────────────────────────────

class _GantiJadwalSheet extends StatefulWidget {
  final Map recipe; // resep dari hasil rekomendasi chatbot

  const _GantiJadwalSheet({required this.recipe});

  @override
  State<_GantiJadwalSheet> createState() => _GantiJadwalSheetState();
}

class _GantiJadwalSheetState extends State<_GantiJadwalSheet> {
  bool _isLoading = true;
  String? _errorMsg;

  /// Daftar sesi hari ini dari API generate
  List<Map<String, dynamic>> _sesiList = [];

  /// Indeks sesi yang dipilih user
  int? _selectedIndex;

  /// Sedang proses konfirmasi
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _fetchJadwal();
  }

  Future<void> _fetchJadwal() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final tanggal = DateTime.now().toIso8601String().substring(0, 10);
      final data = await ApiService.get('/jadwal/generate?tanggal=$tanggal');
      final List items = data['data'] ?? [];

      setState(() {
        _sesiList = items.map<Map<String, dynamic>>((item) {
          final resep = item['resep'] as Map? ?? {};
          return {
            'sesi': item['sesi'] ?? '',
            'sesi_ke': item['sesi_ke'] ?? 0,
            'id_jadwal': item['id_jadwal'],
            'is_done': item['is_done'] ?? false,
            'resep_title': resep['title'] ?? '-',
            'resep_category': resep['category'] ?? '',
            'resep_id': resep['id'] ?? '',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal memuat jadwal. Coba lagi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _konfirmasiGanti() async {
    if (_selectedIndex == null) return;
    final sesi = _sesiList[_selectedIndex!];

    // Tampilkan dialog konfirmasi sebelum benar-benar mengganti.
    // useRootNavigator: false wajib agar pop dari dialog tidak
    // "menular" ke showModalBottomSheet yang menunggu di atasnya.
    final ok = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Konfirmasi Penggantian',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppTheme.slate700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu pada sesi ini akan diganti:',
              style: TextStyle(fontSize: 13, color: AppTheme.slate700),
            ),
            const SizedBox(height: 12),
            // Dari
            _ConfirmRow(
              label: 'Sesi',
              value: sesi['sesi'] as String,
              icon: Icons.access_time_rounded,
              color: AppTheme.orange500,
            ),
            const SizedBox(height: 6),
            _ConfirmRow(
              label: 'Menu lama',
              value: sesi['resep_title'] as String,
              icon: Icons.restaurant_rounded,
              color: AppTheme.slate400,
              strikethrough: true,
            ),
            const SizedBox(height: 6),
            _ConfirmRow(
              label: 'Menu baru',
              value: widget.recipe['title'] ?? '-',
              icon: Icons.auto_awesome_rounded,
              color: AppTheme.green500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Batal', style: TextStyle(color: AppTheme.slate400)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Ganti Sekarang',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _isConfirming = true);

    // Tutup bottom sheet sambil membawa data pengganti ke TodoPage.
    // TodoPage cukup update local state-nya — tidak perlu API tambahan.
    if (!mounted) return;
    Navigator.of(context).pop({
      'sesi_ke': sesi['sesi_ke'] as int,
      'sesi_label': sesi['sesi'] as String,
      'resep': {
        'id': widget.recipe['id'] ?? '',
        'title': widget.recipe['title'] ?? '-',
        'ingredients': widget.recipe['ingredients'] ?? '',
        'steps': widget.recipe['steps'] ?? '',
        'category': widget.recipe['category'] ?? '',
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeTitle = widget.recipe['title'] ?? '-';
    final recipeCategory = widget.recipe['category'] ?? '';

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
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
              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.swap_horiz_rounded,
                            color: Color(0xFF1D4ED8),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ganti Menu Jadwal',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.slate700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Pilih sesi yang ingin diganti',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.slate400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Kartu resep yang akan dipasang
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.orange50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.orange200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: AppTheme.orange500, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Menu pengganti dari rekomendasi:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.orange600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  recipeTitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.slate700,
                                  ),
                                ),
                                if (recipeCategory.isNotEmpty)
                                  Text(
                                    recipeCategory,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.slate400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Jadwal makan hari ini:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.slate700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Daftar sesi
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.orange500))
                    : _errorMsg != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppTheme.slate400, size: 36),
                                const SizedBox(height: 8),
                                Text(_errorMsg!,
                                    style: const TextStyle(
                                        color: AppTheme.slate400,
                                        fontSize: 13)),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _fetchJadwal,
                                  child: const Text('Coba Lagi',
                                      style:
                                          TextStyle(color: AppTheme.orange500)),
                                ),
                              ],
                            ),
                          )
                        : _sesiList.isEmpty
                            ? const Center(
                                child: Text(
                                  'Belum ada jadwal untuk hari ini.',
                                  style: TextStyle(
                                      color: AppTheme.slate400, fontSize: 13),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding:
                                    const EdgeInsets.fromLTRB(24, 0, 24, 16),
                                itemCount: _sesiList.length,
                                itemBuilder: (_, idx) {
                                  final sesi = _sesiList[idx];
                                  final isDone =
                                      sesi['is_done'] as bool? ?? false;
                                  final isSelected = _selectedIndex == idx;

                                  return GestureDetector(
                                    onTap: isDone
                                        ? null
                                        : () => setState(
                                            () => _selectedIndex = idx),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? AppTheme.slate100
                                            : isSelected
                                                ? const Color(0xFFEFF6FF)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDone
                                              ? AppTheme.slate200
                                              : isSelected
                                                  ? const Color(0xFF93C5FD)
                                                  : AppTheme.slate200,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Radio indicator
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isDone
                                                  ? AppTheme.slate200
                                                  : isSelected
                                                      ? const Color(0xFF1D4ED8)
                                                      : Colors.white,
                                              border: Border.all(
                                                color: isDone
                                                    ? AppTheme.slate300
                                                    : isSelected
                                                        ? const Color(
                                                            0xFF1D4ED8)
                                                        : AppTheme.slate300,
                                                width: 2,
                                              ),
                                            ),
                                            child: isSelected
                                                ? const Icon(Icons.check,
                                                    size: 13,
                                                    color: Colors.white)
                                                : null,
                                          ),
                                          const SizedBox(width: 12),

                                          // Info sesi
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: isDone
                                                            ? AppTheme.slate200
                                                            : AppTheme.orange50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: isDone
                                                                ? AppTheme
                                                                    .slate300
                                                                : AppTheme
                                                                    .orange200),
                                                      ),
                                                      child: Text(
                                                        sesi['sesi'] as String,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: isDone
                                                              ? AppTheme
                                                                  .slate400
                                                              : AppTheme
                                                                  .orange600,
                                                        ),
                                                      ),
                                                    ),
                                                    if (isDone) ...[
                                                      const SizedBox(width: 6),
                                                      const Icon(
                                                          Icons
                                                              .check_circle_rounded,
                                                          size: 13,
                                                          color: AppTheme
                                                              .green500),
                                                      const SizedBox(width: 3),
                                                      const Text(
                                                        'Sudah selesai',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: AppTheme
                                                                .green500,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  sesi['resep_title'] as String,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDone
                                                        ? AppTheme.slate400
                                                        : AppTheme.slate700,
                                                    decoration: isDone
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : null,
                                                  ),
                                                ),
                                                if ((sesi['resep_category']
                                                        as String)
                                                    .isNotEmpty)
                                                  Text(
                                                    sesi['resep_category']
                                                        as String,
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            AppTheme.slate400),
                                                  ),
                                              ],
                                            ),
                                          ),

                                          if (!isDone)
                                            Icon(
                                              Icons.swap_horiz_rounded,
                                              size: 18,
                                              color: isSelected
                                                  ? const Color(0xFF1D4ED8)
                                                  : AppTheme.slate300,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),

              // Tombol konfirmasi
              Padding(
                padding: EdgeInsets.fromLTRB(
                    24, 8, 24, MediaQuery.of(context).padding.bottom + 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_selectedIndex == null || _isConfirming)
                        ? null
                        : _konfirmasiGanti,
                    icon: _isConfirming
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: Text(
                      _isConfirming ? 'Mengganti...' : 'Ganti Menu Ini',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndex == null
                          ? AppTheme.slate200
                          : const Color(0xFF1D4ED8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.slate200,
                      disabledForegroundColor: AppTheme.slate400,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// Row kecil di dialog konfirmasi
// ─────────────────────────────────────────

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool strikethrough;

  const _ConfirmRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.strikethrough = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: AppTheme.slate700),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slate400,
                      fontSize: 12),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    decoration: strikethrough
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
