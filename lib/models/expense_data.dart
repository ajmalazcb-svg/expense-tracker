import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class CreditCard {
  String id;
  String name;
  double previousOutstanding;
  double newSpending;
  double paymentMade;
  double minimumDue;
  double totalDue;
  String dueDate;
  String notes;

  CreditCard({
    required this.id,
    required this.name,
    this.previousOutstanding = 0,
    this.newSpending = 0,
    this.paymentMade = 0,
    this.minimumDue = 0,
    this.totalDue = 0,
    this.dueDate = '',
    this.notes = '',
  });

  double get currentOutstanding =>
      previousOutstanding + newSpending - paymentMade;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'previousOutstanding': previousOutstanding,
      'newSpending': newSpending,
      'paymentMade': paymentMade,
      'minimumDue': minimumDue,
      'totalDue': totalDue,
      'dueDate': dueDate,
      'notes': notes,
    };
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'],
      name: map['name'],
      previousOutstanding: (map['previousOutstanding'] ?? 0).toDouble(),
      newSpending: (map['newSpending'] ?? 0).toDouble(),
      paymentMade: (map['paymentMade'] ?? 0).toDouble(),
      minimumDue: (map['minimumDue'] ?? 0).toDouble(),
      totalDue: (map['totalDue'] ?? 0).toDouble(),
      dueDate: map['dueDate'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  CreditCard copyWith({
    String? id,
    String? name,
    double? previousOutstanding,
    double? newSpending,
    double? paymentMade,
    double? minimumDue,
    double? totalDue,
    String? dueDate,
    String? notes,
  }) {
    return CreditCard(
      id: id ?? this.id,
      name: name ?? this.name,
      previousOutstanding: previousOutstanding ?? this.previousOutstanding,
      newSpending: newSpending ?? this.newSpending,
      paymentMade: paymentMade ?? this.paymentMade,
      minimumDue: minimumDue ?? this.minimumDue,
      totalDue: totalDue ?? this.totalDue,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }
}

class RentBill {
  String id;
  String name;
  double thisMonthPayable;
  double totalAmount;
  double paid;
  String dueDate;
  String notes;

  RentBill({
    required this.id,
    required this.name,
    this.thisMonthPayable = 0,
    this.totalAmount = 0,
    this.paid = 0,
    this.dueDate = '',
    this.notes = '',
  });

  double get balance => totalAmount - paid;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'thisMonthPayable': thisMonthPayable,
      'totalAmount': totalAmount,
      'paid': paid,
      'dueDate': dueDate,
      'notes': notes,
    };
  }

  factory RentBill.fromMap(Map<String, dynamic> map) {
    return RentBill(
      id: map['id'],
      name: map['name'],
      thisMonthPayable: (map['thisMonthPayable'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paid: (map['paid'] ?? 0).toDouble(),
      dueDate: map['dueDate'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}

class DailyExpense {
  String id;
  String name;
  double budget;
  String notes;

  DailyExpense({
    required this.id,
    required this.name,
    this.budget = 0,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'budget': budget,
      'notes': notes,
    };
  }

  factory DailyExpense.fromMap(Map<String, dynamic> map) {
    return DailyExpense(
      id: map['id'],
      name: map['name'],
      budget: (map['budget'] ?? 0).toDouble(),
      notes: map['notes'] ?? '',
    );
  }
}

class ExpenseLogEntry {
  String id;
  DateTime date;
  String category; // Petrol, Grocery, Outside Food, Others
  String description;
  String paymentMethod;
  double amount;
  String notes;

  ExpenseLogEntry({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.paymentMethod,
    required this.amount,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'description': description,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'notes': notes,
    };
  }

  factory ExpenseLogEntry.fromMap(Map<String, dynamic> map) {
    return ExpenseLogEntry(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      category: map['category'],
      description: map['description'],
      paymentMethod: map['paymentMethod'],
      amount: (map['amount'] ?? 0).toDouble(),
      notes: map['notes'] ?? '',
    );
  }
}

class MonthlySummary {
  final String month;
  final double salary;
  final double otherIncome;

  // Credit Cards
  final double totalPreviousOutstanding;
  final double totalNewSpending;
  final double totalPayments;
  final double totalCurrentOutstanding;
  final double totalMinimumDue;
  final double totalStatementDue;

  // Rent & Bills
  final double totalRentBillsPayable;
  final double totalRentBillsAmount;
  final double totalRentBillsPaid;
  final double totalRentBillsBalance;

  // Daily Expenses
  final double totalDailyBudget;
  final double totalDailySpent;
  final double totalDailyLeft;

  // Overall
  final double totalMonthlyPayments;
  final double remainingCashAfterPayments;
  final double cashLeftAfterDailyExpenses;
  final double totalOutstanding;

  MonthlySummary({
    required this.month,
    required this.salary,
    required this.otherIncome,
    required this.totalPreviousOutstanding,
    required this.totalNewSpending,
    required this.totalPayments,
    required this.totalCurrentOutstanding,
    required this.totalMinimumDue,
    required this.totalStatementDue,
    required this.totalRentBillsPayable,
    required this.totalRentBillsAmount,
    required this.totalRentBillsPaid,
    required this.totalRentBillsBalance,
    required this.totalDailyBudget,
    required this.totalDailySpent,
    required this.totalDailyLeft,
    required this.totalMonthlyPayments,
    required this.remainingCashAfterPayments,
    required this.cashLeftAfterDailyExpenses,
    required this.totalOutstanding,
  });
}

class ExpenseData extends ChangeNotifier {
  final DatabaseService _db;

  String _currentMonth = 'November 2026';
  double _salary = 7500;
  double _otherIncome = 0;

  List<CreditCard> _creditCards = [];
  List<RentBill> _rentBills = [];
  List<DailyExpense> _dailyExpenses = [];
  List<ExpenseLogEntry> _expenseLog = [];

  ExpenseData(this._db) {
    _loadData();
  }

  String get currentMonth => _currentMonth;
  double get salary => _salary;
  double get otherIncome => _otherIncome;
  double get totalAvailable => _salary + _otherIncome;

  List<CreditCard> get creditCards => _creditCards;
  List<RentBill> get rentBills => _rentBills;
  List<DailyExpense> get dailyExpenses => _dailyExpenses;
  List<ExpenseLogEntry> get expenseLog => _expenseLog;

  // Credit Card totals
  double get totalPreviousOutstanding =>
      _creditCards.fold(0, (sum, c) => sum + c.previousOutstanding);
  double get totalNewSpending =>
      _creditCards.fold(0, (sum, c) => sum + c.newSpending);
  double get totalPayments =>
      _creditCards.fold(0, (sum, c) => sum + c.paymentMade);
  double get totalCurrentOutstanding =>
      _creditCards.fold(0, (sum, c) => sum + c.currentOutstanding);
  double get totalMinimumDue =>
      _creditCards.fold(0, (sum, c) => sum + c.minimumDue);
  double get totalStatementDue =>
      _creditCards.fold(0, (sum, c) => sum + c.totalDue);

  // Rent & Bills totals
  double get totalRentBillsPayable =>
      _rentBills.fold(0, (sum, b) => sum + b.thisMonthPayable);
  double get totalRentBillsAmount =>
      _rentBills.fold(0, (sum, b) => sum + b.totalAmount);
  double get totalRentBillsPaid =>
      _rentBills.fold(0, (sum, b) => sum + b.paid);
  double get totalRentBillsBalance =>
      _rentBills.fold(0, (sum, b) => sum + b.balance);

  // Daily Expenses totals
  double get totalDailyBudget =>
      _dailyExpenses.fold(0, (sum, d) => sum + d.budget);
  double get totalDailySpent => _calculateDailySpent();
  double get totalDailyLeft => totalDailyBudget - totalDailySpent;

  // Overall
  double get totalMonthlyPayments => totalPayments + totalRentBillsPaid;
  double get remainingCashAfterPayments => totalAvailable - totalMonthlyPayments;
  double get cashLeftAfterDailyExpenses => remainingCashAfterPayments - totalDailyBudget;
  double get totalOutstanding => totalCurrentOutstanding + totalRentBillsBalance;

  Future<void> _loadData() async {
    _currentMonth = await _db.getCurrentMonth() ?? 'November 2026';
    _salary = await _db.getSalary() ?? 7500;
    _otherIncome = await _db.getOtherIncome() ?? 0;

    _creditCards = await _db.getCreditCards();
    if (_creditCards.isEmpty) {
      _creditCards = _getDefaultCreditCards();
      await _saveCreditCards();
    }

    _rentBills = await _db.getRentBills();
    if (_rentBills.isEmpty) {
      _rentBills = _getDefaultRentBills();
      await _saveRentBills();
    }

    _dailyExpenses = await _db.getDailyExpenses();
    if (_dailyExpenses.isEmpty) {
      _dailyExpenses = _getDefaultDailyExpenses();
      await _saveDailyExpenses();
    }

    _expenseLog = await _db.getExpenseLog();
    notifyListeners();
  }

  List<CreditCard> _getDefaultCreditCards() {
    return [
      CreditCard(
        id: '1',
        name: 'DIB 1',
        previousOutstanding: 12000,
        minimumDue: 2169.94,
      ),
      CreditCard(
        id: '2',
        name: 'DIB 2',
        previousOutstanding: 12000,
        minimumDue: 1378.58,
      ),
      CreditCard(
        id: '3',
        name: 'Ajman Bank',
        previousOutstanding: 11000,
        minimumDue: 3307.67,
      ),
      CreditCard(
        id: '4',
        name: 'NBF',
        previousOutstanding: 5000,
        minimumDue: 1148.83,
      ),
      CreditCard(
        id: '5',
        name: 'FAB',
        previousOutstanding: 6500,
        minimumDue: 572.84,
      ),
      CreditCard(
        id: '6',
        name: 'Citi',
        previousOutstanding: 17000,
        minimumDue: 1576.37,
      ),
    ];
  }

  List<RentBill> _getDefaultRentBills() {
    return [
      RentBill(id: '1', name: 'Room Rent', thisMonthPayable: 2100, totalAmount: 2100),
      RentBill(id: '2', name: 'Tabby', thisMonthPayable: 1500, totalAmount: 5000),
      RentBill(id: '3', name: 'BOTIM', thisMonthPayable: 1218.44, totalAmount: 4000),
      RentBill(id: '4', name: 'Cash Now', thisMonthPayable: 1733.33, totalAmount: 10425.56, paid: 3492.24),
      RentBill(id: '5', name: 'Office', thisMonthPayable: 1000, totalAmount: 10000),
    ];
  }

  List<DailyExpense> _getDefaultDailyExpenses() {
    return [
      DailyExpense(id: '1', name: 'Petrol', budget: 400),
      DailyExpense(id: '2', name: 'Grocery', budget: 500),
      DailyExpense(id: '3', name: 'Outside Food', budget: 150),
      DailyExpense(id: '4', name: 'Others', budget: 200, notes: 'Baby Toys'),
    ];
  }

  double _calculateDailySpent() {
    double spent = 0;
    for (var expense in _dailyExpenses) {
      spent += _getCategorySpent(expense.name);
    }
    return spent;
  }

  double _getCategorySpent(String category) {
    return _expenseLog
        .where((e) => e.category == category)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getCategorySpent(String category) => _getCategorySpent(category);
  double getCategoryLeft(String category) {
    final expense = _dailyExpenses.firstWhere(
      (e) => e.name == category,
      orElse: () => DailyExpense(id: '', name: category, budget: 0),
    );
    return expense.budget - _getCategorySpent(category);
  }

  // Setters
  Future<void> setCurrentMonth(String month) async {
    _currentMonth = month;
    await _db.setCurrentMonth(month);
    notifyListeners();
  }

  Future<void> setSalary(double salary) async {
    _salary = salary;
    await _db.setSalary(salary);
    notifyListeners();
  }

  Future<void> setOtherIncome(double income) async {
    _otherIncome = income;
    await _db.setOtherIncome(income);
    notifyListeners();
  }

  Future<void> updateCreditCard(CreditCard card) async {
    final index = _creditCards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _creditCards[index] = card;
      await _db.saveCreditCard(card);
      notifyListeners();
    }
  }

  Future<void> updateRentBill(RentBill bill) async {
    final index = _rentBills.indexWhere((b) => b.id == bill.id);
    if (index != -1) {
      _rentBills[index] = bill;
      await _db.saveRentBill(bill);
      notifyListeners();
    }
  }

  Future<void> updateDailyExpense(DailyExpense expense) async {
    final index = _dailyExpenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _dailyExpenses[index] = expense;
      await _db.saveDailyExpense(expense);
      notifyListeners();
    }
  }

  Future<void> addExpenseLogEntry(ExpenseLogEntry entry) async {
    _expenseLog.add(entry);
    await _db.saveExpenseLogEntry(entry);
    notifyListeners();
  }

  Future<void> deleteExpenseLogEntry(String id) async {
    _expenseLog.removeWhere((e) => e.id == id);
    await _db.deleteExpenseLogEntry(id);
    notifyListeners();
  }

  Future<void> _saveCreditCards() async {
    for (var card in _creditCards) {
      await _db.saveCreditCard(card);
    }
  }

  Future<void> _saveRentBills() async {
    for (var bill in _rentBills) {
      await _db.saveRentBill(bill);
    }
  }

  Future<void> _saveDailyExpenses() async {
    for (var expense in _dailyExpenses) {
      await _db.saveDailyExpense(expense);
    }
  }

  MonthlySummary getMonthlySummary() {
    return MonthlySummary(
      month: _currentMonth,
      salary: _salary,
      otherIncome: _otherIncome,
      totalPreviousOutstanding: totalPreviousOutstanding,
      totalNewSpending: totalNewSpending,
      totalPayments: totalPayments,
      totalCurrentOutstanding: totalCurrentOutstanding,
      totalMinimumDue: totalMinimumDue,
      totalStatementDue: totalStatementDue,
      totalRentBillsPayable: totalRentBillsPayable,
      totalRentBillsAmount: totalRentBillsAmount,
      totalRentBillsPaid: totalRentBillsPaid,
      totalRentBillsBalance: totalRentBillsBalance,
      totalDailyBudget: totalDailyBudget,
      totalDailySpent: totalDailySpent,
      totalDailyLeft: totalDailyLeft,
      totalMonthlyPayments: totalMonthlyPayments,
      remainingCashAfterPayments: remainingCashAfterPayments,
      cashLeftAfterDailyExpenses: cashLeftAfterDailyExpenses,
      totalOutstanding: totalOutstanding,
    );
  }

  // Roll to next month
  Future<void> rollToNextMonth() async {
    // Credit cards: current outstanding becomes previous
    for (var card in _creditCards) {
      card = card.copyWith(
        previousOutstanding: card.currentOutstanding,
        newSpending: 0,
        paymentMade: 0,
      );
      await _db.saveCreditCard(card);
    }

    // Rent bills: balance becomes total amount
    for (var bill in _rentBills) {
      bill = RentBill(
        id: bill.id,
        name: bill.name,
        thisMonthPayable: bill.balance,
        totalAmount: bill.balance,
        paid: 0,
        dueDate: bill.dueDate,
        notes: bill.notes,
      );
      await _db.saveRentBill(bill);
    }

    // Clear expense log
    await _db.clearExpenseLog();
    _expenseLog.clear();

    notifyListeners();
  }
}