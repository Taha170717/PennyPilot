import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../theme.dart';
class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;
  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onDelete,
  });
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood_rounded;
      case 'salary':
        return Icons.work_rounded;
      case 'freelance':
        return Icons.laptop_chromebook_rounded;
      case 'shopping':
        return Icons.local_mall_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'travel':
        return Icons.directions_car_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orangeAccent;
      case 'salary':
        return Colors.greenAccent;
      case 'freelance':
        return Colors.tealAccent;
      case 'shopping':
        return Colors.pinkAccent;
      case 'entertainment':
        return Colors.purpleAccent;
      case 'travel':
        return Colors.blueAccent;
      case 'bills':
        return Colors.redAccent;
      case 'gift':
        return Colors.amberAccent;
      case 'investment':
        return Colors.cyanAccent;
      default:
        return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.isIncome;
    final String symbol = transaction.currency == 'PKR' ? 'Rs.' : '\$';
    final String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(transaction.dateTime);
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          gradient: AppColors.expenseGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
        ),
        child: Row(
          children: [
            // Category Icon container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getCategoryColor(transaction.category).withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getCategoryColor(transaction.category).withAlpha((0.25 * 255).round()),
                  width: 1,
                ),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: _getCategoryColor(transaction.category),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Description & Meta Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        transaction.category,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getCategoryColor(transaction.category),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formattedDate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Amount
            Text(
              '${isIncome ? '+' : '-'} $symbol${transaction.amount.toStringAsFixed(2)}',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
