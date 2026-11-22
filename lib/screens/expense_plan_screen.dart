import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_data.dart';
import '../models/user_settings.dart';
import '../theme/app_theme.dart';

class ExpensePlanScreen extends StatelessWidget {
  const ExpensePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<ExpenseData>(
            builder: (context, data, _) => Text('Plan - ${data.currentMonth}'),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Income'),
              Tab(text: 'Credit Cards'),
              Tab(text: 'Rent & Bills'),
              Tab(text: 'Daily Budget'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _IncomeTab(),
            _CreditCardsTab(),
            _RentBillsTab(),
            _DailyBudgetTab(),
          ],
        ),
      ),
    );
  }
}

class _IncomeTab extends StatelessWidget {
  const _IncomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseData, UserSettings>(
      builder: (context, expenseData, settings, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Monthly Income', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _buildIncomeField(
                      'Monthly Salary / Income',
                      expenseData.salary,
                      (v) => expenseData.setSalary(v),
                      settings.currency,
                    ),
                    const SizedBox(height: 12),
                    _buildIncomeField(
                      'Other Income',
                      expenseData.otherIncome,
                      (v) => expenseData.setOtherIncome(v),
                      settings.currency,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Available', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(
                          '${settings.currency} ${NumberFormat('#,##0.00').format(expenseData.totalAvailable)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppTheme.primaryColor.withOpacity(0.05),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How it works', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text('• Enter your monthly salary and any additional income'),
                    Text('• This is your starting point for the month'),
                    Text('• All expenses and payments are deducted from this'),
                    Text('• Change the month from Dashboard to start fresh'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIncomeField(String label, double value, Function(double) onChanged, String currency) {
    final controller = TextEditingController(text: value.toStringAsFixed(2));
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '$currency ',
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onFieldSubmitted: (v) {
        final val = double.tryParse(v) ?? 0;
        onChanged(val);
      },
    );
  }
}

class _CreditCardsTab extends StatelessWidget {
  const _CreditCardsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseData, UserSettings>(
      builder: (context, expenseData, settings, _) {
        final cards = expenseData.creditCards;
        final currency = settings.currency;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Credit Cards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        Text(
                          'Total Outstanding: ${currency} ${NumberFormat('#,##0.00').format(expenseData.totalCurrentOutstanding)}',
                          style: TextStyle(
                            color: expenseData.totalCurrentOutstanding > 0 ? AppTheme.dangerColor : AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Current = Previous + New Spending - Payment\nMinimum Due & Total Due: copy from bank statement',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...cards.map((card) => _CreditCardCard(card: card, currency: currency)).toList(),
            const SizedBox(height: 16),
            _CreditCardTotals(cards: cards, currency: currency),
          ],
        );
      },
    );
  }
}

class _CreditCardCard extends StatelessWidget {
  final CreditCard card;
  final String currency;

  const _CreditCardCard({required this.card, required this.currency});

