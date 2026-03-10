import '../models/news_model.dart';
import '../models/source_model.dart';
import 'scraping_service.dart';

class NewsService {
  final ScrapingService _scrapingService = ScrapingService();

  /// Aggregates news from multiple sources
  Future<List<NewsModel>> aggregateNews(List<SourceModel> sources) async {
    List<NewsModel> allNews = [];

    for (var source in sources) {
      // 1. Get links for each source
      List<String> links = await _scrapingService.fetchArticleLinks(source.url);
      
      // 2. Fetch details for each link (Concurrent would be better, but let's be safe first)
      for (var link in links) {
        NewsModel? news = await _scrapingService.fetchArticleDetails(link, source.category);
        if (news != null) {
          allNews.add(news);
        }
      }
    }

    // 3. Sort by timestamp descending
    allNews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return allNews;
  }
}
