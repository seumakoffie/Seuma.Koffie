// lib/utils/maps_launcher.dart
import 'package:flutter/services.dart';

// Helper universal untuk membuka Google Maps & WhatsApp rute pengantaran kurir
class MapsLauncherHelper {
  static String createGoogleMapsUrl(double lat, double lng) {
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  }

  static String createGoogleMapsDirUrl(double lat, double lng) {
    return 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
  }

  static Future<void> copyCoordinatesToClipboard(double lat, double lng) async {
    final text = '$lat, $lng';
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> copyMapsLinkToClipboard(double lat, double lng) async {
    final url = createGoogleMapsUrl(lat, lng);
    await Clipboard.setData(ClipboardData(text: url));
  }
}
