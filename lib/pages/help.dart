import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
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
                          'Help Center',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(20),
                  children: [
                    _buildSection('Gesture Controls', gestureCommands),
                    SizedBox(height: 20),
                    _buildSection('Voice Commands', voiceCommands),
                    SizedBox(height: 20),
                    _buildSection('Tips & Best Practices', tipCommands),
                    SizedBox(height: 20),
                    _buildSection('Troubleshooting', troubleshootingCommands),
                    SizedBox(height: 20),
                    _buildDocumentationCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<BasicTile> commands) {
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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          children: commands.map((command) => _buildCommandTile(command)).toList(),
        ),
      ),
    );
  }

  Widget _buildCommandTile(BasicTile command) {
    if (command.tiles.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          command.title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              command.title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            children: command.tiles.map((tile) => _buildCommandTile(tile)).toList(),
          ),
        ),
      );
    }
  }

  Widget _buildDocumentationCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Resources',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'For detailed documentation and updates, visit:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'www.liquidgalaxy.eu',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.blue.shade200,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class BasicTile {
  final String title;
  final List<BasicTile> tiles;

  const BasicTile({
    required this.title,
    this.tiles = const [],
  });
}

final gestureCommands = <BasicTile>[
  const BasicTile(title: 'Right Hand Up → Move North'),
  const BasicTile(title: 'Right Hand Down → Move South'),
  const BasicTile(title: 'Left Hand Up → Move East'),
  const BasicTile(title: 'Left Hand Down → Move West'),
  const BasicTile(title: 'Both Hands Up → Zoom In'),
  const BasicTile(title: 'Both Hands Down → Zoom Out'),
];

final voiceCommands = <BasicTile>[
  const BasicTile(title: 'Say "Move North" to move camera northward'),
  const BasicTile(title: 'Say "Move South" to move camera southward'),
  const BasicTile(title: 'Say "Move East" to move camera eastward'),
  const BasicTile(title: 'Say "Move West" to move camera westward'),
  const BasicTile(title: 'Say "Zoom In" to zoom into the view'),
  const BasicTile(title: 'Say "Zoom Out" to zoom out of the view'),
  const BasicTile(title: 'Say any city name to fly to that location'),
];

final tipCommands = <BasicTile>[
  const BasicTile(title: 'Stand 1-2 meters away from the camera'),
  const BasicTile(title: 'Ensure good lighting conditions'),
  const BasicTile(title: 'Make clear, deliberate gestures'),
  const BasicTile(title: 'Keep your hands visible to the camera'),
  const BasicTile(title: 'Avoid rapid or jerky movements'),
  const BasicTile(title: 'Speak clearly for voice commands'),
  const BasicTile(title: 'Check connection status before starting'),
];

final troubleshootingCommands = <BasicTile>[
  const BasicTile(
    title: 'Connection Issues',
    tiles: [
      BasicTile(title: 'Verify IP address and port'),
      BasicTile(title: 'Check network connectivity'),
      BasicTile(title: 'Try reconnecting'),
      BasicTile(title: 'Verify LG master is running'),
    ],
  ),
  const BasicTile(
    title: 'Gesture Recognition Issues',
    tiles: [
      BasicTile(title: 'Check camera permissions'),
      BasicTile(title: 'Improve lighting conditions'),
      BasicTile(title: 'Adjust your distance from camera'),
      BasicTile(title: 'Make slower, more defined gestures'),
    ],
  ),
  const BasicTile(
    title: 'Voice Recognition Issues',
    tiles: [
      BasicTile(title: 'Check microphone permissions'),
      BasicTile(title: 'Reduce background noise'),
      BasicTile(title: 'Speak clearly and slowly'),
      BasicTile(title: 'Try rephrasing commands'),
    ],
  ),
];