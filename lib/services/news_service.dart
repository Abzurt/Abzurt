import '../models/news_model.dart';
import '../models/source_model.dart';
import 'scraping_service.dart';

class NewsService {
  final ScrapingService _scrapingService = ScrapingService();

  /// Aggregates news from multiple sources
  Future<List<NewsModel>> aggregateNews(List<SourceModel> sources) async {
    List<NewsModel> allNews = [];

    print('AGGREGATE: Fetching links for ${sources.length} sources...');
    final List<List<String>> allLinksResults = await Future.wait(
      sources.map((s) => _scrapingService.fetchArticleLinks(s.url))
    );

    int totalLinksCount = allLinksResults.fold(0, (sum, list) => sum + list.length);
    print('AGGREGATE: Found $totalLinksCount links total.');

    // 2. Flatten and prepare detail fetches
    List<Map<String, String>> detailRequests = [];
    for (int i = 0; i < sources.length; i++) {
        final category = sources[i].category;
        for (var link in allLinksResults[i]) {
            detailRequests.add({'link': link, 'category': category});
        }
    }

    // 3. Batch fetch details (Max 5 concurrent)
    const int batchSize = 5;
    for (int i = 0; i < detailRequests.length; i += batchSize) {
      final batch = detailRequests.sublist(
        i, 
        (i + batchSize) > detailRequests.length ? detailRequests.length : i + batchSize
      );
      
      print('AGGREGATE: Fetching batch ${i ~/ batchSize + 1} (${batch.length} items)...');
      final results = await Future.wait(
        batch.map((req) => _scrapingService.fetchArticleDetails(req['link']!, req['category']!))
      );
      
      for (var news in results) {
        if (news != null) allNews.add(news);
      }
      print('AGGREGATE: Batch completed. Current total: ${allNews.length}');
    }

    print('AGGREGATE: Successfully fetched ${allNews.length} articles.');

    // 4. Sort by timestamp descending
    allNews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return allNews;
  }
}
