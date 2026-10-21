import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/savings_goal_model.dart';

class SavingsGoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _goalsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('savingsGoals');
  }

  Stream<List<SavingsGoalModel>> getUserGoals(String userId) {
    return _goalsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SavingsGoalModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    await _goalsRef(goal.userId).add(goal.toMap());
  }

  Future<void> updateGoal(SavingsGoalModel goal) async {
    await _goalsRef(goal.userId).doc(goal.id).update(goal.toMap());
  }

  Future<void> deleteGoal({
    required String userId,
    required String goalId,
  }) async {
    await _goalsRef(userId).doc(goalId).delete();
  }
}