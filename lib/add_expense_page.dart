import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dataconnect_generated/generated.dart';
import 'theme_provider.dart';
import 'functions.dart';
import 'transaction_provider.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});
  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  List<ExpenseCategory> _categories = [];
  ExpenseCategory? _selectedCategory;
  bool _isLoadingCategories = true;
  bool _submitAttempted = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await ExampleConnector.instance
          .listExpenseCategories()
          .execute();
      if (!mounted) return;
      setState(() {
        _categories = result.data.expenseCategories.map((c) {
          return ExpenseCategory(
            c.id,
            c.name,
            getIconByName(c.iconName),
            parseColorHex(c.colorHex),
          );
        }).toList();

        if (_categories.isNotEmpty) {
          _selectedCategory = _categories[0];
        }
        _isLoadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitData() async {
    setState(() => _submitAttempted = true);
    final amountText = _amountController.text.trim();
    final parsedAmount = double.tryParse(amountText);
    if (amountText.isEmpty || parsedAmount == null) return;
    if (_selectedCategory == null) return;

    final enteredAmount = parsedAmount;
    final enteredDescription = _descriptionController.text;

    try {
      await Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).addTransaction(
        enteredDescription,
        enteredAmount,
        _selectedDate,
        categoryName: _selectedCategory!.name,
        categoryId: _selectedCategory!.id,
      );

      if (!mounted) return;
      setState(() => _submitAttempted = false);
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      await popupAlert(
        context,
        message: 'Failed to save transaction.',
        level: AppAlertLevel.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountText = _amountController.text.trim();
    final parsedAmount = double.tryParse(amountText);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: requiredField(
                context,
                label: 'Amount',
                hasError:
                    _submitAttempted &&
                    (amountText.isEmpty || parsedAmount == null),
              ).copyWith(prefixText: currency),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),

            const Text(
              'Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _submitAttempted && _selectedCategory == null
                            ? Color(0xFFB91C1C)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final isSelected =
                              _selectedCategory?.name == cat.name;
                          return ChoiceChip(
                            avatar: Icon(
                              cat.icon,
                              size: 18,
                              color: isSelected ? Colors.white : cat.color,
                            ),
                            label: Text(cat.name),
                            selected: isSelected,
                            selectedColor: cat.color,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (_) {
                              setState(() => _selectedCategory = cat);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Edit date'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3e7f3f),
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : null,
              ),
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
