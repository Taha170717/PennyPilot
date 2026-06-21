import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/transaction_model.dart';
import 'auth_controller.dart';
import '../models/user_model.dart';

class BudgetController extends GetxController {
  final _storage = GetStorage();
  final _storageKeyBase = 'transactions_list';
  // Reactive master list of transactions
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  late final AuthController _auth;

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<AuthController>();
    // load for current user (if any)
    loadTransactionsForCurrentUser();
    // React to auth changes so transactions load for the correct user when login/logout occurs
    ever(_auth.currentUserRx, (UserModel? user) {
      loadTransactionsForUser(user?.id);
    });
  }

  // --- PERSISTENCE ---

  String _userStorageKey(String? userId) => '${_storageKeyBase}_${userId ?? 'public'}';

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
}
