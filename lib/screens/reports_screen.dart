import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

import '../data/default_categories.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../services/category_service.dart';
import '../services/transaction_service.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedWallet = 'All';

  String peso(double value) => '₱ ${NumberFormat.decimalPattern().format(value)}';

  void _showUpgradeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Upgrade to unlock more wallets.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final transactionService = TransactionService();
    final categoryService = CategoryService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: categoryService.getUserCategories(user.uid),
        builder: (context, categorySnapshot) {
          final customCategories = categorySnapshot.data ?? [];
          final allCategories = [
            ...DefaultCategories.getAll(),
            ...customCategories,
          ];

          CategoryModel? getCategory(String name) {
            try {
              return allCategories.firstWhere(
                    (category) => category.name == name,
              );
            } catch (_) {
              return null;
            }
          }

          return StreamBuilder<List<TransactionModel>>(
            stream: transactionService.getUserTransactions(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allTransactions = snapshot.data ?? [];

              final transactions = _selectedWallet == 'All'
                  ? allTransactions
                  : allTransactions.where((transaction) {
                return transaction.walletName == _selectedWallet;
              }).toList();

              double income = 0;
              double expenses = 0;
              final Map<String, double> categoryTotals = {};

              for (final transaction in transactions) {
                if (transaction.type == 'Income') {
                  income += transaction.amount;
                } else {
                  expenses += transaction.amount;
                  categoryTotals[transaction.category] =
                      (categoryTotals[transaction.category] ?? 0) +
                          transaction.amount;
                }
              }

              final balance = income - expenses;

              if (allTransactions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pie_chart_rounded,
                          size: 72,
                          color: AppTheme.textLight,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No report data yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add income and expenses to generate your spending report.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final sections = categoryTotals.entries.map((entry) {
                final percentage =
                expenses == 0 ? 0 : (entry.value / expenses) * 100;

                final categoryData = getCategory(entry.key);
                final color = categoryData != null
                    ? Color(categoryData.colorValue)
                    : AppTheme.primary;

                return PieChartSectionData(
                  value: entry.value,
                  color: color,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 72,
                  titleStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                );
              }).toList();

              final sortedCategories = categoryTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.primaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedWallet == 'All'
                              ? 'Financial Summary'
                              : '$_selectedWallet Summary',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          peso(balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          balance >= 0
                              ? 'You are currently within a positive balance.'
                              : 'Your expenses are higher than your income.',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Wallet Filter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 14),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _walletFilterChip(
                          label: 'All',
                          selected: _selectedWallet == 'All',
                          unlocked: true,
                          onTap: () {
                            setState(() {
                              _selectedWallet = 'All';
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        _walletFilterChip(
                          label: 'Wallet',
                          selected: _selectedWallet == 'Wallet',
                          unlocked: true,
                          onTap: () {
                            setState(() {
                              _selectedWallet = 'Wallet';
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        _walletFilterChip(
                          label: 'GCash',
                          selected: false,
                          unlocked: false,
                          onTap: _showUpgradeMessage,
                        ),
                        const SizedBox(width: 10),
                        _walletFilterChip(
                          label: 'Maya',
                          selected: false,
                          unlocked: false,
                          onTap: _showUpgradeMessage,
                        ),
                        const SizedBox(width: 10),
                        _walletFilterChip(
                          label: 'BPI',
                          selected: false,
                          unlocked: false,
                          onTap: _showUpgradeMessage,
                        ),
                        const SizedBox(width: 10),
                        _walletFilterChip(
                          label: 'BDO',
                          selected: false,
                          unlocked: false,
                          onTap: _showUpgradeMessage,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          label: 'Income',
                          value: peso(income),
                          icon: Icons.arrow_upward_rounded,
                          color: AppTheme.income,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _summaryCard(
                          label: 'Expenses',
                          value: peso(expenses),
                          icon: Icons.arrow_downward_rounded,
                          color: AppTheme.expense,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'Expense Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: expenses == 0
                        ? const Column(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 48,
                          color: AppTheme.textLight,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No expenses recorded yet',
                          style: TextStyle(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    )
                        : SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 48,
                          sectionsSpace: 3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'Category Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (sortedCategories.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        _selectedWallet == 'All'
                            ? 'No expense categories yet.'
                            : 'No expenses found for $_selectedWallet.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.textLight),
                      ),
                    )
                  else
                    ...sortedCategories.map((entry) {
                      final percentage =
                      expenses == 0 ? 0 : (entry.value / expenses);

                      final categoryData = getCategory(entry.key);
                      final color = categoryData != null
                          ? Color(categoryData.colorValue)
                          : AppTheme.primary;
                      final icon = categoryData != null
                          ? IconData(
                        categoryData.iconCode,
                        fontFamily: 'MaterialIcons',
                      )
                          : Icons.category_rounded;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color.withOpacity(0.12),
                                  child: Icon(
                                    icon,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                                Text(
                                  peso(entry.value),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            LinearProgressIndicator(
                              value: percentage.toDouble(),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(20),
                              backgroundColor: Colors.grey.shade200,
                              color: color,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${(percentage * 100).toStringAsFixed(1)}% of expenses',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  static Widget _summaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  static Widget _walletFilterChip({
    required String label,
    required bool selected,
    required bool unlocked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: unlocked ? 1 : 0.55,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withOpacity(0.12)
                : unlocked
                ? Colors.white
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppTheme.primary : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!unlocked) ...[
                Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                unlocked ? label : '$label 🔒',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: unlocked ? AppTheme.textDark : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}