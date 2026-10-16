import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'ui.dart';

class SurchargeCalculatorWidget extends StatefulWidget {
  final VoidCallback? onShipPressed;
  const SurchargeCalculatorWidget({super.key, this.onShipPressed});

  @override
  State<SurchargeCalculatorWidget> createState() =>
      _SurchargeCalculatorWidgetState();
}

class _SurchargeCalculatorWidgetState extends State<SurchargeCalculatorWidget> {
  double weightKg = 5.0;
  double radiusKm = 2.0;

  int get estimatedEarning {
    return (200 + weightKg * 40 + radiusKm * 25).round();
  }

  Widget _slider({
    required String label,
    required String value,
    required double current,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: context.tt.bodyMedium)),
            Text(value, style: context.tt.titleSmall),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: current,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _slider(
            label: 'Parcel weight',
            value: '${weightKg.toStringAsFixed(0)} kg',
            current: weightKg,
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (v) => setState(() => weightKg = v),
          ),
          _slider(
            label: 'Detour radius',
            value: '${radiusKm.toStringAsFixed(0)} km',
            current: radiusKm,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (v) => setState(() => radiusKm = v),
          ),
          Gap.sm,
          const Divider(),
          Gap.md,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated earning', style: context.tt.labelMedium),
                    Gap.xs,
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      child: Text(
                        '৳ $estimatedEarning',
                        key: ValueKey(estimatedEarning),
                        style: context.tt.headlineSmall,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: widget.onShipPressed,
                child: const Text('Post trip'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
