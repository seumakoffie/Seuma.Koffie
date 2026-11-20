// lib/main.dart
// Seuma.Koffie v4.0 — Main Entrypoint
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'services/supabase_service.dart';
import 'state/menu_state.dart';

export 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SeumaSupabaseService.instance.initialize();
    await MenuManager.instance.initialize();
  } catch (e) {
    debugPrint('Supabase initial bootstrap: $e');
  }
  runApp(const SeumaKoffieApp());
}
