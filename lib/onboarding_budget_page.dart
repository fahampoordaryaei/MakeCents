import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dataconnect_generated/generated.dart';
import 'main.dart';
import 'budget_provider.dart';
import 'user_provider.dart';
import 'startup_page.dart';

class OnboardingBudgetPage extends StatefulWidget {
  final String? schoolId;
  final String? courseId;
  final String? otherSchool;
  final String? otherCourse;
  final String firstName;
  final String lastName;

  const OnboardingBudgetPage({
    super.key,
    this.schoolId,
    this.courseId,
    this.otherSchool,
    this.otherCourse,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<OnboardingBudgetPage> createState() => _OnboardingBudgetPageState();
}

class _OnboardingBudgetPageState extends State<OnboardingBudgetPage> {
  final _budgetController = TextEditingController(text: '1000');
  double _sliderValue = 1000.0;
  String _error = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _budgetController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final textVal = _budgetController.text.trim();
    if (textVal.isEmpty) return;
    final val = double.tryParse(textVal);
    if (val != null && val >= 0 && val <= 10000) {
      if (_sliderValue != val) {
        setState(() {
          _sliderValue = val;
        });
      }
    } else if (val != null && val > 10000) {
      if (_sliderValue != 10000) {
        setState(() {
          _sliderValue = 10000;
        });
      }
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
      final newText = value.toInt().toString();
      if (_budgetController.text != newText) {
        _budgetController.text = newText;
        _budgetController.selection = TextSelection.fromPosition(
          TextPosition(offset: _budgetController.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _budgetController.removeListener(_onTextChanged);
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _onFinish() async {
    final budgetText = _budgetController.text.trim();
    if (budgetText.isEmpty) {
      setState(() => _error = 'Please enter your budget.');
      return;
    }

    final budget = double.tryParse(budgetText);
    if (budget == null || budget <= 0) {
      setState(() => _error = 'Please enter a valid amount greater than 0.');
      return;
    }
    if (budget > 10000) {
      setState(() => _error = 'The monthly budget cannot exceed €10,000.');
      return;
    }

    setState(() {
      _error = '';
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _error = 'User not found. Please log in again.');
        return;
      }

      final connector = ExampleConnector.instance;
      await connector
          .storeUserProfile(
            username: user.uid,
            email: user.email ?? '',
            firstName: widget.firstName,
            lastName: widget.lastName,
          )
          .schoolId(widget.schoolId)
          .courseId(widget.courseId)
          .otherSchool(widget.otherSchool)
          .otherCourse(widget.otherCourse)
          .monthlyBudget(budget)
          .execute();

      await connector
          .initPointsBalance(userId: user.uid, totalPoints: 0)
          .execute();

      if (!mounted) return;
      final budgetProvider = context.read<BudgetProvider>();
      final userProvider = context.read<UserProvider>();
      await budgetProvider.init();
      await userProvider.loadProfile();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (r) => false,
      );
    } catch (e) {
      setState(() => _error = 'Failed to save profile: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Container(
            padding: const EdgeInsets.all(30.0),
            margin: const EdgeInsets.symmetric(horizontal: 30.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF3e7f3f),
                        size: 18,
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const StartupPage(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3e7f3f),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 48.0,
                  ),
                ),
                const SizedBox(height: 30.0),
                Text(
                  'Set your budget',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Set a monthly budget.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),

                if (_error.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF8B0000),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error,
                            style: const TextStyle(
                              color: Color(0xFF8B0000),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],

                TextFormField(
                  controller: _budgetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: '€',
                    prefixStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF3e7f3f),
                    inactiveTrackColor: const Color(
                      0xFF3e7f3f,
                    ).withValues(alpha: 0.2),
                    thumbColor: const Color(0xFF3e7f3f),
                    overlayColor: const Color(
                      0xFF3e7f3f,
                    ).withValues(alpha: 0.1),
                    trackHeight: 8.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12.0,
                    ),
                  ),
                  child: Slider(
                    value: _sliderValue,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    onChanged: _onSliderChanged,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '€0',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '€10k+',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36.0),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _onFinish,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3e7f3f),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Complete setup',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
