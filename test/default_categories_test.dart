import 'package:flutter_test/flutter_test.dart';
import 'package:spendsmart/data/default_categories.dart';

void main() {
  group('DefaultCategories', () {
    test('expense categories include local essentials', () {
      final names = DefaultCategories.getExpenseCategories().map((c) => c.name);
      expect(names, containsAll(['Food', 'Fare / Commute', 'School', 'Load']));
    });

    test('income categories include allowance and salary', () {
      final names = DefaultCategories.getIncomeCategories().map((c) => c.name);
      expect(names, containsAll(['Allowance', 'Salary']));
    });

    test('every default category has the right type and is marked default', () {
      for (final c in DefaultCategories.getExpenseCategories()) {
        expect(c.type, 'Expense');
        expect(c.isDefault, isTrue);
      }
      for (final c in DefaultCategories.getIncomeCategories()) {
        expect(c.type, 'Income');
        expect(c.isDefault, isTrue);
      }
    });

    test('default category ids are unique', () {
      final all = [
        ...DefaultCategories.getExpenseCategories(),
        ...DefaultCategories.getIncomeCategories(),
      ];
      expect(all.map((c) => c.id).toSet().length, all.length);
    });
  });
}
