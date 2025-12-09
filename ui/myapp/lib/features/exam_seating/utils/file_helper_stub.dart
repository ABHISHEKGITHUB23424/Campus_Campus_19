/// Stub implementation - this should never be used
/// The actual implementation is provided by file_helper_web.dart or file_helper_io.dart

Future<void> saveFile(List<int> bytes, String filename) async {
  throw UnimplementedError('File download not supported on this platform');
}

void openUrlInBrowser(String url) {
  throw UnimplementedError('URL opening not supported on this platform');
}
