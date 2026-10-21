import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'transaction_history_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionHistoryScreen(),
    SizedBox(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      resizeToAvoidBottomInset: false,
      body: _screens[_selectedIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          height: 58,
          width: 58,
          child: FloatingActionButton(
            heroTag: 'mainAddTransactionFab',
            elevation: 8,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddTransactionScreen(),
                ),
              );
            },
            child: const Icon(Icons.add_rounded, size: 30),
          ),
        ),
      ),

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 76,
          indicatorColor: AppTheme.primary.withOpacity(0.12),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (states) {
              final selected = states.contains(WidgetState.selected);

              return TextStyle(
                fontSize: 10,
                height: 1.0,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              );
            },
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (index == 2) return;
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: SizedBox(width: 34, height: 34),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: Icon(Icons.pie_chart_rounded),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}