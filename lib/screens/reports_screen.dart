import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense_data.dart';
import '../models/user_settings.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseData, UserSettings>(
      builder: (context, expenseData, settings, _) {
        final currency = settings.currency;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Reports - ${expenseData.currentMonth}'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Categories'),
                  Tab(text: 'Trends'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () => _exportToPDF(context, expenseData, currency),
                  tooltip: 'Export PDF Report',
                ),
              ],
            ),
            body: TabBarView(
              children: [
                _OverviewTab(expenseData: expenseData, currency: currency),
                _CategoriesTab(expenseData: expenseData, currency: currency),
                _TrendsTab(expenseData: expenseData, currency: currency),
              ],
            ),
          ),
        );
      },
    );
  }

  void _exportToPDF(BuildContext context, ExpenseData expenseData, String currency) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF Export - Feature coming soon')),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final ExpenseData expenseData;
  final String currency;

  const _OverviewTab({required this.expenseData, required this.currency});

  @override
  Widget build(BuildContext context) {
    final summary = expenseData.getMonthlySummary();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          _buildMetricCards(summary, currency),
          const SizedBox(height: 24),

          // Income vs Expenses Chart
          _buildIncomeExpenseChart(summary, currency),
          const SizedBox(height: 24),

          // Credit Card Breakdown
          _buildCreditCardChart(expenseData, currency),
          const SizedBox(height: 24),

          // Rent & Bills Breakdown
          _buildRentBillsChart(expenseData, currency),
          const SizedBox(height: 24),

          // Daily Expenses Progress
          _buildDailyExpensesProgress(expenseData, currency),
        ],
      ),
    );
  }

  Widget _buildMetricCards(MonthlySummary summary, String currency) {
    final formatter = NumberFormat.currency(symbol: '$currency ', decimalDigits: 2);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _MetricCard(
          title: 'Income',
          value: formatter.format(summary.salary + summary.otherIncome),
          icon: Icons.attach_money,
          color: AppTheme.secondaryColor,
        ),
        _MetricCard(
          title: 'Total Payments',
          value: formatter.format(summary.totalMonthlyPayments),
          icon: Icons.payment,
          color: AppTheme.primaryColor,
        ),
        _MetricCard(
          title: 'Remaining Cash',
          value: formatter.format(summary.remainingCashAfterPayments),
          icon: Icons.savings,
          color: summary.remainingCashAfterPayments >= 0 ? AppTheme.secondaryColor : AppTheme.dangerColor,
        ),
        _MetricCard(
          title: 'Total Outstanding',
          value: formatter.format(summary.totalOutstanding),
          icon: Icons.warning,
          color: AppTheme.warningColor,
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseChart(MonthlySummary summary, String currency) {
    final income = summary.salary + summary.otherIncome;
    final payments = summary.totalMonthlyPayments;
    final dailyBudget = summary.totalDailyBudget;
    final remaining = summary.cashLeftAfterDailyExpenses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Income vs Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (income * 1.2).ceilToDouble(),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Income', 'Card Payments', 'Bills', 'Daily Budget', 'Remaining'];
                          if (value.toInt() < titles.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${currency} ${(value / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10));
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  barGroups: [
                    _makeBarGroup(0, income, AppTheme.secondaryColor),
                    _makeBarGroup(1, summary.totalPayments, AppTheme.primaryColor),
                    _makeBarGroup(2, summary.totalRentBillsPaid, Colors.orange),
                    _makeBarGroup(3, dailyBudget, Colors.purple),
                    _makeBarGroup(4, remaining >= 0 ? remaining : 0, remaining >= 0 ? AppTheme.secondaryColor : AppTheme.dangerColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLegend([
              ('Income', AppTheme.secondaryColor),
              ('Card Payments', AppTheme.primaryColor),
              ('Bills Paid', Colors.orange),
              ('Daily Budget', Colors.purple),
              ('Remaining', remaining >= 0 ? AppTheme.secondaryColor : AppTheme.dangerColor),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardChart(ExpenseData expenseData, String currency) {
    final cards = expenseData.creditCards.where((c) => c.currentOutstanding > 0).toList();

    if (cards.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text('No credit card outstanding', style: TextStyle(color: Colors.grey.shade600)),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Credit Card Outstanding', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: cards.asMap().entries.map((entry) {
                    final index = entry.key;
                    final card = entry.value;
                    final colors = [
                      AppTheme.primaryColor,
                      Colors.blue.shade300,
                      Colors.purple,
                      Colors.teal,
                      Colors.indigo,
                      Colors.cyan,
                    ];
                    return PieChartSectionData(
                      value: card.currentOutstanding,
                      title: '${card.name}\n${currency} ${NumberFormat('#,##0').format(card.currentOutstanding)}',
                      color: colors[index % colors.length],
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildCardLegend(cards, currency),
          ],
        ),
      ),
    );
  }

  Widget _buildCardLegend(List<CreditCard> cards, String currency) {
    final colors = [
      AppTheme.primaryColor,
      Colors.blue.shade300,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: cards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[index % colors.length], shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text('${card.name}: ${currency} ${NumberFormat('#,##0.00').format(card.currentOutstanding)}', style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRentBillsChart(ExpenseData expenseData, String currency) {
    final bills = expenseData.rentBills.where((b) => b.totalAmount > 0).toList();

    if (bills.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text('No rent/bills data', style: TextStyle(color: Colors.grey.shade600))),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rent & Bills Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (bills.fold(0.0, (sum, b) => sum + b.totalAmount) * 1.2).ceilToDouble(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < bills.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(bills[value.toInt()].name, style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${currency} ${(value / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10));
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  barGroups: bills.asMap().entries.map((entry) {
                    final index = entry.key;
                    final bill = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: bill.totalAmount,
                          color: Colors.orange.withOpacity(0.5),
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: bill.paid,
                          color: AppTheme.secondaryColor,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: bill.balance,
                          color: AppTheme.warningColor,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLegend([
              ('Total Amount', Colors.orange.withOpacity(0.5)),
              ('Paid', AppTheme.secondaryColor),
              ('Balance', AppTheme.warningColor),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyExpensesProgress(ExpenseData expenseData, String currency) {
    final expenses = expenseData.dailyExpenses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Expenses Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...expenses.map((expense) {
              final spent = expenseData.getCategorySpent(expense.name);
              final percentage = expense.budget > 0 ? (spent / expense.budget) * 100 : 0;

              Color progressColor = AppTheme.secondaryColor;
              if (percentage >= 100) progressColor = AppTheme.dangerColor;
              else if (percentage >= 75) progressColor = AppTheme.warningColor;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(expense.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          '${percentage.toStringAsFixed(0)}%  •  ${currency} ${NumberFormat('#,##0.00').format(spent)} / ${NumberFormat('#,##0.00').format(expense.budget)}',
                          style: TextStyle(color: progressColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: expense.budget > 0 ? (spent / expense.budget).clamp(0.0, 1.0) : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(List<(String, Color)> items) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.map((item) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: item.$2, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(item.$1, style: const TextStyle(fontSize: 12)),
        ],
      )).toList(),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 25,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  final ExpenseData expenseData;
  final String currency;

  const _CategoriesTab({required this.expenseData, required this.currency});

  @override
  Widget build(BuildContext context) {
    final categories = expenseData.dailyExpenses;
    final entries = expenseData.expenseLog;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Pie Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spending by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: _buildCategoryPieChart(categories),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Category Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...categories.map((cat) => _CategoryDetailRow(
                    category: cat,
                    spent: expenseData.getCategorySpent(cat.name),
                    currency: currency,
                  )).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Expenses by Category
          if (entries.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...entries.take(10).map((entry) => _RecentExpenseRow(entry: entry, currency: currency)).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(List<DailyExpense> categories) {
    final data = categories.where((c) => expenseData.getCategorySpent(c.name) > 0).toList();

    if (data.isEmpty) {
      return Center(child: Text('No spending data yet', style: TextStyle(color: Colors.grey.shade600)));
    }

    final colors = [AppTheme.primaryColor, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink];

    return PieChart(
      PieChartData(
        sections: data.asMap().entries.map((entry) {
          final index = entry.key;
          final cat = entry.value;
          final spent = expenseData.getCategorySpent(cat.name);
          return PieChartSectionData(
            value: spent,
            title: '${cat.name}\n${NumberFormat('#,##0').format(spent)}',
            color: colors[index % colors.length],
            radius: 70,
            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 50,
      ),
    );
  }
}

class _CategoryDetailRow extends StatelessWidget {
  final DailyExpense category;
  final double spent;
  final String currency;

  const _CategoryDetailRow({
    required this.category,
    required this.spent,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final left = category.budget - spent;
    final percentage = category.budget > 0 ? (spent / category.budget) * 100 : 0;

    Color color = AppTheme.secondaryColor;
    if (percentage >= 100) color = AppTheme.dangerColor;
    else if (percentage >= 75) color = AppTheme.warningColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Budget: ${currency} ${NumberFormat('#,##0.00').format(category.budget)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              Text('Spent: ${currency} ${NumberFormat('#,##0.00').format(spent)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: category.budget > 0 ? (spent / category.budget).clamp(0.0, 1.0) : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          if (category.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Note: ${category.notes}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
        ],
      ),
    );
  }
}

class _RecentExpenseRow extends StatelessWidget {
  final ExpenseLogEntry entry;
  final String currency;

  const _RecentExpenseRow({required this.entry, required this.currency});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
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
      default:
        categoryColor = Colors.purple;
        categoryIcon = Icons.category;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: categoryColor.withOpacity(0.1),
            child: Icon(categoryIcon, size: 18, color: categoryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '${dateFormat.format(entry.date)} at ${timeFormat.format(entry.date)} • ${entry.paymentMethod}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '-${currency} ${NumberFormat('#,##0.00').format(entry.amount)}',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.dangerColor),
          ),
        ],
      ),
    );
  }
}

class _TrendsTab extends StatelessWidget {
  final ExpenseData expenseData;
  final String currency;

  const _TrendsTab({required this.expenseData, required this.currency});

  @override
  Widget build(BuildContext context) {
    final entries = expenseData.expenseLog;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No expense data for trends', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Add expenses to see spending trends', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }

    // Group by date
    final dailySpending = <DateTime, double>{};
    for (final entry in entries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      dailySpending[date] = (dailySpending[date] ?? 0) + entry.amount;
    }

    final sortedDates = dailySpending.keys.toList()..sort();
    final maxSpending = dailySpending.values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Spending Trend
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Spending Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < sortedDates.length && value.toInt() >= 0) {
                                  final date = sortedDates[value.toInt()];
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(DateFormat('MM/dd').format(date), style: const TextStyle(fontSize: 10)),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text('${currency} ${(value / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10));
                              },
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: sortedDates.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), dailySpending[e.value]!);
                            }).toList(),
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryColor.withOpacity(0.1),
                            ),
                          ),
                        ],
                        minX: 0,
                        maxX: (sortedDates.length - 1).toDouble(),
                        minY: 0,
                        maxY: (maxSpending * 1.2).ceilToDouble(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Weekly Average
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spending Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _InsightRow(
                    label: 'Average Daily Spend',
                    value: '${currency} ${NumberFormat('#,##0.00').format(dailySpending.values.fold(0.0, (a, b) => a + b) / dailySpending.length)}',
                    icon: Icons.calendar_today,
                  ),
                  _InsightRow(
                    label: 'Highest Spending Day',
                    value: '${currency} ${NumberFormat('#,##0.00').format(maxSpending)}',
                    icon: Icons.trending_up,
                  ),
                  _InsightRow(
                    label: 'Total Days Tracked',
                    value: '${dailySpending.length} days',
                    icon: Icons.date_range,
                  ),
                  _InsightRow(
                    label: 'Projected Monthly',
                    value: '${currency} ${NumberFormat('#,##0.00').format((dailySpending.values.fold(0.0, (a, b) => a + b) / dailySpending.length) * 30)}',
                    icon: Icons.analytics,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InsightRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
              ],
            ),
            const Spacer(),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}