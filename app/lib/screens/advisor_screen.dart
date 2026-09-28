import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/advisor.dart';
import '../models/farmer.dart';
import '../services/advisor_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

/// AGRITEX advisor hub: a directory (currently placeholder — see
/// backend/app/services/advisor_service.py) plus a request/ticket flow
/// for a farm visit, a disease escalation, or a general consultation.
class AdvisorScreen extends StatefulWidget {
  final Farmer farmer;
  final AdvisorService advisorService;
  /// Pre-fills the request type + notes when opened from a disease scan
  /// result (see disease_scan_screen.dart's "Find an extension officer").
  final AdvisorRequestType initialRequestType;
  final String initialNotes;

  const AdvisorScreen({
    super.key,
    required this.farmer,
    required this.advisorService,
    this.initialRequestType = AdvisorRequestType.consultation,
    this.initialNotes = '',
  });

  @override
  State<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends State<AdvisorScreen> {
  List<Advisor> _advisors = [];
  String _dataSource = '';
  bool _loading = true;
  bool _submitting = false;
  String? _ticket;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.advisorService.listAdvisors().then((result) {
      if (!mounted) return;
      setState(() {
        _advisors = result.$1;
        _dataSource = result.$2;
        _loading = false;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _loading = false);
    });
  }

  Future<void> _submit(AdvisorRequestType type, String notes) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await widget.advisorService.submitRequest(
        farmerId: widget.farmer.id,
        requestType: type,
        notes: notes,
      );
      if (!mounted) return;
      setState(() {
        _ticket = result.ticket;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Couldn't submit the request — check your connection and try again.";
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AGRITEX Advisor Hub')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_ticket != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TicketCard(ticket: _ticket!),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0)
                else
                  _RequestForm(
                    initialType: widget.initialRequestType,
                    initialNotes: widget.initialNotes,
                    submitting: _submitting,
                    error: _error,
                    onSubmit: _submit,
                  ),
                const SizedBox(height: 20),
                Text('EXTENSION OFFICERS', style: context.text.labelSmall),
                const SizedBox(height: 4),
                Text(_dataSource,
                    style: TextStyle(fontSize: 11, color: context.colors.onSurface.withValues(alpha: 0.55))),
                const SizedBox(height: 8),
                for (var i = 0; i < _advisors.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _AdvisorCard(advisor: _advisors[i])
                        .animate()
                        .fadeIn(delay: (i * 60).ms, duration: 300.ms),
                  ),
              ],
            ),
    );
  }
}

class _RequestForm extends StatefulWidget {
  final AdvisorRequestType initialType;
  final String initialNotes;
  final bool submitting;
  final String? error;
  final void Function(AdvisorRequestType type, String notes) onSubmit;

  const _RequestForm({
    required this.initialType,
    required this.initialNotes,
    required this.submitting,
    required this.error,
    required this.onSubmit,
  });

  @override
  State<_RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<_RequestForm> {
  late AdvisorRequestType _type = widget.initialType;
  late final _notesController = TextEditingController(text: widget.initialNotes);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request help', style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.onSurface)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in AdvisorRequestType.values)
                ChoiceChip(
                  label: Text(type.label),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'What do you need help with?',
              border: OutlineInputBorder(),
            ),
          ),
          if (widget.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(widget.error!, style: TextStyle(color: context.colors.error, fontSize: 12)),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.submitting ? null : () => widget.onSubmit(_type, _notesController.text),
              child: widget.submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit request'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.secondary.withValues(alpha: context.isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: context.colors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request submitted', style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.onSurface)),
                Text('Ticket $ticket', style: TextStyle(color: context.colors.onSurface.withValues(alpha: 0.75))),
                const SizedBox(height: 4),
                Text(
                  'No live AGRITEX directory is connected yet, so this logs your request rather than dispatching it for real.',
                  style: TextStyle(fontSize: 11, color: context.colors.onSurface.withValues(alpha: 0.55)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisorCard extends StatelessWidget {
  final Advisor advisor;
  const _AdvisorCard({required this.advisor});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.colors.secondary.withValues(alpha: 0.2),
            child: Icon(Icons.support_agent, color: context.colors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(advisor.name, style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.onSurface)),
                Text('${advisor.role} • ${advisor.district}',
                    style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.65))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            tooltip: advisor.phone.isEmpty ? 'No number on file yet' : 'Call',
            onPressed: advisor.phone.isEmpty ? null : () {},
          ),
        ],
      ),
    );
  }
}
