import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dataconnect_generated/generated.dart';
import 'functions.dart';
import 'user_provider.dart';

class Scholarship {
  final String title;
  final String provider;
  final String email;
  final double amount;
  final String currency;
  final List<String> courseIds;
  final String description;
  final Color color;
  final String regionLabel;
  final Color regionColor;

  Scholarship({
    required this.title,
    required this.provider,
    required this.email,
    required this.amount,
    required this.currency,
    required this.courseIds,
    required this.description,
    required this.regionLabel,
    required this.regionColor,
    this.color = const Color(0xFF3e7f3f),
  });
}

class ScholarshipsPage extends StatefulWidget {
  const ScholarshipsPage({super.key});
  @override
  State<ScholarshipsPage> createState() => _ScholarshipsPageState();
}

class _ScholarshipsPageState extends State<ScholarshipsPage> {
  List<Scholarship>? _allScholarships;

  @override
  void initState() {
    super.initState();
    _loadScholarships();
  }

  Future<void> _loadScholarships() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() => _allScholarships = const []);
        return;
      }
      final connector = ExampleConnector.instance;
      final profileResult = await connector
          .getUserProfile(userId: user.uid)
          .execute();
      final countryId = profileResult.data.users.isNotEmpty
          ? profileResult.data.users.first.country?.id
          : null;
      final rows = await fetchScholarshipsForLocation(
        connector,
        countryId: countryId,
      );

      if (!mounted) return;
      setState(() {
        _allScholarships = rows.map((s) {
          final r = scholarshipRegion(s);
          return Scholarship(
            title: s.title,
            provider: s.provider,
            email: s.email,
            amount: s.amount,
            currency: s.currency,
            description: s.description,
            courseIds: s.courses_via_ScholarshipCourse
                .map((course) => course.id)
                .toList(),
            color: Color(int.parse(s.color.replaceFirst('#', '0xFF'))),
            regionLabel: r.$1,
            regionColor: r.$2,
          );
        }).toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _allScholarships = const []);
    }
  }

  List<Scholarship> _scholarshipsMatches(UserProfile? profile) {
    final all = _allScholarships;
    if (all == null || profile == null) return const [];
    if (profile.hasOtherCourse) return const [];
    final id = profile.courseId;
    if (id == null) return const [];
    return all.where((s) => s.courseIds.contains(id)).toList();
  }

  Widget _scholarshipNotice(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 44, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.85),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final matched = _scholarshipsMatches(profile);
    final scholarshipsLoading = _allScholarships == null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scholarships',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scholarships matching your student profile.',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.85),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            if (scholarshipsLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF3e7f3f)),
                ),
              )
            else if (userProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF3e7f3f)),
                ),
              )
            else if (profile?.hasOtherCourse ?? false)
              _scholarshipNotice(
                context,
                icon: Icons.school_outlined,
                title: 'No scholarships',
                body: 'No scholarships for your other course.',
              )
            else
              ...matched.map((s) => _ScholarshipCard(scholarship: s)),
          ],
        ),
      ),
    );
  }
}

class _ScholarshipCard extends StatelessWidget {
  final Scholarship scholarship;
  const _ScholarshipCard({required this.scholarship});

  @override
  Widget build(BuildContext context) {
    final s = scholarship;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: s.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.school_outlined, color: s.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.provider,
                    style: TextStyle(
                      fontSize: 18,
                      color: s.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  scholarshipRegionLabel(s.regionLabel, s.regionColor),
                  const SizedBox(height: 10),
                  Text(
                    s.description,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${s.currency}${s.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: s.color,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => showScholarshipApplyDialog(
                          context,
                          title: s.title,
                          provider: s.provider,
                          email: s.email,
                          amount: s.amount,
                          currency: s.currency,
                          description: s.description,
                          brandColor: s.color,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Apply Now',
                              style: TextStyle(
                                color: s.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, color: s.color, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
