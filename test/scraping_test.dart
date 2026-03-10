import 'package:flutter_test/flutter_test.dart';
import 'package:abzurt/services/scraping_service.dart';

void main() {
  final scrapingService = ScrapingService();

  test('Scraping engine detects article links from Sporx', () async {
    const url = 'https://www.sporx.com/futbol-besiktas';
    final links = await scrapingService.fetchArticleLinks(url);
    
    print('Found ${links.length} articles from Sporx');
    
    expect(links, isNotEmpty);
    expect(links.length, lessThanOrEqualTo(10));
    expect(links.first, startsWith('http'));
  });

  test('Scraping engine extracts metadata from a specific article', () async {
    // Using a known Sporx article structure link
    const articleUrl = 'https://www.sporx.com/besiktas-tan-tff-ye-ikinci-cagri-kayitlar-nerede-SXHBQ1154171SXQ';
    final details = await scrapingService.fetchArticleDetails(articleUrl, 'Spor');
    
    expect(details, isNotNull);
    expect(details!.title, isNotEmpty);
    expect(details.title, isNot('Başlıksız'));
    expect(details.imageUrl, isNotEmpty);
    print('Article Title: ${details.title}');
  });
}
