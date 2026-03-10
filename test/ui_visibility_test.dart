import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abzurt/screens/home/dashboard_screen.dart';
import 'package:abzurt/widgets/main_navigation.dart';
import 'package:abzurt/services/news_provider.dart';
import 'package:abzurt/models/news_model.dart';
import 'package:provider/provider.dart';

// Truly independent Mock that doesn't touch Firebase/real services
class MockNewsProvider extends ChangeNotifier implements NewsProvider {
  @override
  List<NewsModel> get newsList => [];
  
  @override
  bool get isLoading => false;

  @override
  Future<void> refreshFeed() async {}

  @override
  Future<void> addNewsSource(String url, String category) async {}

  @override
  void setUserId(String userId) {}
}

void main() {
  testWidgets('Dashboard Screen shows app title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<NewsProvider>(
        create: (_) => MockNewsProvider(),
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Verify app title
    expect(find.text('Abzurt News'), findsOneWidget);
  });

  testWidgets('Main Navigation has bottom bar and FAB', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<NewsProvider>(
        create: (_) => MockNewsProvider(),
        child: const MaterialApp(
          home: MainNavigation(),
        ),
      ),
    );

    // Verify bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify FAB (+) exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
