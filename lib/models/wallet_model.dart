import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String id;
  final String userId;
  final String name;
  final String type;
  final double initialBalance;
  final int iconCode;
  final int colorValue;
  final bool isDefault;
  final DateTime createdAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.iconCode,
    required this.colorValue,
    required this.isDefault,
    required this.createdAt,
  });

  factory WalletModel.fromMap(String id, Map<String, dynamic> data) {
    return WalletModel(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? 'Cash',
      initialBalance: (data['initialBalance'] ?? 0).toDouble(),
      iconCode: data['iconCode'] ?? 0xe57c,
      colorValue: data['colorValue'] ?? 0xFF10B981,
      isDefault: data['isDefault'] ?? false,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'initialBalance': initialBalance,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}