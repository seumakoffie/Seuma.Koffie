// lib/services/sound_notification_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'sound/sound_player_stub.dart'
    if (dart.library.js_interop) 'sound/sound_player_web.dart';

class SoundNotificationService extends ChangeNotifier {
  static final SoundNotificationService instance = SoundNotificationService._internal();
  SoundNotificationService._internal();

  bool _isSoundEnabled = true;
  bool get isSoundEnabled => _isSoundEnabled;

  void toggleSound([bool? enabled]) {
    _isSoundEnabled = enabled ?? !_isSoundEnabled;
    notifyListeners();
  }

  /// Memutar nada lonceng ganda kasir (Double Chime) saat ada pesanan baru masuk
  void playNewOrderAlert({String? orderNumber, int? amount}) {
    if (!_isSoundEnabled) return;
    try {
      if (kIsWeb) {
        playNativeWebSound('order');
      } else {
        SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      debugPrint('Error playing new order sound: $e');
    }
  }

  /// Memutar nada sambutan lembut saat ada konsumen baru mendaftar
  void playNewCustomerAlert({String? customerName}) {
    if (!_isSoundEnabled) return;
    try {
      if (kIsWeb) {
        playNativeWebSound('signup');
      } else {
        SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      debugPrint('Error playing new customer sound: $e');
    }
  }

  /// Memutar nada uji coba audio
  void playTestSound() {
    try {
      if (kIsWeb) {
        playNativeWebSound('test');
      } else {
        SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      debugPrint('Error playing test sound: $e');
    }
  }
}
