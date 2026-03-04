import 'package:flutter/material.dart';

class MatchPage extends StatelessWidget {
  const MatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Match',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
