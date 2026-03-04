import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  final String name;
  const HomePage({super.key, this.name = 'Admin'});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateText = DateFormat('EEEE, MMMM d, yyyy').format(now);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $name! 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color:
                    Theme.of(context).textTheme.headlineSmall?.color ??
                    Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 6),
            Text(
              dateText,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
