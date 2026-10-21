import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoalModel {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime createdAt;

  SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.createdAt,
  });

  factory SavingsGoalModel.fromMap(String id, Map<String, dynamic> data) {
    return SavingsGoalModel(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      savedAmount: (data['savedAmount'] ?? 0).toDouble(),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}