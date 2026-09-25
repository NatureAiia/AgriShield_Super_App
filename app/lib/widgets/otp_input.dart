import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

/// A 4-digit code entry: one visible [TextField] driving a row of boxes
/// that light up as each digit lands, instead of a single plain field —
/// the standard OTP pattern, with each box popping in as it fills.
class OtpInput extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final int length;

  const OtpInput({super.key, required this.onCompleted, this.length = 4});

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void clear() => setState(_controller.clear);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    final filled = i < value.text.length;
                    final digit = filled ? value.text[i] : '';
                    final active = i == value.text.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 52,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: active ? context.colors.primary : context.colors.outline,
                          width: active ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        digit,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: context.colors.onSurface),
                      ).animate(key: ValueKey('$i-$digit-$filled')).scaleXY(
                            begin: filled ? 0.5 : 1,
                            end: 1,
                            duration: 150.ms,
                            curve: Curves.easeOutBack,
                          ),
                    );
                  },
                ),
              ],
            ],
          ),
          Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(widget.length)],
              onChanged: (v) {
                if (v.length == widget.length) widget.onCompleted(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
