import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wallet_model.dart';
import 'package:flutter/material.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _walletsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('wallets');
  }

  Stream<List<WalletModel>> getUserWallets(String userId) {
    return _walletsRef(userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WalletModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addWallet(WalletModel wallet) async {
    await _walletsRef(wallet.userId).add(wallet.toMap());
  }

  Future<void> updateWallet(WalletModel wallet) async {
    await _walletsRef(wallet.userId).doc(wallet.id).update(wallet.toMap());
  }

  Future<void> deleteWallet({
    required String userId,
    required String walletId,
  }) async {
    await _walletsRef(userId).doc(walletId).delete();
  }

  Future<void> createDefaultWalletsIfNeeded(String userId) async {
    final snapshot = await _walletsRef(userId).limit(1).get();

    if (snapshot.docs.isNotEmpty) return;

    final defaultWallets = [
      WalletModel(
        id: '',
        userId: userId,
        name: 'Wallet',
        type: 'Cash',
        initialBalance: 0,
        iconCode: Icons.account_balance_wallet_rounded.codePoint,
        colorValue: 0xFF8B5E34,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      WalletModel(
        id: '',
        userId: userId,
        name: 'GCash',
        type: 'Digital Wallet',
        initialBalance: 0,
        iconCode: 0xe850,
        colorValue: 0xFF2563EB,
        isDefault: true,
        createdAt: DateTime.now().add(const Duration(milliseconds: 1)),
      ),
      WalletModel(
        id: '',
        userId: userId,
        name: 'Maya',
        type: 'Digital Wallet',
        initialBalance: 0,
        iconCode: 0xe850,
        colorValue: 0xFF06B6D4,
        isDefault: true,
        createdAt: DateTime.now().add(const Duration(milliseconds: 2)),
      ),
      WalletModel(
        id: '',
        userId: userId,
        name: 'BPI',
        type: 'Bank',
        initialBalance: 0,
        iconCode: 0xe84f,
        colorValue: 0xFFDC2626,
        isDefault: true,
        createdAt: DateTime.now().add(const Duration(milliseconds: 3)),
      ),
      WalletModel(
        id: '',
        userId: userId,
        name: 'BDO',
        type: 'Bank',
        initialBalance: 0,
        iconCode: 0xe84f,
        colorValue: 0xFF1E3A8A,
        isDefault: true,
        createdAt: DateTime.now().add(const Duration(milliseconds: 4)),
      ),
    ];

    for (final wallet in defaultWallets) {
      await addWallet(wallet);
    }
  }
}