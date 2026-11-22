import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense_data.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE credit_cards (
        id TEXT PRIMARY KEY,
        name TEXT,
        previousOutstanding REAL,
        newSpending REAL,
        paymentMade REAL,
        minimumDue REAL,
        totalDue REAL,
        dueDate TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE rent_bills (
        id TEXT PRIMARY KEY,
        name TEXT,
        thisMonthPayable REAL,
        totalAmount REAL,
        paid REAL,
        dueDate TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_expenses (
        id TEXT PRIMARY KEY,
        name TEXT,
        budget REAL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE expense_log (
        id TEXT PRIMARY KEY,
        date INTEGER,
        category TEXT,
        description TEXT,
        paymentMethod TEXT,
        amount REAL,
        notes TEXT
      )
    ''');
  }

  Future<void> init() async {
    await database;
  }

  // Settings
  Future<void> setCurrentMonth(String month) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': 'current_month', 'value': month},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCurrentMonth() async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['current_month'],
    );
    if (result.isNotEmpty) return result.first['value'] as String?;
    return null;
  }

  Future<void> setSalary(double salary) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': 'salary', 'value': salary.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double?> getSalary() async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['salary'],
    );
    if (result.isNotEmpty) return double.tryParse(result.first['value'] as String);
    return null;
  }

  Future<void> setOtherIncome(double income) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': 'other_income', 'value': income.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double?> getOtherIncome() async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['other_income'],
    );
    if (result.isNotEmpty) return double.tryParse(result.first['value'] as String);
    return null;
  }

  // Credit Cards
  Future<List<CreditCard>> getCreditCards() async {
    final db = await database;
    final result = await db.query('credit_cards');
    return result.map((map) => CreditCard.fromMap(map)).toList();
  }

  Future<void> saveCreditCard(CreditCard card) async {
    final db = await database;
    await db.insert(
      'credit_cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Rent Bills
  Future<List<RentBill>> getRentBills() async {
    final db = await database;
    final result = await db.query('rent_bills');
    return result.map((map) => RentBill.fromMap(map)).toList();
  }

  Future<void> saveRentBill(RentBill bill) async {
    final db = await database;
    await db.insert(
      'rent_bills',
      bill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Daily Expenses
  Future<List<DailyExpense>> getDailyExpenses() async {
    final db = await database;
    final result = await db.query('daily_expenses');
    return result.map((map) => DailyExpense.fromMap(map)).toList();
  }

  Future<void> saveDailyExpense(DailyExpense expense) async {
    final db = await database;
    await db.insert(
      'daily_expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Expense Log
  Future<List<ExpenseLogEntry>> getExpenseLog() async {
    final db = await database;
    final result = await db.query('expense_log', orderBy: 'date DESC');
    return result.map((map) => ExpenseLogEntry.fromMap(map)).toList();
  }

  Future<void> saveExpenseLogEntry(ExpenseLogEntry entry) async {
    final db = await database;
    await db.insert(
      'expense_log',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteExpenseLogEntry(String id) async {
    final db = await database;
    await db.delete('expense_log', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearExpenseLog() async {
    final db = await database;
    await db.delete('expense_log');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('credit_cards');
    await db.delete('rent_bills');
    await db.delete('daily_expenses');
    await db.delete('expense_log');
    await db.delete('settings');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}