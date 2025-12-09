import 'dart:html' as html;

/// Web implementation for file download
Future<void> saveFile(List<int> bytes, String filename) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}

/// Open URL in new browser tab
void openUrlInBrowser(String url) {
  html.window.open(url, '_blank');
}
