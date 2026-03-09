import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});
  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final _ctrl = PageController();
  int _page = 0;

  static const _slides = [
    _Slide('Track Your Spending', 'See where every penny goes. Stay in control of your student finances.', Icons.show_chart_outlined, Color(0xFF3e7f3f)),
    _Slide('Set Your Budget', 'Define monthly limits and get warned before you overspend.', Icons.account_balance_wallet_outlined, Color(0xFF4ECDC4)),
    _Slide('Earn Points', 'Build healthy money habits and level up as you track.', Icons.emoji_events_outlined, Color(0xFFAA96DA)),
    _Slide('Smart Tips', 'Get personalised advice to make the most of your money.', Icons.lightbulb_outline, Color(0xFFFFBE0B)),
    _Slide('Get Started', 'Join thousands of students managing finances smarter.', Icons.savings_outlined, Color(0xFFFC5185)),
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (p) => setState(() => _page = p),
              itemCount: _slides.length,
              itemBuilder: (_, i) {
                final s = _slides[i];
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: s.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(s.icon, size: 50, color: s.color),
                    ),
                    const SizedBox(height: 40),
                    Text(s.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text(s.subtitle, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.6), textAlign: TextAlign.center),
                  ]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_slides.length, (i) =>
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 22 : 8, height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? const Color(0xFF3e7f3f) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )),
              const SizedBox(height: 28),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RegisterPage())),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3e7f3f),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Get Started', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              )),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage())),
                child: const Text('Already have an account? Log in', style: TextStyle(color: Color(0xFF3e7f3f), fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Slide {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  const _Slide(this.title, this.subtitle, this.icon, this.color);
}