  @override
  Widget build(BuildContext context) {
    final expenseData = context.read<ExpenseData>();
    final currentOutstanding = card.currentOutstanding;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text(card.name, style: const TextStyle(fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: currentOutstanding > 0 ? AppTheme.dangerColor.withOpacity(0.1) : AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${currency} ${NumberFormat('#,##0.00').format(currentOutstanding)}',
                style: TextStyle(
                  color: currentOutstanding > 0 ? AppTheme.dangerColor : AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildEditableRow('Previous Outstanding', card.previousOutstanding, (v) {
                  expenseData.updateCreditCard(card.copyWith(previousOutstanding: v));
                }),
                _buildEditableRow('New Spending / Withdrawal', card.newSpending, (v) {
                  expenseData.updateCreditCard(card.copyWith(newSpending: v));
                }),
                _buildEditableRow('Payment Made', card.paymentMade, (v) {
                  expenseData.updateCreditCard(card.copyWith(paymentMade: v));
                }),
                const Divider(),
                _buildReadOnlyRow('Current Outstanding', currentOutstanding, isTotal: true),
                const SizedBox(height: 8),
                _buildEditableRow('Statement Minimum Due', card.minimumDue, (v) {
                  expenseData.updateCreditCard(card.copyWith(minimumDue: v));
                }),
                _buildEditableRow('Statement Total Due', card.totalDue, (v) {
                  expenseData.updateCreditCard(card.copyWith(totalDue: v));
                }),
                _buildEditableRow('Due Date', card.dueDate, (v) {
                  expenseData.updateCreditCard(card.copyWith(dueDate: v));
                }, isText: true),
                _buildEditableRow('Notes', card.notes, (v) {
                  expenseData.updateCreditCard(card.copyWith(notes: v));
                }, isText: true, maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, dynamic value, Function(dynamic) onChanged, {bool isText = false, int maxLines = 1}) {
    if (isText) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TextFormField(
          initialValue: value as String,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          maxLines: maxLines,
          onFieldSubmitted: (v) => onChanged(v),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        initialValue: (value as double).toStringAsFixed(2),
        decoration: InputDecoration(labelText: label, prefixText: '$currency ', border: const OutlineInputBorder()),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onFieldSubmitted: (v) => onChanged(double.tryParse(v) ?? 0),
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal)),
          Text(
            '${currency} ${NumberFormat('#,##0.00').format(value)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: value < 0 ? AppTheme.dangerColor : (isTotal ? AppTheme.primaryColor : null),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditCardTotals extends StatelessWidget {
  final List<CreditCard> cards;
  final String currency;

  const _CreditCardTotals({required this.cards, required this.currency});

  @override
  Widget build(BuildContext context) {
    final totalPrev = cards.fold(0.0, (sum, c) => sum + c.previousOutstanding);
    final totalNew = cards.fold(0.0, (sum, c) => sum + c.newSpending);
    final totalPay = cards.fold(0.0, (sum, c) => sum + c.paymentMade);
    final totalCurr = cards.fold(0.0, (sum, c) => sum + c.currentOutstanding);
    final totalMin = cards.fold(0.0, (sum, c) => sum + c.minimumDue);
    final totalDue = cards.fold(0.0, (sum, c) => sum + c.totalDue);

    return Card(
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TOTALS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _totRow('Total Previous Outstanding', totalPrev),
            _totRow('Total New Spending', totalNew),
            _totRow('Total Payments Made', totalPay),
            const Divider(),
            _totRow('Total Current Outstanding', totalCurr, isTotal: true),
            const SizedBox(height: 8),
            _totRow('Total Minimum Due', totalMin, color: AppTheme.warningColor),
            _totRow('Total Statement Due', totalDue),
          ],
        ),
      ),
    );
  }

  Widget _totRow(String label, double value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal)),
          Text(
            '${currency} ${NumberFormat('#,##0.00').format(value)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: color ?? (isTotal && value > 0 ? AppTheme.dangerColor : null),
            ),
          ),
        ],
      ),
    );
  }
}

class _RentBillsTab extends StatelessWidget {
  const _RentBillsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseData, UserSettings>(
      builder: (context, expenseData, settings, _) {
        final bills = expenseData.rentBills;
        final currency = settings.currency;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rent & Monthly Bills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        Text(
                          'Balance: ${currency} ${NumberFormat('#,##0.00').format(expenseData.totalRentBillsBalance)}',
                          style: TextStyle(
                            color: expenseData.totalRentBillsBalance > 0 ? AppTheme.warningColor : AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Balance = Total Amount - Paid', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...bills.map((bill) => _RentBillCard(bill: bill, currency: currency)).toList(),
            const SizedBox(height: 16),
            _RentBillTotals(bills: bills, currency: currency),
          ],
        );
      },
    );
  }
}

class _RentBillCard extends StatelessWidget {
  final RentBill bill;
  final String currency;

  const _RentBillCard({required this.bill, required this.currency});

