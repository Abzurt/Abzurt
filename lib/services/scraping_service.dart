import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class ScrapingService {
  // TODO: Replace with your Render.com URL after deployment
  // Example: https://abzurt-news.onrender.com/fetch
  final String _backendUrl = 'https://abzurt-backend.onrender.com/fetch';

  /// Pings the backend to wake it up (Render free tier)
  Future<void> ping() async {
    try {
      await http.get(Uri.parse(_backendUrl.replaceFirst('/fetch', '/health')))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  /// Validates a news source by checking if it returns any links
  Future<bool> validateSource(String url) async {
    final links = await fetchArticleLinks(url);
    return links.isNotEmpty;
  }

  /// Fetches the last 10 article links from a listing page via Backend
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'links',
          'url': sourceUrl,
        }),
      ).timeout(const Duration(seconds: 60));

      print('SUCCESS: fetchArticleLinks took ${stopwatch.elapsedMilliseconds}ms');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['links'] ?? []);
      }
    } catch (e) {
      print('ERROR: fetchArticleLinks failed after ${stopwatch.elapsedMilliseconds}ms: $e');
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
      ).timeout(const Duration(seconds: 60));

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
