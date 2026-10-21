import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _transactionsRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionsRef(transaction.userId).add(transaction.toMap());
  }

  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    return _transactionsRef(userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();

      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionsRef(transaction.userId)
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  }) async {
    await _transactionsRef(userId).doc(transactionId).delete();
  }
}