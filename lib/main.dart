import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MakeCentsApp());
}

class MakeCentsApp extends StatelessWidget {
  const MakeCentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MakeCents',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _amountController = TextEditingController();

  // Demo data for the financial tracker
  // Initial values to make the chart look interesting immediately
  double? _budget;
  double _expenses = 0.0;
  bool _showOverBudgetWarning = true;

  void _submitData() {
    final String input = _amountController.text;
    if (input.isNotEmpty) {
      final double? amount = double.tryParse(input);
      if (amount != null && amount > 0) {
        if (_budget == null) {
            setState(() {
            _budget = amount;
            });
            _amountController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Budget set to: \$${amount.toStringAsFixed(2)}')),
            );
        } else {
          // Check if this expense takes us over budget
          if (_showOverBudgetWarning && (_expenses + amount > _budget!)) {
             _showOverBudgetDialog(amount);
          } else {
             _addExpense(amount);
          }
        }
      }
    }
  }

  void _addExpense(double amount) {
    setState(() {
      _expenses += amount;
    });
    _amountController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added expense: \$${amount.toStringAsFixed(2)}')),
    );
  }
  
  Future<void> _showOverBudgetDialog(double amount) async {
    bool dontShowAgain = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Over Budget Warning"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Adding this expense will exceed your budget by \$${(_expenses + amount - _budget!).toStringAsFixed(2)}. Continue?"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: dontShowAgain,
                        onChanged: (val) {
                          setState(() {
                            dontShowAgain = val ?? false;
                          });
                        },
                      ),
                      const Text("Don't show again"),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), 
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () {
                    if (dontShowAgain) {
                      _showOverBudgetWarning = false;
                    }
                    Navigator.of(context).pop();
                    _addExpense(amount);
                  },
                  child: const Text("Add Anyway"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Screens for each tab
    final List<Widget> pages = [
      _buildTrackerPage(),
      const Center(child: Text("History Page Placeholder")),
      const Center(child: Text("Settings Page Placeholder")),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MakeCents Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.pie_chart),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Form Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                   Text(
                    _budget == null ? "Set Monthly Budget" : "Add New Expense",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Amount',
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: _submitData,
                    icon: Icon(_budget == null ? Icons.save : Icons.add),
                    label: Text(_budget == null ? "Set Budget" : "Add Expense"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Chart Section
          const Text(
            "Financial Breakdown",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (_budget != null && _expenses > _budget!)
             Padding(
               padding: const EdgeInsets.only(top: 8.0),
               child: Text(
                 "You are \$${(_expenses - _budget!).toStringAsFixed(2)} over budget",
                 style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                 textAlign: TextAlign.center,
               ),
             ),
          const SizedBox(height: 20),
          
          // Pie Chart
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _budget == null
                    ? [
                        PieChartSectionData(
                          color: Colors.grey.shade300,
                          value: 100,
                          title: "",
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ]
                    : [
                        PieChartSectionData(
                          color: Colors.green,
                          value:
                              (_budget! - _expenses) > 0 ? (_budget! - _expenses) : 0,
                          title: ((_budget! - _expenses) > 0
                                  ? (_budget! - _expenses)
                                  : 0)
                              .toStringAsFixed(0),
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.redAccent,
                          value: _expenses,
                          title: _expenses.toStringAsFixed(0),
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Custom Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.green, "Available"),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.redAccent, "Expenses"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
