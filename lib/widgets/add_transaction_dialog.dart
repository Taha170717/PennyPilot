import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme.dart';
class AddTransactionDialog extends StatefulWidget {
  final String initialCurrency;
  /// If provided, the dialog will be used to edit the existing transaction.
  final dynamic initialTransaction; // TransactionModel? kept dynamic to avoid import cycles in tests
  const AddTransactionDialog({super.key, required this.initialCurrency, this.initialTransaction});
  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}
class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  bool _isIncome = true;
  late String _selectedCurrency;
  String _selectedCategory = '';
  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salary', 'icon': Icons.work_rounded},
    {'name': 'Freelance', 'icon': Icons.laptop_chromebook_rounded},
    {'name': 'Investment', 'icon': Icons.trending_up_rounded},
    {'name': 'Gift', 'icon': Icons.card_giftcard_rounded},
    {'name': 'Other', 'icon': Icons.account_balance_wallet_rounded},
  ];
  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food', 'icon': Icons.fastfood_rounded},
    {'name': 'Shopping', 'icon': Icons.local_mall_rounded},
    {'name': 'Bills', 'icon': Icons.receipt_long_rounded},
    {'name': 'Travel', 'icon': Icons.directions_car_rounded},
    {'name': 'Entertainment', 'icon': Icons.movie_rounded},
    {'name': 'Other', 'icon': Icons.miscellaneous_services_rounded},
  ];
  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.initialCurrency;
    // If editing an existing transaction, prefill fields
    if (widget.initialTransaction != null) {
      final tx = widget.initialTransaction;
      _isIncome = tx.isIncome;
      _selectedCurrency = tx.currency;
      _selectedCategory = tx.category;
      _amountController.text = tx.amount.toString();
      _descController.text = tx.description;
    } else {
      _selectedCategory = _isIncome ? 'Salary' : 'Food';
    }
  }
  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final categories = _isIncome ? _incomeCategories : _expenseCategories;
    final theme = Theme.of(context);
    final primaryThemeColor = _isIncome ? AppColors.income : AppColors.expense;
    // theme-aware local colors
    final cardBg = theme.cardColor;
    final cardBorder = theme.dividerColor;
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;
     final textMuted = theme.textTheme.bodyMedium?.color == null ? AppColors.textMuted : theme.textTheme.bodyMedium!.color!.withAlpha((0.7 * 255).round());
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: (textMuted).withAlpha((0.3 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

               // Title
               Text(
                 'Add Transaction',
                 style: GoogleFonts.outfit(
                   fontSize: 24,
                   fontWeight: FontWeight.bold,
                   color: textPrimary,
                 ),
               ),
              const SizedBox(height: 20),
              // Transaction Type Selector (Income / Expense)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isIncome = true;
                          _selectedCategory = 'Salary';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                           color: _isIncome
                               ? AppColors.income.withAlpha((0.12 * 255).round())
                               : cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                             color: _isIncome ? AppColors.income : cardBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'INCOME (+)',
                            style: GoogleFonts.outfit(
                               color: _isIncome ? AppColors.income : textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isIncome = false;
                          _selectedCategory = 'Food';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                           color: !_isIncome
                               ? AppColors.expense.withAlpha((0.12 * 255).round())
                               : cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                             color: !_isIncome ? AppColors.expense : cardBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'EXPENSE (-)',
                            style: GoogleFonts.outfit(
                               color: !_isIncome ? AppColors.expense : textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Currency Selector
              Row(
                children: [
                    Text(
                      'Currency:',
                      style: GoogleFonts.outfit(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(width: 16),
                  ...['PKR', 'USD'].map((curr) {
                    final isSelected = _selectedCurrency == curr;
                    final currColor = curr == 'PKR' ? AppColors.pkrColor : AppColors.usdColor;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(curr),
                        selected: isSelected,
                        selectedColor: currColor.withAlpha((0.2 * 255).round()),
                        checkmarkColor: currColor,
                        labelStyle: GoogleFonts.outfit(
                          color: isSelected ? currColor : textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                        side: BorderSide(
                          color: isSelected ? currColor : cardBorder,
                          width: 1.2,
                        ),
                        backgroundColor: cardBg,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _selectedCurrency = curr;
                            });
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.outfit(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Amount',
                   labelStyle: GoogleFonts.outfit(color: textSecondary),
                   prefixIcon: Icon(Icons.attach_money_rounded, color: primaryThemeColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cardBorder, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryThemeColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.expense, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.expense, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description Input (Where money come/gone)
              TextFormField(
                controller: _descController,
                style: GoogleFonts.outfit(color: textPrimary),
                decoration: InputDecoration(
                  labelText: _isIncome ? 'Where did this money come from?' : 'Where did this money go?',
                   labelStyle: GoogleFonts.outfit(color: textSecondary),
                   prefixIcon: Icon(Icons.edit_note_rounded, color: primaryThemeColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cardBorder, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryThemeColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.expense, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.expense, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Category Label
              Text(
                'Category',
                style: GoogleFonts.outfit(
                           color: textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              // Grid/List of Categories
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final String catName = cat['name'] as String;
                    final IconData catIcon = cat['icon'] as IconData;
                    final isSelected = _selectedCategory == catName;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = catName;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                           color: isSelected
                               ? primaryThemeColor.withAlpha((0.15 * 255).round())
                               : cardBg,
                          borderRadius: BorderRadius.circular(16),
                           border: Border.all(
                             color: isSelected ? primaryThemeColor : cardBorder,
                             width: 1.5,
                           ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              catIcon,
                              size: 18,
                                 color: isSelected ? primaryThemeColor : textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              catName,
                              style: GoogleFonts.outfit(
                                color: isSelected ? primaryThemeColor : textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Action Button (Add)
              GestureDetector(
                onTap: () {
                    if (_formKey.currentState!.validate()) {
                        final double amt = double.parse(_amountController.text);
                        final String desc = _descController.text.trim();

                        final result = {
                          'amount': amt,
                          'isIncome': _isIncome,
                          'description': desc,
                          'currency': _selectedCurrency,
                          'category': _selectedCategory,
                        };
                        // If editing, include original id so caller can update
                        if (widget.initialTransaction != null) {
                          result['id'] = widget.initialTransaction.id;
                        }

                        Get.back(result: result);
                      }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: _isIncome ? AppColors.primaryGradient : AppColors.expenseGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: primaryThemeColor.withAlpha((0.3 * 255).round()),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'ADD TRANSACTION',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
