import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:makecents/dataconnect_generated/generated.dart';
import 'package:makecents/helper/ui_helper.dart';
import 'package:makecents/helper/currency_helper.dart';
import 'package:makecents/provider/category_provider.dart';
import 'package:makecents/provider/theme_provider.dart';
import 'package:makecents/provider/transaction_provider.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});
  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  List<Category> _categories = [];
  Category? _selectedCategory;
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
      final result = await ExampleConnector.instance.listCategories().execute();
      if (!mounted) return;
      setState(() {
        _categories = result.data.categories.map((c) {
          return Category(
            c.id,
            c.name,
            getIconByName(c.iconName),
            parseColorHex(c.colorHex),
          );
        }).toList();
        _categories.sort((a, b) {
          final aOther = a.name.toLowerCase() == 'other';
          final bOther = b.name.toLowerCase() == 'other';
          if (aOther != bOther) {
            return aOther ? 1 : -1;
          }
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

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
    if (amountText.isEmpty || parsedAmount == null || parsedAmount <= 0) {
      return;
    }
    if (_selectedCategory == null) return;

    final enteredAmount = parsedAmount;
    final description = _descriptionController.text.trim();

    try {
      await Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).addTransaction(
        enteredAmount,
        _selectedDate,
        description: description.isEmpty ? null : description,
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
    final amountInvalid =
        amountText.isNotEmpty &&
        (parsedAmount == null || !parsedAmount.isFinite || parsedAmount <= 0);

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
                    _submitAttempted && (amountText.isEmpty || amountInvalid),
              ).copyWith(prefixText: currency),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),

            Text(
              'Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
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
                          final onSurface = Theme.of(
                            context,
                          ).colorScheme.onSurface;
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
                              color: isSelected ? Colors.white : onSurface,
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text(
                    'Edit date',
                    style: TextStyle(fontSize: 18),
                  ),
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
