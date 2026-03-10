import 'package:flutter/material.dart';
import '../../models/news_model.dart';
import '../../models/source_model.dart';
import 'news_service.dart';
import 'firebase_service.dart';
import 'scraping_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  final FirebaseService _firebaseService = FirebaseService();
  
  List<NewsModel> _newsList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId; // Should be set after login

  List<NewsModel> get newsList => _newsList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentUserId => _currentUserId ?? 'guest_user';

  Future<List<String>> getUserCategories() async {
    return await _firebaseService.getUserCategories(currentUserId);
  }

  void setUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> refreshFeed() async {
    if (_currentUserId == null) {
       // For now, if no user, use a guest/default view or just return
       // Later, this will be handled by the Auth flow
       _currentUserId = 'guest_user'; 
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 0. Wake up backend (Render free tier)
      await ScrapingService().ping();

      // 1. Fetch real sources from Firebase
      List<SourceModel> sources = await _firebaseService.getSources(_currentUserId!);
      
      // If no sources, add Sporx as default for first-time experience
      if (sources.isEmpty && _currentUserId == 'guest_user') {
        sources = [
          SourceModel(id: 'default', url: 'https://www.sporx.com/futbol-besiktas', category: 'Spor', addedBy: 'system')
        ];
      }

      // 2. Aggregate news
      print('REFRESH: Aggregating news from ${sources.length} sources...');
      _newsList = await _newsService.aggregateNews(sources);
      print('REFRESH: Found ${_newsList.length} articles total.');
      
      if (_newsList.isEmpty && sources.isNotEmpty) {
        _errorMessage = 'Haberler şu an çekilemiyor. Sunucu uyanıyor olabilir, lütfen 30 saniye sonra tekrar deneyin.';
      }
    } catch (e) {
      print('Provider Refresh Error: $e');
      if (e.toString().contains('TimeoutException')) {
        _errorMessage = 'Bağlantı zaman aşımına uğradı. Sunucu uyanıyor olabilir, lütfen birazdan tekrar deneyin.';
      } else {
        _errorMessage = 'Haberler yüklenirken bir sorun oluştu: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNewsSource(String url, String category) async {
    if (_currentUserId == null) _currentUserId = 'guest_user';
    print('PLAYER: Adding source for user: $_currentUserId - URL: $url');
    
    try {
      await _firebaseService.addSource(_currentUserId!, url, category);
      await refreshFeed();
    } catch (e) {
      print('Add Source Error: $e');
      rethrow;
    }
  }

  Future<void> deleteNewsSource(String sourceId) async {
    if (_currentUserId == null) return;
    try {
      await _firebaseService.deleteSource(_currentUserId!, sourceId);
      await refreshFeed();
    } catch (e) {
      print('Delete Source Error: $e');
      rethrow;
    }
  }

  Future<List<String>> testNewsSource(String url) async {
    final ScrapingService scraper = ScrapingService();
    return await scraper.fetchArticleLinks(url);
  }

  Future<List<SourceModel>> getUserSources() async {
    if (_currentUserId == null) return [];
    return await _firebaseService.getSources(_currentUserId!);
  }

  Future<void> updateCategories(List<String> categories) async {
    try {
      await _firebaseService.updateUserCategories(currentUserId, categories);
      notifyListeners();
    } catch (e) {
      print('Update Categories Error: $e');
      rethrow;
    }
  }
}
