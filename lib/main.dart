import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'tracker_page.dart';
import 'home_page.dart';
import 'user_page.dart';
import 'points_page.dart';
import 'match_page.dart';
import 'budget_page.dart';
import 'transaction_provider.dart';
import 'budget_provider.dart';
import 'startup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< Updated upstream
=======
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

>>>>>>> Stashed changes
  final transactionProvider = TransactionProvider();
  await transactionProvider.init();
  final budgetProvider = BudgetProvider();
  await budgetProvider.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: transactionProvider),
      ChangeNotifierProvider.value(value: budgetProvider),
    ],
    child: const MakeCentsApp(),
  ));
}

class MakeCentsApp extends StatelessWidget {
  const MakeCentsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MakeCents',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3e7f3f),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
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
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const TrackerPage(),
      const PointsPage(),
      const MatchPage(),
      UserPage(onNavigateToBudget: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetPage()));
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, -4))],
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          child: NavigationBar(
            backgroundColor: Colors.white,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            indicatorColor: const Color(0xFF3e7f3f).withOpacity(0.15),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF3e7f3f)), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart, color: Color(0xFF3e7f3f)), label: 'Tracker'),
              NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events, color: Color(0xFF3e7f3f)), label: 'Points'),
              NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school, color: Color(0xFF3e7f3f)), label: 'Match'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Color(0xFF3e7f3f)), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
