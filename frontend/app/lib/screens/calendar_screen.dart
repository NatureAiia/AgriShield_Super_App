import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/activity.dart';
import '../models/farmer.dart';
import '../services/calendar_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

/// Spraying & activity calendar (backend/app/routers/calendar.py):
/// schedule farm tasks, toggle pending/completed, delete. A disease scan
/// can seed an entry here via [CalendarScreen.prefill] (see
/// disease_scan_screen.dart's "Schedule spraying" button).
class CalendarScreen extends StatefulWidget {
  final Farmer farmer;
  final CalendarService calendarService;
  final String? prefillTitle;

  const CalendarScreen({
    super.key,
    required this.farmer,
    required this.calendarService,
    this.prefillTitle,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Activity> _activities = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load().then((_) {
      if (widget.prefillTitle != null) _openCreateDialog(initialTitle: widget.prefillTitle);
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final activities = await widget.calendarService.list(widget.farmer.id);
      if (!mounted) return;
      setState(() {
        _activities = activities;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Couldn't load the calendar — check your connection.";
        _loading = false;
      });
    }
  }

  Future<void> _toggle(Activity activity) async {
    try {
      final updated = await widget.calendarService.toggle(activity.id);
      if (!mounted) return;
      setState(() {
        _activities = [for (final a in _activities) if (a.id == updated.id) updated else a];
      });
    } catch (_) {
      // Best-effort — the list still reflects the last known state.
    }
  }

  Future<void> _delete(Activity activity) async {
    try {
      await widget.calendarService.delete(activity.id);
      if (!mounted) return;
      setState(() => _activities.removeWhere((a) => a.id == activity.id));
    } catch (_) {
      // Best-effort.
    }
  }

  Future<void> _openCreateDialog({String? initialTitle}) async {
    final titleController = TextEditingController(text: initialTitle ?? '');
    final notesController = TextEditingController();
    var date = DateTime.now().add(const Duration(days: 1));

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Schedule an activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'What')),
              const SizedBox(height: 8),
              TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (optional)')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('When: ${date.toLocal()}'.split('.').first)),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setDialogState(() => date = picked);
                    },
                    child: const Text('Pick date'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (created != true || titleController.text.trim().isEmpty) return;
    try {
      final activity = await widget.calendarService.create(
        farmerId: widget.farmer.id,
        title: titleController.text.trim(),
        notes: notesController.text.trim(),
        scheduledFor: date,
        source: initialTitle != null ? 'disease_scan' : 'manual',
      );
      if (!mounted) return;
      setState(() => _activities = [..._activities, activity]..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't save that activity.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spraying & Activity Calendar')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateDialog(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _activities.isEmpty
                  ? Center(
                      child: Text('No activities scheduled yet',
                          style: TextStyle(color: context.colors.onSurface.withValues(alpha: 0.6))),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _activities.length,
                      itemBuilder: (context, i) {
                        final activity = _activities[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ActivityRow(
                            activity: activity,
                            onToggle: () => _toggle(activity),
                            onDelete: () => _delete(activity),
                          ).animate().fadeIn(delay: (i * 40).ms, duration: 250.ms),
                        );
                      },
                    ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Activity activity;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const _ActivityRow({required this.activity, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Checkbox(value: activity.isCompleted, onChanged: (_) => onToggle()),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: context.colors.onSurface,
                    decoration: activity.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${activity.scheduledFor.toLocal()}'.split('.').first,
                  style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.6)),
                ),
                if (activity.notes.isNotEmpty)
                  Text(activity.notes, style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.7))),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
        ],
      ),
    );
  }
}
