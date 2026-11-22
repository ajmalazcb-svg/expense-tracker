import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/expense_data.dart';

class ExportService {
  // Export to Excel
  static Future<void> exportToExcel(ExpenseData expenseData, String currency) async {
    final excel = Excel.createExcel();
    final summary = expenseData.getMonthlySummary();

    // Sheet 1: Monthly Expense Plan
    final planSheet = excel['Monthly Expense Plan'];
    _writePlanSheet(planSheet, expenseData, summary, currency);

    // Sheet 2: Expense Log
    final logSheet = excel['Expense Log'];
    _writeLogSheet(logSheet, expenseData, currency);

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'Expense_Tracker_${expenseData.currentMonth.replaceAll(' ', '_')}.xlsx';
    final filePath = '${directory.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      await OpenFilex.open(filePath);
    }
  }

  static void _writePlanSheet(
    Sheet sheet,
    ExpenseData expenseData,
    MonthlySummary summary,
    String currency,
  ) {
    // Headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('MONTHLY EXPENSE PLAN');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value = TextCellValue('Month:');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value = TextCellValue(expenseData.currentMonth);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1)).value = TextCellValue('Currency:');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 1)).value = TextCellValue(currency);

    // Income
    int row = 3;
    _writeRow(sheet, row++, ['INCOME / AVAILABLE FUNDS']);
    _writeRow(sheet, row++, ['Monthly Salary / Income', summary.salary]);
    _writeRow(sheet, row++, ['Other Income', summary.otherIncome]);
    _writeRow(sheet, row++, ['Total Available', summary.salary + summary.otherIncome]);

    // Credit Cards
    row++;
    _writeRow(sheet, row++, ['CREDIT CARDS']);
    _writeRow(sheet, row++, ['Card', 'Previous Outstanding', 'New Spending', 'Payment Made', 'Current Outstanding', 'Min Due', 'Total Due', 'Due Date', 'Notes']);

    for (final card in expenseData.creditCards) {
      _writeRow(sheet, row++, [
        card.name,
        card.previousOutstanding,
        card.newSpending,
        card.paymentMade,
        card.currentOutstanding,
        card.minimumDue,
        card.totalDue,
        card.dueDate,
        card.notes,
      ]);
    }

    _writeRow(sheet, row++, [
      'TOTAL',
      summary.totalPreviousOutstanding,
      summary.totalNewSpending,
      summary.totalPayments,
      summary.totalCurrentOutstanding,
      summary.totalMinimumDue,
      summary.totalStatementDue,
    ]);

    // Rent & Bills
    row++;
    _writeRow(sheet, row++, ['RENT & MONTHLY BILLS']);
    _writeRow(sheet, row++, ['Item', 'This Month Payable', 'Total Amount', 'Paid', 'Balance', 'Due Date / Notes']);

    for (final bill in expenseData.rentBills) {
      _writeRow(sheet, row++, [
        bill.name,
        bill.thisMonthPayable,
        bill.totalAmount,
        bill.paid,
        bill.balance,
        bill.dueDate,
      ]);
    }

    _writeRow(sheet, row++, [
      'TOTAL',
      summary.totalRentBillsPayable,
      summary.totalRentBillsAmount,
      summary.totalRentBillsPaid,
      summary.totalRentBillsBalance,
    ]);

    // Daily Expenses
    row++;
    _writeRow(sheet, row++, ['DAILY EXPENSES']);
    _writeRow(sheet, row++, ['Category', 'Budget', 'Spent', 'Left', 'Notes']);

    for (final expense in expenseData.dailyExpenses) {
      final spent = expenseData.getCategorySpent(expense.name);
      _writeRow(sheet, row++, [
        expense.name,
        expense.budget,
        spent,
        expense.budget - spent,
        expense.notes,
      ]);
    }

    _writeRow(sheet, row++, [
      'TOTAL',
      summary.totalDailyBudget,
      summary.totalDailySpent,
      summary.totalDailyLeft,
    ]);

    // Overall Summary
    row++;
    _writeRow(sheet, row++, ['OVERALL MONTHLY SUMMARY']);
    _writeRow(sheet, row++, ['1. Total Previous CC Outstanding', summary.totalPreviousOutstanding]);
    _writeRow(sheet, row++, ['2. Total New CC Spending', summary.totalNewSpending]);
    _writeRow(sheet, row++, ['3. Total CC Payments', summary.totalPayments]);
    _writeRow(sheet, row++, ['4. Current CC Outstanding', summary.totalCurrentOutstanding]);
    _writeRow(sheet, row++, ['5. Total Minimum Due', summary.totalMinimumDue]);
    _writeRow(sheet, row++, ['6. Total Statement Due', summary.totalStatementDue]);
    _writeRow(sheet, row++, ['7. Total Rent & Bills Payable', summary.totalRentBillsPayable]);
    _writeRow(sheet, row++, ['8. Daily Expenses Budget', summary.totalDailyBudget]);
    _writeRow(sheet, row++, ['9. Total Monthly Payments', summary.totalMonthlyPayments]);
    _writeRow(sheet, row++, ['10. Remaining After Payments', summary.remainingCashAfterPayments]);
    _writeRow(sheet, row++, ['11. Cash Left After Daily', summary.cashLeftAfterDailyExpenses]);
    _writeRow(sheet, row++, ['12. Total Outstanding', summary.totalOutstanding]);
  }

  static void _writeLogSheet(Sheet sheet, ExpenseData expenseData, String currency) {
    _writeRow(sheet, 0, ['Date', 'Category', 'Description', 'Payment Method', 'Amount ($currency)', 'Notes']);

    for (int i = 0; i < expenseData.expenseLog.length; i++) {
      final entry = expenseData.expenseLog[i];
      _writeRow(sheet, i + 1, [
        entry.date.toIso8601String().split('T')[0],
        entry.category,
        entry.description,
        entry.paymentMethod,
        entry.amount,
        entry.notes,
      ]);
    }
  }

  static void _writeRow(Sheet sheet, int row, List<dynamic> values) {
    for (int col = 0; col < values.length; col++) {
      final value = values[col];
      if (value is double) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)).value = DoubleCellValue(value);
      } else if (value is int) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)).value = IntCellValue(value);
      } else {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)).value = TextCellValue(value.toString());
      }
    }
  }

  // Export to PDF
  static Future<void> exportToPDF(ExpenseData expenseData, String currency) async {
    final pdf = pw.Document();
    final summary = expenseData.getMonthlySummary();
    final formatter = (double v) => '$currency ${v.toStringAsFixed(2)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildPDFHeader(expenseData, currency),
          pw.SizedBox(height: 20),
          _buildPDFIncomeSection(summary, formatter),
          pw.SizedBox(height: 15),
          _buildPDFCreditCardsSection(expenseData, formatter),
          pw.SizedBox(height: 15),
          _buildPDFRentBillsSection(expenseData, formatter),
          pw.SizedBox(height: 15),
          _buildPDFDailyExpensesSection(expenseData, formatter),
          pw.SizedBox(height: 15),
          _buildPDFOverallSummary(summary, formatter),
          pw.SizedBox(height: 20),
          _buildPDFExpenseLog(expenseData, formatter),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'Expense_Report_${expenseData.currentMonth.replaceAll(' ', '_')}.pdf';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(filePath);
  }

  static pw.Widget _buildPDFHeader(ExpenseData expenseData, String currency) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('MONTHLY EXPENSE REPORT', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Text('Month: ${expenseData.currentMonth}', style: pw.TextStyle(fontSize: 14)),
        pw.Text('Currency: $currency', style: pw.TextStyle(fontSize: 14)),
        pw.Text('Generated: ${DateTime.now().toString().split('.')[0]}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildPDFIncomeSection(MonthlySummary summary, String Function(double) fmt) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('INCOME', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Item', 'Amount'],
          data: [
            ['Monthly Salary', fmt(summary.salary)],
            ['Other Income', fmt(summary.otherIncome)],
            ['Total Available', fmt(summary.salary + summary.otherIncome)],
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPDFCreditCardsSection(ExpenseData expenseData, String Function(double) fmt) {
    final data = expenseData.creditCards.map((c) => [
      c.name,
      fmt(c.previousOutstanding),
      fmt(c.newSpending),
      fmt(c.paymentMade),
      fmt(c.currentOutstanding),
      fmt(c.minimumDue),
      fmt(c.totalDue),
    ]).toList();

    data.add([
      'TOTAL',
      fmt(expenseData.totalPreviousOutstanding),
      fmt(expenseData.totalNewSpending),
      fmt(expenseData.totalPayments),
      fmt(expenseData.totalCurrentOutstanding),
      fmt(expenseData.totalMinimumDue),
      fmt(expenseData.totalStatementDue),
    ]);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('CREDIT CARDS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Card', 'Previous', 'New', 'Payment', 'Current', 'Min Due', 'Total Due'],
          data: data,
        ),
      ],
    );
  }

  static pw.Widget _buildPDFRentBillsSection(ExpenseData expenseData, String Function(double) fmt) {
    final data = expenseData.rentBills.map((b) => [
      b.name,
      fmt(b.thisMonthPayable),
      fmt(b.totalAmount),
      fmt(b.paid),
      fmt(b.balance),
    ]).toList();

    data.add([
      'TOTAL',
      fmt(expenseData.totalRentBillsPayable),
      fmt(expenseData.totalRentBillsAmount),
      fmt(expenseData.totalRentBillsPaid),
      fmt(expenseData.totalRentBillsBalance),
    ]);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('RENT & MONTHLY BILLS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Item', 'Payable', 'Total', 'Paid', 'Balance'],
          data: data,
        ),
      ],
    );
  }

  static pw.Widget _buildPDFDailyExpensesSection(ExpenseData expenseData, String Function(double) fmt) {
    final data = expenseData.dailyExpenses.map((e) {
      final spent = expenseData.getCategorySpent(e.name);
      return [
        e.name,
        fmt(e.budget),
        fmt(spent),
        fmt(e.budget - spent),
      ];
    }).toList();

    data.add([
      'TOTAL',
      fmt(expenseData.totalDailyBudget),
      fmt(expenseData.totalDailySpent),
      fmt(expenseData.totalDailyLeft),
    ]);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('DAILY EXPENSES BUDGET', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Category', 'Budget', 'Spent', 'Left'],
          data: data,
        ),
      ],
    );
  }

  static pw.Widget _buildPDFOverallSummary(MonthlySummary summary, String Function(double) fmt) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('OVERALL SUMMARY', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Item', 'Amount'],
          data: [
            ['Total Previous CC Outstanding', fmt(summary.totalPreviousOutstanding)],
            ['Total New CC Spending', fmt(summary.totalNewSpending)],
            ['Total CC Payments', fmt(summary.totalPayments)],
            ['Current CC Outstanding', fmt(summary.totalCurrentOutstanding)],
            ['Total Minimum Due', fmt(summary.totalMinimumDue)],
            ['Total Statement Due', fmt(summary.totalStatementDue)],
            ['Total Rent & Bills Payable', fmt(summary.totalRentBillsPayable)],
            ['Daily Expenses Budget', fmt(summary.totalDailyBudget)],
            ['Total Monthly Payments', fmt(summary.totalMonthlyPayments)],
            ['Remaining After Payments', fmt(summary.remainingCashAfterPayments)],
            ['Cash Left After Daily', fmt(summary.cashLeftAfterDailyExpenses)],
            ['Total Outstanding', fmt(summary.totalOutstanding)],
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPDFExpenseLog(ExpenseData expenseData, String Function(double) fmt) {
    if (expenseData.expenseLog.isEmpty) return pw.SizedBox();

    final data = expenseData.expenseLog.take(20).map((e) => [
      e.date.toString().split(' ')[0],
      e.category,
      e.description,
      e.paymentMethod,
      fmt(e.amount),
    ]).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('RECENT EXPENSES (Last 20)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Date', 'Category', 'Description', 'Method', 'Amount'],
          data: data,
        ),
      ],
    );
  }
}