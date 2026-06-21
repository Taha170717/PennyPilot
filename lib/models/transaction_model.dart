class TransactionModel {
  final String id;
  final double amount;
  final bool isIncome; // true for addition (income), false for subtraction (expense)
  final String description; // where money come/gone
  final String currency; // 'PKR' or 'USD'
  final String category;
  final DateTime dateTime;
  final String paymentMethod; // e.g., Cash, Card, Bank
  final String? notes;
  final String? receiptPath;
  TransactionModel({
    required this.id,
    required this.amount,
    required this.isIncome,
    required this.description,
    required this.currency,
    required this.category,
    required this.dateTime,
    this.paymentMethod = 'Cash',
    this.notes,
    this.receiptPath,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'isIncome': isIncome,
      'description': description,
      'currency': currency,
      'category': category,
      'dateTime': dateTime.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'receiptPath': receiptPath,
    };
  }
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      isIncome: json['isIncome'] as bool,
      description: json['description'] as String,
      currency: json['currency'] as String,
      category: json['category'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
      notes: json['notes'] as String?,
      receiptPath: json['receiptPath'] as String?,
    );
  }
}