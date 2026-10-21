import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/budget_model.dart';
import '../models/savings_goal_model.dart';
import '../models/transaction_model.dart';
import '../services/budget_service.dart';
import '../services/savings_goal_service.dart';
import '../services/transaction_service.dart';
import '../theme/app_theme.dart';
import 'transaction_history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String peso(double value) =>
      '₱ ${NumberFormat.decimalPattern().format(value)}';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final transactionService = TransactionService();
    final budgetService = BudgetService();
    final savingsGoalService = SavingsGoalService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: StreamBuilder<BudgetModel?>(
          stream: budgetService.getBudget(user.uid),
          builder: (context, budgetSnapshot) {
            final budget = budgetSnapshot.data;

            return StreamBuilder<List<TransactionModel>>(
              stream: transactionService.getUserTransactions(user.uid),
              builder: (context, transactionSnapshot) {
                final transactions = transactionSnapshot.data ?? [];

                return StreamBuilder<List<SavingsGoalModel>>(
                  stream: savingsGoalService.getUserGoals(user.uid),
                  builder: (context, savingsSnapshot) {
                    final goals = savingsSnapshot.data ?? [];

                    double totalSaved = 0;
                    for (final goal in goals) {
                      totalSaved += goal.savedAmount;
                    }

                    double income = 0;
                    double expenses = 0;
                    double monthlyExpenses = 0;

                    final now = DateTime.now();

                    for (final transaction in transactions) {
                      final isCurrentMonth =
                          transaction.date.month == now.month &&
                              transaction.date.year == now.year;

                      if (transaction.type == 'Income') {
                        income += transaction.amount;
                      } else {
                        expenses += transaction.amount;

                        if (isCurrentMonth) {
                          monthlyExpenses += transaction.amount;
                        }
                      }
                    }

                    final totalBalance = income - expenses;
                    final walletBalance = totalBalance - totalSaved;

                    Map<String, double> monthlyCategoryTotals = {};

                    for (final transaction in transactions) {
                      final isCurrentMonth =
                          transaction.date.month == now.month &&
                              transaction.date.year == now.year;

                      if (transaction.type == 'Expense' && isCurrentMonth) {
                        monthlyCategoryTotals[transaction.category] =
                            (monthlyCategoryTotals[transaction.category] ?? 0) +
                                transaction.amount;
                      }
                    }

                    String topCategory = '';
                    double topCategoryAmount = 0;

                    if (monthlyCategoryTotals.isNotEmpty) {
                      final topEntry = monthlyCategoryTotals.entries.reduce(
                            (a, b) => a.value > b.value ? a : b,
                      );

                      topCategory = topEntry.key;
                      topCategoryAmount = topEntry.value;
                    }

                    final monthlyBudget = budget?.monthlyLimit ?? 0;

                    final budgetProgress = monthlyBudget > 0
                        ? (monthlyExpenses / monthlyBudget).clamp(0.0, 1.0)
                        : 0.0;

                    final nearLimit = monthlyBudget > 0 &&
                        monthlyExpenses >= monthlyBudget * 0.8;

                    final overBudget =
                        monthlyBudget > 0 && monthlyExpenses >= monthlyBudget;

                    if (transactionSnapshot.connectionState ==
                        ConnectionState.waiting ||
                        savingsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .snapshots(),
                                builder: (context, userSnapshot) {
                                  final data = userSnapshot.data?.data()
                                  as Map<String, dynamic>?;

                                  final name =
                                      data?['name'] ?? 'SpendSmart User';

                                  return Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Welcome back 👋',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                },
                                icon: const Icon(Icons.logout_rounded),
                              ),
                            ],
                          ),

                          const SizedBox(height: 26),

                          SizedBox(
                            height: 330,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _walletDashboardCard(
                                  title: 'Wallet',
                                  subtitle: 'Available Balance',
                                  amount: peso(
                                    walletBalance < 0 ? 0 : walletBalance,
                                  ),
                                  color: AppTheme.primary,
                                  icon: Icons.payments_rounded,
                                  unlocked: true,
                                  income: peso(income),
                                  expenses: peso(expenses),
                                  savings: peso(totalSaved),
                                ),
                                const SizedBox(width: 16),
                                _walletDashboardCard(
                                  title: 'GCash',
                                  subtitle: 'Premium Wallet',
                                  amount: 'Locked',
                                  color: Colors.grey.shade500,
                                  icon: Icons.lock_rounded,
                                  unlocked: false,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Upgrade to unlock more wallets.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                _walletDashboardCard(
                                  title: 'Maya',
                                  subtitle: 'Premium Wallet',
                                  amount: 'Locked',
                                  color: Colors.grey.shade500,
                                  icon: Icons.lock_rounded,
                                  unlocked: false,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Upgrade to unlock more wallets.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                _walletDashboardCard(
                                  title: 'BPI',
                                  subtitle: 'Premium Wallet',
                                  amount: 'Locked',
                                  color: Colors.grey.shade500,
                                  icon: Icons.lock_rounded,
                                  unlocked: false,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Upgrade to unlock more wallets.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                _walletDashboardCard(
                                  title: 'BDO',
                                  subtitle: 'Premium Wallet',
                                  amount: 'Locked',
                                  color: Colors.grey.shade500,
                                  icon: Icons.lock_rounded,
                                  unlocked: false,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Upgrade to unlock more wallets.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          if (monthlyBudget > 0) ...[
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                        AppTheme.warning.withOpacity(0.12),
                                        child: const Icon(
                                          Icons.flag_rounded,
                                          color: AppTheme.warning,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Monthly Budget Goal',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Used ${peso(monthlyExpenses)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Limit ${peso(monthlyBudget)}',
                                        style: const TextStyle(
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: budgetProgress,
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(30),
                                    backgroundColor: Colors.grey.shade200,
                                    color: overBudget
                                        ? AppTheme.expense
                                        : nearLimit
                                        ? AppTheme.warning
                                        : AppTheme.primary,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    overBudget
                                        ? 'You are over your monthly budget.'
                                        : nearLimit
                                        ? 'You are close to your monthly budget limit.'
                                        : 'You are within your monthly budget.',
                                    style: TextStyle(
                                      color: overBudget
                                          ? AppTheme.expense
                                          : nearLimit
                                          ? AppTheme.warning
                                          : AppTheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (topCategory.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor:
                                    AppTheme.primary.withOpacity(0.12),
                                    child: const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Monthly Summary',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Your highest expense this month is $topCategory.',
                                          style: const TextStyle(
                                            color: AppTheme.textDark,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'You spent ${peso(topCategoryAmount)} on this category.',
                                          style: const TextStyle(
                                            color: AppTheme.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 30),

                          const Text(
                            'Quick Overview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _overviewCard(
                                  title: 'Transactions',
                                  value: transactions.length.toString(),
                                  icon: Icons.receipt_long_rounded,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _overviewCard(
                                  title: 'Savings',
                                  value: peso(totalSaved),
                                  icon: Icons.savings_rounded,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Transactions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const TransactionHistoryScreen(),
                                    ),
                                  );
                                },
                                child: const Text('See All'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          if (transactions.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(26),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.wallet_rounded,
                                    size: 42,
                                    color: AppTheme.textLight,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'No transactions yet',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Start tracking your gastos and income.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...transactions.take(5).map((transaction) {
                              final isIncome = transaction.type == 'Income';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: isIncome
                                          ? Colors.green.withOpacity(0.12)
                                          : Colors.red.withOpacity(0.12),
                                      child: Icon(
                                        isIncome
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        color: isIncome
                                            ? AppTheme.income
                                            : AppTheme.expense,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction.category,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            transaction.note.isEmpty
                                                ? transaction.walletName
                                                : '${transaction.walletName} • ${transaction.note}',
                                            style: const TextStyle(
                                              color: AppTheme.textLight,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isIncome ? '+' : '-'}${peso(transaction.amount)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: isIncome
                                            ? AppTheme.income
                                            : AppTheme.expense,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                          const SizedBox(height: 0),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  static Widget _miniBalanceCard({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(
              icon,
              color: color,
              size: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _walletDashboardCard({
    required String title,
    required String subtitle,
    required String amount,
    required Color color,
    required IconData icon,
    required bool unlocked,
    String? income,
    String? expenses,
    String? savings,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: unlocked ? 1 : 0.6,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: unlocked
                ? LinearGradient(
              colors: [
                color,
                color.withOpacity(0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: [
                Colors.grey.shade500,
                Colors.grey.shade400,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(
                      icon,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (!unlocked)
                    const Icon(
                      Icons.lock_rounded,
                      color: Colors.white70,
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (unlocked) ...[
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _miniBalanceCard(
                        icon: Icons.arrow_upward_rounded,
                        label: 'Income',
                        amount: income ?? '₱ 0',
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _miniBalanceCard(
                        icon: Icons.arrow_downward_rounded,
                        label: 'Expenses',
                        amount: expenses ?? '₱ 0',
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _overviewCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.12),
            child: Icon(
              icon,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}