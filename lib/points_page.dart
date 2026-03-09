import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'transaction_provider.dart';

class PointsPage extends StatelessWidget {
  const PointsPage({super.key});

  int _calcPoints(List<Transaction> txs) => txs.length * 10;

  @override
  Widget build(BuildContext context) {
    final txs = Provider.of<TransactionProvider>(context).transactions;
    final points = _calcPoints(txs);
    final level = (points / 100).floor() + 1;
    final progress = (points % 100) / 100.0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Points', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          const Text('Earn points by tracking your spending', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),

          // Points card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFAA96DA), Color(0xFFFC5185)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: const Color(0xFFAA96DA).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Column(children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text('$points', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
              const Text('Total Points', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('Level $level', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const SizedBox(height: 16),
              ClipRRect(borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: progress, minHeight: 8,
                  backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white))),
              const SizedBox(height: 6),
              Text('${(progress * 100).toStringAsFixed(0)}% to Level ${level + 1}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 28),

          const Text('How to earn points', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          ...[
            ('Log an expense', '+10 pts', Icons.add_circle_outline, const Color(0xFF4ECDC4)),
            ('Stay under budget', '+50 pts', Icons.savings_outlined, const Color(0xFF3e7f3f)),
            ('Log 7 days in a row', '+100 pts', Icons.local_fire_department_outlined, const Color(0xFFFFBE0B)),
          ].map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: e.$4.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(e.$3, color: e.$4, size: 20)),
                const SizedBox(width: 14),
                Expanded(child: Text(e.$1, style: const TextStyle(fontWeight: FontWeight.w600))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: e.$4.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(e.$2, style: TextStyle(color: e.$4, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ]),
            ),
          )),
        ]),
      ),
    );
  }
}
