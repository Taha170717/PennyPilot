import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction_model.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ExportService {
  /// Export all transactions to Excel file
  static Future<String> exportTransactionsToExcel(
    List<TransactionModel> transactions, {
    String? fileName,
  }) async {
    final excel = Excel.createExcel();

    // Remove default sheet and create our own
    excel.delete('Sheet1');

    final sheet = excel['Transactions'];

    // Add headers
    sheet.appendRow([
      'Date',
      'Description',
      'Category',
      'Amount',
      'Currency',
      'Type',
      'Payment Method',
      'Notes',
    ]);

    // Sort transactions by date (newest first)
    final sortedTransactions = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Add transaction data
    for (final tx in sortedTransactions) {
      sheet.appendRow([
        DateFormat('yyyy-MM-dd').format(tx.dateTime),
        tx.description,
        tx.category,
        tx.amount.toString(),
        tx.currency,
        tx.isIncome ? 'Income' : 'Expense',
        tx.paymentMethod,
        tx.notes ?? '',
      ]);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${fileName ?? 'transactions_${DateTime.now().millisecondsSinceEpoch}.xlsx'}');
    await file.writeAsBytes(excel.encode()!);

    return file.path;
  }

  /// Export monthly summary to Excel file
  static Future<String> exportMonthlySummaryToExcel(
    List<TransactionModel> transactions, {
    String? fileName,
  }) async {
    final excel = Excel.createExcel();

    // Remove default sheet
    excel.delete('Sheet1');

    // Create monthly summary sheet
    final summarySheet = excel['Monthly Summary'];

    // Add headers
    summarySheet.appendRow([
      'Month',
      'Total Income (PKR)',
      'Total Expense (PKR)',
      'Net Balance (PKR)',
      'Total Income (USD)',
      'Total Expense (USD)',
      'Net Balance (USD)',
    ]);

    // Group transactions by month
    Map<String, List<TransactionModel>> monthlyTransactions = {};

    for (final tx in transactions) {
      final monthKey = '${tx.dateTime.year}-${tx.dateTime.month.toString().padLeft(2, '0')}';
      if (!monthlyTransactions.containsKey(monthKey)) {
        monthlyTransactions[monthKey] = [];
      }
      monthlyTransactions[monthKey]!.add(tx);
    }

    // Sort months in descending order
    final sortedMonths = monthlyTransactions.keys.toList()..sort((a, b) => b.compareTo(a));

    // Add monthly data
    for (final month in sortedMonths) {
      final monthTransactions = monthlyTransactions[month]!;

      // PKR calculations
      final pkrTransactions = monthTransactions.where((tx) => tx.currency == 'PKR').toList();
      double pkrIncome = pkrTransactions
          .where((tx) => tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      double pkrExpense = pkrTransactions
          .where((tx) => !tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      double pkrBalance = pkrIncome - pkrExpense;

      // USD calculations
      final usdTransactions = monthTransactions.where((tx) => tx.currency == 'USD').toList();
      double usdIncome = usdTransactions
          .where((tx) => tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      double usdExpense = usdTransactions
          .where((tx) => !tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      double usdBalance = usdIncome - usdExpense;

      summarySheet.appendRow([
        month,
        pkrIncome.toStringAsFixed(2),
        pkrExpense.toStringAsFixed(2),
        pkrBalance.toStringAsFixed(2),
        usdIncome.toStringAsFixed(2),
        usdExpense.toStringAsFixed(2),
        usdBalance.toStringAsFixed(2),
      ]);
    }

    // Create detailed monthly sheets for each month
    for (final month in sortedMonths) {
      final monthTransactions = monthlyTransactions[month]!;

      // Create sheet with month name
      final sheetName = 'Details_$month';
      final detailSheet = excel[sheetName];

      detailSheet.appendRow([
        'Date',
        'Description',
        'Category',
        'Amount',
        'Currency',
        'Type',
        'Payment Method',
        'Notes',
      ]);

      // Sort transactions by date
      monthTransactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      for (final tx in monthTransactions) {
        detailSheet.appendRow([
          DateFormat('yyyy-MM-dd HH:mm').format(tx.dateTime),
          tx.description,
          tx.category,
          tx.amount.toString(),
          tx.currency,
          tx.isIncome ? 'Income' : 'Expense',
          tx.paymentMethod,
          tx.notes ?? '',
        ]);
      }
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${fileName ?? 'monthly_summary_${DateTime.now().millisecondsSinceEpoch}.xlsx'}');
    await file.writeAsBytes(excel.encode()!);

    return file.path;
  }

  /// Get monthly summary data without export
  static Map<String, Map<String, dynamic>> getMonthlySummary(
    List<TransactionModel> transactions,
  ) {
    Map<String, List<TransactionModel>> monthlyTransactions = {};

    for (final tx in transactions) {
      final monthKey = '${tx.dateTime.year}-${tx.dateTime.month.toString().padLeft(2, '0')}';
      if (!monthlyTransactions.containsKey(monthKey)) {
        monthlyTransactions[monthKey] = [];
      }
      monthlyTransactions[monthKey]!.add(tx);
    }

    Map<String, Map<String, dynamic>> summary = {};

    for (final month in monthlyTransactions.keys) {
      final monthTransactions = monthlyTransactions[month]!;

      // PKR calculations
      final pkrTransactions = monthTransactions.where((tx) => tx.currency == 'PKR').toList();
      double pkrIncome = pkrTransactions
          .where((tx) => tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      double pkrExpense = pkrTransactions
          .where((tx) => !tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      // USD calculations
      final usdTransactions = monthTransactions.where((tx) => tx.currency == 'USD').toList();
      double usdIncome = usdTransactions
          .where((tx) => tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      double usdExpense = usdTransactions
          .where((tx) => !tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      summary[month] = {
        'pkrIncome': pkrIncome,
        'pkrExpense': pkrExpense,
        'pkrBalance': pkrIncome - pkrExpense,
        'usdIncome': usdIncome,
        'usdExpense': usdExpense,
        'usdBalance': usdIncome - usdExpense,
        'transactionCount': monthTransactions.length,
      };
    }

    return summary;
  }
}

