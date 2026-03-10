import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/news_provider.dart';
import '../../models/source_model.dart';

class AddSourceScreen extends StatefulWidget {
  const AddSourceScreen({super.key});

  @override
  State<AddSourceScreen> createState() => _AddSourceScreenState();
}

class _AddSourceScreenState extends State<AddSourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _newCategoryController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isAddingNewCategory = false;
  List<String> _userCategories = [];
  List<SourceModel> _currentSources = [];
  List<String> _previewLinks = [];
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<NewsProvider>();
    final categories = await provider.getUserCategories();
    final sources = await provider.getUserSources();
    
    setState(() {
      _userCategories = categories;
      if (_userCategories.isEmpty) {
        _userCategories = ['Gündem', 'Teknoloji', 'Spor', 'Ekonomi'];
      }
      _currentSources = sources;
    });
  }

  Future<void> _testConnection() async {
    if (_urlController.text.isEmpty || !_urlController.text.startsWith('http')) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir URL girin.')),
      );
      return;
    }

    setState(() {
      _isTesting = true;
      _previewLinks = [];
    });

    try {
      final links = await context.read<NewsProvider>().testNewsSource(_urlController.text.trim());
      setState(() {
        _previewLinks = links;
        if (_previewLinks.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu adresten haber çekilemedi. Lütfen bağlantıyı kontrol edin.')),
          );
        }
      });
    } catch (e) {
      String message = 'Bağlantı hatası: $e';
      if (e.toString().contains('TimeoutException')) {
        message = 'Bağlantı zaman aşımına uğradı. Sunucu uyanıyor olabilir, lütfen 10 saniye sonra tekrar deneyin.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _deleteSource(String id) async {
    setState(() => _isLoading = true);
    try {
      await context.read<NewsProvider>().deleteNewsSource(id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kaynak kaldırıldı.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silme hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final category = _isAddingNewCategory 
        ? _newCategoryController.text.trim() 
        : _selectedCategory;

    if (category == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kategori seçin veya oluşturun.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final provider = context.read<NewsProvider>();
      await provider.addNewsSource(_urlController.text.trim(), category);
      
      if (_isAddingNewCategory && !_userCategories.contains(category)) {
        final updatedList = List<String>.from(_userCategories)..add(category);
        await provider.updateCategories(updatedList);
      }

      await _loadData(); // Refresh list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Haber kaynağı başarıyla eklendi!')),
        );
        _urlController.clear();
        setState(() => _previewLinks = []);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
           SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Kaynak Yönetimi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF8743F4).withOpacity(0.3), Colors.black],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('Yeni Kaynak Ekle', Icons.add_link),
                    const SizedBox(height: 20),
                    // URL Input
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _urlController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                              'RSS veya Web adresi',
                              prefixIcon: Icons.link,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'URL girin';
                              if (!value.startsWith('http')) return 'Geçerli bir URL girin';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildTestButton(),
                      ],
                    ),
                    
                    if (_isTesting || _previewLinks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildPreviewSection(),
                    ],

                    const SizedBox(height: 16),
                    
                    // Category Selection
                    if (!_isAddingNewCategory) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: Colors.grey.shade900,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('Kategori', prefixIcon: Icons.category_outlined),
                        items: [
                          ..._userCategories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          const DropdownMenuItem<String>(
                            value: 'ADD_NEW',
                            child: Text('+ Yeni Kategori...', style: TextStyle(color: Color(0xFF8743F4))),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value == 'ADD_NEW') {
                            setState(() {
                              _isAddingNewCategory = true;
                              _selectedCategory = null;
                            });
                          } else {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _newCategoryController,
                        style: const TextStyle(color: Colors.white),
                        autofocus: true,
                        decoration: _buildInputDecoration(
                          'Yeni Kategori Adı',
                          prefixIcon: Icons.add_box_outlined,
                          suffix: IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                            onPressed: () => setState(() => _isAddingNewCategory = false),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Kategori adı girin';
                          return null;
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    _buildMainButton('Kaynağı Kaydet', _isLoading ? null : _submitForm),

                    const SizedBox(height: 48),
                    _buildSectionHeader('Mevcut Kaynaklarım', Icons.list_alt),
                    const SizedBox(height: 16),
                    _buildSourcesList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8743F4), size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label, {IconData? prefixIcon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF8743F4), size: 22) : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF8743F4), width: 1),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isTesting ? null : _testConnection,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isTesting 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Test Et'),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bağlantı Önizlemesi', style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 8),
          if (_isTesting)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Haberler taranıyor...', style: TextStyle(color: Colors.white38)))),
          if (!_isTesting && _previewLinks.isEmpty)
             const Text('⚠️ Bu adresten haber çekilemedi.', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
          if (_previewLinks.isNotEmpty)
            Column(
              children: _previewLinks.take(3).map((link) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 14),
                    const SizedBox(width: 8),
                    Expanded(child: Text(link, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainButton(String text, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8743F4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: const Color(0xFF8743F4).withOpacity(0.4),
      ),
      child: _isLoading 
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSourcesList() {
    if (_currentSources.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: const Center(
          child: Text('Henüz özel bir kaynak eklemediniz.', style: TextStyle(color: Colors.white38)),
        ),
      );
    }

    return Column(
      children: _currentSources.map((source) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF8743F4).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.language, color: Color(0xFF8743F4), size: 20),
          ),
          title: Text(source.url, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(source.category, style: TextStyle(color: const Color(0xFF8743F4).withOpacity(0.7), fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            onPressed: () => _deleteSource(source.id),
          ),
        ),
      )).toList(),
    );
  }
}
