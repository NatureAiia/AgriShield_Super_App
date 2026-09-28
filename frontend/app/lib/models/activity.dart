/// One entry in the spraying & activity calendar (backend/app/routers/calendar.py).
class Activity {
  final String id;
  final String title;
  final String notes;
  final DateTime scheduledFor;
  final String status; // 'pending' | 'completed'
  final String source; // 'manual' | 'disease_scan'

  const Activity({
    required this.id,
    required this.title,
    required this.notes,
    required this.scheduledFor,
    required this.status,
    required this.source,
  });

  bool get isCompleted => status == 'completed';

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        title: json['title'] as String,
        notes: json['notes'] as String? ?? '',
        scheduledFor: DateTime.parse(json['scheduled_for'] as String),
        status: json['status'] as String? ?? 'pending',
        source: json['source'] as String? ?? 'manual',
      );
}