  @override
  Widget build(BuildContext context) {
    final expenseData = context.read<ExpenseData>();
    final balance = bill.balance;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text(bill.name, style: const TextStyle(fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: balance > 0 ? AppTheme.warningColor.withOpacity(0.1) : AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${currency} ${NumberFormat('#,##0.00').format(balance)}',
                style: TextStyle(
                  color: balance > 0 ? AppTheme.warningColor : AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildEditableRow('This Month Payable', bill.thisMonthPayable, (v) {
                  expenseData.updateRentBill(RentBill(
                    id: bill.id,
                    name: bill.name,
                    thisMonthPayable: v,
                    totalAmount: bill.totalAmount,
                    paid: bill.paid,
                    dueDate: bill.dueDate,
                    notes: bill.notes,
                  ));
                }),
                _buildEditableRow('Total Amount', bill.totalAmount, (v) {
                  expenseData.updateRentBill(RentBill(
                    id: bill.id,
                    name: bill.name,
                    thisMonthPayable: bill.thisMonthPayable,
                    totalAmount: v,
                    paid: bill.paid,
                    dueDate: bill.dueDate,
                    notes: bill.notes,
                  ));
                }),
                _buildEditableRow('Paid', bill.paid, (v) {
                  expenseData.updateRentBill(RentBill(
                    id: bill.id,
                    name: bill.name,
                    thisMonthPayable: bill.thisMonthPayable,
                    totalAmount: bill.totalAmount,
                    paid: v,
                    dueDate: bill.dueDate,
                    notes: bill.notes,
                  ));
                }),
                const Divider(),
                _buildReadOnlyRow('Balance', balance, isTotal: true),
                _buildEditableRow('Due Date / Notes', bill.dueDate, (v) {
                  expenseData.updateRentBill(RentBill(
                    id: bill.id,
                    name: bill.name,
                    thisMonthPayable: bill.thisMonthPayable,
                    totalAmount: bill.totalAmount,
                    paid: bill.paid,
                    dueDate: v,
                    notes: bill.notes,
                  ));
                }, isText: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, dynamic value, Function(dynamic) onChanged, {bool isText = false}) {
    if (isText) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TextFormField(
          initialValue: value as String,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          onFieldSubmitted: (v) => onChanged(v),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        initialValue: (value as double).toStringAsFixed(2),
        decoration: InputDecoration(labelText: label, prefixText: '$currency ', border: const OutlineInputBorder()),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onFieldSubmitted: (v) => onChanged(double.tryParse(v) ?? 0),
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal)),
          Text(
            '${currency} ${NumberFormat('#,##0.00').format(value)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: value > 0 ? AppTheme.warningColor : (isTotal ? AppTheme.secondaryColor : null),
            ),
          ),
        ],
      ),
    );
  }
}

class _RentBillTotals extends StatelessWidget {
  final List<RentBill> bills;
  final String currency;

  const _RentBillTotals({required this.bills, required this.currency});

  @override
  Widget build(BuildContext context) {
    final totalPayable = bills.fold(0.0, (sum, b) => sum + b.thisMonthPayable);
    final totalAmount = bills.fold(0.0, (sum, b) => sum + b.totalAmount);
    final totalPaid = bills.fold(0.0, (sum, b) => sum + b.paid);
    final totalBalance = bills.fold(0.0, (sum, b) => sum + b.balance);

    return Card(
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TOTALS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _totRow('Total This Month Payable', totalPayable),
            _totRow('Total Amount', totalAmount),
            _totRow('Total Paid', totalPaid),
            const Divider(),
            _totRow('Total Balance', totalBalance, isTotal: true, color: totalBalance > 0 ? AppTheme.warningColor : AppTheme.secondaryColor),
          ],
        ),
      ),
    );
  }

  Widget _totRow(String label, double value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal)),
          Text(
            '${currency} ${NumberFormat('#,##0.00').format(value)}',
            style: TextStyle(fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal, color: color),
          ),
        ],
      ),
    );
  }
}

