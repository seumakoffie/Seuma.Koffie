// lib/main.dart
// Seuma.Koffie v4.0 — Main Entrypoint
import 'package:flutter/material.dart';
import 'app/app.dart';

export 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SeumaKoffieApp());
}
