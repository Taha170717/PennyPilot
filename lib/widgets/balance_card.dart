import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme.dart';

// Simple helper to format amounts: remove trailing .00 when value is whole
String _formatAmount(double value) {
  final s = value.toStringAsFixed(2);
  if (s.endsWith('.00')) return s.substring(0, s.length - 3);
  if (s.endsWith('0')) return s.substring(0, s.length - 1);
  return s;
}
class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final String currency;
  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    required this.currency,
  });
  @override
  Widget build(BuildContext context) {
    final bool isPkr = currency == 'PKR';
    final gradient = isPkr ? AppColors.pkrGradient : AppColors.usdGradient;
    final symbol = isPkr ? 'Rs.' : '\$';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isPkr ? AppColors.pkrColor : AppColors.usdColor).withAlpha((0.35 * 255).round()),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row containing title and currency logo indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                 'TOTAL BALANCE',
                 style: GoogleFonts.outfit(
                   color: Colors.white.withAlpha((0.8 * 255).round()),
                   fontSize: 12,
                   fontWeight: FontWeight.bold,
                   letterSpacing: 2.0,
                 ),
               ),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                 decoration: BoxDecoration(
                   color: Colors.white.withAlpha((0.18 * 255).round()),
                   borderRadius: BorderRadius.circular(50),
                   border: Border.all(color: Colors.white.withAlpha((0.25 * 255).round()), width: 1),
                 ),
                 child: Text(
                   currency,
                   style: GoogleFonts.outfit(
                     color: Colors.white,
                     fontSize: 12,
                     fontWeight: FontWeight.bold,
                     letterSpacing: 1.0,
                   ),
                 ),
               ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Balance Display
           Text(
             '$symbol ${_formatAmount(balance)}',
             style: GoogleFonts.outfit(
               color: Colors.white,
               fontSize: 36,
               fontWeight: FontWeight.w800,
               letterSpacing: 0.5,
             ),
           ),
          const SizedBox(height: 32),

          // Glassmorphic income & expense breakdown bar
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
               decoration: BoxDecoration(
                 color: Colors.black.withAlpha((0.2 * 255).round()),
                 borderRadius: BorderRadius.circular(20),
                 border: Border.all(color: Colors.white.withAlpha((0.1 * 255).round()), width: 1.2),
               ),
            child: Row(
              children: [
                // Income column
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.15 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                       CrossFadeIncomeExpense(
                         title: 'Income',
                         amount: '$symbol ${_formatAmount(income)}',
                       ),
                    ],
                  ),
                ),

                // Vertical divider
                Container(
                  height: 35,
                  width: 1,
                  color: Colors.white.withAlpha((0.15 * 255).round()),
                ),
                const SizedBox(width: 16),

                // Expense column
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.15 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                       CrossFadeIncomeExpense(
                         title: 'Expense',
                         amount: '$symbol ${_formatAmount(expense)}',
                       ),
                    ],
                  ),
                ),
              ],
            ),
          ),
         ],
      ),
    );
  }
}
class CrossFadeIncomeExpense extends StatelessWidget {
  final String title;
  final String amount;
  const CrossFadeIncomeExpense({
    super.key,
    required this.title,
    required this.amount,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white.withAlpha((0.65 * 255).round()),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
