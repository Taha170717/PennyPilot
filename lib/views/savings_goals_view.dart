import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/budget_controller.dart';
import '../models/savings_goal_model.dart';

String _formatAmount(double value) {
  final s = value.toStringAsFixed(2);
  if (s.endsWith('.00')) return s.substring(0, s.length - 3);
  if (s.endsWith('0')) return s.substring(0, s.length - 1);
  return s;
}

class SavingsGoalsView extends StatefulWidget {
  const SavingsGoalsView({super.key});

  @override
  State<SavingsGoalsView> createState() => _SavingsGoalsViewState();
}

class _SavingsGoalsViewState extends State<SavingsGoalsView> {
  final BudgetController _budgetCtrl = Get.find<BudgetController>();
  String _selectedCurrency = 'PKR';
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor;
    final bg = theme.scaffoldBackgroundColor;
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodyMedium?.color;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardBg,
        title: Text('Savings Goals', style: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: bg,
      body: Obx(() {
        // Get goals for selected currency, filtered by completion status
        final allGoals = _budgetCtrl.getSavingsGoalsByCurrency(_selectedCurrency);
        final goals = _showCompleted ? allGoals.where((g) => g.isCompleted).toList() : allGoals.where((g) => !g.isCompleted).toList();

        return Column(
          children: [
            // Header with currency selector and toggle
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Currency selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: _selectedCurrency,
                        dropdownColor: cardBg,
                        style: GoogleFonts.outfit(color: textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'PKR', child: Text('PKR')),
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _selectedCurrency = v);
                          }
                        },
                      ),
                      // Toggle between active and completed
                      TextButton(
                        onPressed: () => setState(() => _showCompleted = !_showCompleted),
                        child: Text(
                          _showCompleted ? 'Show Active' : 'Show Completed',
                          style: GoogleFonts.outfit(color: primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Summary card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primary.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primary.withAlpha((0.3 * 255).round())),
                    ),
                    child: Obx(() {
                      final symbol = _selectedCurrency == 'PKR' ? 'Rs.' : '\$';
                      final totalSavings = _budgetCtrl.getTotalSavaingsForCurrency(_selectedCurrency);
                      final activeCount = _budgetCtrl.getSavingsGoalsByCurrency(_selectedCurrency).where((g) => !g.isCompleted).length;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Saved', style: GoogleFonts.outfit(color: textSecondary, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('$symbol${_formatAmount(totalSavings)}', style: GoogleFonts.outfit(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Active Goals', style: GoogleFonts.outfit(color: textSecondary, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('$activeCount', style: GoogleFonts.outfit(color: primary, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Goals list
            Expanded(
              child: goals.isEmpty
                  ? Center(
                      child: Text(
                        _showCompleted ? 'No completed goals yet' : 'No active goals yet\nTap + to create one',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(color: textSecondary, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: goals.length,
                      itemBuilder: (context, idx) {
                        final goal = goals[idx];
                        return _SavingsGoalCard(
                          goal: goal,
                          onEdit: () => _showEditDialog(goal),
                          onDelete: () => _showDeleteConfirm(goal.id),
                          onContribute: () => _showContributeDialog(goal),
                          onCompleted: (completed) {
                            _budgetCtrl.updateSavingsGoal(
                              id: goal.id,
                              isCompleted: completed,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    Get.dialog(
      AddSavingsGoalDialog(
        initialCurrency: _selectedCurrency,
        onSave: (goalName, targetAmount, category, targetDate, description) {
          _budgetCtrl.addSavingsGoal(
            goalName: goalName,
            targetAmount: targetAmount,
            currency: _selectedCurrency,
            category: category,
            targetDate: targetDate,
            description: description,
          );
          Get.back();
          Get.snackbar('Success', 'Savings goal created!', snackPosition: SnackPosition.TOP);
        },
      ),
    );
  }

  void _showEditDialog(SavingsGoalModel goal) {
    Get.dialog(
      EditSavingsGoalDialog(
        goal: goal,
        onSave: (goalName, targetAmount, category, targetDate, description) {
          _budgetCtrl.updateSavingsGoal(
            id: goal.id,
            goalName: goalName,
            targetAmount: targetAmount,
            category: category,
            targetDate: targetDate,
            description: description,
          );
          Get.back();
          Get.snackbar('Success', 'Goal updated!', snackPosition: SnackPosition.TOP);
        },
      ),
    );
  }

  void _showContributeDialog(SavingsGoalModel goal) {
    Get.dialog(
      ContributeSavingsDialog(
        goal: goal,
        onContribute: (amount) {
          _budgetCtrl.contributeSavingsGoal(goal.id, amount);
          Get.back();
          Get.snackbar('Success', 'Contribution added! 🎉', snackPosition: SnackPosition.TOP);
        },
      ),
    );
  }

  void _showDeleteConfirm(String goalId) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Goal?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('This action cannot be undone.', style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: GoogleFonts.outfit()),
          ),
          TextButton(
            onPressed: () {
              _budgetCtrl.deleteSavingsGoal(goalId);
              Get.back();
              Get.snackbar('Deleted', 'Savings goal removed', snackPosition: SnackPosition.TOP);
            },
            child: Text('Delete', style: GoogleFonts.outfit(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SavingsGoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onContribute;
  final Function(bool) onCompleted;

  const _SavingsGoalCard({
    required this.goal,
    required this.onEdit,
    required this.onDelete,
    required this.onContribute,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor;
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodyMedium?.color;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    final symbol = goal.currency == 'PKR' ? 'Rs.' : '\$';
    final progress = goal.progressPercentage;
    final daysRemaining = goal.daysRemaining;
    final onTrack = goal.monthlySavingsNeeded > 0;

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.goalName,
                        style: GoogleFonts.outfit(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary.withAlpha((0.15 * 255).round()),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          goal.category,
                          style: GoogleFonts.outfit(color: primary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: primary, size: 18),
                          const SizedBox(width: 8),
                          Text('Edit', style: GoogleFonts.outfit()),
                        ],
                      ),
                      onTap: onEdit,
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Text('Delete', style: GoogleFonts.outfit()),
                        ],
                      ),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$symbol${_formatAmount(goal.currentAmount)} / $symbol${_formatAmount(goal.targetAmount)}',
                      style: GoogleFonts.outfit(color: textSecondary, fontSize: 13),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.outfit(color: primary, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: textSecondary?.withAlpha((0.2 * 255).round()),
                    valueColor: AlwaysStoppedAnimation(
                      goal.isAchieved ? secondary : primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Days Remaining', style: GoogleFonts.outfit(color: textSecondary, fontSize: 11)),
                    Text(
                      daysRemaining > 0 ? '$daysRemaining days' : 'Overdue',
                      style: GoogleFonts.outfit(
                        color: daysRemaining > 0 ? textPrimary : Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Monthly Target', style: GoogleFonts.outfit(color: textSecondary, fontSize: 11)),
                    Text(
                      '$symbol${_formatAmount(goal.monthlySavingsNeeded)}',
                      style: GoogleFonts.outfit(
                        color: onTrack ? textPrimary : Colors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onContribute,
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text('Contribute', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (goal.isAchieved && !goal.isCompleted)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onCompleted(true),
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text('Mark Complete', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddSavingsGoalDialog extends StatefulWidget {
  final String initialCurrency;
  final Function(String goalName, double targetAmount, String category, DateTime targetDate, String? description) onSave;

  const AddSavingsGoalDialog({
    super.key,
    required this.initialCurrency,
    required this.onSave,
  });

  @override
  State<AddSavingsGoalDialog> createState() => _AddSavingsGoalDialogState();
}

class _AddSavingsGoalDialogState extends State<AddSavingsGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _goalNameCtrl;
  late TextEditingController _targetAmountCtrl;
  late TextEditingController _descriptionCtrl;
  late DateTime _targetDate;
  late String _selectedCategory;

  final List<String> _categories = [
    'Vacation',
    'Education',
    'Emergency',
    'Car',
    'House',
    'Wedding',
    'Investment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _goalNameCtrl = TextEditingController();
    _targetAmountCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _targetDate = DateTime.now().add(const Duration(days: 365));
    _selectedCategory = _categories.first;
  }

  @override
  void dispose() {
    _goalNameCtrl.dispose();
    _targetAmountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor;
    final textPrimary = theme.textTheme.bodyLarge?.color;

    return AlertDialog(
      backgroundColor: cardBg,
      title: Text('New Savings Goal', style: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _goalNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  hintText: 'e.g., Summer Vacation',
                  labelStyle: GoogleFonts.outfit(color: textPrimary),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetAmountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Amount',
                  labelStyle: GoogleFonts.outfit(color: textPrimary),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v ?? 'Other'),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: GoogleFonts.outfit(color: textPrimary),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Target Date', style: GoogleFonts.outfit(color: textPrimary)),
                trailing: Text(DateFormat.yMd().format(_targetDate), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) setState(() => _targetDate = picked);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: GoogleFonts.outfit(color: textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel', style: GoogleFonts.outfit()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _goalNameCtrl.text,
                double.parse(_targetAmountCtrl.text),
                _selectedCategory,
                _targetDate,
                _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
              );
            }
          },
          child: Text('Create', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class EditSavingsGoalDialog extends StatefulWidget {
  final SavingsGoalModel goal;
  final Function(String goalName, double targetAmount, String category, DateTime targetDate, String? description) onSave;

  const EditSavingsGoalDialog({
    super.key,
    required this.goal,
    required this.onSave,
  });

  @override
  State<EditSavingsGoalDialog> createState() => _EditSavingsGoalDialogState();
}

class _EditSavingsGoalDialogState extends State<EditSavingsGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _goalNameCtrl;
  late TextEditingController _targetAmountCtrl;
  late TextEditingController _descriptionCtrl;
  late DateTime _targetDate;
  late String _selectedCategory;

  final List<String> _categories = [
    'Vacation',
    'Education',
    'Emergency',
    'Car',
    'House',
    'Wedding',
    'Investment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _goalNameCtrl = TextEditingController(text: widget.goal.goalName);
    _targetAmountCtrl = TextEditingController(text: widget.goal.targetAmount.toString());
    _descriptionCtrl = TextEditingController(text: widget.goal.description ?? '');
    _targetDate = widget.goal.targetDate;
    _selectedCategory = widget.goal.category;
  }

  @override
  void dispose() {
    _goalNameCtrl.dispose();
    _targetAmountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor;
    final textPrimary = theme.textTheme.bodyLarge?.color;

    return AlertDialog(
      backgroundColor: cardBg,
      title: Text('Edit Savings Goal', style: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _goalNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  labelStyle: GoogleFonts.outfit(color: textPrimary),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetAmountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Amount',
                  labelStyle: GoogleFonts.outfit(color: textPrimary),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v ?? 'Other'),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: GoogleFonts.outfit(color: textPrimary),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Target Date', style: GoogleFonts.outfit(color: textPrimary)),
                trailing: Text(DateFormat.yMd().format(_targetDate), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) setState(() => _targetDate = picked);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: GoogleFonts.outfit(color: textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel', style: GoogleFonts.outfit()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _goalNameCtrl.text,
                double.parse(_targetAmountCtrl.text),
                _selectedCategory,
                _targetDate,
                _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
              );
            }
          },
          child: Text('Update', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class ContributeSavingsDialog extends StatefulWidget {
  final SavingsGoalModel goal;
  final Function(double amount) onContribute;

  const ContributeSavingsDialog({
    super.key,
    required this.goal,
    required this.onContribute,
  });

  @override
  State<ContributeSavingsDialog> createState() => _ContributeSavingsDialogState();
}

class _ContributeSavingsDialogState extends State<ContributeSavingsDialog> {
  late TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor;
    final textPrimary = theme.textTheme.bodyLarge?.color;

    final symbol = widget.goal.currency == 'PKR' ? 'Rs.' : '\$';

    return AlertDialog(
      backgroundColor: cardBg,
      title: Text('Add Contribution', style: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal: ${widget.goal.goalName}',
            style: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Remaining: $symbol${_formatAmount(widget.goal.remainingAmount)}',
            style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '$symbol ',
              labelStyle: GoogleFonts.outfit(color: textPrimary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel', style: GoogleFonts.outfit()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_amountCtrl.text.isNotEmpty) {
              final amount = double.tryParse(_amountCtrl.text) ?? 0;
              if (amount > 0) {
                widget.onContribute(amount);
              }
            }
          },
          child: Text('Contribute', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

