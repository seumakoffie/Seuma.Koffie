// lib/services/sound/sound_player_web.dart
import 'dart:js_interop';

@JS('seumaPlaySound')
external void _seumaPlaySound(JSString type);

void playNativeWebSound(String type) {
  try {
    _seumaPlaySound(type.toJS);
  } catch (_) {}
}
