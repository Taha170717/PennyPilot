import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/budget_controller.dart';
import '../theme.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final BudgetController bc = Get.find<BudgetController>();

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
        backgroundColor: AppColors.cardBg,
        title: Text('Dashboard', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: AppColors.cardBg,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Balance', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text('${totalBalance.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: AppColors.cardBg,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Monthly Income', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text(' ${monthlyIncome.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
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
                      color: AppColors.cardBg,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Monthly Expenses', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text('- ${monthlyExpense.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: AppColors.expense, fontSize: 18, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: AppColors.cardBg,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Remaining Budget', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text(remaining.toStringAsFixed(2), style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Expense Breakdown', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: Card(
                  color: AppColors.cardBg,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: pieSections.isEmpty
                        ? Center(child: Text('No expense data', style: GoogleFonts.outfit(color: AppColors.textSecondary)))
                        : PieChart(PieChartData(sections: pieSections, sectionsSpace: 2)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Spending Trend (recent)', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: Card(
                  color: AppColors.cardBg,
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
              Text('Recent Transactions', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() {
                final txs = bc.transactions.take(6).toList();
                if (txs.isEmpty) return Text('No transactions yet', style: GoogleFonts.outfit(color: AppColors.textSecondary));
                return Column(
                  children: txs.map((tx) => ListTile(
                        tileColor: AppColors.cardBg,
                        title: Text(tx.description, style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                        subtitle: Text('${tx.category} • ${tx.currency} ${tx.amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                        trailing: Text(tx.isIncome ? '+${tx.amount.toStringAsFixed(2)}' : '-${tx.amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: tx.isIncome ? AppColors.income : AppColors.expense)),
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

