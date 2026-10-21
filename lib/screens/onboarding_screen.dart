import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({
    super.key,
    required this.onFinish,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'icon': Icons.account_balance_wallet_rounded,
      'title': 'Track your money easily',
      'subtitle': 'Record your income, expenses, and savings in one simple app.',
    },
    {
      'icon': Icons.pie_chart_rounded,
      'title': 'Understand your spending',
      'subtitle': 'See where your money goes through categories and reports.',
    },
    {
      'icon': Icons.school_rounded,
      'title': 'Made for students and young pros',
      'subtitle': 'Manage baon, salary, bills, goals, and daily spending wisely.',
    },
  ];

  void _nextPage() {
    if (_currentPage == pages.length - 1) {
      widget.onFinish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onFinish,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = pages[index];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 210,
                          width: 210,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'],
                            size: 95,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          page['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page['subtitle'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppTheme.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _nextPage,
                child: Text(
                  _currentPage == pages.length - 1
                      ? 'Get Started'
                      : 'Next',
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onFinish,
                child: const Text('I already have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}