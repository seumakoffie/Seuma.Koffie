// lib/widgets/location/interactive_gps_picker_widget.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
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
    this.initialLng = 97.1507,
    this.initialArea = 'Banda Sakti',
    this.initialAddress = '',
    this.initialNotes = '',
    required this.onLocationChanged,
  });

  @override
  State<InteractiveGpsPickerWidget> createState() => _InteractiveGpsPickerWidgetState();
}

class _InteractiveGpsPickerWidgetState extends State<InteractiveGpsPickerWidget> {
  late final MapController _mapController;
  late double _lat;
  late double _lng;
  late String _selectedArea;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  bool _isGpsLocked = false;
  bool _isDetecting = false;
  bool _isGeocoding = false;
  String _activeStreetOrLocation = 'Pusat Kota Lhokseumawe';
  Timer? _debounceTimer;

  static const Map<String, LatLng> _lhokseumaweHotspots = {
    'Banda Sakti': LatLng(5.1801, 97.1507),
    'Muara Dua': LatLng(5.1672, 97.1325),
    'Blang Mangat': LatLng(5.1384, 97.1620),
    'Muara Satu': LatLng(5.2215, 97.0982),
  };

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
    _selectedArea = widget.initialArea.contains('Banda Sakti')
        ? 'Banda Sakti'
        : (widget.initialArea.contains('Muara Dua')
            ? 'Muara Dua'
            : (widget.initialArea.contains('Blang Mangat')
                ? 'Blang Mangat'
                : (widget.initialArea.contains('Muara Satu') ? 'Muara Satu' : 'Banda Sakti')));

    _addressController = TextEditingController(text: widget.initialAddress);
    _notesController = TextEditingController(text: widget.initialNotes);

    if (_addressController.text.trim().isEmpty) {
      _addressController.text = 'Kecamatan $_selectedArea, Kota Lhokseumawe';
    }

