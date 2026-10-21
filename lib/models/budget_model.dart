import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String userId;
  final double monthlyLimit;
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.monthlyLimit,
    required this.updatedAt,
  });

  factory BudgetModel.fromMap(String id, Map<String, dynamic> data) {
    return BudgetModel(
      id: id,
      userId: data['userId'] ?? '',
      monthlyLimit: (data['monthlyLimit'] ?? 0).toDouble(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'monthlyLimit': monthlyLimit,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}