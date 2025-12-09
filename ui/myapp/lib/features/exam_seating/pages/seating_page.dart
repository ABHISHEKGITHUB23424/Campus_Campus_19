import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/file_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../profile_page.dart';
import '../providers/providers.dart';
import '../models/seating.dart';
import 'management_page.dart';
import '../widgets/generate_seating_modal.dart';

/// Seating Page - Empty placeholder with Generate Seating button
/// This section will be populated with seating features later
class SeatingPage extends ConsumerStatefulWidget {
  const SeatingPage({super.key});

  @override
  ConsumerState<SeatingPage> createState() => _SeatingPageState();
}

class _SeatingPageState extends ConsumerState<SeatingPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DateTime? _selectedDate;
  String _selectedSession = 'FN';
  String? _selectedRoomCode;
  bool _loadingSvg = false;
  String? _svgCache; // keep last fetched svg

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dateStr = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : null;
    final roomsAsync = (dateStr != null)
        ? ref.watch(
            availableRoomsProvider(
              SeatingQuery(examDate: dateStr, session: _selectedSession),
            ),
          )
        : null;

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 900;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00ADB5).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.event_seat,
                color: Color(0xFF00ADB5),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Exam Seating Viewer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExamSeatingManagementPage(),
                ),
              );
            },
            icon: const Icon(Icons.admin_panel_settings),
            color: Colors.white,
            tooltip: 'Management',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person_outline),
            color: Colors.white,
            tooltip: 'Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const GenerateSeatingModal(),
          );
        },
        label: const Text(
          'Generate Seating',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.auto_awesome),
        backgroundColor: const Color(0xFF00ADB5),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              const SizedBox(height: 24),

              // Filters Section
              _buildFiltersCard(isMobile),
              const SizedBox(height: 24),

              // Main content area: responsive layout
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rooms list pane
                    Expanded(
                      flex: 3,
                      child: roomsAsync == null
                          ? _buildPlaceholder('Select date to load rooms')
                          : roomsAsync.when(
                              data: (resp) =>
                                  _buildRoomsGrid(resp.rooms, false),
                              loading: () => _buildLoadingState(),
                              error: (e, st) =>
                                  _buildError('Failed to load rooms: $e'),
                            ),
                    ),
                    const SizedBox(width: 20),
                    // SVG preview pane
                    Expanded(flex: 2, child: _buildPreviewPanel()),
                  ],
                )
              else
                Column(
                  children: [
                    // Rooms list
                    roomsAsync == null
                        ? _buildPlaceholder('Select date to load rooms')
                        : roomsAsync.when(
                            data: (resp) =>
                                _buildRoomsGrid(resp.rooms, isMobile),
                            loading: () => _buildLoadingState(),
                            error: (e, st) =>
                                _buildError('Failed to load rooms: $e'),
                          ),
                    const SizedBox(height: 20),
                    // Preview panel
                    _buildPreviewPanel(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'View Exam Seating Arrangements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select date and session to view room allocations',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00ADB5).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_seat,
              color: Color(0xFF00ADB5),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: const Color(0xFF00ADB5), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isMobile)
            Column(
              children: [
                _buildDatePicker(),
                const SizedBox(height: 16),
                _buildSessionSelector(),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: 16),
                Expanded(child: _buildSessionSelector()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF00ADB5),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading rooms...',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: const Color(0xFF00ADB5), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Seating Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildViewSvgButton(),
          const SizedBox(height: 12),
          Container(
            height: 500,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: _svgCache == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_seat_outlined,
                          size: 64,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No preview loaded',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select a room to view seating',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildInteractiveSvg(_svgCache!),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String msg) => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      border: Border.all(color: const Color(0xFF2A2A2A)),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF00ADB5).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.info_outline,
            color: Color(0xFF00ADB5),
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildError(String msg) => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      border: Border.all(color: Colors.red.shade900.withOpacity(0.5), width: 2),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.red.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade900.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red.shade300,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildRoomsGrid(List<RoomAvailability> rooms, bool isMobile) {
    if (rooms.isEmpty) {
      return _buildPlaceholder('No rooms found for date/session');
    }

    final crossAxisCount = isMobile ? 1 : (rooms.length == 1 ? 1 : 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.meeting_room,
                  color: const Color(0xFF00ADB5),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Available Rooms (${rooms.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00ADB5).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${rooms.where((r) => r.status == 'available').length} Available',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00ADB5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 1.2 : 1.5,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return _buildRoomCard(room);
          },
        ),
      ],
    );
  }

  Widget _buildRoomCard(RoomAvailability room) {
    final isSelected = _selectedRoomCode == room.code;
    final occupancyPercent = (room.occupiedSeats / room.capacity * 100).round();

    Color statusColor;
    IconData statusIcon;
    switch (room.status) {
      case 'full':
        statusColor = const Color(0xFFE74C3C);
        statusIcon = Icons.block;
        break;
      case 'partial':
        statusColor = const Color(0xFFF39C12);
        statusIcon = Icons.warning_amber_rounded;
        break;
      default:
        statusColor = const Color(0xFF27AE60);
        statusIcon = Icons.check_circle;
    }

    return InkWell(
      onTap: () {
        setState(() => _selectedRoomCode = room.code);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00ADB5)
                : const Color(0xFF2A2A2A),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF00ADB5).withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00ADB5).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.meeting_room,
                          color: Color(0xFF00ADB5),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          room.code,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(statusIcon, color: statusColor, size: 20),
              ],
            ),
            const SizedBox(height: 12),

            // Capacity Info
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.event_seat,
                    'Capacity',
                    room.capacity.toString(),
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    Icons.people,
                    'Occupied',
                    room.occupiedSeats.toString(),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Occupancy Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Occupancy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$occupancyPercent%',
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: occupancyPercent / 100,
                    backgroundColor: const Color(0xFF2A2A2A),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _selectedRoomCode = room.code);
                      _fetchSvg();
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text(
                      'Preview',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ADB5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _downloadSvgForRoom(room.code),
                  icon: const Icon(Icons.download),
                  color: const Color(0xFF00ADB5),
                  tooltip: 'Download',
                  iconSize: 20,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF00ADB5).withOpacity(0.15),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSvgButton() {
    final enabled = _selectedDate != null && _selectedRoomCode != null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled && !_loadingSvg ? _fetchSvg : null,
        icon: _loadingSvg
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.visibility),
        label: Text(_loadingSvg ? 'Loading SVG...' : 'View Seating SVG'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00ADB5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchSvg() async {
    if (_selectedDate == null || _selectedRoomCode == null) return;
    setState(() => _loadingSvg = true);
    try {
      final api = ref.read(apiServiceProvider);
      final bytes = await api.getSvgByRoom(
        examDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        session: _selectedSession,
        roomCode: _selectedRoomCode!,
      );
      final svgString = utf8.decode(bytes);
      setState(() => _svgCache = svgString);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loaded SVG for $_selectedRoomCode'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Clear cache if there's an error (e.g., no seating data for this room)
      setState(() => _svgCache = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching SVG: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingSvg = false);
    }
  }

  Widget _buildInteractiveSvg(String svg) {
    if (svg.isEmpty) {
      return const Center(child: Text('Empty SVG content'));
    }
    // Interactive pan/zoom viewer to improve SVG inspection
    return LayoutBuilder(
      builder: (context, constraints) {
        // Provide a large canvas to pan around
        final canvasSize = Size(
          constraints.maxWidth * 2,
          constraints.maxHeight * 2,
        );
        return InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          minScale: 0.1,
          maxScale: 5.0,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Container(
            color: const Color(0xFF0F0F0F),
            child: Center(
              child: SizedBox(
                width: canvasSize.width,
                height: canvasSize.height,
                child: SvgPicture.string(
                  svg,
                  allowDrawingOutsideViewBox: true,
                  clipBehavior: Clip.none,
                  fit: BoxFit.contain,
                  placeholderBuilder: (BuildContext context) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00ADB5)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadSvgForRoom(String roomCode) async {
    if (_selectedDate == null) return;
    try {
      final api = ref.read(apiServiceProvider);
      final bytes = await api.getSvgByRoom(
        examDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        session: _selectedSession,
        roomCode: roomCode,
      );
      final filename =
          'seating_${roomCode}_${DateFormat('yyyy-MM-dd').format(_selectedDate!)}_${_selectedSession}.svg';
      await FileHelper.downloadFile(bytes, filename);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded $filename'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
                _selectedRoomCode = null; // Clear selected room
                _svgCache = null; // Clear preview
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00ADB5).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF00ADB5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                        : 'Select exam date',
                    style: TextStyle(
                      fontSize: 15,
                      color: _selectedDate != null
                          ? Colors.white
                          : Colors.white54,
                    ),
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
            color: Colors.white,
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
        onTap: () {
          setState(() {
            _selectedSession = value;
            _selectedRoomCode = null; // Clear selected room
            _svgCache = null; // Clear preview
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00ADB5).withOpacity(0.15)
                : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00ADB5)
                  : const Color(0xFF00ADB5).withOpacity(0.3),
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
                  color: isSelected ? const Color(0xFF00ADB5) : Colors.white60,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? const Color(0xFF00ADB5) : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// GenerateSeatingModal moved to widgets/generate_seating_modal.dart
