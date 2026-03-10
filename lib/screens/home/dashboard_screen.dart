import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/news_provider.dart';
import '../news/news_detail_screen.dart';
import '../../models/news_model.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch news on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().refreshFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Image.asset('assets/images/logo.png', height: 40),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8743F4)));
          }

          if (newsProvider.newsList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.newspaper, size: 64, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  const Text('Henüz haber yok.', style: TextStyle(color: Colors.white38)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => newsProvider.refreshFeed(),
            color: const Color(0xFF8743F4),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Categories
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildCategoryChip('Hepsi', true),
                        _buildCategoryChip('Gündem', false),
                        _buildCategoryChip('Teknoloji', false),
                        _buildCategoryChip('Spor', false),
                        _buildCategoryChip('Ekonomi', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Featured News Card (First item)
                  if (newsProvider.newsList.isNotEmpty)
                    _buildFeaturedCard(context, newsProvider.newsList[0]),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Son Haberler',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Tümünü Gör', style: TextStyle(color: Color(0xFF8743F4))),
                        ),
                      ],
                    ),
                  ),
                  
                  // News List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: newsProvider.newsList.length - 1,
                    itemBuilder: (context, index) {
                      final news = newsProvider.newsList[index + 1];
                      return _buildNewsItem(context, news);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF8743F4),
          unselectedItemColor: Colors.white38,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Ana Sayfa'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Keşfet'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Kaydedilen'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, NewsModel news) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewsDetailScreen(
          title: news.title,
          content: news.content,
          imageUrl: news.imageUrl,
          source: 'Sporx',
          category: news.category,
        )),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: news.imageUrl.isNotEmpty
                ? DecorationImage(image: NetworkImage(news.imageUrl), fit: BoxFit.cover)
                : null,
            gradient: news.imageUrl.isEmpty 
                ? const LinearGradient(colors: [Color(0xFF8743F4), Color(0xFF43187A)])
                : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8743F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(news.category, style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
                const SizedBox(height: 8),
                Text(
                  news.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8743F4) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? const Color(0xFF8743F4) : Colors.white10,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, NewsModel news) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          image: news.imageUrl.isNotEmpty
              ? DecorationImage(image: NetworkImage(news.imageUrl), fit: BoxFit.cover)
              : null,
        ),
        child: news.imageUrl.isEmpty ? const Icon(Icons.image, color: Colors.white24) : null,
      ),
      title: Text(
        news.title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          '${DateFormat('HH:mm').format(news.timestamp)} • ${news.category}',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewsDetailScreen(
          title: news.title,
          content: news.content,
          imageUrl: news.imageUrl,
          source: 'Sporx',
          category: news.category,
        )),
      ),
    );
  }
}
