import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _categoriesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  Stream<List<CategoryModel>> getUserCategories(String userId) {
    return _categoriesRef(userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoriesRef(category.userId).add(category.toMap());
  }

  Future<void> updateCategory({
    required String userId,
    required String categoryId,
    required String name,
    required int iconCode,
    required int colorValue,
  }) async {
    await _categoriesRef(userId).doc(categoryId).update({
      'name': name.trim(),
      'iconCode': iconCode,
      'colorValue': colorValue,
    });
  }

  Future<void> deleteCategory({
    required String userId,
    required String categoryId,
  }) async {
    await _categoriesRef(userId).doc(categoryId).delete();
  }
}