class _DailyBudgetTab extends StatelessWidget {
  const _DailyBudgetTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseData, UserSettings>(
      builder: (context, expenseData, settings, _) {
        final expenses = expenseData.dailyExpenses;
        final currency = settings.currency;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Daily Expenses Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        Text(
                          'Left: ${currency} ${NumberFormat('#,##0.00').format(expenseData.totalDailyLeft)}',
                          style: TextStyle(
                            color: expenseData.totalDailyLeft >= 0 ? AppTheme.secondaryColor : AppTheme.dangerColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Left = Set Aside - Spent (spent comes from Expense Log)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...expenses.map((expense) => _DailyExpenseCard(expense: expense, currency: currency)).toList(),
            const SizedBox(height: 16),
            _DailyExpenseTotals(expenses: expenses, currency: currency),
          ],
        );
      },
    );
  }
}

class _DailyExpenseCard extends StatelessWidget {
  final DailyExpense expense;
  final String currency;

  const _DailyExpenseCard({required this.expense, required this.currency});

  @override
  Widget build(BuildContext context) {
    final expenseData = context.read<ExpenseData>();
    final spent = expenseData.getCategorySpent(expense.name);
    final left = expenseData.getCategoryLeft(expense.name);
    final percentage = expense.budget > 0 ? (spent / expense.budget) * 100 : 0;

    Color progressColor = AppTheme.secondaryColor;
    if (percentage >= 100) progressColor = AppTheme.dangerColor;
    else if (percentage >= 75) progressColor = AppTheme.warningColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text(expense.name, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(
              '${currency} ${NumberFormat('#,##0.00').format(spent)} / ${NumberFormat('#,##0.00').format(expense.budget)}',
              style: TextStyle(fontWeight: FontWeight.w600, color: progressColor),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: expense.budget > 0 ? (spent / expense.budget).clamp(0.0, 1.0) : 0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                _buildEditableRow('Set Aside / Budget', expense.budget, (v) {
                  expenseData.updateDailyExpense(DailyExpense(
                    id: expense.id,
                    name: expense.name,
                    budget: v,
                    notes: expense.notes,
                  ));
                }),
                _buildReadOnlyRow('Spent So Far', spent, color: AppTheme.dangerColor),
                _buildReadOnlyRow('Left', left, isTotal: true, color: left >= 0 ? AppTheme.secondaryColor : AppTheme.dangerColor),
                if (expense.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Notes: ${expense.notes}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        initialValue: value.toStringAsFixed(2),
        decoration: InputDecoration(labelText: label, prefixText: '$currency ', border: const OutlineInputBorder()),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onFieldSubmitted: (v) => onChanged(double.tryParse(v) ?? 0),
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, double value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal)),
          Text(
            '${currency} ${NumberFormat('#,##0.00').format(value)}',
            style: TextStyle(fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal, color: color),
          ),
        ],
      ),
    );
  }
}

class _DailyExpenseTotals extends StatelessWidget {
  final List<DailyExpense> expenses;
  final String currency;

  const _DailyExpenseTotals({required this.expenses, required this.currency});

  @override
  Widget build(BuildContext context) {
    final expenseData = context.read<ExpenseData>();

    return Card(
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TOTALS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _totRow('Total Budget', expenseData.totalDailyBudget),
            _totRow('Total Spent', expenseData.totalDailySpent, color: AppTheme.dangerColor),
            const Divider(),
            _totRow('Total Left', expenseData.totalDailyLeft, isTotal: true, color: expenseData.totalDailyLeft >= 0 ? AppTheme.secondaryColor : AppTheme.dangerColor),
          ],
        ),
      ),
    );
  }

  Widget _totRow(String label, double value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal)),
          Text(
            '${currency} ${NumberFormat('#,##0.00').format(value)}',
            style: TextStyle(fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal, color: color),
          ),
        ],
      ),
    );
  }
}