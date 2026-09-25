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
