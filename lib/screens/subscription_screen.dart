import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isYearly = false;
  String _selectedPlan = 'Plus';

  String get plusPrice => _isYearly ? '₱999/yr' : '₱99/mo';
  String get premiumPrice => _isYearly ? '₱1,799/yr' : '₱179/mo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(height: 18),
                Text(
                  'Upgrade your SpendSmart experience',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Unlock more wallets, premium insights, and advanced financial tools.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isYearly = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isYearly
                                  ? AppTheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                'Monthly',
                                style: TextStyle(
                                  color: !_isYearly
                                      ? Colors.white
                                      : AppTheme.textLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isYearly = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isYearly
                                  ? AppTheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                'Yearly',
                                style: TextStyle(
                                  color: _isYearly
                                      ? Colors.white
                                      : AppTheme.textLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_offer_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '7-day free trial included',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _planCard(
                        title: 'Plus',
                        price: plusPrice,
                        subtitle: 'Smart finance insights',
                        color: AppTheme.primary,
                        selected: _selectedPlan == 'Plus',
                        onTap: () {
                          setState(() {
                            _selectedPlan = 'Plus';
                          });
                        },
                        features: const [
                          'Up to 3 wallets',
                          'Advanced reports',
                          'Cloud backup',
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _planCard(
                        title: 'Premium',
                        price: premiumPrice,
                        subtitle: 'Complete finance tools',
                        color: AppTheme.warning,
                        selected: _selectedPlan == 'Premium',
                        onTap: () {
                          setState(() {
                            _selectedPlan = 'Premium';
                          });
                        },
                        features: const [
                          'Unlimited wallets',
                          'AI suggestions',
                          'Priority support',
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$_selectedPlan plan selected. Payment setup will be available after the free trial.',
                        ),
                      ),
                    );
                  },
                  child: Text('Start $_selectedPlan 7-Day Trial'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.savings,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'This is a prototype showcase. Payment and billing setup will be available in future versions.',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String price,
    required String subtitle,
    required Color color,
    required List<String> features,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.035 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.09) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? color : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: color.withOpacity(0.28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              if (selected)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Selected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

              SizedBox(height: selected ? 6 : 0),

              CircleAvatar(
                backgroundColor: color.withOpacity(selected ? 0.18 : 0.12),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: color,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: selected ? 21 : 20,
                  color: color,
                ),
              ),

              const SizedBox(height: 16),

              ...features.map(
                    (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: color,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 10.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}