import 'dart:io';

/// Desktop implementation for file download
Future<void> saveFile(List<int> bytes, String filename) async {
  try {
    // Get downloads directory
    String? downloadsPath;
    if (Platform.isWindows) {
      downloadsPath = Platform.environment['USERPROFILE'];
      if (downloadsPath != null) {
        downloadsPath = '$downloadsPath\\Downloads';
      }
    } else if (Platform.isMacOS || Platform.isLinux) {
      downloadsPath = Platform.environment['HOME'];
      if (downloadsPath != null) {
        downloadsPath = '$downloadsPath/Downloads';
      }
    }

    if (downloadsPath == null) {
      throw Exception('Could not determine downloads directory');
    }

    final file = File('$downloadsPath${Platform.pathSeparator}$filename');
    await file.writeAsBytes(bytes);
    print('✅ File saved to: ${file.path}');
  } catch (e) {
    print('❌ Error saving file: $e');
    rethrow;
  }
}

/// Desktop: Print URL to console (or use url_launcher package)
void openUrlInBrowser(String url) {
  print('📎 Open this URL in your browser: $url');
  // On desktop, you would need url_launcher package to open URLs
  // For now, just print the URL
}
