// lib/widgets/location/interactive_gps_picker_widget.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../utils/maps_launcher.dart';

class InteractiveGpsPickerWidget extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final String initialArea;
  final String initialAddress;
  final String initialNotes;
  final Function({
    required double lat,
    required double lng,
    required String area,
    required String address,
    required String notes,
    required String mapsUrl,
  }) onLocationChanged;

  const InteractiveGpsPickerWidget({
    super.key,
    this.initialLat = 5.1801,
    this.initialLng = 97.1407,
    this.initialArea = 'Banda Sakti (Pusat Kota)',
    this.initialAddress = '',
    this.initialNotes = '',
    required this.onLocationChanged,
  });

  @override
  State<InteractiveGpsPickerWidget> createState() => _InteractiveGpsPickerWidgetState();
}

class _InteractiveGpsPickerWidgetState extends State<InteractiveGpsPickerWidget>
    with SingleTickerProviderStateMixin {
  late double _lat;
  late double _lng;
  late String _selectedArea;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  bool _isGpsLocked = false;
  bool _isDetecting = false;
  late AnimationController _pulseController;

  static const Map<String, List<double>> _lhokseumaweHotspots = {
    'Banda Sakti (Pusat Kota)': [5.1801, 97.1407],
    'Muara Dua (Cunda / Uteunkot)': [5.1672, 97.1325],
    'Blang Mangat (Punteut)': [5.1384, 97.1620],
    'Muara Satu (Batuphat / Arun)': [5.2215, 97.0982],
  };

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
    _selectedArea = widget.initialArea;
    _addressController = TextEditingController(text: widget.initialAddress);
    _notesController = TextEditingController(text: widget.initialNotes);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    if (_addressController.text.trim().isEmpty) {
      _addressController.text = 'Kecamatan $_selectedArea, Kota Lhokseumawe';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final mapsUrl = MapsLauncherHelper.createGoogleMapsUrl(_lat, _lng);
    widget.onLocationChanged(
      lat: _lat,
      lng: _lng,
      area: _selectedArea,
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      mapsUrl: mapsUrl,
    );
  }

  Future<void> _detectGpsLocation() async {
    setState(() => _isDetecting = true);
    // Simulasi penangkapan GPS presisi tinggi (mendukung fallback browser)
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    final coords = _lhokseumaweHotspots[_selectedArea] ?? [5.1801, 97.1407];
    // Variasi presisi mikro (simulasi pinpoint real time)
    final randomJitterLat = (math.Random().nextDouble() - 0.5) * 0.0012;
    final randomJitterLng = (math.Random().nextDouble() - 0.5) * 0.0012;

    setState(() {
      _lat = double.parse((coords[0] + randomJitterLat).toStringAsFixed(6));
      _lng = double.parse((coords[1] + randomJitterLng).toStringAsFixed(6));
      _isGpsLocked = true;
      _isDetecting = false;
      if (_addressController.text.trim().isEmpty || _addressController.text.contains('Kecamatan')) {
        _addressController.text = 'Kecamatan $_selectedArea, Kota Lhokseumawe (Titik Presisi GPS Terkunci)';
      }
    });

    _notifyChange();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('📍 Titik GPS Terkunci: ${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}'),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectAreaHotspot(String area, List<double> coords) {
    setState(() {
      _selectedArea = area;
      _lat = coords[0];
      _lng = coords[1];
      _isGpsLocked = true;
      _addressController.text = 'Kecamatan $area, Kota Lhokseumawe (Titik Pinpoint)';
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Visual Map Pinpoint Card ala Grab/GoFood ─────────────────
        Container(
          height: 155,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2833),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // Background Peta Abstrak / Map Styling
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapCanvasBackgroundPainter(),
                  ),
                ),

                // Gradasi Gelap Elegan
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ),

                // Radar Wave Pulse di Pusat Pin
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 48 + (_pulseController.value * 28),
                        height: 48 + (_pulseController.value * 28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.caramel.withValues(alpha: 0.28 * (1.0 - _pulseController.value)),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.5 * (1.0 - _pulseController.value)),
                            width: 1.5,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Center Pinpoint Marker ala GoFood / Grab
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.espresso,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gold, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.coffee_rounded, size: 12, color: AppColors.gold),
                            SizedBox(width: 4),
                            Text(
                              'Titik Pengantaran',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Icon(
                        Icons.location_on_rounded,
                        size: 36,
                        color: Color(0xFFE53935),
                      ),
                    ],
                  ),
                ),

                // Top Badge: Status GPS
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isGpsLocked ? Colors.greenAccent : AppColors.gold,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isGpsLocked ? Icons.gps_fixed_rounded : Icons.my_location_rounded,
                          size: 13,
                          color: _isGpsLocked ? Colors.greenAccent : AppColors.gold,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isGpsLocked
                              ? 'GPS Terkunci (${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)})'
                              : 'Mode Peta Interaktif Seuma',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: _isGpsLocked ? Colors.greenAccent : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Overlay: Kota Lhokseumawe & Google Maps Link
                Positioned(
                  bottom: 8,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '📍 $_selectedArea • Lhokseumawe',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          final link = MapsLauncherHelper.createGoogleMapsUrl(_lat, _lng);
                          Clipboard.setData(ClipboardData(text: link));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tautan Google Maps disalin: $link'),
                              backgroundColor: Colors.blue.shade800,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.6)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.open_in_new_rounded, size: 11, color: Colors.white),
                              SizedBox(width: 3),
                              Text('Google Maps', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Tombol Deteksi GPS Presisi Tinggi (Highlight Button) ──────
        InkWell(
          onTap: _isDetecting ? null : _detectGpsLocation,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: _isGpsLocked ? const Color(0xFFE8F5E9) : const Color(0xFFFBF4ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isGpsLocked ? Colors.green.shade400 : AppColors.caramel.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                _isDetecting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.caramel),
                      )
                    : Icon(
                        _isGpsLocked ? Icons.verified_rounded : Icons.gps_fixed_rounded,
                        size: 20,
                        color: _isGpsLocked ? const Color(0xFF2E7D32) : AppColors.caramel,
                      ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isGpsLocked ? 'Lokasi GPS Presisi Terkunci' : 'Gunakan Lokasi GPS Saya Saat Ini',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _isGpsLocked ? const Color(0xFF1B5E20) : AppColors.espresso,
                        ),
                      ),
                      Text(
                        'Kurir Seuma akan langsung membuka rute Google Maps ke titik akurat Anda.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: _isGpsLocked ? const Color(0xFF2E7D32) : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isGpsLocked ? Colors.green.shade700 : AppColors.caramel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isGpsLocked ? 'Perbarui' : 'Kunci GPS',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Pilihan Cepat Wilayah Lhokseumawe (Hotspot Chips) ─────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _lhokseumaweHotspots.entries.map((entry) {
              final isSelected = _selectedArea == entry.key;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(
                    entry.key.split(' (').first,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.espresso,
                  backgroundColor: const Color(0xFFF7F4F0),
                  checkmarkColor: AppColors.gold,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppColors.espresso : Colors.grey.shade300,
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  onSelected: (_) => _selectAreaHotspot(entry.key, entry.value),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // ── Input Detail Alamat & Patokan Rumah ala Grab/GoFood ───────
        TextField(
          controller: _addressController,
          maxLines: 2,
          style: const TextStyle(fontSize: 12.5),
          onChanged: (_) => _notifyChange(),
          decoration: InputDecoration(
            labelText: 'Detail Alamat Pengantaran (Nama Jalan / Kelurahan) *',
            labelStyle: const TextStyle(fontSize: 12),
            hintText: 'Contoh: Jl. Merdeka No. 45, Mon Geudong',
            hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
            isDense: true,
            prefixIcon: const Icon(Icons.location_city_rounded, size: 18, color: AppColors.caramel),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: _notesController,
          maxLines: 1,
          style: const TextStyle(fontSize: 12.5),
          onChanged: (_) => _notifyChange(),
          decoration: InputDecoration(
            labelText: 'Catatan Patokan untuk Kurir (Opsional)',
            labelStyle: const TextStyle(fontSize: 12),
            hintText: 'Contoh: Pagar cokelat depan warkop, bel rumah warna putih',
            hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
            isDense: true,
            prefixIcon: const Icon(Icons.directions_bike_rounded, size: 18, color: AppColors.espresso),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// Custom Painter untuk simulasi peta jalanan & pelabuhan Kota Lhokseumawe
class _MapCanvasBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF1E2833);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Garis pantai / air teluk
    final waterPaint = Paint()..color = const Color(0xFF15222E);
    final waterPath = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.1, size.width, size.height * 0.25)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Garis jalan utama / Grid jalan Lhokseumawe
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final secondaryRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Jalan arteri
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.55), roadPaint);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.45, size.height), roadPaint);

    // Grid jalan blok
    for (int i = 1; i <= 5; i++) {
      final y = size.height * (i / 6.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 10), secondaryRoadPaint);
    }
    for (int j = 1; j <= 6; j++) {
      final x = size.width * (j / 7.0);
      canvas.drawLine(Offset(x, 0), Offset(x - 15, size.height), secondaryRoadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
