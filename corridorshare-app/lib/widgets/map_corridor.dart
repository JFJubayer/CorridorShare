import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/package_model.dart';

class MapCorridorWidget extends StatelessWidget {
  final List<PackageModel> packages;
  final List<GeoPoint> routePoints;
  final Function(PackageModel)? onPackageTap;

  const MapCorridorWidget({
    super.key,
    required this.packages,
    this.routePoints = const [],
    this.onPackageTap,
  });

  @override
  Widget build(BuildContext context) {
    final corridorPolyline = routePoints.isNotEmpty
        ? routePoints.map((p) => LatLng(p.latitude, p.longitude)).toList(growable: false)
        : const <LatLng>[
            // Bangladesh overview fallback (not a hardcoded N3 trip route).
            LatLng(23.8103, 90.4125),
            LatLng(22.3569, 91.7832),
            LatLng(24.8949, 91.8687),
            LatLng(24.3745, 88.6042),
          ];

    final center = corridorPolyline[corridorPolyline.length ~/ 2];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: routePoints.isEmpty ? 6.4 : 7.8,
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
            markers: [
              for (final pkg in packages) ...[
                Marker(
                  point: LatLng(pkg.pickup.latitude, pkg.pickup.longitude),
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
                ),
                Marker(
                  point: LatLng(pkg.dropoff.latitude, pkg.dropoff.longitude),
                  width: 34,
                  height: 34,
                  child: GestureDetector(
                    onTap: () {
                      if (onPackageTap != null) onPackageTap!(pkg);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white70, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
