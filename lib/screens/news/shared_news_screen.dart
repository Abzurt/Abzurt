import 'package:flutter/material.dart';

class SharedNewsScreen extends StatefulWidget {
  const SharedNewsScreen({super.key});

  @override
  State<SharedNewsScreen> createState() => _SharedNewsScreenState();
}

class _SharedNewsScreenState extends State<SharedNewsScreen> {
  int _selectedIndex = 1; // "Explore/Shared" tab logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Paylaştıklarım',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF8743F4).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_outlined, size: 80, color: Color(0xFF8743F4)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz haber paylaşmadınız.',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Paylaştığınız haberler burada görünecek.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 0) Navigator.pushReplacementNamed(context, '/home');
            // Add other routes as needed
          },
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
}
