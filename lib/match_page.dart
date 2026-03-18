import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dataconnect_generated/generated.dart';

class Scholarship {
  final String title;
  final String provider;
  final String email;
  final double amount;
  final String currency;
  final List<String> courseIds;
  final String description;
  final Color color;

  const Scholarship({
    required this.title,
    required this.provider,
    required this.email,
    required this.amount,
    this.currency = '€',
    required this.courseIds,
    required this.description,
    this.color = const Color(0xFF3e7f3f),
  });
}

class MatcherCourse {
  final String id;
  final String name;
  const MatcherCourse({required this.id, required this.name});
}

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});
  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  List<MatcherCourse> _courses = const [];
  String? _selectedCourseId;
  List<Scholarship>? _allScholarships;
  List<Scholarship>? _results;
  bool _searched = false;
  bool _coursesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadScholarships();
    _loadCoursesAndProfileSelection();
  }

  Future<void> _loadCoursesAndProfileSelection() async {
    try {
      final connector = ExampleConnector.instance;
      final coursesResult = await connector.listCourses().execute();
      final courses = coursesResult.data.courses
          .map((c) => MatcherCourse(id: c.id, name: c.name))
          .toList();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _coursesLoaded = true;
          _courses = courses;
          _selectedCourseId = courses.isNotEmpty ? courses.first.id : null;
        });
        return;
      }

      final result = await connector
          .getUserProfile(username: user.uid)
          .execute();
      final dbUser = result.data.users.isNotEmpty
          ? result.data.users.first
          : null;
      final selectedCourseId = dbUser?.course?.id;

      if (!mounted) return;
      setState(() {
        _coursesLoaded = true;
        _courses = courses;
        _selectedCourseId =
            selectedCourseId ?? (courses.isNotEmpty ? courses.first.id : null);
      });
    } catch (e) {
      debugPrint('Error loading courses: $e');
      if (!mounted) return;
      setState(() {
        _coursesLoaded = true;
        _courses = const [];
        _selectedCourseId = null;
      });
    }
  }

  Future<void> _loadScholarships() async {
    try {
      final connector = ExampleConnector.instance;
      final result = await connector.listScholarships().execute();

      setState(() {
        _allScholarships = result.data.scholarships.map((s) {
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
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading scholarships: $e');
      setState(() {});
    }
  }

  void _findMatches() {
    if (_allScholarships == null) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searched = true;
      final selectedCourseId = _selectedCourseId;
      if (selectedCourseId == null) {
        _results = <Scholarship>[];
        return;
      }
      _results = _allScholarships!.where((s) {
        return s.courseIds.contains(selectedCourseId);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Scholarship\nMatcher',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Find opportunities based on your background and course.',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Profile input card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Course dropdown
                  const Text(
                    'COURSE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_coursesLoaded)
                    const LinearProgressIndicator(minHeight: 2)
                  else if (_courses.isEmpty)
                    Text(
                      'No courses available.',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCourseId,
                          isExpanded: true,
                          items: _courses
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCourseId = v),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Find button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _findMatches,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF3e7f3f),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.radar_outlined),
                      label: const Text(
                        'Find matches',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Results
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searched ? 'Matched Scholarships' : 'All Scholarships',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (_searched && _results != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3e7f3f).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_results!.length} found',
                      style: const TextStyle(
                        color: Color(0xFF3e7f3f),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_searched && _results != null && _results!.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_outlined,
                        size: 44,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No matches found',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try a different course to see more scholarships.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(_searched ? (_results ?? []) : (_allScholarships ?? [])).map(
                (s) => _ScholarshipCard(scholarship: s),
              ),
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
          borderRadius: BorderRadius.circular(18),
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
                borderRadius: BorderRadius.circular(14),
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
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.provider,
                    style: TextStyle(
                      fontSize: 15,
                      color: s.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Please email us your application letter and school records.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
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
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: s.color,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showApplyDialog(context, s),
                        child: Row(
                          children: [
                            Text(
                              'Apply Now',
                              style: TextStyle(
                                color: s.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
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

  void _showApplyDialog(BuildContext context, Scholarship s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(s.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provider: ${s.provider}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: ${s.currency}${s.amount.toStringAsFixed(0)}',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              s.description,
              style: const TextStyle(color: Colors.black87, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please email us your application letter and school records.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontSize: 16)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: s.color),
            onPressed: () => _launchApplyEmail(context, s),
            child: const Text('Open Email', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchApplyEmail(BuildContext context, Scholarship s) async {
    final uri = Uri(
      scheme: 'mailto',
      path: s.email,
      queryParameters: {
        'subject': 'Scholarship Application - ${s.title}',
        'body': 'Please email us your application letter and school records.',
      },
    );

    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open your email app.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
