import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tracker_page.dart';
import 'home_page.dart';
import 'user_page.dart';
import 'points_page.dart';
import 'match_page.dart';
import 'add_expense_page.dart';
import 'budget_page.dart';
import 'transaction_provider.dart';
import 'budget_provider.dart';
import 'startup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final transactionProvider = TransactionProvider();
  await transactionProvider.init();

  final budgetProvider = BudgetProvider();
  await budgetProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: transactionProvider),
        ChangeNotifierProvider.value(value: budgetProvider),
      ],
      child: const MakeCentsApp(),
    ),
  );
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
      home: const StartupPage(),
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

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomePage(), // Home
      const TrackerPage(), // Tracker
      const PointsPage(), // Points
      const MatchPage(), // Match
      UserPage(
        onNavigateToBudget: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BudgetPage()),
          );
        },
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const AddExpensePage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MakeCents')),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseModal,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Points',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Match'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
