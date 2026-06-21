import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/budget_controller.dart';
import '../theme.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/transaction_card.dart';
import '../widgets/balance_card.dart';
import 'monthly_view.dart';
import 'dashboard_view.dart';
import 'login_view.dart';
import 'settings_view.dart';
import 'about_view.dart';
import '../controllers/auth_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}
class _HomeViewState extends State<HomeView> {
  final BudgetController _controller = Get.put(BudgetController());
  final AuthController _auth = Get.find<AuthController>();
  String _activeCurrency = 'PKR'; // 'PKR' or 'USD'
  void _openAddTransactionSheet() async {
    final result = await Get.bottomSheet(
      AddTransactionDialog(initialCurrency: _activeCurrency),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
    if (result != null && result is Map<String, dynamic>) {
      _controller.addTransaction(
        amount: result['amount'] as double,
        isIncome: result['isIncome'] as bool,
        description: result['description'] as String,
        currency: result['currency'] as String,
        category: result['category'] as String,
      );
      // Switch active currency tab if they added to the other currency
      if (result['currency'] != _activeCurrency) {
        setState(() {
          _activeCurrency = result['currency'] as String;
        });
      }
      Get.snackbar(
        'Transaction Added',
        'Your account has been updated successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.cardBg.withAlpha((0.9 * 255).round()),
        colorText: AppColors.textPrimary,
        borderColor: AppColors.primary.withAlpha((0.3 * 255).round()),
        borderWidth: 1.5,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        icon: Icon(
          result['isIncome'] ? Icons.check_circle_outline_rounded : Icons.payment_rounded,
          color: result['isIncome'] ? AppColors.income : AppColors.primary,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppColors.cardBg,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(() {
                  final user = _auth.currentUser;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'Guest', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user?.username ?? 'Not signed in', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                    ],
                  );
                }),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: Text('Profile', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                title: Text('Monthly Tracking', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                onTap: () {
                  Get.to(() => const MonthlyView());
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: Text('Settings', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                onTap: () {
                  Get.to(() => const SettingsView());
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: Text('About', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                onTap: () {
                  Get.to(() => const AboutView());
                },
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: Text('Logout', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                onTap: () {
                  _auth.logout();
                  // go back to login
                  Get.offAll(() => const LoginView());
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: Stack(
          children: [
            // Ambient subtle glow top-left
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withAlpha((0.08 * 255).round()),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha((0.08 * 255).round()),
                      blurRadius: 90,
                      spreadRadius: 60,
                      offset: Offset.zero,
                    ),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Custom Header Bar
                    Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PennyPilot',
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Navigate your wealth',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Logo icon indicator
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cardBorder, width: 1.2),
                          ),
                          child: const Icon(
                            Icons.flight_takeoff_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Dashboard button
                        IconButton(
                          onPressed: () {
                            Get.to(() => const DashboardView(), transition: Transition.rightToLeft);
                          },
                          icon: const Icon(Icons.dashboard_rounded),
                          color: AppColors.primary,
                        ),
                        // Drawer button
                        Builder(builder: (context) {
                          return IconButton(
                            icon: const Icon(Icons.menu_rounded),
                            color: AppColors.primary,
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Custom animated slider for currency selection (PKR / USD)
                    Center(
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCurrencyTab('PKR', AppColors.pkrColor),
                            const SizedBox(width: 8),
                            _buildCurrencyTab('USD', AppColors.usdColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Balance Card section listening to reactive controller state
                    Obx(() {
                      final balance = _activeCurrency == 'PKR'
                          ? _controller.pkrBalance
                          : _controller.usdBalance;
                      final income = _activeCurrency == 'PKR'
                          ? _controller.pkrIncome
                          : _controller.usdIncome;
                      final expense = _activeCurrency == 'PKR'
                          ? _controller.pkrExpense
                          : _controller.usdExpense;

                      return BalanceCard(
                        balance: balance,
                        income: income,
                        expense: expense,
                        currency: _activeCurrency,
                      );
                    }),

                    const SizedBox(height: 32),

                    // History Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction History',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Obx(() {
                          final count = _activeCurrency == 'PKR'
                              ? _controller.pkrTransactions.length
                              : _controller.usdTransactions.length;
                          return Text(
                            '$count records',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Scrollable Transaction List
                    Expanded(
                      child: Obx(() {
                        final txList = _activeCurrency == 'PKR'
                            ? _controller.pkrTransactions
                            : _controller.usdTransactions;
                        if (txList.isEmpty) {
                          return _buildEmptyState();
                        }
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: txList.length,
                          itemBuilder: (context, index) {
                            final tx = txList[index];
                            return TransactionCard(
                              transaction: tx,
                              onDelete: () {
                                _controller.deleteTransaction(tx.id);
                                Get.snackbar(
                                  'Transaction Deleted',
                                  'The item has been removed from history.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppColors.cardBg.withAlpha((0.9 * 255).round()),
                                  colorText: AppColors.textPrimary,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 16,
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.expense,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionSheet,
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha((0.4 * 255).round()),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  Widget _buildCurrencyTab(String currency, Color activeColor) {
    final bool isActive = _activeCurrency == currency;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCurrency = currency;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 110,
        decoration: BoxDecoration(
          color: isActive ? activeColor.withAlpha((0.15 * 255).round()) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            currency,
            style: GoogleFonts.outfit(
              color: isActive ? activeColor : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    final symbol = _activeCurrency == 'PKR' ? 'Rs.' : '\$';
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1.2),
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 55,
                 color: AppColors.textMuted.withAlpha((0.5 * 255).round()),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Transactions Yet',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Tap the "+" button to add income or log expenses in $symbol.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