    // Jalankan reverse geocoding awal secara aman
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reverseGeocode(LatLng(_lat, _lng));
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      final center = camera.center;
      setState(() {
        _lat = center.latitude;
        _lng = center.longitude;
        _isGpsLocked = false;
      });

      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 650), () {
        _reverseGeocode(center);
      });
    }
  }

  Future<void> _reverseGeocode(LatLng target) async {
    if (!mounted) return;
    setState(() => _isGeocoding = true);

    String? resolvedAddress;
    String? detectedDistrict;

    // 1. Coba Nominatim OpenStreetMap (Language: ID)
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${target.latitude}&lon=${target.longitude}&zoom=18&addressdetails=1&accept-language=id',
      );
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'SeumaKoffieDeliveryApp/1.0 (info@seumakoffie.id)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final road = address['road'] ?? address['pedestrian'] ?? address['path'] ?? address['neighbourhood'];
          final village = address['village'] ?? address['suburb'] ?? address['quarter'];
          final subdistrict = address['subdistrict'] ?? address['county'] ?? address['city_district'];

          final parts = <String>[];
          if (road != null && road.toString().isNotEmpty) parts.add(road.toString());
          if (village != null && village.toString().isNotEmpty) parts.add(village.toString());
          if (subdistrict != null && subdistrict.toString().isNotEmpty) {
            parts.add(subdistrict.toString());
            detectedDistrict = subdistrict.toString();
          }
          parts.add('Kota Lhokseumawe');

          if (parts.isNotEmpty) {
            resolvedAddress = parts.join(', ');
          }
        }
      }
    } catch (_) {
      // Nominatim timeout/CORS fallback
    }

    // 2. Fallback ke Photon Komoot jika Nominatim belum berhasil
    if (resolvedAddress == null) {
      try {
        final uri = Uri.parse(
          'https://photon.komoot.io/reverse?lat=${target.latitude}&lon=${target.longitude}',
        );
        final response = await http.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final features = data['features'] as List?;
          if (features != null && features.isNotEmpty) {
            final props = (features.first as Map<String, dynamic>)['properties'] as Map<String, dynamic>?;
            if (props != null) {
              final name = props['name'] ?? props['street'];
              final district = props['district'] ?? props['county'];
              final city = props['city'] ?? 'Kota Lhokseumawe';

              final parts = <String>[];
              if (name != null) parts.add(name.toString());
              if (district != null) {
                parts.add(district.toString());
                detectedDistrict = district.toString();
              }
              parts.add(city.toString());
              resolvedAddress = parts.join(', ');
            }
          }
        }
      } catch (_) {
        // Fallback Photon gagal
      }
    }

    if (!mounted) return;

    // 3. Fallback aman lokal jika reverse geocoding internet gagal
    if (resolvedAddress == null || resolvedAddress.isEmpty) {
      resolvedAddress = 'Kecamatan $_selectedArea, Kota Lhokseumawe (Titik Pinpoint)';
    }

    // Sinkronisasi otomatis kecamatan chip jika cocok
    if (detectedDistrict != null) {
      for (final key in _lhokseumaweHotspots.keys) {
        if (detectedDistrict.toLowerCase().contains(key.toLowerCase())) {
          _selectedArea = key;
          break;
        }
      }
    }

    setState(() {
      _isGeocoding = false;
      _activeStreetOrLocation = resolvedAddress!.split(',').first.trim();
      _addressController.text = resolvedAddress;
    });

    _notifyChange();
  }

  Future<void> _handleGpsLock() async {
    setState(() => _isDetecting = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layanan lokasi GPS pada browser/perangkat belum aktif.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isDetecting = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Izin GPS ditolak browser. Anda tetap dapat menggeser pin peta secara manual.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() => _isDetecting = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin GPS diblokir permanen di pengaturan browser. Geser pin peta secara manual.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isDetecting = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final newLatLng = LatLng(position.latitude, position.longitude);
      _lat = newLatLng.latitude;
      _lng = newLatLng.longitude;
      _mapController.move(newLatLng, 17.0);

      setState(() {
        _isGpsLocked = true;
        _isDetecting = false;
      });

      await _reverseGeocode(newLatLng);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('📍 GPS Terkunci: ${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}'),
              ],
            ),
            backgroundColor: const Color(0xFF1B5E20),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mendeteksi GPS: ${e.toString().split(":").last.trim()}. Anda tetap dapat menggeser pin peta secara manual.',
            ),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
      setState(() => _isDetecting = false);
    }
  }

  void _selectAreaHotspot(String area, LatLng coords) {
    setState(() {
      _selectedArea = area;
      _lat = coords.latitude;
      _lng = coords.longitude;
      _isGpsLocked = false;
      _addressController.text = 'Kecamatan $area, Kota Lhokseumawe';
      _activeStreetOrLocation = 'Kecamatan $area';
    });
    _mapController.move(coords, 16.0);
    _reverseGeocode(coords);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(LatLng(_lat, _lng), (currentZoom + 1).clamp(11.0, 18.5));
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(LatLng(_lat, _lng), (currentZoom - 1).clamp(11.0, 18.5));
  }

  Future<void> _openGoogleMapsExternal() async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_lat,$_lng');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback salin link
      await MapsLauncherHelper.copyMapsLinkToClipboard(_lat, _lng);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 Tautan Google Maps disalin: $url'),
            backgroundColor: Colors.blue.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Peta Interaktif OpenStreetMap Sungguhan (FlutterMap) ───────
        Container(
          height: 195,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // Real OpenStreetMap Tiles
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(_lat, _lng),
                    initialZoom: 15.5,
                    minZoom: 11.0,
                    maxZoom: 18.5,
                    onPositionChanged: _onPositionChanged,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'id.seumakoffie.app',
                      maxNativeZoom: 19,
                    ),
                  ],
                ),

                // Center Pinpoint Marker Tetap di Tengah (Alignment.center)
                IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 34),
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
                                  color: Colors.black.withValues(alpha: 0.45),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isGeocoding)
                                  const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.gold),
                                  )
                                else
                                  const Icon(Icons.location_on_rounded, size: 12, color: AppColors.gold),
                                const SizedBox(width: 4),
                                Text(
                                  _isGeocoding ? 'Mencari Alamat...' : 'Titik Antar Seuma',
                                  style: const TextStyle(
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
                            size: 38,
                            color: Color(0xFFE53935),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tombol Zoom In & Zoom Out (+ / -) di Kanan Atas
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
                      _buildMapIconButton(
                        icon: Icons.add_rounded,
                        tooltip: 'Perbesar Peta',
                        onTap: _zoomIn,
                      ),
                      const SizedBox(height: 6),
                      _buildMapIconButton(
                        icon: Icons.remove_rounded,
                        tooltip: 'Perkecil Peta',
                        onTap: _zoomOut,
                      ),
                    ],
                  ),
                ),

                // Top-Left Badge: Status GPS
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
                          _isGpsLocked ? Icons.gps_fixed_rounded : Icons.pan_tool_rounded,
                          size: 13,
                          color: _isGpsLocked ? Colors.greenAccent : AppColors.gold,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isGpsLocked
                              ? 'GPS Terkunci (${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)})'
                              : 'Geser Peta untuk Mengatur Pin',
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

                // Bottom Overlay: Nama Jalan Aktif + Tombol Google Maps Tab Baru
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2833).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.near_me_rounded, size: 14, color: AppColors.gold),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _activeStreetOrLocation,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: _openGoogleMapsExternal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade800,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.open_in_new_rounded, size: 11, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Google Maps',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Tombol "Kunci GPS" Presisi Web (Geolocator High Accuracy) ───
        InkWell(
          onTap: _isDetecting ? null : _handleGpsLock,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        _isGpsLocked ? 'Titik GPS Presisi Terkunci' : 'Gunakan Lokasi GPS Saya Saat Ini',
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isGpsLocked ? Colors.green.shade700 : AppColors.caramel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isDetecting
                        ? 'Mencari...'
                        : (_isGpsLocked ? 'Perbarui GPS' : 'Kunci GPS'),
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
                    entry.key,
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

        // ── Input Detail Alamat Pengantaran (Otomatis + Bisa Diedit) ───
        TextField(
          controller: _addressController,
          maxLines: 2,
          style: const TextStyle(fontSize: 12.5),
          onChanged: (_) => _notifyChange(),
          decoration: InputDecoration(
            labelText: 'Detail Alamat Pengantaran (Nama Jalan / Kelurahan) *',
            labelStyle: const TextStyle(fontSize: 12),
            hintText: 'Contoh: Jl. Sukaramai, Banda Sakti, Kota Lhokseumawe',
            hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
            isDense: true,
            suffixIcon: _isGeocoding
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.caramel),
                    ),
                  )
                : null,
            prefixIcon: const Icon(Icons.location_city_rounded, size: 18, color: AppColors.caramel),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 10),

        // ── Input Catatan Patokan untuk Kurir ─────────────────────────
        TextField(
          controller: _notesController,
          maxLines: 1,
          style: const TextStyle(fontSize: 12.5),
          onChanged: (_) => _notifyChange(),
          decoration: InputDecoration(
            labelText: 'Catatan Patokan untuk Kurir (Opsional)',
            labelStyle: const TextStyle(fontSize: 12),
            hintText: 'Contoh: Pagar hitam depan pos ronda, bel no 2',
            hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
            isDense: true,
            prefixIcon: const Icon(Icons.directions_bike_rounded, size: 18, color: AppColors.espresso),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildMapIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
