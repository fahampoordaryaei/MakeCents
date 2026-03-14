import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dataconnect_generated/generated.dart';
import 'transaction_provider.dart';
import 'functions.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  List<ExpenseCategory> _categories = [];
  ExpenseCategory? _selectedCategory;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await ExampleConnector.instance
          .listExpenseCategories()
          .execute();
      setState(() {
        _categories = result.data.expenseCategories.map((c) {
          return ExpenseCategory(
            c.id,
            c.name,
            _getIcon(c.iconName),
            Color(int.parse(c.colorHex.replaceFirst('#', '0xFF'))),
          );
        }).toList();

        if (_categories.isNotEmpty) {
          _selectedCategory = _categories[0];
        }
        _isLoadingCategories = false;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'favorite':
        return Icons.favorite;
      case 'school':
        return Icons.school;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'receipt_long':
        return Icons.receipt_long;
      default:
        return Icons.more_horiz;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    final enteredAmount = double.parse(_amountController.text);
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
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save transaction.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '€',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),

              const Text(
                'Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory?.name == cat.name;
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
                    child: const Text('Change Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
