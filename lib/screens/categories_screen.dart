import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/category_service.dart';
import '../theme/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedTab = 0;
  final CategoryService _categoryService = CategoryService();

  final List<String> _defaultExpenseCategories = [
    'Food',
    'Fare / Commute',
    'School',
    'Load',
    'Shopping',
    'Bills',
    'Rent',
    'Health',
    'Entertainment',
    'Emergency',
  ];

  final List<String> _defaultIncomeCategories = [
    'Allowance',
    'Salary',
    'Part-time',
    'Business',
    'Gift',
    'Savings',
  ];

  final List<IconData> _availableIcons = [
    Icons.restaurant_rounded,
    Icons.directions_bus_rounded,
    Icons.school_rounded,
    Icons.phone_android_rounded,
    Icons.shopping_bag_rounded,
    Icons.receipt_long_rounded,
    Icons.home_rounded,
    Icons.favorite_rounded,
    Icons.movie_rounded,
    Icons.warning_amber_rounded,
    Icons.wallet_rounded,
    Icons.work_rounded,
    Icons.schedule_rounded,
    Icons.store_rounded,
    Icons.card_giftcard_rounded,
    Icons.savings_rounded,
    Icons.category_rounded,
  ];

  final List<Color> _availableColors = [
    Colors.orange,
    Colors.blue,
    Colors.indigo,
    Colors.teal,
    Colors.pink,
    Colors.deepPurple,
    Colors.brown,
    Colors.red,
    Colors.amber,
    Colors.deepOrange,
    Colors.green,
    Colors.lightGreen,
    Colors.cyan,
    Colors.purple,
    AppTheme.primary,
  ];

  final Map<String, IconData> _defaultIcons = {
    'Food': Icons.restaurant_rounded,
    'Fare / Commute': Icons.directions_bus_rounded,
    'School': Icons.school_rounded,
    'Load': Icons.phone_android_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Bills': Icons.receipt_long_rounded,
    'Rent': Icons.home_rounded,
    'Health': Icons.favorite_rounded,
    'Entertainment': Icons.movie_rounded,
    'Emergency': Icons.warning_amber_rounded,
    'Allowance': Icons.wallet_rounded,
    'Salary': Icons.work_rounded,
    'Part-time': Icons.schedule_rounded,
    'Business': Icons.store_rounded,
    'Gift': Icons.card_giftcard_rounded,
    'Savings': Icons.savings_rounded,
  };

  String get _selectedType => _selectedTab == 0 ? 'Expense' : 'Income';

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Fare / Commute':
        return Colors.blue;
      case 'School':
        return Colors.indigo;
      case 'Load':
        return Colors.teal;
      case 'Shopping':
        return Colors.pink;
      case 'Bills':
        return Colors.deepPurple;
      case 'Rent':
        return Colors.brown;
      case 'Health':
        return Colors.red;
      case 'Entertainment':
        return Colors.amber;
      case 'Emergency':
        return Colors.deepOrange;
      case 'Allowance':
        return Colors.green;
      case 'Salary':
        return Colors.lightGreen;
      case 'Part-time':
        return Colors.cyan;
      case 'Business':
        return Colors.deepPurpleAccent;
      case 'Gift':
        return Colors.purple;
      case 'Savings':
        return AppTheme.primary;
      default:
        return AppTheme.primary;
    }
  }

  Future<void> _showCategoryDialog({
    required String userId,
    CategoryModel? category,
  }) async {
    final controller = TextEditingController(text: category?.name ?? '');
    final isEditing = category != null;

    IconData selectedIcon = isEditing
        ? IconData(category.iconCode, fontFamily: 'MaterialIcons')
        : Icons.category_rounded;

    Color selectedColor = isEditing
        ? Color(category.colorValue)
        : (_selectedType == 'Expense' ? AppTheme.expense : AppTheme.income);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Category' : 'Add Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Category name',
                      ),
                    ),
                    const SizedBox(height: 18),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose Icon',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableIcons.map((icon) {
                        final selected = selectedIcon.codePoint == icon.codePoint;

                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedIcon = icon;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: selected
                                ? selectedColor.withOpacity(0.18)
                                : Colors.grey.shade100,
                            child: Icon(
                              icon,
                              color: selected ? selectedColor : AppTheme.textLight,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose Color',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableColors.map((color) {
                        final selected = selectedColor.value == color.value;

                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected ? Colors.black : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: selected
                                ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final value = controller.text.trim();

                    if (value.isEmpty) return;

                    if (isEditing) {
                      await _categoryService.updateCategory(
                        userId: userId,
                        categoryId: category.id,
                        name: value,
                        iconCode: selectedIcon.codePoint,
                        colorValue: selectedColor.value,
                      );
                    } else {
                      await _categoryService.addCategory(
                        CategoryModel(
                          id: '',
                          userId: userId,
                          name: value,
                          type: _selectedType,
                          iconCode: selectedIcon.codePoint,
                          colorValue: selectedColor.value,
                          isDefault: false,
                          createdAt: DateTime.now(),
                        ),
                      );
                    }

                    if (!dialogContext.mounted) return;

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Category updated successfully.'
                              : 'Category added successfully.',
                        ),
                      ),
                    );
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _confirmDelete(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return confirm == true;
  }

  List<CategoryModel> _buildDefaultCategories(String userId, String type) {
    final names =
    type == 'Expense' ? _defaultExpenseCategories : _defaultIncomeCategories;

    return names.map((name) {
      final icon = _defaultIcons[name] ?? Icons.category_rounded;
      final color = _getCategoryColor(name);

      return CategoryModel(
        id: 'default_${type}_$name',
        userId: userId,
        name: name,
        type: type,
        iconCode: icon.codePoint,
        colorValue: color.value,
        isDefault: true,
        createdAt: DateTime(2020),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showCategoryDialog(userId: user.uid),
        child: const Icon(Icons.add_rounded),
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: _categoryService.getUserCategories(user.uid),
        builder: (context, snapshot) {
          final customCategories = (snapshot.data ?? [])
              .where((category) => category.type == _selectedType)
              .toList();

          final categories = [
            ..._buildDefaultCategories(user.uid, _selectedType),
            ...customCategories,
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _tabButton('Expenses', 0),
                    _tabButton('Income', 1),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                _selectedType == 'Expense'
                    ? 'Expense Categories'
                    : 'Income Categories',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Tap custom categories to edit. Swipe left to delete.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else
                ...categories.map((category) {
                  return _categoryTile(
                    userId: user.uid,
                    category: category,
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _categoryTile({
    required String userId,
    required CategoryModel category,
  }) {
    final icon = IconData(category.iconCode, fontFamily: 'MaterialIcons');
    final color = Color(category.colorValue);

    final tile = Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListTile(
        onTap: category.isDefault
            ? null
            : () {
          _showCategoryDialog(
            userId: userId,
            category: category,
          );
        },
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.14),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          category.isDefault
              ? 'Default ${category.type.toLowerCase()} category'
              : 'Custom ${category.type.toLowerCase()} category',
          style: const TextStyle(
            color: AppTheme.textLight,
          ),
        ),
        trailing: category.isDefault
            ? Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Default',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        )
            : const Icon(
          Icons.edit_rounded,
          color: AppTheme.textLight,
          size: 20,
        ),
      ),
    );

    if (category.isDefault) return tile;

    return Dismissible(
      key: Key(category.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: AppTheme.expense,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        return await _confirmDelete(category);
      },
      onDismissed: (_) async {
        await _categoryService.deleteCategory(
          userId: userId,
          categoryId: category.id,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully.'),
          ),
        );
      },
      child: tile,
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}