// lib/widgets/admin/components/admin_delivery_mini_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AdminDeliveryMiniMap extends StatelessWidget {
  final double lat;
  final double lng;
  final String address;
  final VoidCallback? onTap;

  const AdminDeliveryMiniMap({
    super.key,
    required this.lat,
    required this.lng,
    required this.address,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final center = LatLng(lat, lng);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 160,
          child: Stack(
            children: [
              // === LAYER 1: OpenStreetMap Tiles ===
              FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 15.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.seuma.koffie',
                  ),
                  // === LAYER 2: Pin Merah Lokasi Konsumen ===
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 36,
                        height: 42,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_pin, color: Color(0xFFC62828), size: 36),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // === LAYER 3: Overlay Info Bar Bawah ===
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.65), Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, size: 13, color: Colors.white),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                        child: const Text(
                          '🔍 Lihat Penuh',
                          style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === LAYER 4: Overlay Tap Ripple ===
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
