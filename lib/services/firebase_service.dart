import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_data.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Anonymous sign in failed: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Email sign in failed: $e');
      return null;
    }
  }

  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Registration failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Save all data to Firestore
  Future<void> backupData(ExpenseData expenseData) async {
    final user = currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(user.uid);

    // Settings
    batch.set(userRef.collection('settings').doc('current_month'), {
      'value': expenseData.currentMonth,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(userRef.collection('settings').doc('salary'), {
      'value': expenseData.salary,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(userRef.collection('settings').doc('other_income'), {
      'value': expenseData.otherIncome,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Credit Cards
    for (final card in expenseData.creditCards) {
      batch.set(userRef.collection('credit_cards').doc(card.id), card.toMap());
    }

    // Rent Bills
    for (final bill in expenseData.rentBills) {
      batch.set(userRef.collection('rent_bills').doc(bill.id), bill.toMap());
    }

    // Daily Expenses
    for (final expense in expenseData.dailyExpenses) {
      batch.set(userRef.collection('daily_expenses').doc(expense.id), expense.toMap());
    }

    // Expense Log (only last 100 entries to avoid large writes)
    final recentLog = expenseData.expenseLog.take(100).toList();
    for (final entry in recentLog) {
      batch.set(userRef.collection('expense_log').doc(entry.id), entry.toMap());
    }

    await batch.commit();
  }

  // Restore data from Firestore
  Future<void> restoreData(ExpenseData expenseData) async {
    final user = currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);

    // Settings
    final monthDoc = await userRef.collection('settings').doc('current_month').get();
    if (monthDoc.exists) await expenseData.setCurrentMonth(monthDoc['value'] as String);

    final salaryDoc = await userRef.collection('settings').doc('salary').get();
    if (salaryDoc.exists) await expenseData.setSalary((salaryDoc['value'] as num).toDouble());

    final otherIncomeDoc = await userRef.collection('settings').doc('other_income').get();
    if (otherIncomeDoc.exists) await expenseData.setOtherIncome((otherIncomeDoc['value'] as num).toDouble());

    // Credit Cards
    final cardsSnapshot = await userRef.collection('credit_cards').get();
    for (final doc in cardsSnapshot.docs) {
      final card = CreditCard.fromMap(doc.data());
      await expenseData.updateCreditCard(card);
    }

    // Rent Bills
    final billsSnapshot = await userRef.collection('rent_bills').get();
    for (final doc in billsSnapshot.docs) {
      final bill = RentBill.fromMap(doc.data());
      await expenseData.updateRentBill(bill);
    }

    // Daily Expenses
    final expensesSnapshot = await userRef.collection('daily_expenses').get();
    for (final doc in expensesSnapshot.docs) {
      final expense = DailyExpense.fromMap(doc.data());
      await expenseData.updateDailyExpense(expense);
    }

    // Expense Log
    final logSnapshot = await userRef.collection('expense_log')
        .orderBy('date', descending: true)
        .limit(200)
        .get();
    for (final doc in logSnapshot.docs) {
      final entry = ExpenseLogEntry.fromMap(doc.data());
      expenseData._expenseLog.add(entry);
    }
    expenseData.notifyListeners();
  }

  // Real-time sync listener
  Stream<void> syncListener(ExpenseData expenseData) {
    final user = currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.exists) {
        await restoreData(expenseData);
      }
    });
  }
}