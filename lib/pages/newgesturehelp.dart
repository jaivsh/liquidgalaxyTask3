import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GestureHelp extends StatefulWidget {
  const GestureHelp({super.key});

  @override
  State<GestureHelp> createState() => _GestureHelpState();
}

class _GestureHelpState extends State<GestureHelp> {
  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Gesture Guide',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              // Gesture Cards List
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildGestureSection(
                        'Navigation Controls',
                        [
                          _buildGestureCard(
                            'North',
                            'assets/images/north.png',
                            'Right Hand Up',
                            Colors.blue.shade400,
                          ),
                          _buildGestureCard(
                            'South',
                            'assets/images/south.png',
                            'Right Hand Down',
                            Colors.red.shade400,
                          ),
                        ],
                      ),
                      _buildGestureSection(
                        'Direction Controls',
                        [
                          _buildGestureCard(
                            'East',
                            'assets/images/east.png',
                            'Left Hand Up',
                            Colors.green.shade400,
                          ),
                          _buildGestureCard(
                            'West',
                            'assets/images/west.png',
                            'Left Hand Down',
                            Colors.orange.shade400,
                          ),
                        ],
                      ),
                      _buildGestureSection(
                        'Zoom Controls',
                        [
                          _buildGestureCard(
                            'Zoom In',
                            'assets/images/zoom.png',
                            'Both Hands Up',
                            Colors.purple.shade400,
                          ),
                          _buildGestureCard(
                            'Zoom Out',
                            'assets/images/zoomout.png',
                            'Both Hands Down',
                            Colors.teal.shade400,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGestureSection(String title, List<Widget> cards) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ...cards,
        ],
      ),
    );
  }

  Widget _buildGestureCard(String title, String imagePath, String description, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              imagePath,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Description Section
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.gesture, color: color),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}