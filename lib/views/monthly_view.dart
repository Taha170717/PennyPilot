import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/budget_controller.dart';

// Helper to format amounts without unnecessary trailing zeros
String _formatAmount(double value) {
  final s = value.toStringAsFixed(2);
  if (s.endsWith('.00')) return s.substring(0, s.length - 3);
  if (s.endsWith('0')) return s.substring(0, s.length - 1);
  return s;
}

// Compact formatter: convert large numbers to K/M for better calendar display
String _compactAmount(double value) {
  if (value.abs() >= 1000000) {
    return '${_formatAmount((value / 1000000))}M';
  }
  if (value.abs() >= 1000) {
    return '${_formatAmount((value / 1000))}K';
  }
  return _formatAmount(value);
}

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
     final theme = Theme.of(context);
     final cardBg = theme.cardColor;
     final bg = theme.scaffoldBackgroundColor;
     final textPrimary = theme.textTheme.bodyLarge?.color;
     final textMuted = theme.textTheme.bodyMedium?.color == null ? Colors.grey : theme.textTheme.bodyMedium!.color!.withAlpha((0.7 * 255).round());
     final primary = theme.colorScheme.primary;
    final daysInMonth = DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
    final firstWeekday = DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday; // Monday=1
    final dailyMap = _dailySpentMap();
    final monthLabel = DateFormat.yMMM().format(_visibleMonth);
    final symbol = _currency == 'PKR' ? 'Rs.' : '\$';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardBg,
        title: Text('Monthly Tracking', style: GoogleFonts.outfit(color: textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () {},
            color: primary,
          ),
        ],
      ),
      backgroundColor: bg,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with month navigation and currency selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _prevMonth,
                      icon: const Icon(Icons.chevron_left_rounded),
                      color: textPrimary,
                    ),
                    Text(monthLabel, style: GoogleFonts.outfit(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right_rounded),
                      color: textPrimary,
                    ),
                  ],
                ),

                 // Currency selector
                 DropdownButton<String>(
                   value: _currency,
                   dropdownColor: cardBg,
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
                             child: Text(d, style: GoogleFonts.outfit(color: textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
                           ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 6),

            // Calendar grid - occupy remaining vertical space (Expanded)
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final startIndex = (firstWeekday - 1); // convert Monday=1 to 0-based
                final totalCells = ((startIndex + daysInMonth + 6) ~/ 7) * 7; // round up to full weeks
                final rows = (totalCells / 7).ceil();

                // compute cell dimensions based on available width and height
                final cellWidth = constraints.maxWidth / 7;
                final cellHeight = (constraints.maxHeight) / rows;
                final childAspect = cellWidth / cellHeight;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: childAspect,
                  ),
                  itemCount: totalCells,
                  itemBuilder: (context, index) {
                    final dayNumber = index - startIndex + 1;
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox.shrink();
                    }

                    final spent = dailyMap[dayNumber] ?? 0.0;

                    // Improved layout: day number in top-left, compact amount at bottom center
                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                         child: Container(
                         decoration: BoxDecoration(
                           color: spent > 0 ? cardBg : Colors.transparent,
                           borderRadius: BorderRadius.circular(10),
                           border: Border.all(color: theme.dividerColor, width: 1),
                         ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Day number top-left
                            Align(
                              alignment: Alignment.topLeft,
                               child: Text('$dayNumber', style: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),

                            const Spacer(),

                            // Compact amount at bottom, use FittedBox so it scales on narrow cells
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                height: 18,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    spent > 0 ? '$symbol${_compactAmount(spent)}' : '-',
                                     style: GoogleFonts.outfit(color: spent > 0 ? theme.colorScheme.error : textMuted, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
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
                   Text('Total spent this month', style: GoogleFonts.outfit(color: textPrimary?.withAlpha((0.7 * 255).round()))),
                   Text('$symbol${_formatAmount(monthExpenses)}', style: GoogleFonts.outfit(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
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

