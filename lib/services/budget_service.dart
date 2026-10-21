import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _budgetRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('budget');
  }

  Stream<BudgetModel?> getBudget(String userId) {
    return _budgetRef(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;

      return BudgetModel.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> saveBudget({
    required String userId,
    required double monthlyLimit,
  }) async {
    await _budgetRef(userId).set({
      'userId': userId,
      'monthlyLimit': monthlyLimit,
      'updatedAt': Timestamp.now(),
    });
  }
}