import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/package_model.dart';

class MapCorridorWidget extends StatelessWidget {
  final List<PackageModel> packages;
  final Function(PackageModel)? onPackageTap;

  const MapCorridorWidget({
    super.key,
    required this.packages,
    this.onPackageTap,
  });

  @override
  Widget build(BuildContext context) {
    final corridorPolyline = [
      const LatLng(23.8103, 90.4125), // Uttara / Dhaka Airport
      const LatLng(23.9999, 90.4203), // Gazipur Chaurasta
      const LatLng(24.2500, 90.3900), // Mawna / Trishal
      const LatLng(24.7471, 90.4203), // Mymensingh Bypass
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(24.2500, 90.4100),
          initialZoom: 8.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.corridorshare.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: corridorPolyline,
                strokeWidth: 6.0,
                color: const Color(0xFFF97316),
              ),
              Polyline(
                points: corridorPolyline,
                strokeWidth: 14.0,
                color: const Color(0xFFF97316).withValues(alpha: 0.2),
              ),
            ],
          ),
          MarkerLayer(
            markers: packages.map((pkg) {
              return Marker(
                point: LatLng(pkg.pickupLat, pkg.pickupLng),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    if (onPackageTap != null) onPackageTap!(pkg);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: pkg.isNearMiss ? Colors.amber : const Color(0xFFF97316),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
