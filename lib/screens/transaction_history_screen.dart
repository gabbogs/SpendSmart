import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../theme/app_theme.dart';
import 'edit_transaction_screen.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends State<TransactionHistoryScreen> {
  String _selectedWallet = 'All';

  String peso(double value) => '₱ ${NumberFormat.decimalPattern().format(value)}';

  void _showUpgradeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Upgrade to unlock more wallets.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final transactionService = TransactionService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: StreamBuilder<List<TransactionModel>>(
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

          if (allTransactions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 70,
                      color: AppTheme.textLight,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the + button below to add your first income or expense.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            );
          }

          double income = 0;
          double expenses = 0;

          for (final transaction in transactions) {
            if (transaction.type == 'Income') {
              income += transaction.amount;
            } else {
              expenses += transaction.amount;
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _topSummary(
                        label: 'Income',
                        amount: peso(income),
                        icon: Icons.arrow_upward_rounded,
                        color: AppTheme.income,
                      ),
                    ),
                    Container(
                      height: 48,
                      width: 1,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      child: _topSummary(
                        label: 'Expenses',
                        amount: peso(expenses),
                        icon: Icons.arrow_downward_rounded,
                        color: AppTheme.expense,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 24),

              Text(
                _selectedWallet == 'All'
                    ? 'All Transactions'
                    : '$_selectedWallet Transactions',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 14),

              if (transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    'No transactions found for $_selectedWallet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                    ),
                  ),
                )
              else
                ...transactions.map((transaction) {
                  final isIncome = transaction.type == 'Income';

                  return Dismissible(
                    key: Key(transaction.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 22),
                      decoration: BoxDecoration(
                        color: AppTheme.expense,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Transaction'),
                            content: const Text(
                              'Are you sure you want to delete this transaction?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) async {
                      await transactionService.deleteTransaction(
                        userId: user.uid,
                        transactionId: transaction.id,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction deleted.'),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditTransactionScreen(
                                transaction: transaction,
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: isIncome
                              ? AppTheme.income.withOpacity(0.12)
                              : AppTheme.expense.withOpacity(0.12),
                          child: Icon(
                            isIncome
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: isIncome
                                ? AppTheme.income
                                : AppTheme.expense,
                          ),
                        ),
                        title: Text(
                          transaction.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        subtitle: Text(
                          transaction.note.trim().isEmpty
                              ? transaction.walletName
                              : '${transaction.walletName} • ${transaction.note}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textLight,
                          ),
                        ),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}${peso(transaction.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isIncome
                                ? AppTheme.income
                                : AppTheme.expense,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  static Widget _topSummary({
    required String label,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 10),
        Text(
          amount,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textLight,
            fontSize: 13,
          ),
        ),
      ],
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
              color: selected
                  ? AppTheme.primary
                  : Colors.grey.shade300,
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
                  color: unlocked
                      ? AppTheme.textDark
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}