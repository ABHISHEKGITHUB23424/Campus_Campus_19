import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/file_helper.dart';
import '../providers/providers.dart';
import '../models/seating.dart';

/// Global Generate Seating Modal
/// This modal can be opened from anywhere in the app
class GenerateSeatingModal extends ConsumerStatefulWidget {
  const GenerateSeatingModal({super.key});

  @override
  ConsumerState<GenerateSeatingModal> createState() =>
      _GenerateSeatingModalState();
}

class _GenerateSeatingModalState extends ConsumerState<GenerateSeatingModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  DateTime? _selectedDate;
  String _selectedSession = 'FN';
  List<String> _selectedRooms = [];
  bool _isLoading = false;
  bool _autoSelectRooms = true; // Auto-select by default

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00ADB5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF00ADB5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generate Seating',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222831),
                          ),
                        ),
                        Text(
                          'Automatically arrange exam seating',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF393E46),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: const Color(0xFF393E46),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDatePicker(),
                    const SizedBox(height: 20),
                    _buildSessionSelector(),
                    const SizedBox(height: 20),
                    _buildAutoSelectToggle(),
                    const SizedBox(height: 20),
                    if (!_autoSelectRooms) _buildRoomSelector(),
                    const SizedBox(height: 32),
                    _buildGenerateButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exam Date',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222831),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF00ADB5)),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                      : 'Select exam date',
                  style: TextStyle(
                    fontSize: 15,
                    color: _selectedDate != null
                        ? const Color(0xFF222831)
                        : const Color(0xFF393E46),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Session',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222831),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildSessionChip('FN', 'Forenoon')),
            const SizedBox(width: 12),
            Expanded(child: _buildSessionChip('AN', 'Afternoon')),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionChip(String value, String label) {
    final isSelected = _selectedSession == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () => setState(() => _selectedSession = value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00ADB5).withOpacity(0.1)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00ADB5)
                  : const Color(0xFFE0E0E0),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? const Color(0xFF00ADB5)
                      : const Color(0xFF393E46),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? const Color(0xFF00ADB5)
                      : const Color(0xFF393E46),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutoSelectToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Selection',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222831),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _autoSelectRooms
                ? const Color(0xFF00ADB5).withOpacity(0.1)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _autoSelectRooms
                  ? const Color(0xFF00ADB5)
                  : const Color(0xFFE0E0E0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _autoSelectRooms
                          ? 'Auto-Select Rooms'
                          : 'Manual Room Selection',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _autoSelectRooms
                            ? const Color(0xFF00ADB5)
                            : const Color(0xFF222831),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _autoSelectRooms
                          ? 'System will automatically select available rooms'
                          : 'Choose specific rooms manually',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF393E46),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoSelectRooms,
                onChanged: (value) {
                  setState(() {
                    _autoSelectRooms = value;
                    if (value) _selectedRooms.clear();
                  });
                },
                activeColor: const Color(0xFF00ADB5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomSelector() {
    final roomsAsync = ref.watch(roomsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Rooms',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222831),
          ),
        ),
        const SizedBox(height: 8),
        roomsAsync.when(
          data: (rooms) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rooms.map((room) {
              final isSelected = _selectedRooms.contains(room.code);
              return FilterChip(
                label: Text(room.code),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedRooms.add(room.code);
                    } else {
                      _selectedRooms.remove(room.code);
                    }
                  });
                },
                selectedColor: const Color(0xFF00ADB5).withOpacity(0.2),
                checkmarkColor: const Color(0xFF00ADB5),
              );
            }).toList(),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cannot connect to backend',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Please ensure the FastAPI backend is running at:',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                ),
                const SizedBox(height: 4),
                Text(
                  'http://localhost:8000',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Run: uvicorn app.main:app --reload',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red.shade700,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    final canGenerate =
        _selectedDate != null &&
        (_autoSelectRooms || _selectedRooms.isNotEmpty);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canGenerate && !_isLoading ? _generateSeating : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00ADB5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Generate Seating Arrangement',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _generateSeating() async {
    if (_selectedDate == null) return;

    setState(() => _isLoading = true);

    try {
      final api = ref.read(apiServiceProvider);
      final request = GenerateSeatingRequest(
        examDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        session: _selectedSession,
        roomCodes: _autoSelectRooms
            ? []
            : _selectedRooms, // Empty array for auto-select
      );

      final response = await api.generateSeating(request);

      // Invalidate the provider to refresh the UI (SeatingPage)
      // This ensures the "Available Rooms" list updates with new occupancy data
      final query = SeatingQuery(
        examDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        session: _selectedSession,
      );
      ref.invalidate(availableRoomsProvider(query));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // If user manually selected a room, auto-load its SVG preview
        if (!_autoSelectRooms && _selectedRooms.isNotEmpty) {
          _loadSvgForRoom(_selectedRooms.first);
        }
        // TODO: For auto-select mode we could list used rooms if backend returns them.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Fetch SVG for a given room after seating generation
  Future<void> _loadSvgForRoom(String roomCode) async {
    try {
      final api = ref.read(apiServiceProvider);
      final bytes = await api.getSvgByRoom(
        examDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        session: _selectedSession,
        roomCode: roomCode,
      );
      final svgString = utf8.decode(bytes);
      if (mounted) {
        // Show a dialog with preview
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Seating Preview - $roomCode',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: SvgPicture.string(svgString),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final filename =
                                'seating_${roomCode}_${DateFormat('yyyy-MM-dd').format(_selectedDate!)}_${_selectedSession}.svg';
                            await FileHelper.downloadFile(bytes, filename);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('SVG downloaded: $filename'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Download SVG'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            _loadSvgForRoom(roomCode); // refresh
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load SVG: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
