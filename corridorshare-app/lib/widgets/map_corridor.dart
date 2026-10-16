import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/theme/app_colors.dart';
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
    final cs = context.cs;
    final corridorPolyline = routePoints.isNotEmpty
        ? routePoints
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(growable: false)
        : const <LatLng>[
            // Bangladesh overview fallback (not a hardcoded N3 trip route).
            LatLng(23.8103, 90.4125),
            LatLng(22.3569, 91.7832),
            LatLng(24.8949, 91.8687),
            LatLng(24.3745, 88.6042),
          ];

    final center = corridorPolyline[corridorPolyline.length ~/ 2];

    Widget marker({
      required IconData icon,
      required bool filled,
      required double size,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: filled ? cs.inverseSurface : cs.surface,
            shape: BoxShape.circle,
            border: Border.all(color: cs.inverseSurface, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppPalette.ink.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: filled ? cs.onInverseSurface : cs.onSurface,
            size: size,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
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
                strokeWidth: 14.0,
                color: AppPalette.steel.withValues(alpha: 0.25),
              ),
              Polyline(
                points: corridorPolyline,
                strokeWidth: 4.0,
                color: AppPalette.ink,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              for (final pkg in packages) ...[
                Marker(
                  point: LatLng(pkg.pickup.latitude, pkg.pickup.longitude),
                  width: 36,
                  height: 36,
                  child: marker(
                    icon: Icons.inventory_2_outlined,
                    filled: !pkg.isNearMiss,
                    size: 18,
                    onTap: () => onPackageTap?.call(pkg),
                  ),
                ),
                Marker(
                  point: LatLng(pkg.dropoff.latitude, pkg.dropoff.longitude),
                  width: 30,
                  height: 30,
                  child: marker(
                    icon: Icons.flag_outlined,
                    filled: false,
                    size: 14,
                    onTap: () => onPackageTap?.call(pkg),
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
