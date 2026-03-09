import 'package:flutter/material.dart';

class Scholarship {
  final String title;
  final String provider;
  final String location;
  final double amount;
  final String currency;
  final double minGrade;
  final List<String> subjects;
  final String description;
  final Color color;

  const Scholarship({
    required this.title,
    required this.provider,
    required this.location,
    required this.amount,
    this.currency = '€',
    required this.minGrade,
    required this.subjects,
    required this.description,
    this.color = const Color(0xFF3e7f3f),
  });
}

const List<Scholarship> kScholarships = [
  Scholarship(
    title: 'Tech Excellence Award',
    provider: 'Global Tech Malta',
    location: 'MALTA',
    amount: 5000,
    minGrade: 85,
    subjects: ['Computer Engineering', 'Computer Science', 'IT', 'Software Engineering'],
    description: 'For high-achieving tech students based in Malta pursuing a career in software or engineering.',
    color: Color(0xFF3e7f3f),
  ),
  Scholarship(
    title: 'STEM Future Leaders',
    provider: 'EU Education Fund',
    location: 'EUROPE',
    amount: 3500,
    minGrade: 75,
    subjects: ['Computer Engineering', 'Computer Science', 'Mathematics', 'Physics', 'Chemistry', 'Biology'],
    description: 'Supporting the next generation of European STEM innovators with funding for tuition and research.',
    color: Color(0xFF4ECDC4),
  ),
  Scholarship(
    title: 'Creative Minds Grant',
    provider: 'Arts Council',
    location: 'GLOBAL',
    amount: 2500,
    minGrade: 70,
    subjects: ['Arts', 'Design', 'Music', 'Media', 'Architecture'],
    description: 'Open to creative students worldwide with a passion for arts, design, and cultural expression.',
    color: Color(0xFFAA96DA),
  ),
  Scholarship(
    title: 'Business Leaders Bursary',
    provider: 'Chamber of Commerce',
    location: 'MALTA',
    amount: 4000,
    minGrade: 80,
    subjects: ['Business', 'Economics', 'Finance', 'Management', 'Accounting'],
    description: 'Awarded to ambitious business students who demonstrate leadership and financial acumen.',
    color: Color(0xFFFFBE0B),
  ),
  Scholarship(
    title: 'Health Sciences Award',
    provider: 'National Health Foundation',
    location: 'EUROPE',
    amount: 6000,
    minGrade: 88,
    subjects: ['Medicine', 'Nursing', 'Pharmacy', 'Physiotherapy', 'Biology'],
    description: 'Supporting future healthcare professionals with exceptional academic records.',
    color: Color(0xFFFC5185),
  ),
  Scholarship(
    title: 'General Academic Merit',
    provider: 'Student Finance Malta',
    location: 'GLOBAL',
    amount: 1500,
    minGrade: 65,
    subjects: ['All Subjects'],
    description: 'Open to all students regardless of subject, based purely on academic achievement.',
    color: Color(0xFFFF6B6B),
  ),
];

const List<String> kSubjects = [
  'All Subjects',
  'Computer Engineering',
  'Computer Science',
  'IT',
  'Software Engineering',
  'Mathematics',
  'Physics',
  'Chemistry',
  'Biology',
  'Medicine',
  'Nursing',
  'Pharmacy',
  'Physiotherapy',
  'Business',
  'Economics',
  'Finance',
  'Management',
  'Accounting',
  'Arts',
  'Design',
  'Music',
  'Media',
  'Architecture',
];

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});
  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  final _gradeCtrl = TextEditingController();
  String _subject = 'Computer Engineering';
  String _location = 'Malta';
  List<Scholarship>? _results;
  bool _searched = false;

  @override
  void dispose() {
    _gradeCtrl.dispose();
    super.dispose();
  }

  void _findMatches() {
    final grade = double.tryParse(_gradeCtrl.text.trim());
    if (grade == null || grade < 0 || grade > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid grade between 0 and 100.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _searched = true;
      _results = kScholarships.where((s) {
        final gradeOk = grade >= s.minGrade;
        final subjectOk = s.subjects.contains('All Subjects') || s.subjects.contains(_subject);
        return gradeOk && subjectOk;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          const Text('Scholarship\nMatcher', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), height: 1.2)),
          const SizedBox(height: 4),
          const Text('Find opportunities based on your grades and background.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),

          // Profile input card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Your Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 20),

              // Grade field
              const Text('AVERAGE GRADE (%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              TextField(
                controller: _gradeCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g. 85',
                  filled: true, fillColor: const Color(0xFFF4F7F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Subject dropdown
              const Text('SUBJECT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFFF4F7F5), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _subject,
                    isExpanded: true,
                    items: kSubjects.where((s) => s != 'All Subjects').map((s) =>
                      DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
                    onChanged: (v) => setState(() => _subject = v!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location field
              const Text('LOCATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: _location),
                onChanged: (v) => _location = v,
                decoration: InputDecoration(
                  hintText: 'e.g. Malta',
                  filled: true, fillColor: const Color(0xFFF4F7F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.radar_outlined),
                  label: const Text('Find My Matches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 28),

          // Results
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              _searched ? 'Matched Scholarships' : 'All Scholarships',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
            ),
            if (_searched && _results != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF3e7f3f).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text('${_results!.length} found', style: const TextStyle(color: Color(0xFF3e7f3f), fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            if (!_searched)
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 16, color: Colors.grey),
                label: const Text('Filter', style: TextStyle(color: Colors.grey)),
              ),
          ]),
          const SizedBox(height: 12),

          if (_searched && _results != null && _results!.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Column(children: [
                Icon(Icons.search_off_outlined, size: 44, color: Colors.grey),
                SizedBox(height: 12),
                Text('No matches found', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                SizedBox(height: 4),
                Text('Try a different subject or improve your grade to unlock more scholarships.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
              ])),
            )
          else
            ...(_searched ? _results! : kScholarships).map((s) => _ScholarshipCard(scholarship: s)),
        ]),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Icon
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: s.color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.school_outlined, color: s.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 2),
            Text(s.provider, style: TextStyle(fontSize: 13, color: s.color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            // Tags
            Row(children: [
              _Tag(Icons.location_on_outlined, s.location),
              const SizedBox(width: 8),
              _Tag(Icons.check_circle_outline, 'MIN ${s.minGrade.toInt()}%'),
            ]),
            const SizedBox(height: 10),
            Text(s.description, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${s.currency}${s.amount.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: s.color)),
              GestureDetector(
                onTap: () => _showApplyDialog(context, s),
                child: Row(children: [
                  Text('Apply Now', style: TextStyle(color: s.color, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: s.color, size: 16),
                ]),
              ),
            ]),
          ])),
        ]),
      ),
    );
  }

  void _showApplyDialog(BuildContext context, Scholarship s) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(s.title),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.description, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Text('Amount: ${s.currency}${s.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
        Text('Provider: ${s.provider}', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text('Min Grade: ${s.minGrade.toInt()}%', style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: s.color),
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Application started for ${s.title}!'), backgroundColor: s.color),
            );
          },
          child: const Text('Start Application'),
        ),
      ],
    ));
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFF4F7F5), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: Colors.grey),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
