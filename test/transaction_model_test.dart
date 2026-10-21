import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsmart/models/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    final date = DateTime(2026, 10, 21, 9, 41);
    final transaction = TransactionModel(
      id: 'tx1',
      userId: 'user1',
      type: 'Expense',
      amount: 250,
      category: 'Food',
      paymentMethod: 'Cash',
      walletId: 'wallet1',
      walletName: 'Wallet',
      note: 'Lunch with classmates',
      date: date,
      createdAt: date,
    );

    test('toMap stores dates as Firestore timestamps', () {
      final map = transaction.toMap();
      expect(map['amount'], 250);
      expect(map['category'], 'Food');
      expect(map['date'], isA<Timestamp>());
      expect((map['date'] as Timestamp).toDate(), date);
    });

    test('fromMap restores the same values', () {
      final restored = TransactionModel.fromMap('tx1', transaction.toMap());
      expect(restored.id, 'tx1');
      expect(restored.type, 'Expense');
      expect(restored.amount, 250.0);
      expect(restored.note, 'Lunch with classmates');
      expect(restored.date, date);
    });

    test('fromMap fills in defaults for missing fields', () {
      final restored = TransactionModel.fromMap('tx2', {'amount': 100});
      expect(restored.amount, 100.0);
      expect(restored.walletName, 'Wallet');
      expect(restored.category, '');
    });
  });
}
