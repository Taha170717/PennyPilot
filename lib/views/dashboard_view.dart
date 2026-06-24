import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/budget_controller.dart';

// Helper to format amounts without unnecessary trailing zeros
String _formatAmount(double value) {
  final s = value.toStringAsFixed(2);
  if (s.endsWith('.00')) return s.substring(0, s.length - 3);
  if (s.endsWith('0')) return s.substring(0, s.length - 1);
  return s;
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final BudgetController bc = Get.find<BudgetController>();
     final theme = Theme.of(context);
     final cardBg = theme.cardColor;
     final bg = theme.scaffoldBackgroundColor;
     final textPrimary = theme.textTheme.bodyLarge?.color;
     final textSecondary = theme.textTheme.bodyMedium?.color;

    // compute totals
    final totalBalance = bc.pkrBalance + bc.usdBalance; // naive combined
    final monthlyIncome = bc.pkrIncome + bc.usdIncome;
    final monthlyExpense = bc.pkrExpense + bc.usdExpense;
    final remaining = totalBalance; // placeholder

    // category breakdown for expenses (PKR+USD)
    final Map<String, double> categorySums = {};
    for (var tx in bc.transactions) {
      if (!tx.isIncome) {
        categorySums[tx.category] = (categorySums[tx.category] ?? 0) + tx.amount;
      }
    }

    final pieSections = categorySums.entries.map((e) {
      final value = e.value;
      return PieChartSectionData(
        value: value,
        title: '${((value / (categorySums.values.fold(0.0, (a, b) => a + b))) * 100).toStringAsFixed(0)}%',
        radius: 50,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardBg,
        title: Text('Dashboard', style: GoogleFonts.outfit(color: textPrimary)),
      ),
      backgroundColor: bg,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text('Overview', style: GoogleFonts.outfit(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                       child: Card(
                       color: cardBg,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text('Total Balance', style: GoogleFonts.outfit(color: textSecondary)),
                            const SizedBox(height: 8),
                              Text(_formatAmount(totalBalance), style: GoogleFonts.outfit(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                       child: Card(
                       color: cardBg,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                           Text('Monthly Income', style: GoogleFonts.outfit(color: textSecondary)),
                          const SizedBox(height: 8),
                             Text(' ${_formatAmount(monthlyIncome)}', style: GoogleFonts.outfit(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                       child: Card(
                       color: cardBg,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                           Text('Monthly Expenses', style: GoogleFonts.outfit(color: textSecondary)),
                          const SizedBox(height: 8),
                              Text('- ${_formatAmount(monthlyExpense)}', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.error, fontSize: 18, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                       child: Card(
                       color: cardBg,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                           Text('Remaining Budget', style: GoogleFonts.outfit(color: textSecondary)),
                          const SizedBox(height: 8),
                             Text(_formatAmount(remaining), style: GoogleFonts.outfit(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
               Text('Expense Breakdown', style: GoogleFonts.outfit(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                 child: Card(
                   color: cardBg,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                         child: pieSections.isEmpty
                         ? Center(child: Text('No expense data', style: GoogleFonts.outfit(color: textSecondary)))
                        : PieChart(PieChartData(sections: pieSections, sectionsSpace: 2)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
               Text('Spending Trend (recent)', style: GoogleFonts.outfit(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                 child: Card(
                   color: cardBg,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LineChart(LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(spots: [
                          FlSpot(0, 0),
                          FlSpot(1, 1),
                          FlSpot(2, 0.5),
                          FlSpot(3, 1.5),
                          FlSpot(4, 1.0),
                        ], isCurved: true, dotData: FlDotData(show: false)),
                      ],
                    )),
                  ),
                ),
              ),
              const SizedBox(height: 16),
               Text('Recent Transactions', style: GoogleFonts.outfit(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() {
                final txs = bc.transactions.take(6).toList();
                 if (txs.isEmpty) return Text('No transactions yet', style: GoogleFonts.outfit(color: textSecondary));
                return Column(
                  children: txs.map((tx) => ListTile(
                        tileColor: cardBg,
                        title: Text(tx.description, style: GoogleFonts.outfit(color: textPrimary)),
                        subtitle: Text('${tx.category} • ${tx.currency} ${_formatAmount(tx.amount)}', style: GoogleFonts.outfit(color: textSecondary)),
                        trailing: Text(tx.isIncome ? '+${_formatAmount(tx.amount)}' : '-${_formatAmount(tx.amount)}', style: GoogleFonts.outfit(color: tx.isIncome ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error)),
                      )).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

