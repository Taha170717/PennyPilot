class SavingsGoalModel {
  final String id;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final String currency; // 'PKR' or 'USD'
  final String category; // e.g., 'Vacation', 'Education', 'Emergency', 'Car', 'House', 'Other'
  final DateTime createdDate;
  final DateTime targetDate;
  final String? description;
  final bool isCompleted;

  SavingsGoalModel({
    required this.id,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    required this.category,
    required this.createdDate,
    required this.targetDate,
    this.description,
    this.isCompleted = false,
  });

  /// Calculate the progress as a percentage (0.0 to 1.0)
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  /// Get remaining amount needed
  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0.0, double.infinity);
  }

  /// Check if goal is achieved
  bool get isAchieved => currentAmount >= targetAmount;

  /// Get days remaining until target date
  int get daysRemaining {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }

  /// Calculate monthly savings needed to reach goal
  double get monthlySavingsNeeded {
    final now = DateTime.now();
    final monthsRemaining = targetDate.difference(now).inDays / 30;
    if (monthsRemaining <= 0) return 0.0;
    return remainingAmount / monthsRemaining;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalName': goalName,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'currency': currency,
      'category': category,
      'createdDate': createdDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] as String,
      goalName: json['goalName'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      category: json['category'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      targetDate: DateTime.parse(json['targetDate'] as String),
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Create a copy with updated fields
  SavingsGoalModel copyWith({
    String? id,
    String? goalName,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    String? category,
    DateTime? createdDate,
    DateTime? targetDate,
    String? description,
    bool? isCompleted,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      goalName: goalName ?? this.goalName,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      createdDate: createdDate ?? this.createdDate,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

