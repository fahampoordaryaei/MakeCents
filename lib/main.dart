import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_page.dart';
import 'budget_provider.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'match_page.dart';
import 'points_page.dart';
import 'startup_page.dart';
import 'theme_provider.dart';
import 'tracker_page.dart';
import 'transaction_provider.dart';
import 'user_page.dart';
import 'user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final transactionProvider = TransactionProvider();
  final budgetProvider = BudgetProvider();
  final themeProvider = ThemeProvider();
  try {
    await transactionProvider.fetchTransactions();
  } catch (_) {}
  try {
    await budgetProvider.init();
  } catch (_) {}
  try {
    await themeProvider.loadTheme();
  } catch (_) {}
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: transactionProvider),
        ChangeNotifierProvider.value(value: budgetProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MakeCentsApp(),
    ),
  );
}

class MakeCentsApp extends StatelessWidget {
  const MakeCentsApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'MakeCents',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
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

  Future<void> _refreshSessionData() async {
    final transactionProvider = context.read<TransactionProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    final userProvider = context.read<UserProvider>();

    await transactionProvider.fetchTransactions();
    await budgetProvider.init();
    await userProvider.loadProfile();
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const TrackerPage(),
      const PointsPage(),
      const MatchPage(),
      UserPage(
        onNavigateToBudget: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BudgetPage()),
          );
        },
      ),
    ];
    Future.microtask(_refreshSessionData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: NavigationBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            indicatorColor: const Color(0xFF3e7f3f).withValues(alpha: 0.15),
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                selectedIcon: const Icon(Icons.home, color: Color(0xFF3e7f3f)),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.show_chart_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                selectedIcon: const Icon(
                  Icons.show_chart,
                  color: Color(0xFF3e7f3f),
                ),
                label: 'Tracker',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.emoji_events_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                selectedIcon: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFF3e7f3f),
                ),
                label: 'Points',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.school_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                selectedIcon: const Icon(
                  Icons.school,
                  color: Color(0xFF3e7f3f),
                ),
                label: 'Match',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                selectedIcon: const Icon(
                  Icons.person,
                  color: Color(0xFF3e7f3f),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
