import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/transaction_model.dart';
import '../models/savings_goal_model.dart';
import 'auth_controller.dart';
import '../models/user_model.dart';
import '../services/export_service.dart';

class BudgetController extends GetxController {
  final _storage = GetStorage();
  final _storageKeyBase = 'transactions_list';
  final _savingsGoalsKeyBase = 'savings_goals_list';
  // Reactive master list of transactions
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  // Reactive master list of savings goals
  final RxList<SavingsGoalModel> savingsGoals = <SavingsGoalModel>[].obs;
  late final AuthController _auth;

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<AuthController>();
    // load for current user (if any)
    loadTransactionsForCurrentUser();
    loadSavingsGoalsForCurrentUser();
    // React to auth changes so transactions load for the correct user when login/logout occurs
    ever(_auth.currentUserRx, (UserModel? user) {
      loadTransactionsForUser(user?.id);
      loadSavingsGoalsForUser(user?.id);
    });
  }

  // --- PERSISTENCE ---

  String _userStorageKey(String? userId) => '${_storageKeyBase}_${userId ?? 'public'}';
  String _savingsGoalsStorageKey(String? userId) => '${_savingsGoalsKeyBase}_${userId ?? 'public'}';

  void loadTransactionsForCurrentUser() {
    final userId = _auth.currentUser?.id;
    loadTransactionsForUser(userId);
  }

  void loadTransactionsForUser(String? userId) {
    final key = _userStorageKey(userId);
    final storedData = _storage.read<List<dynamic>>(key);
    if (storedData != null) {
      transactions.value = storedData
          .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      transactions.clear();
    }
  }

   void saveTransactions() {
     final userId = _auth.currentUser?.id;
     final key = _userStorageKey(userId);
     final listJson = transactions.map((tx) => tx.toJson()).toList();
     _storage.write(key, listJson);
   }

   void loadSavingsGoalsForCurrentUser() {
     final userId = _auth.currentUser?.id;
     loadSavingsGoalsForUser(userId);
   }

   void loadSavingsGoalsForUser(String? userId) {
     final key = _savingsGoalsStorageKey(userId);
     final storedData = _storage.read<List<dynamic>>(key);
     if (storedData != null) {
       savingsGoals.value = storedData
           .map((item) => SavingsGoalModel.fromJson(Map<String, dynamic>.from(item)))
           .toList();
     } else {
       savingsGoals.clear();
     }
   }

   void saveSavingsGoals() {
     final userId = _auth.currentUser?.id;
     final key = _savingsGoalsStorageKey(userId);
     final listJson = savingsGoals.map((goal) => goal.toJson()).toList();
     _storage.write(key, listJson);
   }
   // --- ACTIONS ---
  void addTransaction({
    required double amount,
    required bool isIncome,
    required String description,
    required String currency,
    required String category,
  }) {
    final newTx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      isIncome: isIncome,
      description: description,
      currency: currency,
      category: category,
      dateTime: DateTime.now(),
    );

    // Insert at index 0 for showing latest transaction first
    transactions.insert(0, newTx);
    saveTransactions();
  }
  void deleteTransaction(String id) {
    transactions.removeWhere((tx) => tx.id == id);
    saveTransactions();
  }
  /// Update an existing transaction by id. Fields provided will replace the old values.
  void updateTransaction({
    required String id,
    required double amount,
    required bool isIncome,
    required String description,
    required String currency,
    required String category,
  }) {
    final idx = transactions.indexWhere((tx) => tx.id == id);
    if (idx == -1) return; // not found
    final old = transactions[idx];
    final updated = TransactionModel(
      id: old.id,
      amount: amount,
      isIncome: isIncome,
      description: description,
      currency: currency,
      category: category,
      dateTime: old.dateTime,
      paymentMethod: old.paymentMethod,
      notes: old.notes,
      receiptPath: old.receiptPath,
    );
    transactions[idx] = updated;
    saveTransactions();
  }
  // --- GETTERS FOR PKR ---
  List<TransactionModel> get pkrTransactions =>
      transactions.where((tx) => tx.currency == 'PKR').toList();
  double get pkrBalance {
    double bal = 0;
    for (var tx in pkrTransactions) {
      if (tx.isIncome) {
        bal += tx.amount;
      } else {
        bal -= tx.amount;
      }
    }
    return bal;
  }
  double get pkrIncome {
    return pkrTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
  double get pkrExpense {
    return pkrTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
  // --- GETTERS FOR USD ---
  List<TransactionModel> get usdTransactions =>
      transactions.where((tx) => tx.currency == 'USD').toList();
  double get usdBalance {
    double bal = 0;
    for (var tx in usdTransactions) {
      if (tx.isIncome) {
        bal += tx.amount;
      } else {
        bal -= tx.amount;
      }
    }
    return bal;
  }
  double get usdIncome {
    return usdTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
  double get usdExpense {
    return usdTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // --- MONTHLY GETTERS ---

  /// Get transactions for a specific month (YYYY-MM format)
  List<TransactionModel> getMonthlyTransactions(String yearMonth) {
    // yearMonth format: "2024-06"
    return transactions.where((tx) {
      final txMonth = '${tx.dateTime.year}-${tx.dateTime.month.toString().padLeft(2, '0')}';
      return txMonth == yearMonth;
    }).toList();
  }

  /// Get monthly income for PKR
  double getMonthlyPkrIncome(String yearMonth) {
    return getMonthlyTransactions(yearMonth)
        .where((tx) => tx.currency == 'PKR' && tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Get monthly expense for PKR
  double getMonthlyPkrExpense(String yearMonth) {
    return getMonthlyTransactions(yearMonth)
        .where((tx) => tx.currency == 'PKR' && !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Get monthly income for USD
  double getMonthlyUsdIncome(String yearMonth) {
    return getMonthlyTransactions(yearMonth)
        .where((tx) => tx.currency == 'USD' && tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Get monthly expense for USD
  double getMonthlyUsdExpense(String yearMonth) {
    return getMonthlyTransactions(yearMonth)
        .where((tx) => tx.currency == 'USD' && !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

   /// Get all unique months with transactions (sorted descending)
   List<String> getAllMonths() {
     Set<String> months = {};
     for (final tx in transactions) {
       final monthKey = '${tx.dateTime.year}-${tx.dateTime.month.toString().padLeft(2, '0')}';
       months.add(monthKey);
     }
     return months.toList()..sort((a, b) => b.compareTo(a));
   }

   // --- SAVINGS GOALS ACTIONS ---

   void addSavingsGoal({
     required String goalName,
     required double targetAmount,
     required String currency,
     required String category,
     required DateTime targetDate,
     String? description,
   }) {
     final newGoal = SavingsGoalModel(
       id: DateTime.now().millisecondsSinceEpoch.toString(),
       goalName: goalName,
       targetAmount: targetAmount,
       currentAmount: 0.0,
       currency: currency,
       category: category,
       createdDate: DateTime.now(),
       targetDate: targetDate,
       description: description,
       isCompleted: false,
     );
     savingsGoals.add(newGoal);
     saveSavingsGoals();
   }

   void deleteSavingsGoal(String id) {
     savingsGoals.removeWhere((goal) => goal.id == id);
     saveSavingsGoals();
   }

   void updateSavingsGoal({
     required String id,
     String? goalName,
     double? targetAmount,
     String? currency,
     String? category,
     DateTime? targetDate,
     String? description,
     bool? isCompleted,
   }) {
     final idx = savingsGoals.indexWhere((goal) => goal.id == id);
     if (idx == -1) return;
     final old = savingsGoals[idx];
     final updated = old.copyWith(
       goalName: goalName,
       targetAmount: targetAmount,
       currency: currency,
       category: category,
       targetDate: targetDate,
       description: description,
       isCompleted: isCompleted,
     );
     savingsGoals[idx] = updated;
     saveSavingsGoals();
   }

   /// Contribute an amount to a savings goal
   void contributeSavingsGoal(String id, double amount) {
     final idx = savingsGoals.indexWhere((goal) => goal.id == id);
     if (idx == -1) return;
     final old = savingsGoals[idx];
     final newAmount = (old.currentAmount + amount).clamp(0.0, old.targetAmount);
     final updated = old.copyWith(
       currentAmount: newAmount,
       isCompleted: newAmount >= old.targetAmount,
     );
     savingsGoals[idx] = updated;
     saveSavingsGoals();
   }

   /// Get savings goals for a specific currency
   List<SavingsGoalModel> getSavingsGoalsByCurrency(String currency) {
     return savingsGoals.where((goal) => goal.currency == currency).toList();
   }

   /// Get active savings goals (not completed)
   List<SavingsGoalModel> get activeSavingsGoals => savingsGoals.where((goal) => !goal.isCompleted).toList();

   /// Get completed savings goals
   List<SavingsGoalModel> get completedSavingsGoals => savingsGoals.where((goal) => goal.isCompleted).toList();

   /// Get total savings across all goals for a currency
   double getTotalSavaingsForCurrency(String currency) {
     return getSavingsGoalsByCurrency(currency).fold(0.0, (sum, goal) => sum + goal.currentAmount);
   }

  // --- EXPORT METHODS ---

  /// Export all transactions to Excel
  Future<String> exportAllTransactionsToExcel() async {
    return ExportService.exportTransactionsToExcel(transactions);
  }

  /// Export monthly summary to Excel
  Future<String> exportMonthlySummaryToExcel() async {
    return ExportService.exportMonthlySummaryToExcel(transactions);
  }

  /// Get monthly summary without exporting (for in-app display)
  Map<String, Map<String, dynamic>> getMonthlySummary() {
    return ExportService.getMonthlySummary(transactions);
  }
}
