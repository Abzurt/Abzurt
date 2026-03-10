import 'package:flutter/material.dart';
import '../../models/news_model.dart';
import '../../models/source_model.dart';
import '../../services/news_service.dart';
import '../../services/firebase_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  final FirebaseService _firebaseService = FirebaseService();
  
  List<NewsModel> _newsList = [];
  bool _isLoading = false;
  String? _currentUserId; // Should be set after login

  List<NewsModel> get newsList => _newsList;
  bool get isLoading => _isLoading;
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
    notifyListeners();

    try {
      // 1. Fetch real sources from Firebase
      List<SourceModel> sources = await _firebaseService.getSources(_currentUserId!);
      
      // If no sources, add Sporx as default for first-time experience
      if (sources.isEmpty && _currentUserId == 'guest_user') {
        sources = [
          SourceModel(id: 'default', url: 'https://www.sporx.com/futbol-besiktas', category: 'Spor', addedBy: 'system')
        ];
      }

      // 2. Aggregate news
      _newsList = await _newsService.aggregateNews(sources);
    } catch (e) {
      print('Provider Refresh Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNewsSource(String url, String category) async {
    if (_currentUserId == null) _currentUserId = 'guest_user';
    
    try {
      await _firebaseService.addSource(_currentUserId!, url, category);
      await refreshFeed(); // Refresh to get news from new source
    } catch (e) {
      print('Add Source Error: $e');
      rethrow;
    }
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
