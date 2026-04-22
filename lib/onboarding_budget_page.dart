import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'budget_provider.dart';
import 'dataconnect_generated/generated.dart';
import 'functions.dart';
import 'main.dart';
import 'startup_page.dart';
import 'user_provider.dart';

class OnboardingBudgetPage extends StatefulWidget {
  final String? institutionId;
  final String? courseId;
  final String? otherSchool;
  final String? otherCourse;
  final String firstName;
  final String lastName;
  final String? countryIsoCode;
  final String? countryDisplayName;

  const OnboardingBudgetPage({
    super.key,
    this.institutionId,
    this.courseId,
    this.otherSchool,
    this.otherCourse,
    required this.firstName,
    required this.lastName,
    this.countryIsoCode,
    this.countryDisplayName,
  });
  @override
  State<OnboardingBudgetPage> createState() => _OnboardingBudgetPageState();
}

class _OnboardingBudgetPageState extends State<OnboardingBudgetPage> {
  final _budgetController = TextEditingController(text: '1000');
  double _sliderValue = 1000.0;
  String _error = '';
  bool _isLoading = false;
  String _budgetPeriod = 'monthly';

  List<ListCurrenciesCurrencies> _currencies = const [];
  ListCurrenciesCurrencies? _selectedCurrency;

  bool get _isWeekly => _budgetPeriod == 'weekly';

  @override
  void initState() {
    super.initState();
    _budgetController.addListener(_onTextChanged);
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      final result = await ExampleConnector.instance.listCurrencies().execute();
      if (!mounted) return;
      final list = result.data.currencies;
      if (list.isEmpty) return;
      final defaultCurrency = list.firstWhere(
        (c) => c.code.trim().toUpperCase() == 'EUR',
        orElse: () => list.first,
      );
      setState(() {
        _currencies = list;
        _selectedCurrency = defaultCurrency;
      });
      setGlobalCurrency(sign: defaultCurrency.sign, id: defaultCurrency.id);
    } catch (e) {
      debugPrint('onboarding_budget: listCurrencies failed: $e');
    }
  }

  void _onCurrencyChanged(ListCurrenciesCurrencies c) {
    setState(() => _selectedCurrency = c);
    setGlobalCurrency(sign: c.sign, id: c.id);
  }

  void _onTextChanged() {
    final textVal = _budgetController.text.trim();
    if (textVal.isEmpty) return;
    final val = double.tryParse(textVal);
    if (val != null && val >= 10 && val <= 10000) {
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
    if (budget == null || budget < 10) {
      setState(() => _error = 'The minimum budget is ${currency}10.');
      return;
    }
    if (budget > 10000) {
      setState(
        () => _error =
            'The $_budgetPeriod budget cannot exceed ${currency}10,000.',
      );
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

      final fullName = '${widget.firstName} ${widget.lastName}'.trim();
      if (fullName.isNotEmpty && (user.displayName?.trim().isEmpty ?? true)) {
        try {
          await user.updateDisplayName(fullName);
          await user.reload();
        } on FirebaseAuthException catch (e) {
          debugPrint('onboarding_budget: updateDisplayName failed: $e');
        }
      }

      final connector = ExampleConnector.instance;

      final countryId = await _resolveCountryId(
        connector,
        widget.countryIsoCode,
      );

      await connector
          .storeUserProfile(
            userId: user.uid,
            email: _checkEmailCredentials(user),
            firstName: widget.firstName,
            lastName: widget.lastName,
          )
          .institutionId(widget.institutionId)
          .courseId(widget.courseId)
          .otherSchool(widget.otherSchool)
          .otherCourse(widget.otherCourse)
          .budget(budget)
          .countryId(countryId)
          .currencyId(_selectedCurrency?.id)
          .isWeekly(_isWeekly)
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
      debugPrint('onboarding_budget: onFinish failed: $e');
      setState(() => _error = 'Could not save your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<int?> _resolveCountryId(
    ExampleConnector connector,
    String? isoCode,
  ) async {
    final code = isoCode?.trim().toUpperCase();
    if (code == null || code.length != 2) return null;
    try {
      final result = await connector.getCountryIdByCode(code: code).execute();
      final matches = result.data.countries;
      if (matches.isEmpty) {
        debugPrint('onboarding_budget: no country row for ISO "$code"');
        return null;
      }
      return matches.first.id;
    } catch (e) {
      debugPrint('onboarding_budget: getCountryIdByCode("$code") failed: $e');
      return null;
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
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Set your budget period',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                _BudgetPeriodToggle(
                  value: _budgetPeriod,
                  onChanged: (v) => setState(() => _budgetPeriod = v),
                ),
                const SizedBox(height: 32.0),
                Text(
                  'Set your $_budgetPeriod budget.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                if (_error.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEC),
                      borderRadius: BorderRadius.circular(8),
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
                              fontSize: 16,
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
                    prefix: _buildCurrencyDropdown(context),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
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
                    min: 10,
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
                        '${currency}10',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${currency}10,000',
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
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                              fontSize: 18,
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

  Widget _buildCurrencyDropdown(BuildContext context) {
    final sign = _selectedCurrency?.sign ?? currency;
    final textStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 32,
      fontWeight: FontWeight.w900,
    );

    final divider = Container(
      width: 3,
      height: 32,
      margin: const EdgeInsets.only(left: 8, right: 12),
      color: const Color(0xFF7B7B7B),
    );

    if (_currencies.length < 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sign, style: textStyle),
          divider,
        ],
      );
    }

    return PopupMenuButton<ListCurrenciesCurrencies>(
      tooltip: 'Change currency',
      position: PopupMenuPosition.under,
      onSelected: _onCurrencyChanged,
      itemBuilder: (context) => [
        for (final c in _currencies)
          PopupMenuItem<ListCurrenciesCurrencies>(
            value: c,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    c.sign,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(c.code.trim()),
                if (c.id == _selectedCurrency?.id) ...[
                  const Spacer(),
                  const Icon(Icons.check, size: 18, color: Color(0xFF3e7f3f)),
                ],
              ],
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sign, style: textStyle),
          Icon(
            Icons.arrow_drop_down,
            size: 36,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          divider,
        ],
      ),
    );
  }
}

String _checkEmailCredentials(User user) {
  final email = user.email?.trim();
  if (email != null && email.isNotEmpty) return email;
  final phone = user.phoneNumber?.trim();
  if (phone != null && phone.isNotEmpty) return phone;
  return '';
}

class _BudgetPeriodToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _BudgetPeriodToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: _option(context, 'monthly', 'Monthly')),
          Expanded(child: _option(context, 'weekly', 'Weekly')),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, String optionValue, String label) {
    final selected = value == optionValue;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!selected) onChanged(optionValue);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3e7f3f) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }
}
