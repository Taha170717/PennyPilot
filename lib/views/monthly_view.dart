import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/budget_controller.dart';
import '../theme.dart';

class MonthlyView extends StatefulWidget {
  const MonthlyView({super.key});

  @override
  State<MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<MonthlyView> {
  final BudgetController _controller = Get.find<BudgetController>();
  DateTime _visibleMonth = DateTime.now();
  String _currency = 'PKR';

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  Map<int, double> _dailySpentMap() {
    final Map<int, double> map = {};
    final txList = _currency == 'PKR' ? _controller.pkrTransactions : _controller.usdTransactions;
    for (var tx in txList) {
      final dt = tx.dateTime;
      if (dt.year == _visibleMonth.year && dt.month == _visibleMonth.month) {
        if (!tx.isIncome) {
          map[dt.day] = (map[dt.day] ?? 0) + tx.amount;
        }
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
    final firstWeekday = DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday; // Monday=1
    final dailyMap = _dailySpentMap();
    final monthLabel = DateFormat.yMMM().format(_visibleMonth);
    final symbol = _currency == 'PKR' ? 'Rs.' : '\$';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        title: Text('Monthly Tracking', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () {},
            color: AppColors.primary,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _prevMonth,
                      icon: const Icon(Icons.chevron_left_rounded),
                      color: AppColors.textPrimary,
                    ),
                    Text(monthLabel, style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right_rounded),
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),

                // Currency selector
                DropdownButton<String>(
                  value: _currency,
                  dropdownColor: AppColors.cardBg,
                  items: const [DropdownMenuItem(value: 'PKR', child: Text('PKR')), DropdownMenuItem(value: 'USD', child: Text('USD'))],
                  onChanged: (v) {
                    if (v != null) setState(() => _currency = v);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Weekday labels
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d, style: GoogleFonts.outfit(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 6),

            // Calendar grid
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.1,
                ),
                itemCount: 7 * ((firstWeekday % 7) + daysInMonth ~/ 7 + 6), // ensure enough cells; we will calculate more simply below
                itemBuilder: (context, index) {
                  // Calculate visible day index mapping
                  // We'll display blanks for days before the 1st of month
                  final startIndex = (firstWeekday - 1); // convert Monday=1 to 0-based
                  final dayNumber = index - startIndex + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return Container();
                  }

                  final spent = dailyMap[dayNumber] ?? 0.0;

                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: spent > 0 ? AppColors.cardBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder, width: 1),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$dayNumber', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text(
                            spent > 0 ? '$symbol${spent.toStringAsFixed(2)}' : '-',
                            style: GoogleFonts.outfit(color: spent > 0 ? AppColors.expense : AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            // Summary
            Builder(builder: (context) {
              final txList = _currency == 'PKR' ? _controller.pkrTransactions : _controller.usdTransactions;
              final monthExpenses = txList
                  .where((tx) => !tx.isIncome && tx.dateTime.year == _visibleMonth.year && tx.dateTime.month == _visibleMonth.month)
                  .fold(0.0, (sum, tx) => sum + tx.amount);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total spent this month', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                  Text('$symbol${monthExpenses.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: AppColors.expense, fontWeight: FontWeight.bold)),
                ],
              );
            }),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

