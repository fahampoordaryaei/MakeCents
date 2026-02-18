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
  final double _income = 2000.0;
  double _expenses = 500.0;

  void _addExpense() {
    final String input = _amountController.text;
    if (input.isNotEmpty) {
      final double? amount = double.tryParse(input);
      if (amount != null && amount > 0) {
        setState(() {
          _expenses += amount;
        });
        _amountController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added expense: \$${amount.toStringAsFixed(2)}')),
        );
      }
    }
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
                  const Text(
                    "Add New Expense",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    onPressed: _addExpense,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Expense"),
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
          const SizedBox(height: 20),
          
          // Pie Chart
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: _income,
                    title: _income.toStringAsFixed(0),
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
              _buildLegendItem(Colors.green, "Income (Fixed)"),
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
