import 'file_helper_stub.dart'
    if (dart.library.html) 'file_helper_web.dart'
    if (dart.library.io) 'file_helper_io.dart';

/// Platform-agnostic file download helper
/// Works on both web and desktop platforms
class FileHelper {
  /// Download a file with the given bytes and filename
  /// On web: Uses blob download
  /// On desktop: Saves to downloads folder
  static Future<void> downloadFile(List<int> bytes, String filename) async {
    await saveFile(bytes, filename);
  }

  /// Download text content as a file
  static Future<void> downloadTextFile(String content, String filename) async {
    final bytes = content.codeUnits;
    await downloadFile(bytes, filename);
  }

  /// Open URL in browser (web-specific, shows message on desktop)
  static void openUrl(String url) {
    openUrlInBrowser(url);
  }
}
