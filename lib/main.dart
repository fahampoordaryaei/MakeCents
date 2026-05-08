import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:makecents/firebase_options.dart';
import 'package:makecents/page/budget_page.dart';
import 'package:makecents/page/home_page.dart';
import 'package:makecents/page/points_page.dart';
import 'package:makecents/page/profile_page.dart';
import 'package:makecents/page/scholarships_page.dart';
import 'package:makecents/page/startup_page.dart';
import 'package:makecents/page/tracker_page.dart';
import 'package:makecents/provider/budget_provider.dart';
import 'package:makecents/provider/category_budget_provider.dart';
import 'package:makecents/provider/theme_provider.dart';
import 'package:makecents/provider/transaction_provider.dart';
import 'package:makecents/provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    try {
      final installationId = await FirebaseInstallations.instance.getId();
      debugPrint('Firebase Installation ID: $installationId');
    } catch (e, st) {
      debugPrint('Firebase Installation ID: failed — $e\n$st');
    }
  }

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode
          ? AppleProvider.debug
          : AppleProvider.deviceCheck,
    );
  } catch (_) {}

  final transactionProvider = TransactionProvider();
  final budgetProvider = BudgetProvider();
  final themeProvider = ThemeProvider();
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
        ChangeNotifierProvider(create: (_) => CategoryBudgetProvider()),
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final transactionProvider = context.read<TransactionProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    final userProvider = context.read<UserProvider>();
    await context.read<CategoryBudgetProvider>().load(user.uid);

    await transactionProvider.fetchTransactions();
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    await budgetProvider.init();
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    await userProvider.loadProfile();
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const TrackerPage(),
      const PointsPage(),
      const ScholarshipsPage(),
      ProfilePage(
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
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            removeTop: true,
            child: NavigationBar(
              height: 90,
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              indicatorColor: const Color(0xFF3e7f3f).withValues(alpha: 0.15),
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 32,
                  ),
                  selectedIcon: const Icon(
                    Icons.home,
                    color: Color(0xFF3e7f3f),
                    size: 32,
                  ),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.insights_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 32,
                  ),
                  selectedIcon: const Icon(
                    Icons.insights,
                    color: Color(0xFF3e7f3f),
                    size: 32,
                  ),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.emoji_events_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 32,
                  ),
                  selectedIcon: const Icon(
                    Icons.emoji_events,
                    color: Color(0xFF3e7f3f),
                    size: 32,
                  ),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.school_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 32,
                  ),
                  selectedIcon: const Icon(
                    Icons.school,
                    color: Color(0xFF3e7f3f),
                    size: 32,
                  ),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 32,
                  ),
                  selectedIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF3e7f3f),
                    size: 32,
                  ),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
