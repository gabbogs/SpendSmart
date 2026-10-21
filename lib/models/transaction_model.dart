import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String type;
  final double amount;
  final String category;
  final String paymentMethod;
  final String walletId;
  final String walletName;
  final String note;
  final DateTime date;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.walletId,
    required this.walletName,
    required this.note,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'walletId': walletId,
      'walletName': walletName,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TransactionModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return TransactionModel(
      id: id,
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      walletId: map['walletId'] ?? '',
      walletName: map['walletName'] ?? 'Wallet',
      note: map['note'] ?? '',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}