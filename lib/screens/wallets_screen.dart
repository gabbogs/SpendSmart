import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/wallet_model.dart';
import '../services/wallet_service.dart';
import '../theme/app_theme.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  final WalletService _walletService = WalletService();

  String peso(double value) =>
      '₱ ${NumberFormat.decimalPattern().format(value)}';

  final String _currentPlan = 'Basic';

  final List<String> _walletTypes = [
    'Cash',
    'Digital Wallet',
    'Bank',
  ];

  final List<Color> _colors = [
    const Color(0xFF8B5E34),
    const Color(0xFF2563EB),
    const Color(0xFF06B6D4),
    const Color(0xFFDC2626),
    const Color(0xFF1E3A8A),
    AppTheme.primary,
    Colors.purple,
  ];

  bool _isWalletUnlocked(WalletModel wallet) {
    if (_currentPlan == 'Premium') return true;
    if (_currentPlan == 'Plus') return true;

    return wallet.name == 'Wallet';
  }

  void _showUpgradeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Upgrade to Plus or Premium to unlock more wallets.',
        ),
      ),
    );
  }

  IconData _walletIcon(String type) {
    switch (type) {
      case 'Digital Wallet':
        return Icons.account_balance_wallet_rounded;
      case 'Bank':
        return Icons.account_balance_rounded;
      default:
        return Icons.wallet_rounded;
    }
  }

  Future<void> _showWalletDialog({
    required String userId,
    WalletModel? wallet,
  }) async {
    final isEditing = wallet != null;

    final nameController = TextEditingController(
      text: wallet?.name ?? '',
    );

    final balanceController = TextEditingController(
      text: wallet == null
          ? ''
          : NumberFormat.decimalPattern().format(wallet.initialBalance),
    );

    String selectedType = wallet?.type ?? 'Cash';
    Color selectedColor =
    wallet == null ? AppTheme.primary : Color(wallet.colorValue);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Wallet' : 'Add Wallet'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Wallet Name',
                        hintText: 'e.g. GCash, Maya, BDO',
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Wallet Type',
                      ),
                      items: _walletTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: balanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Starting Balance',
                        prefixText: '₱ ',
                        hintText: '0',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose Color',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _colors.map((color) {
                        final selected = selectedColor.value == color.value;

                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: selected
                                ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                                : null,
                          ),
                        );
                      }).toList(),
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
                    final name = nameController.text.trim();

                    final balance = double.tryParse(
                      balanceController.text.replaceAll(',', '').trim(),
                    );

                    if (name.isEmpty || balance == null || balance < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter valid wallet details.',
                          ),
                        ),
                      );
                      return;
                    }

                    final icon = _walletIcon(selectedType);

                    final model = WalletModel(
                      id: wallet?.id ?? '',
                      userId: userId,
                      name: name,
                      type: selectedType,
                      initialBalance: balance,
                      iconCode: icon.codePoint,
                      colorValue: selectedColor.value,
                      isDefault: wallet?.isDefault ?? false,
                      createdAt: wallet?.createdAt ?? DateTime.now(),
                    );

                    if (isEditing) {
                      await _walletService.updateWallet(model);
                    } else {
                      await _walletService.addWallet(model);
                    }

                    if (!dialogContext.mounted) return;

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Wallet updated successfully.'
                              : 'Wallet added successfully.',
                        ),
                      ),
                    );
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user logged in.'),
        ),
      );
    }

    _walletService.createDefaultWalletsIfNeeded(user.uid);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Wallets'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        onPressed: _showUpgradeMessage,
        child: const Icon(Icons.add_rounded),
      ),
      body: StreamBuilder<List<WalletModel>>(
        stream: _walletService.getUserWallets(user.uid),
        builder: (context, snapshot) {
          final wallets = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Basic users can use Wallet only. Upgrade to Plus for 3 wallets or Premium for unlimited wallets.',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              ...wallets.map((wallet) {
                final unlocked = _isWalletUnlocked(wallet);
                final color = unlocked
                    ? Color(wallet.colorValue)
                    : Colors.grey.shade500;

                final icon = unlocked
                    ? IconData(
                  wallet.iconCode,
                  fontFamily: 'MaterialIcons',
                )
                    : Icons.lock_rounded;

                return GestureDetector(
                  onTap: unlocked
                      ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Default wallet cannot be edited.',
                        ),
                      ),
                    );
                  }
                      : _showUpgradeMessage,
                  child: Opacity(
                    opacity: unlocked ? 1.0 : 0.55,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? Colors.white
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: unlocked
                              ? Colors.transparent
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: unlocked
                                ? color.withOpacity(0.14)
                                : Colors.grey.shade300,
                            child: Icon(
                              icon,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        wallet.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ),
                                    if (!unlocked) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.lock_rounded,
                                        size: 15,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  unlocked
                                      ? wallet.type
                                      : 'Upgrade required',
                                  style: const TextStyle(
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Default',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
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
      ),
    );
  }
}