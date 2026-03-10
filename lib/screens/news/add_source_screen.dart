import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/news_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await context.read<NewsProvider>().getUserCategories();
    setState(() {
      _userCategories = categories;
      if (_userCategories.isEmpty) {
        _userCategories = ['Gündem', 'Teknoloji', 'Spor', 'Ekonomi'];
      }
    });
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
      
      // 1. Add news source
      await provider.addNewsSource(_urlController.text.trim(), category);
      
      // 2. If it's a new category, save it to user profile
      if (_isAddingNewCategory && !_userCategories.contains(category)) {
        final updatedList = List<String>.from(_userCategories)..add(category);
        await provider.updateCategories(updatedList);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Haber kaynağı başarıyla eklendi!')),
        );
        Navigator.pop(context);
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
      appBar: AppBar(
        title: const Text('Haber Kaynağı Ekle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Haber Kaynağı Ekle',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Takip etmek istediğiniz haber sitesinin bağlantısını ekleyin.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),
              // URL Input
              TextFormField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Site URL (RSS veya Web adresi)',
                  hintText: 'https://example.com',
                  prefixIcon: const Icon(Icons.link, color: Color(0xFF8743F4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Lütfen bir URL girin';
                  if (!value.startsWith('http')) return 'Geçerli bir URL girin';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Category Selection
              if (!_isAddingNewCategory) ...[
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: Colors.grey.shade900,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Kategori Seçin',
                    prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF8743F4)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    ..._userCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    const DropdownMenuItem<String>(
                      value: 'ADD_NEW',
                      child: Text('+ Yeni Kategori Ekle...', style: TextStyle(color: Color(0xFF8743F4))),
                    ),
                  ],
                  onChanged: (String? value) {
                    if (value == 'ADD_NEW') {
                      setState(() {
                        _isAddingNewCategory = true;
                        _selectedCategory = null;
                      });
                    } else {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ] else ...[
                // New Category Input
                TextFormField(
                  controller: _newCategoryController,
                  style: const TextStyle(color: Colors.white),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Yeni Kategori Adı',
                    prefixIcon: const Icon(Icons.add_box_outlined, color: Color(0xFF8743F4)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => setState(() => _isAddingNewCategory = false),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Kategori adı girin';
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 48),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8743F4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF8743F4).withOpacity(0.4),
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Haber Kaynağı Ekle',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
