import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class ScrapingService {
  // TODO: Replace with your Render.com URL after deployment
  // Example: https://abzurt-news.onrender.com/fetch
  final String _backendUrl = 'https://abzurt-backend.onrender.com/fetch';

  /// Fetches the last 10 article links from a listing page via Backend
  Future<List<String>> fetchArticleLinks(String sourceUrl) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'links',
          'url': sourceUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['links'] ?? []);
      }
    } catch (e) {
      print('Error fetching article links via Backend: $e');
    }
    return [];
  }

  /// Fetches detailed metadata for a specific article via Backend
  Future<NewsModel?> fetchArticleDetails(String articleUrl, String category) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'details',
          'url': articleUrl,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final details = data['details'];
        if (details != null) {
          return NewsModel(
            id: articleUrl.hashCode.toString(),
            title: details['title'] ?? 'Başlıksız',
            content: details['content'] ?? 'İçerik çekilemedi.',
            imageUrl: details['imageUrl'] ?? '',
            sourceUrl: articleUrl,
            category: category,
            timestamp: DateTime.now(),
          );
        }
      }
    } catch (e) {
      print('Error fetching article details via Backend: $e');
    }
    return null;
  }
}
