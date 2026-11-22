import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_data.dart';
import '../models/user_settings.dart';
import '../theme/app_theme.dart';

class ExpenseLogScreen extends StatelessWidget {
  const ExpenseLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseData, UserSettings>(
      builder: (context, expenseData, settings, _) {
        final entries = expenseData.expenseLog;
        final currency = settings.currency;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Expense Log'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context, expenseData),
                tooltip: 'Filter',
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _exportToExcel(context, expenseData, currency),
                tooltip: 'Export to Excel',
              ),
            ],
          ),
          body: entries.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _ExpenseLogTile(entry: entry, currency: currency);
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No expenses logged yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Tap + to add your first expense', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddExpenseDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, ExpenseData expenseData) {
    String? selectedCategory;
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Expenses'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Categories')),
                  ...['Petrol', 'Grocery', 'Outside Food', 'Others'].map(
                    (c) => DropdownMenuItem(value: c, child: Text(c)),
                  ),
                ],
                onChanged: (v) => setState(() => selectedCategory = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => startDate = date);
                      },
                      child: Text(startDate != null
                          ? 'From: ${DateFormat('MMM dd, yyyy').format(startDate!)}'
                          : 'From Date'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => endDate = date);
                      },
                      child: Text(endDate != null
                          ? 'To: ${DateFormat('MMM dd, yyyy').format(endDate!)}'
                          : 'To Date'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                // Apply filter - in a real app, you'd filter the list
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filter applied')),
                );
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _exportToExcel(BuildContext context, ExpenseData expenseData, String currency) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export to Excel - Feature coming soon')),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddExpenseBottomSheet(),
    );
  }
}

class _ExpenseLogTile extends StatelessWidget {
  final ExpenseLogEntry entry;
  final String currency;

  const _ExpenseLogTile({required this.entry, required this.currency});

  @override
  Widget build(BuildContext context) {
    final expenseData = context.read<ExpenseData>();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    Color categoryColor;
    IconData categoryIcon;
    switch (entry.category) {
      case 'Petrol':
        categoryColor = Colors.blue;
        categoryIcon = Icons.local_gas_station;
        break;
      case 'Grocery':
        categoryColor = Colors.green;
        categoryIcon = Icons.shopping_cart;
        break;
      case 'Outside Food':
        categoryColor = Colors.orange;
        categoryIcon = Icons.restaurant;
        break;
      case 'Others':
      default:
        categoryColor = Colors.purple;
        categoryIcon = Icons.category;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: categoryColor.withOpacity(0.1),
          child: Icon(categoryIcon, color: categoryColor),
        ),
        title: Text(
          entry.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${dateFormat.format(entry.date)} at ${timeFormat.format(entry.date)} • ${entry.paymentMethod}',
              style: const TextStyle(fontSize: 12),
            ),
            if (entry.notes.isNotEmpty)
              Text(entry.notes, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '-${currency} ${NumberFormat('#,##0.00').format(entry.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.dangerColor,
                fontSize: 16,
              ),
            ),
            Text(
              entry.category,
              style: TextStyle(
                fontSize: 11,
                color: categoryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        onLongPress: () => _showDeleteDialog(context, expenseData),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ExpenseData expenseData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text('Remove "${entry.description}" (${currency} ${NumberFormat('#,##0.00').format(entry.amount)})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              expenseData.deleteExpenseLogEntry(entry.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense deleted')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddExpenseBottomSheet extends StatefulWidget {
  const _AddExpenseBottomSheet();

  @override
  State<_AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<_AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'Petrol';
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _paymentMethod = 'Cash';
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['Petrol', 'Grocery', 'Outside Food', 'Others'];
  final List<String> _paymentMethods = ['Cash', 'Card', 'UPI', 'Bank Transfer'];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category *'),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description *', hintText: 'e.g., Fuel at ADNOC'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount (AED) *', hintText: '0.00'),
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
              items: _paymentMethods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Date: ', style: TextStyle(fontWeight: FontWeight.w500)),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveExpense,
                child: const Text('Save Expense'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expenseData = context.read<ExpenseData>();
      final entry = ExpenseLogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
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