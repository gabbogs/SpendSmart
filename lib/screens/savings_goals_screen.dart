import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/savings_goal_model.dart';
import '../models/transaction_model.dart';
import '../services/savings_goal_service.dart';
import '../services/transaction_service.dart';
import '../theme/app_theme.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final SavingsGoalService _goalService = SavingsGoalService();
  final TransactionService _transactionService = TransactionService();

  String peso(double value) =>
      '₱ ${NumberFormat.decimalPattern().format(value)}';

  Future<void> _showErrorDialog(
      BuildContext dialogContext,
      String message,
      ) async {
    await showDialog(
      context: dialogContext,
      builder: (errorContext) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(errorContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGoalDialog({
    required String userId,
    SavingsGoalModel? goal,
  }) async {
    final titleController = TextEditingController(text: goal?.title ?? '');
    final targetController = TextEditingController(
      text: goal == null
          ? ''
          : NumberFormat.decimalPattern().format(goal.targetAmount),
    );

    final isEditing = goal != null;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Savings Goal' : 'Add Savings Goal'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Goal Name',
                    prefixIcon: Icon(Icons.flag_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target Amount',
                    prefixText: '₱ ',
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Current saved amount stays at ${peso(goal.savedAmount)}. Use Deposit or Transfer to adjust savings.',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();

                final target = double.tryParse(
                  targetController.text.replaceAll(',', '').trim(),
                );

                if (title.isEmpty || target == null || target <= 0) {
                  await _showErrorDialog(
                    dialogContext,
                    'Please enter valid goal details.',
                  );
                  return;
                }

                if (goal != null && target < goal.savedAmount) {
                  await _showErrorDialog(
                    dialogContext,
                    'Target amount cannot be lower than current saved amount.',
                  );
                  return;
                }

                final model = SavingsGoalModel(
                  id: goal?.id ?? '',
                  userId: userId,
                  title: title,
                  targetAmount: target,
                  savedAmount: goal?.savedAmount ?? 0,
                  createdAt: goal?.createdAt ?? DateTime.now(),
                );

                if (isEditing) {
                  await _goalService.updateGoal(model);
                } else {
                  await _goalService.addGoal(model);
                }

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                if (!mounted) return;

                Future.delayed(const Duration(milliseconds: 150), () {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Savings goal updated successfully.'
                            : 'Savings goal added successfully.',
                      ),
                    ),
                  );
                });
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDepositDialog({
    required SavingsGoalModel goal,
    required double availableToSave,
  }) async {
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        final remainingGoalAmount = goal.targetAmount - goal.savedAmount;
        final maxAllowed = availableToSave < remainingGoalAmount
            ? availableToSave
            : remainingGoalAmount;

        return AlertDialog(
          title: Text('Deposit to ${goal.title}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available to Save',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        peso(availableToSave),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: '₱ ',
                    hintText: 'Deposit amount',
                    helperText: 'Maximum: ${peso(maxAllowed)}',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(
                  amountController.text.replaceAll(',', '').trim(),
                );

                if (amount == null || amount <= 0) {
                  await _showErrorDialog(
                    dialogContext,
                    'Please enter a valid deposit amount.',
                  );
                  return;
                }

                if (amount > availableToSave) {
                  await _showErrorDialog(
                    dialogContext,
                    'Amount cannot exceed your available savings.',
                  );
                  return;
                }

                if (goal.savedAmount + amount > goal.targetAmount) {
                  await _showErrorDialog(
                    dialogContext,
                    'Amount cannot exceed the goal target.',
                  );
                  return;
                }

                final updatedGoal = SavingsGoalModel(
                  id: goal.id,
                  userId: goal.userId,
                  title: goal.title,
                  targetAmount: goal.targetAmount,
                  savedAmount: goal.savedAmount + amount,
                  createdAt: goal.createdAt,
                );

                await _goalService.updateGoal(updatedGoal);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                if (!mounted) return;

                Future.delayed(const Duration(milliseconds: 150), () {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${peso(amount)} deposited to ${goal.title}.',
                      ),
                    ),
                  );
                });
              },
              child: const Text('Deposit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTransferDialog({
    required SavingsGoalModel goal,
  }) async {
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Transfer from ${goal.title}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Saved',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        peso(goal.savedAmount),
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: '₱ ',
                    hintText: 'Transfer amount',
                    helperText: 'Maximum: ${peso(goal.savedAmount)}',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(
                  amountController.text.replaceAll(',', '').trim(),
                );

                if (amount == null || amount <= 0) {
                  await _showErrorDialog(
                    dialogContext,
                    'Please enter a valid transfer amount.',
                  );
                  return;
                }

                if (amount > goal.savedAmount) {
                  await _showErrorDialog(
                    dialogContext,
                    'Amount cannot exceed current saved amount.',
                  );
                  return;
                }

                final updatedGoal = SavingsGoalModel(
                  id: goal.id,
                  userId: goal.userId,
                  title: goal.title,
                  targetAmount: goal.targetAmount,
                  savedAmount: goal.savedAmount - amount,
                  createdAt: goal.createdAt,
                );

                await _goalService.updateGoal(updatedGoal);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                if (!mounted) return;

                Future.delayed(const Duration(milliseconds: 150), () {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${peso(amount)} transferred back to available balance.',
                      ),
                    ),
                  );
                });
              },
              child: const Text('Transfer'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDelete(SavingsGoalModel goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Savings Goal'),
          content: Text('Are you sure you want to delete "${goal.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return confirm == true;
  }

  double _calculateAvailableToSave({
    required List<TransactionModel> transactions,
    required List<SavingsGoalModel> goals,
  }) {
    double income = 0;
    double expenses = 0;

    for (final transaction in transactions) {
      if (transaction.type == 'Income') {
        income += transaction.amount;
      } else {
        expenses += transaction.amount;
      }
    }

    final allocatedSavings = goals.fold<double>(
      0,
          (sum, goal) => sum + goal.savedAmount,
    );

    final available = income - expenses - allocatedSavings;

    return available < 0 ? 0 : available;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Savings Goals'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showGoalDialog(userId: user.uid),
        child: const Icon(Icons.add_rounded),
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: _transactionService.getUserTransactions(user.uid),
        builder: (context, transactionSnapshot) {
          final transactions = transactionSnapshot.data ?? [];

          return StreamBuilder<List<SavingsGoalModel>>(
            stream: _goalService.getUserGoals(user.uid),
            builder: (context, snapshot) {
              final goals = snapshot.data ?? [];

              if (transactionSnapshot.connectionState ==
                  ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final availableToSave = _calculateAvailableToSave(
                transactions: transactions,
                goals: goals,
              );

              if (goals.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                  children: [
                    _availableToSaveCard(availableToSave),
                    const SizedBox(height: 120),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.savings_rounded,
                              size: 72,
                              color: AppTheme.textLight,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No savings goals yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap the + button to add your first goal.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textLight),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                children: [
                  _availableToSaveCard(availableToSave),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Goals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...goals.map((goal) {
                    final progress = goal.targetAmount > 0
                        ? (goal.savedAmount / goal.targetAmount)
                        .clamp(0.0, 1.0)
                        : 0.0;

                    final completed = goal.savedAmount >= goal.targetAmount;

                    final remainingGoalAmount =
                        goal.targetAmount - goal.savedAmount;

                    final canDeposit =
                        availableToSave > 0 && remainingGoalAmount > 0;

                    final canTransfer = goal.savedAmount > 0;

                    return Dismissible(
                      key: Key(goal.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 22),
                        decoration: BoxDecoration(
                          color: AppTheme.expense,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (_) => _confirmDelete(goal),
                      onDismissed: (_) async {
                        await _goalService.deleteGoal(
                          userId: user.uid,
                          goalId: goal.id,
                        );
                      },
                      child: GestureDetector(
                        onTap: () => _showGoalDialog(
                          userId: user.uid,
                          goal: goal,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: completed
                                        ? AppTheme.income.withOpacity(0.12)
                                        : AppTheme.primary.withOpacity(0.12),
                                    child: Icon(
                                      completed
                                          ? Icons.check_rounded
                                          : Icons.savings_rounded,
                                      color: completed
                                          ? AppTheme.income
                                          : AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      goal.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: completed
                                          ? AppTheme.income
                                          : AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              LinearProgressIndicator(
                                value: progress.toDouble(),
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(30),
                                backgroundColor: Colors.grey.shade200,
                                color: completed
                                    ? AppTheme.income
                                    : AppTheme.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${peso(goal.savedAmount)} saved of ${peso(goal.targetAmount)}',
                                style: const TextStyle(
                                  color: AppTheme.textLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: canDeposit
                                          ? () => _showDepositDialog(
                                        goal: goal,
                                        availableToSave:
                                        availableToSave,
                                      )
                                          : null,
                                      icon: const Icon(Icons.south_west_rounded),
                                      label: const Text('Deposit'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: canTransfer
                                          ? () => _showTransferDialog(
                                        goal: goal,
                                      )
                                          : null,
                                      icon: const Icon(Icons.north_east_rounded),
                                      label: const Text('Transfer'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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

  static Widget _availableToSaveCard(double availableToSave) {
    return Container(
      width: double.infinity,
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
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available to Save',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₱ ${NumberFormat.decimalPattern().format(availableToSave)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Balance left after expenses and allocated goals.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}