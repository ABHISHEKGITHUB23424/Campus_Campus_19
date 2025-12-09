import 'dart:async';
import 'dart:convert';
// dart:io and foundation not required now (Platform/kIsWeb handled in backend helper)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'backend.dart';

class LabDetailPage extends StatefulWidget {
  final String labName;
  const LabDetailPage({super.key, required this.labName});

  @override
  State<LabDetailPage> createState() => _LabDetailPageState();
}

class _LabDetailPageState extends State<LabDetailPage> {
  bool _loading = false;
  int? result;
  Timer? timer;
  final TextEditingController _urlController = TextEditingController();
  String? _errorMessage;

Future<void> uploadVideo() async {
  final picker = ImagePicker();
  final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
  if (file == null) return;

  setState(() {
    _loading = true;
    result = 0;
    _errorMessage = null;
  });

  final backendBase = getBackendBaseUrl();
  final String backendUrl = '$backendBase/process_video_file';

  print("UPLOAD URL => $backendUrl");
  print("VIDEO PATH => ${file.path}");
  print("LAB NAME => ${widget.labName}");

  try {
    final req = http.MultipartRequest("POST", Uri.parse(backendUrl));

    req.files.add(
      await http.MultipartFile.fromPath(
        "file",
        file.path,
      ),
    );
    
    // ✅ ADD LAB NAME TO REQUEST
    req.fields['lab_name'] = widget.labName;

    final streamed = await req.send();
    final response = await http.Response.fromStream(streamed);

    print("STATUS CODE => ${response.statusCode}");
    print("RESPONSE BODY => ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      setState(() {
        result = -1;
        _errorMessage =
            'Server error: ${response.statusCode} ${response.reasonPhrase}';
        _loading = false;
      });
      return;
    }

    // ✅ Start polling safely
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        final countRes =
            await http.get(Uri.parse('$backendBase/count'));

        if (countRes.statusCode == 200) {
          final data = jsonDecode(countRes.body);
          
          print("📊 POLL RESPONSE: $data");
          print("📊 LAB NAME: ${widget.labName}");
          
          // ✅ GET COUNT FROM THE SPECIFIC LAB
          final labs = data["labs"] ?? {};
          final labCount = labs[widget.labName] ?? 0;

          print("📊 LAB COUNT: $labCount");

          setState(() {
            result = labCount;
            _errorMessage = null;
          });

          if (data["processing"] == false) {
            timer?.cancel();
            setState(() => _loading = false);
          }
        }
      } catch (e) {
        print("❌ POLLING ERROR: $e");
        setState(() => _errorMessage = 'Polling error: $e');
      }
    });
  } catch (e) {
    setState(() {
      result = -1;
      _errorMessage = 'Upload error: $e';
      _loading = false;
    });
  }
}

  Future<void> processVideoUrl(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a video URL')));
      return;
    }

    setState(() {
      _loading = true;
      result = 0;
    });

    final backendUrl = getBackendBaseUrl();

    try {
      final res = await http.post(
        Uri.parse('$backendUrl/process_video_url'),
        headers: {'Content-Type': 'application/json'},
        // ✅ ADD LAB NAME TO REQUEST
        body: jsonEncode({
          'url': url,
          'lab_name': widget.labName,
        }),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        setState(() {
          result = -1;
          _errorMessage = 'Server error: ${res.statusCode} ${res.reasonPhrase}';
          _loading = false;
        });
        return;
      }

      // Start polling /count
      timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        try {
          final countRes = await http.get(Uri.parse('$backendUrl/count'));
          if (countRes.statusCode == 200) {
            final data = jsonDecode(countRes.body);
            
            print("📊 POLL RESPONSE: $data");
            print("📊 LAB NAME: ${widget.labName}");
            
            // ✅ GET COUNT FROM THE SPECIFIC LAB
            final labs = data["labs"] ?? {};
            final labCount = labs[widget.labName] ?? 0;
            
            print("📊 LAB COUNT: $labCount");
            
            setState(() {
              result = labCount;
              _errorMessage = null;
            });
            if (data["processing"] == false) {
              timer?.cancel();
              setState(() => _loading = false);
            }
          }
        } catch (e) {
          print("❌ POLLING ERROR: $e");
          setState(() => _errorMessage = 'Polling error: $e');
        }
      });
    } catch (e) {
      setState(() {
        result = -1;
        _errorMessage = 'Request error: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🎥 ${widget.labName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00ADB5),
        elevation: 8,
        shadowColor: const Color(0xFF00ADB5).withOpacity(0.5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header card with description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00ADB5).withOpacity(0.9),
                    const Color(0xFF00ADB5).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00ADB5).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.video_library,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Video Analysis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Upload or provide a video URL to detect unique students',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // URL Input Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔗 Video URL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222831),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'Enter URL or file path',
                      prefixIcon: const Icon(
                        Icons.link,
                        color: Color(0xFF00ADB5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF00ADB5),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF00ADB5),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading
                          ? null
                          : () => processVideoUrl(_urlController.text.trim()),
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Process Video'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00ADB5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBackgroundColor: Colors.grey.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Divider
            Container(height: 1, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 16),

            // Upload Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📁 Upload from Device',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222831),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : uploadVideo,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Select Video File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBackgroundColor: Colors.grey.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status & Results Card
            if (_loading || result != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _loading
                        ? [
                            Colors.blue.withOpacity(0.8),
                            Colors.cyan.withOpacity(0.6),
                          ]
                        : (result == -1
                              ? [
                                  Colors.red.withOpacity(0.8),
                                  Colors.redAccent.withOpacity(0.6),
                                ]
                              : [
                                  Colors.green.withOpacity(0.8),
                                  Colors.teal.withOpacity(0.6),
                                ]),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_loading)
                      Column(
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 4,
                              value: null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '🔄 Processing Video',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (result != null)
                            Text(
                              'Detected so far: $result students',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      )
                    else if (result == -1)
                      Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '❌ Processing Failed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      )
                    else if (result != null && result! >= 0)
                      Column(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '✅ Detection Complete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Total Students Detected',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$result',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

