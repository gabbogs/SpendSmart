import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/budget_service.dart';
import '../theme/app_theme.dart';

class BudgetSettingsScreen extends StatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  final NumberFormat _currencyFormat =
  NumberFormat.decimalPattern();
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  final BudgetService _budgetService = BudgetService();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final budget = await _budgetService.getBudget(user.uid).first;

    if (budget != null && budget.monthlyLimit > 0) {
      _budgetController.text = _currencyFormat.format(budget.monthlyLimit);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    await _budgetService.saveBudget(
      userId: user.uid,
      monthlyLimit: double.parse(_budgetController.text.replaceAll(',', '').trim(),
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Monthly budget saved successfully.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Budget Goal'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.flag_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Set your monthly spending limit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'SpendSmart will help you monitor if your expenses are getting close to your budget.',
                        style: TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Monthly Budget Limit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '₱ ',
                    hintText: '0',
                    prefixIcon: Icon(Icons.savings_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.replaceAll(',', '').trim().isEmpty) {
                      return 'Budget amount is required';
                    }

                    final amount = double.tryParse(value.replaceAll(',', '').trim());

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid budget amount';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
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
                          'Tip: Set a budget based on your allowance, salary, and regular expenses.',
                          style: TextStyle(
                            color: AppTheme.textLight,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 34),

                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveBudget,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Budget Goal',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}