import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_data.dart';
import '../models/user_settings.dart';
import '../theme/app_theme.dart';
import 'expense_plan_screen.dart';
import 'expense_log_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardScreen(),
    const ExpensePlanScreen(),
    const ExpenseLogScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton(
              onPressed: () => _showQuickAddExpense(context),
              child: const Icon(Icons.add),
            )
          : _currentIndex == 1
              ? FloatingActionButton(
                  onPressed: () => _showQuickAddPayment(context),
                  child: const Icon(Icons.payment),
                )
              : null,
    );
  }

  void _showQuickAddExpense(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _QuickAddExpenseSheet(),
    );
  }

  void _showQuickAddPayment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _QuickAddPaymentSheet(),
    );
  }
}

class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseData, UserSettings>(
      builder: (context, expenseData, settings, child) {
        final summary = expenseData.getMonthlySummary();
        final currency = settings.currency;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text('Dashboard - ${expenseData.currentMonth}'),
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_calendar),
                  onPressed: () => _showMonthPicker(context, expenseData),
                  tooltip: 'Change Month',
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIncomeCard(summary, currency),
                    const SizedBox(height: 16),
                    _buildCreditCardSummary(summary, currency),
                    const SizedBox(height: 16),
                    _buildRentBillsSummary(summary, currency),
                    const SizedBox(height: 16),
                    _buildDailyExpensesSummary(expenseData, currency),
                    const SizedBox(height: 16),
                    _buildOverallSummary(summary, currency),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIncomeCard(MonthlySummary summary, String currency) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Income & Available Funds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn('Monthly Salary', '${_formatCurrency(summary.salary, currency)}', Colors.green),
                ),
                Expanded(
                  child: _buildInfoColumn('Other Income', '${_formatCurrency(summary.otherIncome, currency)}', Colors.blue),
                ),
                Expanded(
                  child: _buildInfoColumn('Total Available', '${_formatCurrency(summary.salary + summary.otherIncome, currency)}', AppTheme.primaryColor, isTotal: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardSummary(MonthlySummary summary, String currency) {
    final isOverdue = summary.totalCurrentOutstanding > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Credit Cards', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Outstanding',
                      style: TextStyle(
                        color: AppTheme.dangerColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Previous Outstanding', summary.totalPreviousOutstanding, currency),
            _buildSummaryRow('New Spending', summary.totalNewSpending, currency),
            _buildSummaryRow('Payments Made', summary.totalPayments, currency, isPositive: false),
            const Divider(),
            _buildSummaryRow('Current Outstanding', summary.totalCurrentOutstanding, currency, isTotal: true, color: isOverdue ? AppTheme.dangerColor : AppTheme.primaryColor),
            const SizedBox(height: 8),
            _buildSummaryRow('Total Minimum Due', summary.totalMinimumDue, currency, color: AppTheme.warningColor),
            _buildSummaryRow('Total Statement Due', summary.totalStatementDue, currency),
          ],
        ),
      ),
    );
  }

  Widget _buildRentBillsSummary(MonthlySummary summary, String currency) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rent & Monthly Bills', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildSummaryRow('This Month Payable', summary.totalRentBillsPayable, currency),
            _buildSummaryRow('Total Amount', summary.totalRentBillsAmount, currency),
            _buildSummaryRow('Paid', summary.totalRentBillsPaid, currency, isPositive: false),
            const Divider(),
            _buildSummaryRow('Balance', summary.totalRentBillsBalance, currency, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyExpensesSummary(ExpenseData expenseData, String currency) {
    final categories = expenseData.dailyExpenses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Expenses Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...categories.map((cat) => _buildCategoryRow(cat, expenseData, currency)),
            const Divider(),
            _buildSummaryRow(
              'Total Budget',
              expenseData.totalDailyBudget,
              currency,
            ),
            _buildSummaryRow(
              'Total Spent',
              expenseData.totalDailySpent,
              currency,
              color: AppTheme.dangerColor,
            ),
            _buildSummaryRow(
              'Left',
              expenseData.totalDailyLeft,
              currency,
              isTotal: true,
              color: expenseData.totalDailyLeft >= 0 ? AppTheme.secondaryColor : AppTheme.dangerColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(DailyExpense cat, ExpenseData expenseData, String currency) {
    final spent = expenseData.getCategorySpent(cat.name);
    final left = expenseData.getCategoryLeft(cat.name);
    final percentage = cat.budget > 0 ? (spent / cat.budget) * 100 : 0;

    Color progressColor = AppTheme.secondaryColor;
    if (percentage >= 100) progressColor = AppTheme.dangerColor;
    else if (percentage >= 75) progressColor = AppTheme.warningColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  cat.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '${_formatCurrency(spent, currency)} / ${_formatCurrency(cat.budget, currency)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: cat.budget > 0 ? (spent / cat.budget).clamp(0.0, 1.0) : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallSummary(MonthlySummary summary, String currency) {
    return Card(
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monthly Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildSummaryRow('Total Monthly Payments', summary.totalMonthlyPayments, currency),
            const Divider(),
            _buildSummaryRow('Remaining After Payments', summary.remainingCashAfterPayments, currency, isTotal: true, color: summary.remainingCashAfterPayments >= 0 ? AppTheme.secondaryColor : AppTheme.dangerColor),
            _buildSummaryRow('After Daily Expenses', summary.cashLeftAfterDailyExpenses, currency, isTotal: true, color: summary.cashLeftAfterDailyExpenses >= 0 ? AppTheme.secondaryColor : AppTheme.dangerColor),
            const Divider(),
            _buildSummaryRow('Total Outstanding (Cards + Bills)', summary.totalOutstanding, currency, isTotal: true, color: AppTheme.warningColor),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Add Expense',
                Icons.add_shopping_cart,
                AppTheme.secondaryColor,
                () => Navigator.pushNamed(context, '/expense-log'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Scan Receipt',
                Icons.camera_alt,
                AppTheme.primaryColor,
                () => Navigator.pushNamed(context, '/receipt-scanner'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'View Reports',
                Icons.analytics,
                Colors.purple,
                () => Navigator.pushNamed(context, '/reports'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Next Month',
                Icons.calendar_today,
                Colors.orange,
                () => _rollToNextMonth(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value,
    String currency, {
    bool isPositive = true,
    bool isTotal = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 15 : 14,
            ),
          ),
          Text(
            '${isPositive && value >= 0 ? '+' : ''}${_formatCurrency(value, currency)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 15 : 14,
              color: color ?? (value < 0 ? AppTheme.dangerColor : (isPositive ? AppTheme.textPrimary : AppTheme.dangerColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value, String currency) {
    final formatter = NumberFormat.currency(symbol: '$currency ', decimalDigits: 2);
    return formatter.format(value.abs());
  }

  void _showMonthPicker(BuildContext context, ExpenseData expenseData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Month'),
        content: SizedBox(
          width: 300,
          child: Consumer<ExpenseData>(
            builder: (context, data, _) => TextField(
              decoration: const InputDecoration(
                labelText: 'Month (e.g., December 2026)',
                hintText: data.currentMonth,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  data.setCurrentMonth(value);
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _rollToNextMonth(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Roll to Next Month?'),
        content: const Text('This will:\n• Move current card outstanding to previous\n• Move bill balances to total amount\n• Clear expense log\n• Keep daily expense budgets'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<ExpenseData>().rollToNextMonth();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rolled to next month')),
              );
            },
            child: const Text('Roll Over'),
          ),
        ],
      ),
    );
  }
}

class _QuickAddExpenseSheet extends StatefulWidget {
  const _QuickAddExpenseSheet();

  @override
  State<_QuickAddExpenseSheet> createState() => _QuickAddExpenseSheetState();
}

class _QuickAddExpenseSheetState extends State<_QuickAddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'Petrol';
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _paymentMethod = 'Cash';
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Petrol', 'Grocery', 'Outside Food', 'Others'];
    final paymentMethods = ['Cash', 'Card', 'UPI', 'Bank Transfer'];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Add Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description', hintText: 'e.g., Fuel at ADNOC'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount (AED)', hintText: '0.00'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                if (double.tryParse(v!) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Payment Method'),
              items: paymentMethods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveExpense,
                child: const Text('Add Expense'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expenseData = context.read<ExpenseData>();
      final entry = ExpenseLogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        category: _category,
        description: _descriptionController.text,
        paymentMethod: _paymentMethod,
        amount: double.parse(_amountController.text),
        notes: _notesController.text,
      );
      expenseData.addExpenseLogEntry(entry);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added')),
      );
    }
  }
}

class _QuickAddPaymentSheet extends StatefulWidget {
  const _QuickAddPaymentSheet();

  @override
  State<_QuickAddPaymentSheet> createState() => _QuickAddPaymentSheetState();
}

class _QuickAddPaymentSheetState extends State<_QuickAddPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Credit Card';
  String? _selectedItem;
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, expenseData, _) {
        final cardItems = expenseData.creditCards.map((c) => c.name).toList();
        final billItems = expenseData.rentBills.map((b) => b.name).toList();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quick Add Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Credit Card', 'Rent/Bill'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _type = v!;
                      _selectedItem = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedItem,
                  decoration: InputDecoration(labelText: _type == 'Credit Card' ? 'Card' : 'Bill'),
                  items: (_type == 'Credit Card' ? cardItems : billItems)
                      .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedItem = v),
                  validator: (v) => v == null ? 'Select an item' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount (AED)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    if (double.tryParse(v!) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _savePayment(expenseData),
                    child: const Text('Add Payment'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _savePayment(ExpenseData expenseData) {
    if (_formKey.currentState!.validate() && _selectedItem != null) {
      final amount = double.parse(_amountController.text);

      if (_type == 'Credit Card') {
        final card = expenseData.creditCards.firstWhere((c) => c.name == _selectedItem);
        card = card.copyWith(paymentMade: card.paymentMade + amount);
        expenseData.updateCreditCard(card);
      } else {
        final bill = expenseData.rentBills.firstWhere((b) => b.name == _selectedItem);
        bill = RentBill(
          id: bill.id,
          name: bill.name,
          thisMonthPayable: bill.thisMonthPayable,
          totalAmount: bill.totalAmount,
          paid: bill.paid + amount,
          dueDate: bill.dueDate,
          notes: bill.notes,
        );
        expenseData.updateRentBill(bill);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded')),
      );
    }
  }
}