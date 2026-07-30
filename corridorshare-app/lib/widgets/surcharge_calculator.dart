import 'package:flutter/material.dart';

class SurchargeCalculatorWidget extends StatefulWidget {
  final VoidCallback? onShipPressed;
  const SurchargeCalculatorWidget({super.key, this.onShipPressed});

  @override
  State<SurchargeCalculatorWidget> createState() => _SurchargeCalculatorWidgetState();
}

class _SurchargeCalculatorWidgetState extends State<SurchargeCalculatorWidget> {
  double weightKg = 5.0;
  double radiusKm = 2.0;

  int get estimatedEarning {
    return (200 + weightKg * 40 + radiusKm * 25).round();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Stitch surface container
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.calculate, color: Color(0xFFF97316), size: 22),
              SizedBox(width: 8),
              Text(
                'Earnings Estimator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Parcel Weight slider
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Parcel Weight', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(
                    '${weightKg.toStringAsFixed(0)} kg',
                    style: const TextStyle(color: Color(0xFFF97316), fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Slider(
                value: weightKg,
                min: 1.0,
                max: 20.0,
                divisions: 19,
                activeColor: const Color(0xFFF97316),
                inactiveColor: const Color(0xFF273647),
                onChanged: (val) {
                  setState(() {
                    weightKg = val;
                  });
                },
              ),

              // Detour Radius slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Detour Radius', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(
                    '${radiusKm.toStringAsFixed(0)} km',
                    style: const TextStyle(color: Color(0xFFF97316), fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Slider(
                value: radiusKm,
                min: 0.0,
                max: 10.0,
                divisions: 10,
                activeColor: const Color(0xFFF97316),
                inactiveColor: const Color(0xFF273647),
                onChanged: (val) {
                  setState(() {
                    radiusKm = val;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1E293B)),
          const SizedBox(height: 8),

          // Price result display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimated Earning',
                    style: TextStyle(
                      color: Color(0xFFE0C0B1),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '$estimatedEarning BDT',
                      key: ValueKey(estimatedEarning),
                      style: const TextStyle(
                        color: Color(0xFFF97316),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: widget.onShipPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Post Trip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
