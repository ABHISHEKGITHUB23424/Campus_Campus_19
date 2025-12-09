import 'dart:io';
import 'package:flutter/foundation.dart';

String getBackendBaseUrl() {
  // Use emulator localhost for Android emulator, localhost for web/desktop.
  if (kIsWeb) return 'http://127.0.0.1:8000';
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
  } catch (_) {
    // Platform not available in some environments; fallthrough
  }
  return 'http://127.0.0.1:8000';
}
