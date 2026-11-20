// lib/widgets/admin/components/admin_map_full_view_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/order_model.dart';
import '../../../theme/app_theme.dart';

class AdminMapFullViewModal extends StatefulWidget {
  final OrderModel order;

  const AdminMapFullViewModal({super.key, required this.order});

  static void show(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => AdminMapFullViewModal(order: order),
    );
  }

  @override
  State<AdminMapFullViewModal> createState() => _AdminMapFullViewModalState();
}

class _AdminMapFullViewModalState extends State<AdminMapFullViewModal> {
  late final MapController _mapController;
  double _currentZoom = 16.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      await Clipboard.setData(ClipboardData(text: url));
      messenger.showSnackBar(
        SnackBar(
          content: Text('📋 Link disalin (browser tidak terbuka otomatis): $url'),
          backgroundColor: const Color(0xFF37474F),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _zoomIn() {
    _currentZoom = (_currentZoom + 1).clamp(1.0, 19.0);
    final lat = widget.order.deliveryLat ?? 5.1801;
    final lng = widget.order.deliveryLng ?? 97.1407;
    _mapController.move(LatLng(lat, lng), _currentZoom);
  }

  void _zoomOut() {
    _currentZoom = (_currentZoom - 1).clamp(1.0, 19.0);
    final lat = widget.order.deliveryLat ?? 5.1801;
    final lng = widget.order.deliveryLng ?? 97.1407;
    _mapController.move(LatLng(lat, lng), _currentZoom);
  }

  void _resetView() {
    _currentZoom = 16.0;
    final lat = widget.order.deliveryLat ?? 5.1801;
    final lng = widget.order.deliveryLng ?? 97.1407;
    _mapController.move(LatLng(lat, lng), _currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final lat = order.deliveryLat ?? 5.1801;
    final lng = order.deliveryLng ?? 97.1407;
    final center = LatLng(lat, lng);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth - 48.0).clamp(0.0, 620.0);

    final googleMapsRoute =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
    final osmUrl =
        'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng&zoom=17';
    final latStr = lat.toStringAsFixed(6);
    final lngStr = lng.toStringAsFixed(6);
    final coordText = '$latStr, $lngStr';
    final hasRealGps = order.deliveryLat != null && order.deliveryLng != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      content: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── HEADER ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.espresso,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🗺️ Peta Lokasi Pengantaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${order.orderNumber} • ${order.recipientName}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Tutup',
                  ),
                ],
              ),
            ),

            // ─── PETA INTERAKTIF ──────────────────────────────────────
            SizedBox(
              height: 400,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: _currentZoom,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.seuma.koffie',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 48,
                            height: 56,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: Color(0xFFC62828),
                                  size: 48,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Badge GPS tidak ada
                  if (!hasRealGps)
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '⚠️ GPS tidak tersedia — menampilkan pusat kota Lhokseumawe',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),

                  // Tombol Zoom Kanan Bawah
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _zoomButton(Icons.add, _zoomIn, 'Zoom In'),
                        const SizedBox(height: 4),
                        _zoomButton(Icons.remove, _zoomOut, 'Zoom Out'),
                        const SizedBox(height: 4),
                        _zoomButton(Icons.my_location_rounded, _resetView, 'Kembali ke titik pengantaran'),
                      ],
                    ),
                  ),

                  // Overlay koordinat kiri bawah
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        '📍 $latStr, $lngStr',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF37474F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── INFO + TOMBOL ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alamat
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Color(0xFFC62828), size: 15),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.deliveryAddress,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Patokan
                  if (order.deliveryNotes != null &&
                      order.deliveryNotes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.signpost_outlined,
                            color: AppColors.textMuted, size: 13),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Patokan: ${order.deliveryNotes}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 6),

                  // GPS koordinat + Salin
                  Row(
                    children: [
                      const Icon(Icons.gps_fixed,
                          color: AppColors.textMuted, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        'GPS: $coordText',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: coordText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('📋 Koordinat GPS disalin!'),
                              backgroundColor: Color(0xFF37474F),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            '📋 Salin',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Tombol Navigasi
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openUrl(googleMapsRoute),
                          icon: const Text('🛵',
                              style: TextStyle(fontSize: 14)),
                          label: const Text(
                            'Rute Google Maps',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openUrl(osmUrl),
                          icon: const Text('🗺️',
                              style: TextStyle(fontSize: 14)),
                          label: const Text(
                            'OpenStreetMap',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF388E3C),
                            side:
                                const BorderSide(color: Color(0xFF81C784)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: AppColors.espresso),
        ),
      ),
    );
  }
}
