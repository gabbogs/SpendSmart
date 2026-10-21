import 'package:flutter/material.dart';

import '../models/category_model.dart';

class DefaultCategories {
  static List<CategoryModel> getExpenseCategories() {
    return [
      _category('Food', 'Expense', Icons.restaurant_rounded, Colors.orange),
      _category('Fare / Commute', 'Expense', Icons.directions_bus_rounded, Colors.blue),
      _category('School', 'Expense', Icons.school_rounded, Colors.indigo),
      _category('Load', 'Expense', Icons.phone_android_rounded, Colors.teal),
      _category('Shopping', 'Expense', Icons.shopping_bag_rounded, Colors.pink),
      _category('Bills', 'Expense', Icons.receipt_long_rounded, Colors.deepPurple),
      _category('Rent', 'Expense', Icons.home_rounded, Colors.brown),
      _category('Health', 'Expense', Icons.favorite_rounded, Colors.red),
      _category('Entertainment', 'Expense', Icons.movie_rounded, Colors.amber),
      _category('Emergency', 'Expense', Icons.warning_amber_rounded, Colors.deepOrange),
    ];
  }

  static List<CategoryModel> getIncomeCategories() {
    return [
      _category('Allowance', 'Income', Icons.wallet_rounded, Colors.green),
      _category('Salary', 'Income', Icons.work_rounded, Colors.lightGreen),
      _category('Part-time', 'Income', Icons.schedule_rounded, Colors.cyan),
      _category('Business', 'Income', Icons.store_rounded, Colors.deepPurpleAccent),
      _category('Gift', 'Income', Icons.card_giftcard_rounded, Colors.purple),
      _category('Savings', 'Income', Icons.savings_rounded, Colors.greenAccent),
    ];
  }

  static List<CategoryModel> getAll() {
    return [
      ...getExpenseCategories(),
      ...getIncomeCategories(),
    ];
  }

  static CategoryModel _category(
      String name,
      String type,
      IconData icon,
      Color color,
      ) {
    return CategoryModel(
      id: 'default_${type}_$name',
      userId: '',
      name: name,
      type: type,
      iconCode: icon.codePoint,
      colorValue: color.value,
      isDefault: true,
      createdAt: DateTime(2020),
    );
  }
}