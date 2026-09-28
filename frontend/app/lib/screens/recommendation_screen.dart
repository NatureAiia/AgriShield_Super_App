import 'package:flutter/material.dart';
import '../models/crop_recommendation.dart';
import '../services/recommendation_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

/// V2 module (docs/roadmap/V2_INTELLIGENCE_LAYER.md) — soil N/P/K, pH,
/// rainfall, temperature and humidity in, a recommended crop + fertilizer
/// advice out. Ported from AgriLite-FL's crop-recommend/fertilizer forms.
class RecommendationScreen extends StatefulWidget {
  final RecommendationService recommendationService;
  const RecommendationScreen({super.key, required this.recommendationService});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nitrogen = TextEditingController(text: '90');
  final _phosphorous = TextEditingController(text: '42');
  final _potassium = TextEditingController(text: '43');
  final _ph = TextEditingController(text: '6.5');
  final _rainfall = TextEditingController(text: '200');
  final _temperature = TextEditingController(text: '25');
  final _humidity = TextEditingController(text: '80');

  bool _loading = false;
  String? _error;
  CropRecommendation? _result;

  @override
  void dispose() {
    for (final c in [_nitrogen, _phosphorous, _potassium, _ph, _rainfall, _temperature, _humidity]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await widget.recommendationService.recommend(
        nitrogen: double.parse(_nitrogen.text),
        phosphorous: double.parse(_phosphorous.text),
        potassium: double.parse(_potassium.text),
        ph: double.parse(_ph.text),
        rainfall: double.parse(_rainfall.text),
        temperature: double.parse(_temperature.text),
        humidity: double.parse(_humidity.text),
      );
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not reach the recommendation service. Is the backend running?');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SOIL & CLIMATE', style: context.text.labelSmall),
                const SizedBox(height: 10),
                _numberField('Nitrogen (N, kg/ha)', _nitrogen),
                _numberField('Phosphorous (P, kg/ha)', _phosphorous),
                _numberField('Potassium (K, kg/ha)', _potassium),
                _numberField('Soil pH', _ph),
                _numberField('Rainfall (mm)', _rainfall),
                _numberField('Temperature (°C)', _temperature),
                _numberField('Humidity (%)', _humidity),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: Text(_loading ? 'Checking…' : 'Get recommendation'),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppCard(
                child: Text(_error!, style: TextStyle(color: context.colors.error)),
              ),
            ),
          if (_result != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RECOMMENDED CROP', style: context.text.labelSmall),
                    Text(
                      _result!.crop,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.colors.onSurface),
                    ),
                    if (_result!.demoOnly) ...[
                      const SizedBox(height: 10),
                      _DemoNotice(limitations: _result!.limitations),
                    ],
                    if (_result!.suggestions.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text('HOW SURE THE MODEL IS', style: context.text.labelSmall),
                      const SizedBox(height: 8),
                      for (final s in _result!.suggestions) _SuggestionRow(suggestion: s),
                    ],
                    if (_result!.fertilizerAdvice != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        'FERTILIZER — ${_result!.fertilizerNutrient} is ${_result!.fertilizerDirection}',
                        style: context.text.labelSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(_result!.fertilizerAdvice!, style: TextStyle(color: context.colors.onSurface)),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(labelText: label, isDense: true),
        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter a number' : null,
      ),
    );
  }
}

/// Always-visible caution when the model is demo-only — the roadmap's
/// honesty principle: the limitation sits next to the answer, not in a
/// separate screen. Amber = caution, same in light and dark mode.
class _DemoNotice extends StatelessWidget {
  final String? limitations;
  const _DemoNotice({this.limitations});

  @override
  Widget build(BuildContext context) {
    const dot = AgriShieldStatus.moderate;
    final textColor = AgriShieldStatus.text(dot, context.isDark);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color.alphaBlend(dot.withValues(alpha: context.isDark ? 0.22 : 0.14), context.colors.surface),
        borderRadius: BorderRadius.circular(AgriShieldRadii.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              limitations ?? 'Demo only — not validated for Zimbabwe. Check with an extension officer.',
              style: TextStyle(fontSize: 13, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  final CropSuggestion suggestion;
  const _SuggestionRow({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final percent = (suggestion.confidence * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(suggestion.crop, style: TextStyle(color: context.colors.onSurface))),
              Text('$percent%', style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.onSurface)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AgriShieldRadii.pill),
            child: LinearProgressIndicator(
              value: suggestion.confidence.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: context.colors.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}
