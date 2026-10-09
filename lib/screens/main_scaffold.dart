import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';
import '../widgets/bottom_nav.dart';
import 'home_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>();

    // standalone: false → el BottomNav se mantiene visible en el tab
    final screens = [
      const HomeScreen(),
      const MyReportsScreen(standalone: false),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        reportBadgeCount: reports.pendingCount,
      ),
    );
  }
}

