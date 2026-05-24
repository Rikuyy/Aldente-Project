import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/theme_toggle.dart';
import '../main.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isLoading = false;

  String _username = '';
  String _email = '';
  String _originalUsername = '';
  String _originalEmail = '';
  int _eatFrequency = 3;
  int _budget = 0;
  int _originalBudget = 0;
  int _originalEatFrequency = 3;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  List<String> _availableCategories = [];
  List<String> _selectedCategories = [];
  List<String> _originalSelectedCategories = [];

  List<String> _allergies = [];
  List<String> _originalAllergies = [];

  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _budgetController.addListener(_formatBudgetInput);
    _fetchProfileFromBackend();
    _fetchCategories();
  }

  void _formatBudgetInput() {
    String raw = _budgetController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return;
    int value = int.parse(raw);
    String formatted = _formatRpValue(value);
    if (_budgetController.text != formatted) {
      _budgetController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  String _formatRpValue(int value) {
    if (value == 0) return '0';
    String stringValue = value.toString();
    String result = '';
    int length = stringValue.length;
    for (int i = 0; i < length; i++) {
      if ((length - i) % 3 == 0 && i != 0) result += '.';
      result += stringValue[i];
    }
    return result;
  }

  int _parseBudgetFromFormatted(String formatted) {
    return int.tryParse(formatted.replaceAll('.', '')) ?? 0;
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final response = await ApiService.get('/resep/categories');
      if (response['success'] == true && response['categories'] is List) {
        setState(() {
          _availableCategories = List<String>.from(response['categories']);
          _isLoadingCategories = false;
        });
      } else {
        throw Exception('Gagal memuat kategori');
      }
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      _showSnackBar('Gagal memuat kategori makanan', Colors.red);
    }
  }

  Future<void> _fetchProfileFromBackend() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        _showSnackBar('Sesi habis, silakan login kembali.', Colors.amber);
        return;
      }

      final url = Uri.parse('${ApiService.baseUrl}/profile');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final profile = data['data'];
          setState(() {
            _username = profile['username'] ?? '';
            _email = profile['email'] ?? '';
            _eatFrequency = profile['jumlah_makan'] ?? 3;
            _budget = (profile['budget_bulanan'] ?? 0).toInt();
            _selectedCategories =
                List<String>.from(profile['kategori_favorit'] ?? []);
            _allergies = List<String>.from(profile['alergi'] ?? []);

            _originalUsername = _username;
            _originalEmail = _email;
            _originalEatFrequency = _eatFrequency;
            _originalBudget = _budget;
            _originalSelectedCategories = List.from(_selectedCategories);
            _originalAllergies = List.from(_allergies);

            _usernameController.text = _username;
            _emailController.text = _email;
            _budgetController.text = _formatRpValue(_budget);
          });
        }
      } else {
        _showSnackBar('Gagal memuat data (${response.statusCode})', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Gagal terhubung ke server', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Verifikasi password untuk perubahan email
  Future<bool> _verifyPassword() async {
    Completer<bool> completer = Completer<bool>();
    String password = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi Password'),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Masukkan password Anda'),
          onChanged: (value) => password = value,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              completer.complete(false);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (password.isEmpty) {
                _showSnackBar('Password tidak boleh kosong', Colors.red);
                completer.complete(false);
                return;
              }
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('jwt_token');
              if (token == null) {
                _showSnackBar('Token tidak ditemukan', Colors.red);
                completer.complete(false);
                return;
              }
              final url = Uri.parse('${ApiService.baseUrl}/verify-password');
              try {
                final response = await http.post(
                  url,
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: json.encode({'password': password}),
                );
                final data = json.decode(response.body);
                if (data['success'] == true) {
                  completer.complete(true);
                } else {
                  _showSnackBar(
                      data['message'] ?? 'Password salah', Colors.red);
                  completer.complete(false);
                }
              } catch (e) {
                _showSnackBar('Gagal verifikasi password', Colors.red);
                completer.complete(false);
              }
            },
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
    return completer.future;
  }

  Future<void> _saveProfileToBackend() async {
    // Validasi makanan kesukaan minimal 2
    if (_selectedCategories.length < 2) {
      _showSnackBar('Pilih minimal 2 kategori makanan kesukaan', Colors.orange);
      return;
    }

    // Kumpulkan perubahan
    Map<String, dynamic> changes = {};
    if (_usernameController.text.trim() != _originalUsername) {
      changes['Username'] = _usernameController.text.trim();
    }
    if (_emailController.text.trim() != _originalEmail) {
      changes['Email'] = _emailController.text.trim();
    }
    if (_eatFrequency != _originalEatFrequency) {
      changes['Jumlah_Makan'] = _eatFrequency;
    }
    int newBudget = _parseBudgetFromFormatted(_budgetController.text);
    if (newBudget != _originalBudget) {
      changes['Budget_Bulanan'] = newBudget;
    }
    if (!_listEquals(_selectedCategories, _originalSelectedCategories)) {
      changes['Kategori_Favorit'] = _selectedCategories;
    }
    bool allergyChanged = !_listEquals(_allergies, _originalAllergies);
    if (allergyChanged) {
      // Jika alergi berubah menjadi kosong (sebelumnya tidak kosong), konfirmasi khusus
      if (_allergies.isEmpty && _originalAllergies.isNotEmpty) {
        bool confirmClear = await _showConfirmDialog(
          changes: {
            'Alergi':
                'Semua alergi akan dihapus. Apakah Anda yakin tidak memiliki alergi?'
          },
          isAllergyClear: true,
        );
        if (!confirmClear) return;
      }
      changes['Alergi'] = _allergies;
    }

    if (changes.isEmpty) {
      setState(() => _isEditing = false);
      _showSnackBar('Tidak ada perubahan', Colors.orange);
      return;
    }

    // Jika ada perubahan email, minta verifikasi password
    if (changes.containsKey('Email')) {
      bool verified = await _verifyPassword();
      if (!verified) return;
    }

    // Tampilkan konfirmasi umum
    bool confirmed = await _showConfirmDialog(changes: changes);
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        _showSnackBar('Token tidak ditemukan.', Colors.red);
        return;
      }

      final url = Uri.parse('${ApiService.baseUrl}/profile');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(changes),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          _username = _usernameController.text.trim();
          _email = _emailController.text.trim();
          _originalUsername = _username;
          _originalEmail = _email;
          _originalEatFrequency = _eatFrequency;
          _originalBudget = _parseBudgetFromFormatted(_budgetController.text);
          _originalSelectedCategories = List.from(_selectedCategories);
          _originalAllergies = List.from(_allergies);
          _isEditing = false;
        });
        _showSnackBar('Profil berhasil diperbarui!', Colors.green);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal menyimpan.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Dialog konfirmasi dengan desain yang lebih menarik dan jelas
  Future<bool> _showConfirmDialog(
      {required Map<String, dynamic> changes,
      bool isAllergyClear = false}) async {
    List<Widget> contentWidgets = [];

    if (isAllergyClear) {
      contentWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.orange600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  changes['Alergi'] as String,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Bangun daftar perubahan dengan ikon dan warna
      List<Map<String, dynamic>> changeItems = [];

      if (changes.containsKey('Username')) {
        changeItems.add({
          'icon': Icons.person,
          'label': 'Username',
          'value': changes['Username'],
          'color': AppTheme.blue600
        });
      }
      if (changes.containsKey('Email')) {
        changeItems.add({
          'icon': Icons.email,
          'label': 'Email',
          'value': changes['Email'],
          'color': AppTheme.blue600
        });
      }
      if (changes.containsKey('Jumlah_Makan')) {
        changeItems.add({
          'icon': Icons.restaurant,
          'label': 'Frekuensi makan',
          'value': '${changes['Jumlah_Makan']} kali/hari',
          'color': AppTheme.purple600
        });
      }
      if (changes.containsKey('Budget_Bulanan')) {
        changeItems.add({
          'icon': Icons.account_balance_wallet,
          'label': 'Budget bulanan',
          'value': 'Rp ${_formatRpValue(changes['Budget_Bulanan'])}',
          'color': AppTheme.green600
        });
      }
      if (changes.containsKey('Kategori_Favorit')) {
        changeItems.add({
          'icon': Icons.favorite,
          'label': 'Kategori favorit',
          'value': '${changes['Kategori_Favorit'].length} kategori dipilih',
          'color': AppTheme.orange600
        });
      }
      if (changes.containsKey('Alergi') && !isAllergyClear) {
        changeItems.add({
          'icon': Icons.warning,
          'label': 'Daftar alergi',
          'value':
              _allergies.isEmpty ? 'Tidak ada alergi' : _allergies.join(', '),
          'color': AppTheme.red600
        });
      }

      if (changeItems.isEmpty) {
        contentWidgets.add(const Text('Tidak ada perubahan yang jelas.'));
      } else {
        contentWidgets.add(const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('Anda akan mengubah data berikut:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ));
        for (var item in changeItems) {
          contentWidgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'], size: 18, color: item['color']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['label'],
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(item['value'],
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: item['color'])),
                    ],
                  ),
                ),
              ],
            ),
          ));
        }
      }
    }

    return await showDialog(
          context: context,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.cardBackground,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header dengan ikon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.orange50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        size: 32, color: AppTheme.orange600),
                  ),
                  const SizedBox(height: 16),
                  const Text('Konfirmasi Perubahan',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...contentWidgets,
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                          ),
                          child: const Text('Batal',
                              style: TextStyle(fontSize: 15)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.orange600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            elevation: 0,
                          ),
                          child: const Text('Simpan',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _toggleAllergy(String allergy) {
    setState(() {
      if (_allergies.contains(allergy)) {
        _allergies.remove(allergy);
      } else {
        _allergies.add(allergy);
      }
    });
  }

  // Perbaikan: menambahkan alergi kustom dengan TextEditingController yang benar
  Future<void> _addCustomAllergy() async {
    final controller = TextEditingController();
    String? newAllergy = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Alergi Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Contoh: Durian, Ikan Asin'),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) Navigator.pop(context, value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    if (newAllergy != null && newAllergy.isNotEmpty) {
      if (!_allergies.contains(newAllergy)) {
        setState(() => _allergies.add(newAllergy));
      } else {
        _showSnackBar('Alergi sudah ada', Colors.orange);
      }
    }
  }

  void _incrementFrequency() {
    if (_eatFrequency >= 4) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Batas Maksimal'),
          content:
              const Text('Frekuensi makan maksimal adalah 4 kali per hari.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _eatFrequency++);
    }
  }

  void _decrementFrequency() {
    if (_eatFrequency > 1) setState(() => _eatFrequency--);
  }

  String _formatRp(int v) => 'Rp ${_formatRpValue(v)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.orange500))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: context.colors.cardBackground,
                  elevation: 0,
                  toolbarHeight: 60,
                  leading: IconButton(
                    icon: Icon(Icons.chevron_left,
                        size: 28, color: context.colors.textPrimary),
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go('/app/home'),
                  ),
                  // Perubahan judul: "Profile User"
                  title: Text('Profile User',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: context.colors.textPrimary,
                          letterSpacing: -0.5)),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () {
                          if (_isEditing) {
                            _saveProfileToBackend();
                          } else {
                            setState(() => _isEditing = true);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                _isEditing ? Colors.green : AppTheme.orange50,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                  _isEditing
                                      ? Icons.save_rounded
                                      : Icons.edit_rounded,
                                  size: 14,
                                  color: _isEditing
                                      ? Colors.white
                                      : AppTheme.orange600),
                              const SizedBox(width: 4),
                              Text(_isEditing ? 'Simpan' : 'Edit',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _isEditing
                                          ? Colors.white
                                          : AppTheme.orange600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child:
                          Container(color: context.colors.border, height: 1)),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Column(
                        children: [
                          AvatarGlow(
                            glowColor:
                                _isEditing ? Colors.green : AppTheme.orange500,
                            repeat: _isEditing,
                            duration: const Duration(milliseconds: 1500),
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.orange100,
                                border: Border.all(
                                    color: context.colors.cardBackground,
                                    width: 4),
                              ),
                              child: Center(
                                child: Text(
                                    _username.isNotEmpty
                                        ? _username[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        color:
                                            Color.fromARGB(255, 147, 75, 3))),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_isEditing)
                            Column(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: _usernameController,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: 'Username',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                    ),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 250,
                                  child: TextField(
                                    controller: _emailController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                Text(_username,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: context.colors.textPrimary,
                                        letterSpacing: -0.5)),
                                const SizedBox(height: 4),
                                Text(_email,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: context.colors.textSecondary)),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _ProfileSection(
                        isEditing: _isEditing,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department_rounded,
                                    color: AppTheme.orange500, size: 20),
                                const SizedBox(width: 8),
                                Text('Makanan Kesukaan',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: context.colors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (_isLoadingCategories)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            else if (_availableCategories.isEmpty)
                              const Text('Tidak ada kategori',
                                  style: TextStyle(color: Colors.red))
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableCategories.map((category) {
                                  final isSelected =
                                      _selectedCategories.contains(category);
                                  return GestureDetector(
                                    onTap: _isEditing
                                        ? () => _toggleCategory(category)
                                        : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.orange50
                                            : context.colors.cardBackground,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color: isSelected
                                                ? AppTheme.orange500
                                                : context.colors.border,
                                            width: isSelected ? 2 : 1),
                                      ),
                                      child: Text(category,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? AppTheme.orange600
                                                  : context
                                                      .colors.textSecondary)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            if (_isEditing && _selectedCategories.length < 2)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('Minimal pilih 2 kategori',
                                    style: TextStyle(
                                        fontSize: 12, color: AppTheme.red600)),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ProfileSection(
                        isEditing: _isEditing,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    color: AppTheme.red500, size: 20),
                                const SizedBox(width: 8),
                                Text('Alergi Bahan Makanan',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: context.colors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (!_isEditing && _allergies.isEmpty)
                              // Perubahan teks: tanpa "Aman!"
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: AppTheme.green50,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                        color: const Color(0xFFBBF7D0))),
                                child: const Text('Tidak ada alergi',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.green600)),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ..._allergies.map((allergy) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.red50,
                                        borderRadius: BorderRadius.circular(50),
                                        border:
                                            Border.all(color: AppTheme.red200),
                                      ),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.warning_amber_rounded,
                                                size: 12,
                                                color: AppTheme.red600),
                                            const SizedBox(width: 6),
                                            Text(allergy,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppTheme.red600)),
                                            if (_isEditing) ...[
                                              const SizedBox(width: 6),
                                              GestureDetector(
                                                onTap: () =>
                                                    _toggleAllergy(allergy),
                                                child: const Icon(Icons.close,
                                                    size: 14,
                                                    color: AppTheme.red600),
                                              ),
                                            ],
                                          ]),
                                    );
                                  }).toList(),
                                  if (_isEditing)
                                    GestureDetector(
                                      onTap: _addCustomAllergy,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: context.colors.cardBackground,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                              color: context.colors.border),
                                        ),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.add,
                                                  size: 14,
                                                  color: context
                                                      .colors.textSecondary),
                                              const SizedBox(width: 4),
                                              Text('Tambah',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: context.colors
                                                          .textSecondary)),
                                            ]),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ProfileSection(
                        isEditing: _isEditing,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet_rounded,
                                    color: AppTheme.green600, size: 20),
                                const SizedBox(width: 8),
                                Text('Budget Bulanan',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: context.colors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_isEditing)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: AppTheme.green50,
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: AppTheme.green100)),
                                child: Row(
                                  children: [
                                    const Text('Rp ',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800)),
                                    Expanded(
                                      child: TextField(
                                        controller: _budgetController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800),
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '0'),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    color: context.colors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: context.colors.border)),
                                child: Text(_formatRp(_budget),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppTheme.green700)),
                              ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                      color: AppTheme.purple100,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Center(
                                      child: Text('${_eatFrequency}x',
                                          style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: AppTheme.purple600))),
                                ),
                                const SizedBox(width: 8),
                                Text('Frekuensi Makan Sehari',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: context.colors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_isEditing)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: AppTheme.purple50,
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: AppTheme.purple100)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: _decrementFrequency,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color:
                                                context.colors.cardBackground,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: AppTheme.purple100)),
                                        child: Center(
                                            child: Text('-',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w900,
                                                    color: context
                                                        .colors.textPrimary))),
                                      ),
                                    ),
                                    SizedBox(
                                        width: 48,
                                        child: Center(
                                            child: Text('$_eatFrequency',
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w900,
                                                    color:
                                                        AppTheme.purple600)))),
                                    GestureDetector(
                                      onTap: _incrementFrequency,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color:
                                                context.colors.cardBackground,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: AppTheme.purple100)),
                                        child: Center(
                                            child: Text('+',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w900,
                                                    color: context
                                                        .colors.textPrimary))),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    color: context.colors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: context.colors.border)),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.textSecondary),
                                    children: [
                                      const TextSpan(text: 'Makan '),
                                      TextSpan(
                                          text: '$_eatFrequency kali',
                                          style: const TextStyle(
                                              color: AppTheme.purple600)),
                                      const TextSpan(text: ' sehari.'),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.go('/'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.red600,
                            side: const BorderSide(color: AppTheme.red100),
                            backgroundColor: AppTheme.red50,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Keluar dari CookCash',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
      floatingActionButton: ThemeToggle(
        onToggle: () {
          themeNotifier.value = themeNotifier.value == ThemeMode.light
              ? ThemeMode.dark
              : ThemeMode.light;
        },
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final Widget child;
  final bool isEditing;

  const _ProfileSection({required this.child, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isEditing ? AppTheme.orange500 : context.colors.border,
          width: isEditing ? 2 : 1,
        ),
        boxShadow: isEditing
            ? [
                BoxShadow(
                  color: AppTheme.orange500.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: child,
    );
  }
}
