import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/items_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/three_d_container.dart';
import 'widgets/app_drawer.dart';

import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'Suraj Book Store 3D',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigationWrapper(),
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const DashboardScreen(),
    const ItemsScreen(),
    const MenuScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentIndex = appState.navigationIndex;

    return Scaffold(
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildThreeDNavigationBar(currentIndex),
    );
  }

  // Bespoke 3D bottom navigation bar with active items floating above
  Widget _buildThreeDNavigationBar(int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildNavItem(0, Icons.home_rounded, "HOME", currentIndex)),
              Expanded(child: _buildNavItem(1, Icons.bar_chart_rounded, "DASHBOARD", currentIndex)),
              Expanded(child: _buildNavItem(2, Icons.inventory_2_rounded, "ITEMS", currentIndex)),
              Expanded(child: _buildNavItem(3, Icons.menu_rounded, "MENU", currentIndex)),
              Expanded(child: _buildNavItem(4, Icons.account_circle_rounded, "PROFILE", currentIndex)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int currentIndex) {
    final isActive = currentIndex == index;
    final activeColor = index == 4 ? AppTheme.warningOrange : AppTheme.primary;

    return InkWell(
      onTap: () {
        Provider.of<AppState>(context, listen: false).setNavigationIndex(index);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              // Floating 3D active state container
              ThreeDContainer(
                depth: 3,
                borderRadius: 14,
                color: activeColor.withOpacity(0.12),
                borderColor: activeColor.withOpacity(0.2),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  color: activeColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
            ] else ...[
              Icon(
                icon,
                color: const Color(0xFF94A3B8),
                size: 22,
              ),
              const SizedBox(height: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: isActive ? activeColor : const Color(0xFF94A3B8),
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
