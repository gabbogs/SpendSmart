import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String type;
  final int iconCode;
  final int colorValue;
  final bool isDefault;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.iconCode,
    required this.colorValue,
    required this.isDefault,
    required this.createdAt,
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? 'Expense',
      iconCode: data['iconCode'] ?? 0xe574,
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
      'iconCode': iconCode,
      'colorValue': colorValue,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}