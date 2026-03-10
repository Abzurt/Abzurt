import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Haberlerin Geleceğini Keşfedin',
      'description': 'En güncel teknoloji ve dünya haberleri tek bir platformda.',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDaezeyIGZGR8LB98DkOzOvMw9Djdvhm6pVH9ILbPjgQdphMKAnU8O_Rbkv5Fb88Ii1IihSKOWYqfbpsQtHZufe8Psp-cNyH2BKZuB6eP40CEbFLQSgTkypikmVWbM3f9dYZ0EXtB-ArERaO0-o3oQQ2NflGE9uO5tDJYBHDkLEsHO2J-yolzRYXorKHj8F2FNsTy0YaCDysr0L0pL79GdmRAmDgHFueMu3RjrUk7wyyXMdHWweRR2xNrCKyiXStQ5VRQVb',
    },
    {
      'title': 'Size Özel Akıllı Akış',
      'description': 'İlgi alanlarınıza göre yapay zeka tarafından derlenen haberlere anında ulaşın.',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuA3L5i9zG9mOqYzS8945SMC2j9W_z5A5O4B-Wj5h9w_r2L45Yv6v8Rj-3n4v5B6n7m8v9B0n1m2v3B4n5m6v7B8n9m0v1B2n3m4v5B6n7m8v9B0', // Alternative premium image logic
    },
  ];

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) => setState(() => _currentPage = value),
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) => Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  _onboardingData[index]['image']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo (Always visible or moves with pages)
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8743F4).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                    ),
                  ),
                  const Spacer(),
                  // Text Content
                  Text(
                    _onboardingData[_currentPage]['title']!,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _onboardingData[_currentPage]['description']!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 4,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? const Color(0xFF8743F4) : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _onboardingData.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _navigateToLogin();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8743F4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage == _onboardingData.length - 1 ? 'Hadi Başlayalım' : 'Devam Et',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: _navigateToLogin,
                        child: const Text(
                          'Geç',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
