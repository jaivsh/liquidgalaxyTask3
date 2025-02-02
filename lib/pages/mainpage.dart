import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settingsProvider.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _MainState();
}

class _MainState extends ConsumerState<MainPage> {
  @override
  Widget build(BuildContext context) {
    bool isConnectedToLg = ref.watch(isConnectedToLGProvider);
    String? errorMessage = ref.watch(errorMessageProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF3498DB),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(isConnectedToLg),
                  Expanded(
                    child: _buildMainContent(),
                  ),
                ],
              ),
              if (errorMessage != null) _buildErrorBanner(errorMessage),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildExpandableMenu(),
    );
  }

  Widget _buildHeader(bool isConnectedToLg) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Text(
            'Liquid Galaxy Controller',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isConnectedToLg ? Colors.green : Colors.red.shade400,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConnectedToLg ? Icons.check_circle : Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  isConnectedToLg ? 'Connected' : 'Disconnected',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildControlCard(
            'Gesture Control',
            'Control LG using hand gestures',
            Icons.back_hand_outlined,
            Colors.orange.shade400,
            '/camera',
          ),
          SizedBox(height: 15),
          _buildControlCard(
            'Voice Control',
            'Control LG using voice commands',
            Icons.mic_none_outlined,
            Colors.purple.shade400,
            '/voice',
          ),
          SizedBox(height: 25),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildControlCard(String title, String description, IconData icon, Color color, String route) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, route),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                SizedBox(height: 15),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Quick Tips',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          _buildTipItem('Ensure your device camera is working properly'),
          _buildTipItem('Stand at least 1 meter away from the camera'),
          _buildTipItem('Make sure you have good lighting'),
          _buildTipItem('Speak clearly for voice commands'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates, color: Colors.white70, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.red.shade400,
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  ref.read(errorMessageProvider.notifier).state = null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableMenu() {
    return ExpandableFloatingActionButton();
  }
}

class ExpandableFloatingActionButton extends StatefulWidget {
  @override
  _ExpandableFloatingActionButtonState createState() =>
      _ExpandableFloatingActionButtonState();
}

class _ExpandableFloatingActionButtonState
    extends State<ExpandableFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  final List<_FABItem> _items = [
    _FABItem(Icons.settings, 'Settings', '/settings'),
    _FABItem(Icons.help_outline, 'Help', '/help'),
    _FABItem(Icons.info_outline, 'About', '/about'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOpen)
          ..._items.map((item) => _buildFABItem(item)).toList(),
        SizedBox(height: 8),
        FloatingActionButton(
          onPressed: _toggleExpanded,
          backgroundColor: Colors.blue.shade700,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _expandAnimation,
          ),
          elevation: 8,
        ),
      ],
    );
  }

  Widget _buildFABItem(_FABItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: FloatingActionButton(
        mini: true,
        onPressed: () {
          _toggleExpanded();
          Navigator.pushNamed(context, item.route);
        },
        backgroundColor: Colors.blue.shade600,
        child: Icon(item.icon),
        tooltip: item.label,
      ),
    );
  }
}

class _FABItem {
  final IconData icon;
  final String label;
  final String route;

  _FABItem(this.icon, this.label, this.route);
}