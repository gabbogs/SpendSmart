import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../theme/app_theme.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../data/default_categories.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();
  final WalletService _walletService = WalletService();

  late String _type;
  late String _category;
  late String _paymentMethod;
  late String _walletId;
  late String _walletName;
  late DateTime _selectedDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _type = widget.transaction.type;
    _category = widget.transaction.category;
    _paymentMethod = widget.transaction.paymentMethod;
    _walletId = widget.transaction.walletId;
    _walletName = widget.transaction.walletName;
    _selectedDate = widget.transaction.date;

    _amountController.text = widget.transaction.amount.toString();
    _noteController.text = widget.transaction.note;
  }

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedTransaction = TransactionModel(
        id: widget.transaction.id,
        userId: widget.transaction.userId,
        type: _type,
        amount: double.parse(_amountController.text.trim()),
        category: _category,
        paymentMethod: _paymentMethod,
        walletId: _walletId,
        walletName: _walletName,
        note: _noteController.text.trim(),
        date: _selectedDate,
        createdAt: widget.transaction.createdAt,
      );

      await _transactionService.updateTransaction(updatedTransaction);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction updated successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update transaction: $e'),
        ),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Widget _typeButton(String value) {
    final bool selected = _type == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: selected
                ? value == 'Income'
                ? AppTheme.income
                : AppTheme.expense
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(CategoryModel category) {
    final bool selected = _category == category.name;

    return GestureDetector(
      onTap: () {
        setState(() {
          _category = category.name;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Color(category.colorValue).withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Color(category.colorValue)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconData(
                category.iconCode,
                fontFamily: 'MaterialIcons',
              ),
              size: 18,
              color: selected
                  ? Color(category.colorValue)
                  : AppTheme.textLight,
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected
                    ? Color(category.colorValue)
                    : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletChip(WalletModel wallet) {
    final unlocked = wallet.name == 'Wallet';

    final selected = _walletId == wallet.id ||
        (_walletId.isEmpty && wallet.name == 'Wallet');

    final color = unlocked ? Color(wallet.colorValue) : Colors.grey.shade500;

    final icon = unlocked
        ? IconData(
      wallet.iconCode,
      fontFamily: 'MaterialIcons',
    )
        : Icons.lock_rounded;

    return GestureDetector(
      onTap: unlocked
          ? () {
        setState(() {
          _walletId = wallet.id;
          _walletName = wallet.name;
        });
      }
          : () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upgrade to unlock more wallets.'),
          ),
        );
      },
      child: Opacity(
        opacity: unlocked ? 1 : 0.55,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withOpacity(0.12)
                : unlocked
                ? Colors.white
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                unlocked ? wallet.name : '${wallet.name} 🔒',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Edit Transaction'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction Type',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    _typeButton('Income'),
                    const SizedBox(width: 12),
                    _typeButton('Expense'),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  'Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '₱ ',
                    hintText: '0.00',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount is required';
                    }

                    final amount = double.tryParse(value);

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                const Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 14),

                StreamBuilder<List<CategoryModel>>(
                  stream: _categoryService.getUserCategories(
                    currentUser!.uid,
                  ),
                  builder: (context, snapshot) {
                    final customCategories = snapshot.data ?? [];

                    final defaultCategories = DefaultCategories.getAll();

                    final categories = [
                      ...defaultCategories,
                      ...customCategories,
                    ].where((category) => category.type == _type).toList();

                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((category) {
                        return _categoryChip(category);
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 28),

                const Text(
                  'Wallet',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 14),

                StreamBuilder<List<WalletModel>>(
                  stream: _walletService.getUserWallets(
                    currentUser.uid,
                  ),
                  builder: (context, snapshot) {
                    final wallets = snapshot.data ?? [];

                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: wallets.map((wallet) {
                        return _walletChip(wallet);
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add a note (optional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                          AppTheme.primary.withOpacity(0.12),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Transaction Date',
                                style: TextStyle(
                                  color:
                                  AppTheme.textLight,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                                style: const TextStyle(
                                  fontWeight:
                                  FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 34),

                ElevatedButton.icon(
                  onPressed:
                  _isLoading ? null : _updateTransaction,
                  icon:
                  const Icon(Icons.save_rounded),
                  label: Text(
                    _isLoading
                        ? 'Updating...'
                        : 'Update Transaction',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}